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
- update the _config.yml to use this theme
```bash
theme: next
```
- pull the theme update when it is needed 
```bash
cd theme/next
git pull
```
## The problem ##
For most of themes (including NexT), we will have to modify the theme's _config.yml file which is under the theme folder, in order to:
- change the configuration on the theme level, such change theme style
- update personal information
- setup Google Analytic key
- integrate with 3rd party commenting plugin
- future customize the theme the way you want

Naturally, you would like to have above modifications also under version control, so you check them in and push to Git.  

Now, if you head to Github source code page, you will find an interesting grayed-out folder named "Next"
{% asset_img "grayedout-folder-in-github-without-ref.png" "Grayed-out folder in github" %}
You also lost the possibility to browse the theme source code there.

<!-- more -->

# Root cause #
Technically we created a **nested git repository structure**: there is a git repository "Next" underneath of git repository "Blog-Hexo". This [git document](https://git-scm.com/book/en/v2/Git-Tools-Submodules) has a good explanation about this. 

# The right way #
As our customized theme became an independent component component of the blog system, it requires proper version control of it. 

1. fork theme project
By doing this, you can properly verion control your modification of your theme, but still have the possiblity to keep it up-to-date.
2. create Git submodule which named "next-linkcd", means it's our version of NexT theme.
```bash
cd blog-hexo
git submodule add https://github.com/linkcd/hexo-theme-next themes/next-linkcd
```
3. ask hexo to use this theme
```bash
theme: next-linkcd
```
4. now you have 2 seperated repositories, one for your blog-hexo, and one for your own theme. You can run below command to see the relatioship.
{% asset_img "Next-linkcd git submodule command line.png" "Next-linkcd git submodule in command line" %}
It also works in Github webpage
{% asset_img "Next-linkcd submodule in github.png" "Next-linkcd git submodule in Github" %}
Please note that the "git stamp" is **d82e379** for both place.


 
