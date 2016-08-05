---
title: 'How to setup a hexo-based blog: Part 1'
date: 2016-08-05 18:59:19
tags:
- hexo
- github
- blog
---

[Hexo](https://hexo.io/) is a simple and powerful blog framework that allows you setup your blog quickly and easily.  

# Why Hexo? #
Instead of create the blog in https://wordpress.com/, I decided to setup and own the whole blog website. You can read a good [discussion](http://www.kaushik.net/avinash/best-web-metrics-digital-marketing-own-rent-strategies/) by Avinash Kaushik. 

However, own a web site on interent is not easy. Normal maintenance tasks, such as backup database (your content) and apply security patch, are too much to a part-time blogger. Therefore, Hexo became a good solution:

1. Customization: Hexo and its components are open-source. You can customize your blog the way you want.  
2. Light-weight: Hexo is a static blog system. It does not require any server-side code, or a database. Git is the best mechanism.
3. Safety: Hexo only publish static files to internet, such as html, css and javascript. It is much less vulnerable compares to any rumtime web application.
4. No compromise on functionality: Even it is a static site, but you can still embed 3rd party services for common blog functionalities such as commenting and web analytic.  
4. Cost: Together with [Github page](https://pages.github.com/), host your blog is free. If you are not a fan of the yourname.github.io domain name, you can also pay a little to have your own domain. 

<!-- more -->

# Setup in nutshell # 
There are tons of articles on internet show how to setup a Hexo-based blog in Github page. Therefore I will only list necessary steps in below: 

## Installation  ##
you will need to install below applications on your local machine first:
- Node.js
- Git

Then install Hexo 
``` bash
npm install hexo-cli -g
```
## Create your blog ##
Assuming you will store all your blog files in c:\private\blog-hexo. At c:\private\, run below command:
``` bash
hexo init blog-hexo
```

## Install plugin ##
At this moment, we need plug-in for feed generation and Git deployment. wWe also install the browser auto fresher for a better writing experience. Inside of the blog folder, run:
``` bash
npm install hexo-deployer-git --save
npm install hexo-generator-feed --save
npm install hexo-browsersync --save
```
More plug-in are [here](https://hexo.io/plugins/).

Verify before we move on. In the blog-hexo folder, run:
``` bash
hexo s --open
```

## Version control ##
By now, everything is in your local machine. Let's use Git and Github to version control it.
- Create a repo in your Github account, such as https://github.com/linkcd/blog-hexo.git
- Create a new local Git repo in your blog folder c:\private\blog-hexo
- Push your local Git repo to remote one. Use default branch is fine.

If you are using GVIM as me, you can also the last 2 lines in your .gitignore file:
``` bash
.DS_Store
Thumbs.db
db.json
*.log
node_modules/
public/
.deploy*/
*~
*.swp
``` 
Done, from now on you can use the standard Git commands to control all your articles.

In next article, we will dive into the interesting parts of Hexo: Switching between PC, Theme and Git process.