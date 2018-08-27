---
title: Using new domain feng.lu
date: 2018-08-27 21:13:52
tags:
- Domain
- DNS
- Blog
---
Shortly after I have renewed my blog domain **fenglu.me**, it just crossed my mind that "hey, is it possible to register a top-level domain with my family name **.lu**? So I can literally have my name for my site: **feng.lu**! That will be cool!"

{% asset_img "Header.jpeg" "picture credit: www.dreamhost.com" %}
(picture copyright: www.dreamhost.com)

And, (after googling), yes! It is possible! **.lu** is the Internet country code top-level domain for Luxembourg. OK... (continue googling) "Can I register a .lu domain without been a Luxembourgers?" "No problem!" Great!

Long story short, after some quick research on vendors and paid 24 Euro, I got the brand new feng.lu domain! :)

The remaining is pretty straightforward:
- In feng.lu domain provider, set up an apex domain and www subdomain for my real blog host Github page, according to [their document](https://help.github.com/articles/using-a-custom-domain-with-github-pages/).
- In github page settings, update the custom domain (equals to update the CNAME file).
- Update blog source code (hexo) with the new domain 
- **Important!**: Since I would like to keep all existing links from the old domain [fenglu.me](http://fenglu.me) continue working, I also setup the domain forwarding. [Document](https://www.namecheap.com/support/knowledgebase/article.aspx/10043/2237/url-redirect-with-parameters). Remember to use "Redirect to a specific page/folder/subfolder".
- Update Google Analytics, GTM, etc
- Done!   

Happy blogging!