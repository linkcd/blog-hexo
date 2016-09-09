---
title: How to connect VSTS project and Azure subscription
tags:
  - VSTS
  - Azure
  - Release management
date: 2016-09-08 20:16:18
---

# Introduction  #
For enabling the continues deployment from VSTS to Azure, e.g. provision the environment and deploy code, you must create connection between VSTS project and Azure subscription. It should be done in individual project and not in the VSTS top level. Therefore, each project can connect to different Azure subscription. 

It contains two main parts, and normally you need both of them
- Connect Azure Classic (for deploying your application code)
- Connect Azure Resource Manager (for provisioning your environment)

<!-- more -->

# How to connect Azure Classic #
1. Make sure you are the admin of VSTS project and also the admin of Azure subscription
2. Go to your project management page, such as https://your_instance.visualstudio.com/DefaultCollection/your_project_name/_admin
3. Select "Services" in the tab, then "Azure Classic"
	{% asset_img "Azure Class 1.png" "" %}
4. Change radio button to "**Certificate Based**", then download the setting file by following [publish settings file](http://go.microsoft.com/fwlink/?LinkID=312990)
	{% asset_img "Azure Class 2.png" "" %}
5. Setting file is downloaded
	{% asset_img "Azure Class 3.png" "" %}
6. Carefully copy values from that file into the form
	{% asset_img "Azure Class 4.png" "" %}
7. Done
	{% asset_img "Azure Class 5.png" "" %} 

# How to connect Azure Resource Manager #
1. Make sure you are the admin of VSTS project and also the admin of Azure subscription
2. Go to your project management page, such as https://your_instance.visualstudio.com/DefaultCollection/your_project_name/_admin
3. Select "Services" in the tab, then "Azure Resource Manager"
	{% asset_img "Azure RM 1.png" "" %} 
4. Follow the instruction in the page that link from the picture, to fill up all information that is needed in the form. 
	{% asset_img "Azure RM 2.png" "" %}
5. A key step from the instruction is to run a powershell script. This script can be download from the page.
6. Download and run the script, it will ask for:
	- The name of your Azure Subscription name
	- A password that you would like to set for the Service Principal that is going to be created
7. Copy the name from your Azure subscription, in this case, it is "MSDN Dev/Test Pay-As-You-Go"
	{% asset_img "Azure RM 3.png" "" %}
8. Complete the script execution. It will pop up a window for logging. Log in.
	{% asset_img "Azure RM 4.png" "" %} 
9. Finally you will get values that you can use for the form
	{% asset_img "Azure RM 5.png" "" %}  
10. Copy paste into the form from VSTS project, the click OK
	{% asset_img "Azure RM 6.png" "" %} 
11. Done
	{% asset_img "Azure RM 7.png" "" %}