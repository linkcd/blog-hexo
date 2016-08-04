---
title: How to setup a hexo-based blog
tags:
  - hexo
  - blog
  - github
date: 2016-08-04 19:04:02
---


# Install below components:
- node.js
- git

# Installation
## Basic
```bash
npm install hexo-cli -g
hexo init blog-hexo
cd blog-hexo
```
Now you have the blog in the folder blog-hexo

## Install plugin
```bash
npm install hexo-deployer-git --save
npm install hexo-generator-feed --save
```

# Config
edit _config.yml file

## Try out
```bash
hexo s
```

# Apply for 2 repositories in github
- <your_user_name>.github.io (No need to clone to local)
- blog-hexo for storing the original hexo files

## setup local git
in the blog-hexo folder, init git
```bash
git init
#update .gitignore file
git add .
git commit -m "message"
git remote add origin remote repository-URL
git push origin master
```
https://help.github.com/articles/adding-an-existing-project-to-github-using-the-command-line/

now you have your blog original file under version control

# Theme
```bash
git clone https://github.com/klugjo/hexo-theme-clean-blog.git themes/clean-blog
```bash
update _config.yml file
check in all files from theme to git

# new PC
git clone hexo-blog repo
in the folder, run
```bash
npm install hexo
npm install
```
No need to reinstall plugs

# comments
apply for a site in ...
update current theme config to connect

#google analytic
apply for track id
update curernt theme config to connect

 