---
title: Virtual Disk Lib - Workflow
date: 2024-12-10T19:15:41
tags: [
  blog
]
image: /assets/images/virtual-disk-lib-workflow.png
---
As part of documenting the process of developing this Virtual Disk Lib I wanted to have some docs in the repo that I could use to cover the steps.
So I wanted to have a `docs` folder where I could have a markdown file for each step. However, it seems that a GitHub `README.md` file cannot pull in content from other files in the repo.

To get around this I set up a `docs` folder in the repo, and added numbered markedown files (`docs/1-README.md`, `doc/REQUIREMENTS.md` etc) and set up a GitHub workflow so that on a push to the main branch on origin, it would concatenate all the files in that `docs` directory into `README.md` in the root of the repo and then push a commit with that change.

The workflow yaml looks like this :

```yaml
name: Regenerate README
on: push
permissions:
  contents: write
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: |
          cat docs/*.md > README.md
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add README.md
          git commit -m "Re-generated README.md"
          git push
```

Note the `permissions ... contents: write` that is needed as the GitHub Actions Bot only has read permissions by default.
