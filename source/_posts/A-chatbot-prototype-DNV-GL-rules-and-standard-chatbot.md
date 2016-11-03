---
title: A chatbot prototype - DNV GL rules and standard chatbot
date: 2016-09-25 08:06:15
tags:
  - chatbot
  - artificial intelligence 
  - machine learning 
  - Microsoft Language Understanding Intelligent Service
  - prototype
---
At the end of March 2016, Microsoft announced the [Bot Framework](https://bots.botframework.com/), a platform that helps you to quickly build the high quality bots for your business. 

After a long weekend happy hacking, I have built a chatbot prototype who can help you to find [DNV GL service document](https://rules.dnvgl.com/servicedocuments/dnvgl).  

<!-- more -->
You can head to https://dnvgl-rs-bot.azurewebsites.net/ to have a chat with it, or via skype and slack.

There is a preview:
{% iframe "https://webchat.botframework.com/embed/DNVGL_RS_BOT?s=LKtmYpdq6Tk.cwA.fnQ.HKq6uLosO1bpUjqHck8lenJKiyGBVPgBdfTy3-x7FtY" %}

**Some facts about it:**
- It understands human language (English), thanks to the integrated Microsoft [Language Understanding Intelligent Service](https://www.luis.ai/Home/About). It can be extended to support such as Chinese or Spanish. 
- The business user (such as a Rules and Standard expert) can easily train this bot via the Machine Learning interface, to provide a better intelligence insight. I have only trained it with less than 50 sample inputs. But the more we talk, the more smart it can be.
- It is hosted in Azure, the Microsoft cloud service.
- Currently it supports 3 channels: Web Chat, Skype and Slack.
- All data is from the publicly available information of DNV GL service document.

{% asset_img "web conversation.png" "Web page conversation" %}

or

{% asset_img "slack conversation.png" "Slack conversation" %}


**Disclaimer**
This chatbot prototype is a personal project. It is only based on the public information of the DNV GL documents. It has NO connection with DNV GL AS. All information from the chatbot is presented 'as-is'. No warranties whatsoever for correctness; completeness or usefulness.
 
