---
title: Web test against an ADFS federated application
tags:
  - ADFS
  - Web Testing
  - Application Insights 
---
In Application Insights, you can create an [availability web testing](https://azure.microsoft.com/en-us/documentation/articles/app-insights-monitor-web-app-availability/) to monitor the availability of a web application. It supports 2 type of testing:
 - URL ping test: a simple test that you can create in the Azure portal.
 - Multi-step web test: which you create in Visual Studio Ultimate or Visual Studio Enterprise and upload to the portal.

Normally it is easy to setup ping test and multiple step testing against a public site.

However, in order to have a multiple step testing against an ADFS federated application, you will have to do some extra in order to take care of the authentication part.

<!-- more -->

 
