---
title: 'How to setup a hexo-based blog: Part 2'
tags:
- hexo
- github
- blog
---

Previously we have setup and published the hexo-based blog. The article source code and the hexo configuration files are under git version control.  

# Config theme, the wrong way#
As most hexo tutorials, the next step is to change the default theme. There are [lots of themes](https://hexo.io/themes/) that you can choose from. However, most of the theme simply ask you to clone itself under the themes folder. 

In this case, we will use the popular theme [NexT](https://github.com/iissnan/hexo-theme-next). Its document specified follow below steps:
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
## The problem ##
Technically we created a **nested git repository structure**: there is a git repository "Next" underneath of git repository "Blog-Hexo".

In addition, for most of themes (including NexT), we will have to modify the _config.xml file which is under the theme folder, in order to:
- personalize the theme, such change theme style
- update personal information
- setup Google Analytic key
- integrate with 3rd party commenting plugin

Naturally, you would like to have above modifications also under version control, so you check them in and push to Git.  

Now, if you head to Github source code page, you will find an interesting grayed-out folder named "Next"
{% asset_img "grayedout-folder-in-github-without-ref.png" "Grayedout folder in github" %}
You also lost the possibility to browse the theme source code there.

# The right way #
The [git document](https://git-scm.com/book/en/v2/Git-Tools-Submodules) has a good explanation about this. Therefore we have the solution 
