---
title: How to Decrypt Native App's HTTPS Traffic (and Debug for In-app Browser)
tags:
  - Troubleshooting
  - Fiddler
  - Native App
  - HTTPS
  - Decryption
date: 2020-04-03 20:10:18
---
## Problem with in-app browser of LinkedIn and Facebook iOS apps
Recently our QA reported an interesting issue regarding the native app and our website: When the webpage was shared on Linkedin iOS App and/or Facebook iOS App, the built-in browsers cannot show it correctly but a blank page. 

{% asset_img "problem.gif" "Problems on Facebook and Linkedin app" %}

- This issue only happens on some of the iOS apps (see the list below). 
- Other iOS native apps have no problem.
- Safari and Chrome for iOS have no problem.
- All Android-based native apps have no problem.
- All desktop browsers have no problem.

<!-- more -->

| Native App         	| Platform 	| Result 	|
|--------------------	|----------	|:------:	|
| **Linkedin**           	| iOS      	| **Not OK** 	|
| **Facebook**           	| iOS      	| **Not OK** 	|
| **Facebook messenger** 	| iOS      	| **Not OK** 	|
| Slack               | iOS      	|  OK |
| Skype for Business  | iOS      	|  OK |
| Linkedin           	| Android  	|  OK |
| Facebook           	| Android  	|  OK |
| Facebook messenger 	| Android  	|  OK |
| Slack               | Android  	|  OK |
| Skype for Business  | Android  	|  OK |
| Safari              | iOS       |  OK |
| Chrome for iOS      | iOS       |  OK | 
| Any desktop browser | Win 10    |  OK |

So the problem is about iOS in-app browser in **some** native apps. But unfortunately these apps (LinkedIn and Facebook) are too important to ignore, so we will have to fix it.



## Possible ways for troubleshooting
It is challenging to debug this issue, as it only happens in some of the iOS apps. It can not be reproduced in Safari or other browsers. Possible approaches are:
1. Reach out to Linkedin or Facebook, ask for what web viewer they’re using in the app.
2. Search on the internet and hope there is a solution for it. 
3. Let's become a hacker: Perform a [Man-in-the-middle attack](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) between apps and the internet, and to decrypt and manipulate the web traffic of Apps as troubleshooting.

The #1 and #2 are long shots, then I will continue with approach #3. The following diagram shows the architecture.

{% asset_img "dzonemitmdiagram.png" "Man-in-the-middle (credit:dzone.com)" %}

## Let's decrypt the web traffic of a native app with Fiddler
There some many ways to place a "Man-in-the-middle" between mobile and internet. For example, the famous fiddler can do it. 

Follow the documentation https://docs.telerik.com/fiddler/Configure-Fiddler/Tasks/ConfigureForiOS. The key steps are:
1. Follow the instruction to install and configure fiddler on your PC.
2. Ensure the phone and PC are in the sane network (e.g. same wifi), so your phone can access the PC. 
3. Turn off cellphone data on the phone, to sure traffic from the phone always go through the PC.
4. From the phone, access http://FiddlerMachineIP:8888 with safari. (Chrome does not support download and install profile)
5. If your phone can not reach the url on PC, ensure the firewall is turned off on your PC.
6. Download  FiddlerRoot certificate, then install it via Settings -> Profile Downloaded.
7. On iOS 10 and later, after installing the FiddlerRoot certificate, go to Settings -> General -> About -> Certificate Trust Settings and manually enable full trust for the FiddlerRoot root certificate. 
8. Config proxy on your phone as in the fiddler documentation.
9. Done, you should be able to see HTTP and HTTPS traffics from the apps now.

## The blank page issue is caused by incorrect Content-Security-Policy 
Now I have started comparing the HTTPS response for the same URL but from different Apps, and quickly narrowed down the cause to the different values in response header **The Content-Security-Policy (CSP).**

Content-Security-Policy in the App that **have** the problem
```bash
#Added line break for better readability
Content-Security-Policy: script-src az416426.vo.msecnd.net
veracitycdn.azureedge.net 'unsafe-inline' https://tagmanager.google.com
https://www.googletagmanager.com www.google-analytics.com
sjs.bizographics.com/insight.min.js https://px.ads.linkedin.com/
https://*.hotjar.com https://*.hotjar.io; connect-src
dc.services.visualstudio.com https://*.hotjar.com:* https://*.hotjar.io;
frame-src https://*.hotjar.com https://*.hotjar.io
https://www.googletagmanager.com/ns.html; img-src www.google-analytics.com
stats.g.doubleclick.net ssl.gstatic.com www.gstatic.com
https://px.ads.linkedin.com/ www.google.no www.google.com px.ads.linkedin.com
www.linkedin.com; font-src data: fonts.gstatic.com; style-src
tagmanager.google.com fonts.googleapis.com
'sha256-SvLgADqEePEV9RNxBrRQXSBJafFHcVNG7cPzHz6h9eA='
```

