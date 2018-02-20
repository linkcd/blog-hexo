---
title: Review and manage your web site disk space in Azure
date: 2017-02-23 20:07:31
tags:
  - Azure
  - KUDU
  - Monitoring
  - DevOps
---

# Problem #

We have a large distributed system which is hosted in Azure. The front end web application are Azure web sites. 

From time to time, the web applications were down, due to running out disk space in the Azure web sites. Our operation team would like to quickly identify what are the large files and how we can free up disk space in Azure web sites. 

Lucky, Azure application service already provides a nice tool for this type of work: **[Kudu service](https://github.com/projectkudu/kudu/wiki)**.

<!-- more -->
# Kudu Service #

Kudu is a tool set for troubleshooting and analysis. To access it, simply go to Azure portal -> Your_APP_Service -> Development tools -> Advanced Tools. 

{% asset_img "Accesss Kudo.png" "Accesss Kudo" %}

Another shortcut is directly access https://Your_APP_Service_URL.SCM.azurewebsites.net. 

Note: you need contributor or owner permission to access kudu, as you can do almost anything to your site.

The kudu landing page is like below

{% asset_img "Kudu interface.png" "Kudo interface" %}

There are many possibilities with Kudu such as
- Execute cmd and/or powershell
- Check environment variables 
- Browse processes
- Browse files 
- Update files (Upload, download, edit and delete files)
- Install extensions 

but in this post I will focus on the monitoring of disk space. 

**Alternative 1**:
	You can run powershell script to list the folder size. 

**Alternative 2**:
	Install the disk space extension 
	{% asset_img "Kudu disk usage extension.png" "Kudu disk usage extension" %}
	Once the extension is installed, there is a nice diagram showing how the disk space is used.
	{% asset_img "Web site disk usage.png" "Web site disk usage" %}

# Root cause #
Now the problem is clear: The search functionality in this solution is powered by a [lucene](https://lucene.apache.org/) library. Whenever the data source is updated, the lucene instance in the Azure web site node will re-index the data, generate index files and store them locally.

Due to some issues, the lucene instance is generating new index files every single time without removing old index files. These old index files quickly ate up all disk space and eventually bring the site down.

# Solution #
Once we have identified these out-of-date index files, it is fairly easy for our operation team to delete them by using Kudu debug console. But this process is not ideal since the team need to check the disk space site regularly.

To address that, we created a disk space dashboard by using Application Insight and Azure web site API. Now it is much easier to avoid similar issue in the future.

{% asset_img "Disk space dashboard.png" "Disk space dashboard" %}
  

PS: And our smart team fixed the lucene issue afterwards. :)
