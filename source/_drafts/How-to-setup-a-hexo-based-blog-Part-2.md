---
title: 'How to setup a hexo-based blog: Part 2'
tags:
- hexo
- github
- blog
---

Previously we have setup and published the hexo-based blog. The article source code and the hexo configuration files are under git version control.  

# Config theme, the wrong way#
As most hexo tutorials, the next step is to change the default theme. There are [lots of themes](https://hexo.io/themes/) that you can choose from. However, most of the theme simply ask you to follow below steps:
- install
```bash
git clone https://github.com/iissnan/hexo-theme-next themes/next
```
- update the _config.xml to use this theme
```bash
theme: next
```
- pull the theme update when it is needed 
```bash
cd theme/next
git pull
```
## Problem ##
Technically we created a nested git repository structure: there is a git repository "Next" underneath of git repository "Blog-Hexo". If you check in and commit the changed after installation, then push to Github, you will find an interesting grayed-out folder named "Next" in your source code page.
{% asset_img "grayedout-folder-in-github-without-ref.png" "grayedout-folder-in-github-without-ref.png" %}

If the theme files are 

# The right way #