Content-Security-Policy in the Apps that **do NOT have** the problem
```bash
#Added line break for better readability
Content-Security-Policy: default-src 'self' veracitystatic.azureedge.net
veracitycdn.azureedge.net veracity-cdn.azureedge.net
veracity-static.azureedge.net veracity.azureedge.net; style-src 'self'
'sha256-UTjtaAWWTyzFjRKbltk24jHijlTbP20C1GUYaWPqg7E=' tagmanager.google.com
fonts.googleapis.com 'sha256-SvLgADqEePEV9RNxBrRQXSBJafFHcVNG7cPzHz6h9eA=';
img-src 'self' data: veracityprod.blob.core.windows.net
veracitycdn.azureedge.net veracitystatic.azureedge.net
veracity-cdn.azureedge.net veracity-static.azureedge.net
veracitytest.azureedge.net veracity.azureedge.net brandcentral.dnvgl.com
devtestdevprofile.blob.core.windows.net testdevprofile.blob.core.windows.net
stagdevprofile.blob.core.windows.net cdn.sanity.io
devprofile.blob.core.windows.net www.google-analytics.com
stats.g.doubleclick.net ssl.gstatic.com www.gstatic.com
https://px.ads.linkedin.com/ www.google.no www.google.com px.ads.linkedin.com
www.linkedin.com; script-src 'self' veracitycdn.azureedge.net
veracity.azureedge.net https://localhost:3010 az416426.vo.msecnd.net
'unsafe-inline' https://tagmanager.google.com https://www.googletagmanager.com
www.google-analytics.com sjs.bizographics.com/insight.min.js
https://px.ads.linkedin.com/ https://*.hotjar.com https://*.hotjar.io;
media-src 'self' veracityprod.blob.core.windows.net
veracitystatic.azureedge.net veracitycdn.azureedge.net
veracity-cdn.azureedge.net veracity-static.azureedge.net veracity.azureedge.net
cdn.sanity.io brandcentral.dnvgl.com; connect-src 'self'
veracitystatic.azureedge.net veracitycdn.azureedge.net
veracity-cdn.azureedge.net veracity-static.azureedge.net veracity.azureedge.net
cdn.sanity.io wss://localhost:3011 dc.services.visualstudio.com
https://*.hotjar.com:* https://*.hotjar.io; font-src veracitycdn.azureedge.net
data: fonts.gstatic.com; report-uri
https://veracitycommon.report-uri.com/r/d/csp/enforce; report-to
https://veracitycommon.report-uri.com/a/d/g; frame-src https://*.hotjar.com
https://*.hotjar.io https://www.googletagmanager.com/ns.html
```
It is pretty clear that due to the incorrect (much shorter) value of Content-Security-Policy caused the problem.

## Some User-Agent caused incorrect Content-Security-Policy (CSP)
Now we need to check what caused the different CSP values. By comparing the requests that these apps were sending in Fiddler, I have quickly identified the request header "User-Agent" is the key.

User-Agent values from Apps that cause **wrong** CSP
```bash
#Linkedin
Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 [LinkedInApp]

#Facebook
Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 [FBAN/FBIOS;FBDV/iPhone11,2;FBMD/iPhone;FBSN/iOS;FBSV/13.3.1;FBSS/3;FBID/phone;FBLC/en_US;FBOP/5;FBCR/Telenor]

#Facebook Messenger
Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 LightSpeed [FBAN/MessengerLiteForiOS;FBAV/256.0.1.26.113;FBBV/203261359;FBDV/iPhone11,2;FBMD/iPhone;FBSN/iOS;FBSV/13.3.1;FBSS/3;FBCR/;FBID/phone;FBLC/en_NO;FBOP/0]
```

User-Agent values from Apps that cause **correct** CSP
```bash
#Slack
Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.5 Mobile/15E148 Safari/604.1

#Skype for Business
Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.5 Mobile/15E148 Safari/604.1
```

## Manipulate web traffic of the apps to simulate different behaviors
Although we cannot change the logic of these apps, we can still easily manipulate the request or response, to simulate the different behaviors. 

Head to Fiddler, go to "Filters" table, then you can 
1. Setup the filter to target the manipulation to a specific page
2. Manipulate requests, such as add/update/remove request headers and body
3. Manipulate responses, such as headers and body

{% asset_img "fiddler.png" "Manipulate request and response in fiddler" %}

Some findings are:
1. “[…]” part in the user-agent does NOT cause the problem, even though they are quite long strings
2. Missing the "Version/13.0.5" part is causing the problem

| Original LinkedIn User-Agent (with issue) 	| Updated LinkedIn User-Agent (without issue) 	|
|---------------------------------------------------------------------------------------------------------------------------------	|-------------------------------------------------------------------------------------------------------------------------------------------------	|
| Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148  [LinkedInApp] | Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 **Version/13.0.5** [LinkedInApp] 	|

## Root cause and solution
Generally, the web site should return the same CSP for most of the cases. So this is an issue that we should fix on the website. 

The investigation led us to the opensource library [Helmet](https://github.com/helmetjs) where we reported a bug https://github.com/helmetjs/csp/issues/105. 

Now we have fixed this issue locally and once Helmet merged the PR, we are ready to go.

## Take away
1. It is easy to perform a "Man-in-the-middle" like attack, but ONLY IF you have control on the device (e.g. you can install the root certificate). 
2. Once you have a machine between mobile and internet, you can not only monitor the web traffic, but also manipulate both request and response. So if you are interested in how an app is talking to its backend, you have tools to do that.
3. Advice to normal app user: be careful who have access to your device and try to stay away from the public wifi.
4. Advice to app developers: always remind yourself that technically it is possible for a hacker to "open your app" and look at which API endpoint your app is talking to, and manipulate the requests. Your app's private API endpoint will be exposed, take all necessray security measurement on it!  

## References
-	Establish the proxy https://docs.telerik.com/fiddler/Configure-Fiddler/Tasks/ConfigureForiOS
-	Manipulate the request header https://hackernoon.com/manipulating-web-application-http-traffic-with-fiddler-140d789d0a1c 
