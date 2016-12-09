---
title: No agent pool found with identifier 0 error when setup build agent in VSTS
tags:
  - VSTS
  - Trouble Shooting
  - Build
date: 2016-11-19 15:39:32
---


# Problem #
We cannot register a private build agent on VSTS by using a service account. This service account has created Personal Access Token with expiration for 1 year and authorization for all scopes.

Whenever we run the config.cmd, then connecting to the server, type the Agent Pool and Agent Name, configuration command throws error.

	No agent pool found with identifier 0.
	Failed to add the agent.  Try again or ctrl-c to quit

{% asset_img "Error No agent pool found with identifier 0.jpg" "Error: No agent pool found with identifier 0" %}

However, with the same build server and with another developer's account, it works fine and the build agent is up and running.

<!-- more -->

# Root Cause #
It turns out that the service account is **Stakeholder** role in VSTS. Users defined as Stakeholder do not have access to build components such as build agents private or hosted. Documentation is at [there](https://www.visualstudio.com/en-us/docs/work/connect/work-as-a-stakeholder).

It also explained that using the developers account can work fine, since it has MSDN subscription. 

Regardless, the error message is somewhat misleading.

# Solution #
We purchased a **Basic Account** for this service account, and it works perfectly. 

