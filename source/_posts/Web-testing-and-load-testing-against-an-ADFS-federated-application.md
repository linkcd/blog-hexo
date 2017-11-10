---
title: Web/Load testing against an ADFS federated application
tags:
  - ADFS
  - Web testing
  - Load testing
  - Application Insights
date: 2016-10-29 20:25:07
---

In Application Insights, you can create an [availability web testing](https://azure.microsoft.com/en-us/documentation/articles/app-insights-monitor-web-app-availability/) to monitor the availability of a web application. It supports 2 type of testing:
 - URL ping test: a simple test that you can create in the Azure portal.
 - Multi-step web test: which you create in Visual Studio Ultimate or Visual Studio Enterprise and upload to the portal.

Normally it is easy to setup ping test and multiple step testing against a public site.

However, in order to have a multiple step testing against an ADFS federated application, you will have to do some extra in order to take care of the authentication part.

<!-- more -->

# The problem #
By default, the test scripts that you recorded via Visual studio cannot handle the ADFS authentication. Depends on the version of your Visual Studio, the generated script either has no token, or has a token with a timestamp.

{% asset_img "Recorded script with a timestamp.png" "Recorded script with a timestamp" %}

If you setup the multiple step web test with this script, after the token with a timestamp expired, you will see error message such as "System.IdentityModel.Tokens.SecurityTokenExpiredException at System.IdentityModel.Tokens.SamlSecurityTokenHandler.ValidateToken", "The SamlSecurityToken is rejected because the SamlAssertion.NotOnOrAfter condition is not satisfied. NotOnOrAfter: '10/24/2016 2:03:42 PM' Current time: '10/27/2016 1:20:52 AM' "

{% asset_img "Exception due to invalid token timestamp.png" "Exception due to invalid token timestamp" %}
 
# Solution #
## Steps of ADFS login ##
1. Redirect to ADFS for login
	If the current session does not have an valid ADFS token, the end user will be automatically redirected to the ADFS login page. Pay attention to the hyperlink in the response body. 

	{% asset_img "1 Redirect to ADFS for login.png" "Step 1: Redirect to ADFS for login" %}

2. In the ADFS login form, user types the account name and password, then submit. The input values can be found in step 3 HTTP request body in below.
	{% asset_img "2 ADFS login form.png" "Step 2: ADFS login form" %}

3. HTTP POST the user name and password to ADFS URL for verification. 
	{% asset_img "3 Post credential back to ADFS.png" "Step 3: Post credential back to ADFS" %}

4. If the credential is valid, generate a response HTML which triggers a HTTP POST back to the application URL. The values in the HTTP POST can be found in Step 5 screenshot in below.
	{% asset_img "4 Completed login and post form.png" "Step 4: Completed login and post form.png" %}
	
5. As the result of the generated HTTP POST to application URL, User got the authentication token to login 
	{% asset_img "5 Form posted and got authenticated cookie.png" "Step 5: Form posted and got authenticated cookie" %}

## Setup script ##
In the script, we have following setup: (Please note that the script is accessing a specify application URL: "/notifications", instead of the root URL "/")
	{% asset_img "Test steps.png" "Test steps" %}
 
1. Conduct a directly **POST** call to ADFS URL
	**Querystring**: values for protocol(wa), application information(wtrealm and wctx) and RedirectToIdentityProvider
	**Form**: authenticaiton method, account name and password

2. Once we got the response, extract from context parameter _cert
	{% asset_img "Extract hidden field.png" "Extract hidden field to a variable _cert" %}
 
3. Conduct a directly **POST** call to application URL , with values that we extracted from previous call to ADFS
	{% asset_img "Pass values from hidden field.png" "Pass values from hidden field" %}
 
4. From now on, you can continue the testing with more URLs of the application, without passed values from hidden fields as we did in above.
5. Successed tests
{% asset_img "Successed tests.png" "Successed tests" %} 

# Load Testing #
As far as the web testing script is ready, you can quickly load them into the load test cases. 
{% asset_img "Load testing results.png" "Load testing results" %}

# Ref #
There are two similar posts about authentication of ADFS:
- http://southworks.com/blog/2013/01/03/load-testing-adfs-federated-sharepoint-applications/
- https://blogs.msdn.microsoft.com/zwsong/2014/07/23/load-testing-saml-ping-based-sharepoint-2013-sites/ 