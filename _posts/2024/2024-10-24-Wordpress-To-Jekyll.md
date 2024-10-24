---
title: Migrating from Wordpress to Jekyll
date: 2024-10-23T18:00:00
tags: [
  blog
]
image: /assets/images/jekyll-sticker.png
---
After having left Barracuda earlier this month I finally have a bit of time on my hands, so I thoght was about time I got around to migrating thias blog from Wordpress to a bunch of Markdown files and a static site generator.

# Making the Switch: Moving from WordPress to Jekyll

After having left Barracuda earlier this month I finally have a bit of time on my hands, so I thought it was about time I got around to migrating this blog from Wordpress to a bunch of Markdown files and a static site generator. I had been planning this for a while, but never had time to do anything about it.

After a quick tour of Ghost, Hugo and a couple of other static site generators, I finally settled on Jekyll.

## Why Jekyll?

Before diving into the migration process, let's discuss why you might want to consider Jekyll:

- **Speed**: Static sites are blazingly fast compared to dynamic WordPress installations
- **Security**: With no database or server-side code, there's virtually nothing to hack - with wordpress I'd had a few occaisions where plugins had been exploited via some vulnerability or other, and ended up deleted tones of fake posts / spam.
- **Version Control**: Your entire site lives in Git, making changes trackable and reversible.
- **Cost**: Free hosting on GitHub Pages or minimal costs for static hosting elsewhere
- **Developer-Friendly**: Write in Markdown, use your favorite text editor, and leverage Git workflows

## Prerequisites

Before starting the migration, ensure you have:

- Ruby installed on your system
- Basic familiarity with command line operations
- Git installed locally
- A GitHub account (if you plan to use GitHub Pages)

## Migration Steps

### 1. Export WordPress Content

First, we need to export your existing WordPress content:

1. Log into your WordPress admin panel
2. Go to Tools → Export
3. Choose "All content"
4. Download the exported XML file

### 2. Set Up Jekyll

```bash
# Install Jekyll and bundler gems
gem install jekyll bundler

# Create a new Jekyll site
jekyll new my-blog

# Change into the new directory
cd my-blog

# Install dependencies
bundle install
```

### 3. Convert WordPress Content

To convert your WordPress posts to Jekyll-compatible format:

```bash
# Install the Jekyll import gem
gem install jekyll-import

# Convert WordPress export file
ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::WordpressDotCom.run({
      "source" => "wordpress.xml"
    })'
```

### 4. Customize Your Jekyll Site

Update your `_config.yml`:

```yaml
title: Your Blog Name
description: Your blog description
baseurl: ""
url: "https://yourdomain.com"

# Build settings
markdown: kramdown
permalink: /:year/:month/:day/:title/
```

### 5. Handle Media Files

1. Create an `assets` directory in your Jekyll project
2. Copy media files from WordPress `wp-content/uploads`
3. Update post references to use new media paths

For the third item, I did have to do a good bit of search and replace using VSCode, to get links into the correct format, and get the `frontmatter` setup correctly.

### 6. Set Up Hosting

For GitHub Pages:

```bash
# Initialize Git repository
git init

# Add your files
git add .

# Commit changes
git commit -m "Initial Jekyll site"

# Push to GitHub
git remote add origin https://github.com/username/username.github.io.git
git push -u origin main
```

I also added a workflow to auto publish the site - the default github one doesn't work too well, at least it didn't for me, so I ended up using the one named `Jekyll` rather than the one named `Github Pages Jekyll`.

![Workflow](/assets/images/jekyll-workflow.png)

You'll also need to configure the reporsitory to enable Pages, and do some DNS stuff (documented on the `Pages` setting page)

## Other Aspects

I didn't bother with porting comments over (yet). In wordpress I had it set up to use Disqus - I may get around to that at some point.

## Performance Improvements

After migration, you should see significant performance improvements:

- Decreased load time (typically 300-500ms vs 2-3s)
- Improved Google PageSpeed scores (hopefully)
- Better reliability

## Conclusion

While migrating from WordPress to Jekyll requires some initial effort, the benefits in terms of performance, security, and maintainability make it worthwhile in my opinion. The static site approach aligns well with my simplification goal and Markdown provides a better/simpler writing experience that might encourage me to actually write a bit more....

*Now to do the same thing for kennetrunner.com ...*
