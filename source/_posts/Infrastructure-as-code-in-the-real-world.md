---
title: Infrastructure-as-Code and Continuous Deployment in the real world, with VSTS and Azure
date: 2017-11-05 11:13:36
tags:
  - Azure 
  - Azure template
  - Infrastructure as Code
  - Continuous deployment
  - Release management
  - Build 
  - VSTS
  - DevOps 
---
Hello again! 

It has be been a while since my last post. It is because I was quite busy leading a team in a program for delivering [veracity.com](https://www.veracity.com), the open industry data platform from DNV GL. It is a pretty exciting project - to build an open, independent data platform with bleeding edge technologies, to serve a large user base (100 000 registered users). You can read more about veracity at [here](https://www.dnvgl.com/data-platform/index.html) and [here](https://www.veracity.com/articles/why-we-build-veracity).

It actually is a long and interesting story behind veracity (and its predecessor), together with all challenges that we encountered in this journey. Hopefully I can them with you in the future.

Anyway, today I would like to talk about in the real world, how Infrastructure-as-Code looks like, together with Azure and VSTS.     

<!-- more -->
# Starting point and challenges #
There are tons of [azure templates](https://github.com/Azure/azure-quickstart-templates) which is a great start point to use Infrastructure-as-Code in Azure. However, in the real world project, we always need to do a lot of extra work due to:
1.	We need multiple environments such as Nightlybuild, Testing and Production environment. 
2.	We need different settings for different environments. 
	For example, we use more powerful App Service Plan in Production, but cheaper plan for Nightlybuild, in order to save the cost.
3.	Some considerations for releasing new version to production without downtime.
4.	We need automatic testing for Infrastructure-as-Code as it is source code.    

Above introduces the complexity to the CI/CD process, so it is important to have some best practices and common understanding in the team.

