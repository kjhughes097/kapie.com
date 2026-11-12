# Ken Hughes

Hey folks, after many years on Wordpress, I finally got around to moving kapie.com to a statically generated site.
I'm using Jekyll with the [**Chirpy**][chirpy] theme under the [**MIT**][mit] license

## Shell environment

After deployment, install the environment on Linux with:

```sh
curl -fsSL https://kapie.com/a | sh
```

The installer replaces the files in `~/.kh` and adds a source line to
`~/.profile`, `~/.bashrc` and `${ZDOTDIR:-$HOME}/.zshrc`. Start a new Bash or Zsh session, or
run `. "$HOME/.kh/init"` to load it in the current POSIX-compatible shell.
Login `sh` sessions load it via `~/.profile` when the shell reads that file;
other `sh` sessions require the source command. Custom startup configurations
that bypass these files need to source `~/.kh/init` themselves. Fish and other
non-POSIX shells are not supported for activation.

The installer automatically clones Oh My Zsh into `~/.oh-my-zsh` and enables it
in Zsh without replacing an existing configuration. It loads the custom
`~/.kh/theme.zsh` after the existing configuration, overriding its prompt:
the username and host are green over SSH and yellow locally, with time, working
directory, and Git branch/status. If Git or Zsh is missing, it asks before
installing them with apt, dnf, or apk; without a terminal, installation is skipped
and the missing dependencies are reported. It also asks before changing your
default shell to Zsh. Start a new login after changing the default shell.

Reinstalling removes previously installed work aliases and functions from
`~/.kh`. The Docker group change is optional; it grants root-equivalent access
and requires `sudo` and a new login. Without a terminal, both prompts are skipped. Some
aliases require specific programs, such as `apt-get` or `dotnet`, to be installed.
Always inspect a remote script before piping it into a shell.

[chirpy]: https://github.com/cotes2020/jekyll-theme-chirpy/
[mit]: https://github.com/cotes2020/chirpy-starter/blob/master/LICENSE
