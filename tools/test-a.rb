require "fileutils"
require "minitest/autorun"
require "open3"
require "pty"
require "tmpdir"
require "timeout"

class ShellInstallerTest < Minitest::Test
  SCRIPT = File.expand_path("../a", __dir__)

  def setup
    @home = Dir.mktmpdir("kapie-shell-test-")
    @bin = File.join(@home, "bin")
    Dir.mkdir(@bin)
    @env = { "HOME" => @home, "ZDOTDIR" => @home, "PATH" => "#{@bin}:/usr/bin:/bin", "TZ" => "UTC", "SHELL" => "/bin/bash" }
    stub("git", <<~'SH')
      echo clone >> "$HOME/git-calls"
      mkdir "$HOME/.oh-my-zsh"
      printf '%s\n' 'omz() { :; }' 'alias ll=overridden' 'git_prompt_info() { echo "${ZSH_THEME_GIT_PROMPT_PREFIX}main${ZSH_THEME_GIT_PROMPT_DIRTY}${ZSH_THEME_GIT_PROMPT_SUFFIX}"; }' > "$HOME/.oh-my-zsh/oh-my-zsh.sh"
    SH
  end

  def stub(name, script)
    path = File.join(@bin, name)
    File.unlink(path) if File.symlink?(path)
    File.write(path, "#!/bin/sh\n#{script}\n")
    File.chmod(0o700, path)
  end

  def teardown
    FileUtils.remove_entry @home
  end

  def run_command(*command, input: nil)
    stdout, stderr, status = Open3.capture3(@env, *command, stdin_data: input)
    assert status.success?, "#{command.inspect} failed: #{stderr}\n#{stdout}"
    stdout
  end

  def test_piped_install_and_shell_startup_are_repeatable
    %w[.profile .bashrc .zshrc].each do |file|
      File.write(File.join(@home, file), "alias lsf='old-value'\n")
    end
    2.times do
      output = run_command("sh", input: File.read(SCRIPT))
      assert_includes output, "skipped the optional shell and Docker prompts"
    end

    %w[.profile .bashrc .zshrc].each do |file|
      assert_equal 1, File.read(File.join(@home, file)).lines.count { |line| line.include?('# kh environment') }
    end
    assert_equal 0o600, File.stat(File.join(@home, ".kh", ".aliases")).mode & 0o777
    assert_equal 1, File.readlines(File.join(@home, "git-calls")).size
    assert_equal 1, File.read(File.join(@home, ".zshrc")).scan('source "$ZSH/oh-my-zsh.sh"').size

    check = <<~'SH'
      alias ll
      command -v epoch
      [ "$(epoch 1970-01-01)" = "0" ]
      [ "$(d64 Zm8)" = "
      fo" ]
      ! d64 '!' >/dev/null 2>&1
      ! alias lsf >/dev/null 2>&1
      if [ -n "${BASH_VERSION:-}${ZSH_VERSION:-}" ]; then
        lsf | grep -Fx epoch
      fi
      . "$HOME/.kh/init"
      case "$PATH" in *"$HOME/.dotnet"*) ;; *) exit 1 ;; esac
      [ "$(printf '%s' "$PATH" | grep -oF "$HOME/.dotnet" | wc -l)" -eq 1 ]
    SH
    run_command("sh", "-c", '. "$HOME/.profile"; ' + check)
    run_command("bash", "--noprofile", "--rcfile", File.join(@home, ".bashrc"), "-ic", check)
    run_command("zsh", "-ic", check + "\ncommand -v omz\nalias ll | grep -F 'ls -alF'") if system("command -v zsh >/dev/null 2>&1")
  end

  def run_interactively(responses)
    transcript = +""
    status = nil
    PTY.spawn(@env.merge("INSTALLER" => SCRIPT), "sh", "-c", 'cat "$INSTALLER" | sh') do |reader, writer, pid|
      Timeout.timeout(10) do
        responses.each do |prompt, response|
          transcript << reader.readpartial(4096) until transcript.include?(prompt)
          writer.puts response
        end
        begin
          loop { transcript << reader.readpartial(4096) }
        rescue EOFError, Errno::EIO
        end
        _, status = Process.wait2(pid)
      end
    end
    [transcript, status]
  end

  def test_docker_change_requires_confirmation
    stub("sudo", 'printf "%s\\n" "$@" > "$HOME/sudo-args"')

    output, status = run_interactively(
      "Change your default shell to Zsh?" => "n",
      "Add your user to the docker group?" => "y"
    )
    assert status.success?, output
    refute_includes output, "WORK aliases"
    assert_includes File.read(File.join(@home, "sudo-args")), "usermod\n-aG\ndocker\n"
  end

  def test_shell_change_requires_confirmation
    stub("chsh", 'printf "%s\\n" "$@" > "$HOME/chsh-args"')
    output, status = run_interactively(
      "Change your default shell to Zsh?" => "y",
      "Add your user to the docker group?" => "n"
    )
    assert status.success?, output
    assert_match(/\A-s\n.*\/zsh\n\z/, File.read(File.join(@home, "chsh-args")))
  end

  def test_existing_startup_line_is_reloaded_after_oh_my_zsh
    File.write(File.join(@home, ".zshrc"), <<~'SH')
      # source "$ZSH/oh-my-zsh.sh"
      . "$HOME/.kh/init" # kh environment
    SH
    2.times { run_command("sh", input: File.read(SCRIPT)) }
    rc = File.read(File.join(@home, ".zshrc"))
    assert_equal 1, rc.scan('# kh environment after Oh My Zsh').size
    assert_equal 1, rc.lines.count { |line| line.start_with?("source ") }
    run_command("zsh", "-ic", "alias ll | grep -F 'ls -alF'") if system("command -v zsh >/dev/null 2>&1")
  end

  def test_custom_theme_overrides_existing_prompt_and_changes_colour_for_ssh
    File.write(File.join(@home, ".zshrc"), "PROMPT='old prompt'\n")
    2.times { run_command("sh", input: File.read(SCRIPT)) }
    rc = File.read(File.join(@home, ".zshrc"))
    assert_equal 1, rc.lines.count { |line| line.include?("# kh theme") }
    assert_operator rc.index("source \"$ZSH/oh-my-zsh.sh\""), :<, rc.index("# kh theme")

    return unless system("command -v zsh >/dev/null 2>&1")

    output = run_command("zsh", "-ic", <<~'ZSH')
      unset SSH_TTY
      print -r -- "local=$(prompt_colour)"
      print -P -- "$PROMPT"
      SSH_TTY=/dev/pts/1
      print -r -- "ssh=$(prompt_colour)"
      print -P -- "$PROMPT"
    ZSH
    assert_includes output, "local=226"
    assert_includes output, "ssh=10"
    assert_equal 2, output.scan("[main*]").size
    refute_includes output, "old prompt"
  end

  def test_failed_clone_is_reported
    stub("git", 'echo "clone failed" >&2; exit 1')
    _, stderr, status = Open3.capture3(@env, "sh", stdin_data: File.read(SCRIPT))
    refute status.success?
    assert_includes stderr, "clone failed"
  end

  def restrict_path_without_zsh
    %w[sh cat mkdir chmod grep basename id].each do |name|
      File.symlink("/usr/bin/#{name}", File.join(@bin, name))
    end
    @env["PATH"] = @bin
  end

  def test_missing_dependency_is_reported_without_terminal
    restrict_path_without_zsh
    stdout, stderr, status = Open3.capture3(@env, "sh", stdin_data: File.read(SCRIPT))
    assert status.success?, stderr
    assert_includes stderr, "missing dependencies: zsh"
    assert_includes stderr, "Oh My Zsh was not installed"
    refute File.exist?(File.join(@home, "git-calls"))
    assert_includes stdout, "skipped the optional shell and Docker prompts"
  end

  def test_dependency_install_requires_confirmation
    restrict_path_without_zsh
    stub("id", 'if [ "$1" = "-u" ]; then echo 0; else /usr/bin/id "$@"; fi')
    stub("apt-get", <<~'SH')
      echo "$*" >> "$HOME/apt-calls"
      if [ "$1" = install ]; then
        printf '#!/bin/sh\nexit 0\n' > "$HOME/bin/zsh"
        chmod 700 "$HOME/bin/zsh"
      fi
    SH
    output, status = run_interactively(
      "Install missing dependencies" => "y",
      "Change your default shell to Zsh?" => "n",
      "Add your user to the docker group?" => "n"
    )
    assert status.success?, output
    assert_equal ["update", "install -y zsh"], File.readlines(File.join(@home, "apt-calls"), chomp: true)
    assert File.exist?(File.join(@home, ".oh-my-zsh", "oh-my-zsh.sh"))
  end

  def test_reinstall_removes_previous_work_entries
    run_command("sh", input: File.read(SCRIPT))
    %w[.aliases .functions].each do |file|
      File.open(File.join(@home, ".kh", file), "a") { |f| f.puts "# previous work entry" }
    end
    run_command("sh", input: File.read(SCRIPT))
    %w[.aliases .functions].each do |file|
      refute_includes File.read(File.join(@home, ".kh", file)), "previous work entry"
    end
  end
end
