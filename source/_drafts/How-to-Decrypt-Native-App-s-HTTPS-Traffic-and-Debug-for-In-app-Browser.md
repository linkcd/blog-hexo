---
title: How to Decrypt Native App's HTTPS Traffic (and Debug for In-app Browser)
tags:
  - Troubleshooting
  - Fiddler
  - Native App
  - HTTPS
---

{% asset_img "problem.gif" "Problems on Facebook and Linkedin app" %}

https://docs.telerik.com/fiddler/Configure-Fiddler/Tasks/ConfigureForiOS

1. Follow the instruction to install and configure fiddler on your PC.
2. Ensure the phone and PC are in the sane network (e.g. same wifi), so your phone can access the PC. 
3. Turn off cellphone data on the phone, to sure traffic from the phone always go through the PC.
4. From the phone, access http://FiddlerMachineIP:8888 with safari. (Chrome does not support download and install profile)
5. If your phone can not reach the url, ensure the firewall is turned off on your PC.
6. Download  FiddlerRoot certificate, then install it via Settings -> Profile Downloaded.
7. On iOS 10 and later, after installing the FiddlerRoot certificate, go to Settings -> General -> About -> Certificate Trust Settings and manually enable full trust for the FiddlerRoot root certificate. 
8. Config proxy on your phone as the fiddler documentation.
9. Done, you should be able to see HTTP and HTTPS traffics from the apps now.


Now I have started comparing the HTTPS response for the same URL but from different Apps, and quickly narrowed down to the reponse header **The Content-Security-Policy**

Content-Security-Policy in the App that have the problem
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

Content-Security-Policy in the App that do NOT have the problem
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

This is caused by the different User-Agent that different Apps are using.

User-Agent value from Apps that have issue
```bash
#Linkedin
Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 [LinkedInApp]

#Facebook
Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 [FBAN/FBIOS;FBDV/iPhone11,2;FBMD/iPhone;FBSN/iOS;FBSV/13.3.1;FBSS/3;FBID/phone;FBLC/en_US;FBOP/5;FBCR/Telenor]

#Facebook Messenger
Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 LightSpeed [FBAN/MessengerLiteForiOS;FBAV/256.0.1.26.113;FBBV/203261359;FBDV/iPhone11,2;FBMD/iPhone;FBSN/iOS;FBSV/13.3.1;FBSS/3;FBCR/;FBID/phone;FBLC/en_NO;FBOP/0]
```

User-Agent value from Apps that do NOT have issue
```bash
#Slack
Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.5 Mobile/15E148 Safari/604.1

#Skype for Business
Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.5 Mobile/15E148 Safari/604.1
```

To narrow down the core issue, we are start manipulate the request

Root cause
https://github.com/helmetjs/csp/issues/105

Ref.
-	Establish the proxy https://docs.telerik.com/fiddler/Configure-Fiddler/Tasks/ConfigureForiOS
-	Manipulate the request header https://hackernoon.com/manipulating-web-application-http-traffic-with-fiddler-140d789d0a1c 
