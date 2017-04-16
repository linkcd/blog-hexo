---
title: Tracking subdomains by GTM
date: 2017-04-16 21:10:06
tags:
-	Google Tag Manager
-	Google Analytics
---
Recently I am investigating how to track user behaviors across our digital services. 

We have web applications like:
1. example.com (the company homepage)
2. **service-A**.example.com (digital service A)
3. **service-B**.example.com (digital service B)

and we are using Google Tag Manager (and Google Analytics)

<!-- more -->
To be straight forward, what we need are:
1. Use Universal Analytics
2. In tag settings of GTM, set **cookieDomain**'s value to **auto**
3. In Referral Exclusion List of GA, add **example.com**
4. Done

For trouble shooting, I recommend to install Google Analytics Debugger (A chrome extension). 

To test it, you can 
1. go to example.com
	Use GA debugger to find the GA clientId, e.g. 1753731437.1492367410, and
	It has a cookie **_ga** with value "GA1.2.**1753731437.1492367410**", and the domain is: "**.example.com**"
2. Click a link to navigate to **service-A**.example.com
	The GA clientID on Service A should be the same, and
	It has an identical _ga cookie: same value, same domain ".example.com"
4. Directly type URL **service-B**.example.com
	Again, the same GA clientID and _ga cookie


There some some great articles about this topic. The most useful posts that I found are from lunametrics ([**cross-domain** tracking](http://www.lunametrics.com/blog/2015/06/16/cross-domain-tracking-with-google-tag-manager/) and [**sub-domain** tracking with a great diagram](http://www.lunametrics.com/blog/2016/08/11/subdomain-tracking-google-analytics/)), and from Simo Ahava ([here](https://www.simoahava.com/analytics/cross-domain-tracking-across-subdomains/) and [here](https://www.simoahava.com/analytics/cookie-settings-and-subdomain-tracking-in-universal-analytics/)) with deep core code explanation. A post from [e-nor](https://www.e-nor.com/blog/google-analytics/cross-domain-and-roll-up-reporting) is also useful. 

 
