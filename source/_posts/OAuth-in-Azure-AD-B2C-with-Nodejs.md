---
title: OAuth in Azure AD B2C with Nodejs
date: 2017-06-28 14:54:24
tags:
  - OAuth
  - OpenID
  - Azure
  - Azure AD B2C
  - Nodejs
  - Authentication
  - Authorization
---

Recently we need to build a Nodejs single-page-application (SPA) solution that is using Azure AD B2C as the identity provider (idp). Since it is a single-page-application, we are going to use OAuth2 Implicit Flow.

{% asset_img "what-is-oauth.jpg" "picture credit:stormpath.com" %}

This article demonstrates the basic steps for setting up both the server side (WebAPI)  as well as the client application.

<!-- more -->

# Setup your own Azure AD B2C #
## Create an Azure AD B2C tenant ##
First of all, let's create an AAD B2C tenant with domain **luconsultingb2c.onmicrosoft.com** by following the steps in [this document](https://docs.microsoft.com/en-us/azure/active-directory-b2c/active-directory-b2c-get-started).
{% asset_img "Azure AD B2C Create Tenant.png" "Azure AD B2C Create Tenant" %}

Then you can switch by using the top-right menu
{% asset_img "Switch domain.png" "Switch domain" %}

If you want, you can connect the AAD to an existing Azure subscription
{% asset_img "Connect Azure AD B2C to subscription.png" "Connect Azure AD B2C to subscription" %}

Now you can start using this tenant
{% asset_img "AAD B2C Dashboard.png" "AAD B2C Dashboard" %}


## Configure Linkedin as an identity provider ##
Follow the step in [Azure Active Directory B2C: Provide sign-up and sign-in to consumers with LinkedIn accounts](https://docs.microsoft.com/en-us/azure/active-directory-b2c/active-directory-b2c-setup-li-app "https://docs.microsoft.com/en-us/azure/active-directory-b2c/active-directory-b2c-setup-li-app"). 

1. Create a Linkedin App to generate the client id and secret
{% asset_img "Create Linkedin App.png" "Create a Linkedin App" %}

2. Add Linkedin as an identity provider in AAD B2C, together with Email as local accounts
{% asset_img "Add linkedin as an Identity provider.png" "Add linkedin as an Identity provider" %}
Remember to give it a meaningful name for your Linkedin idp, as the name will be used in the login page. (Do not use "LI" as the Microsoft article suggested)

## Create policy ##
1. Now create a Signup/Signin prolicy by following the steps in [Azure Active Directory B2C: Built-in policies](https://docs.microsoft.com/en-us/azure/active-directory-b2c/active-directory-b2c-reference-policies).
	We name this policy **"SiUpIn"**, and it will be automatically renamed **"B2C_1_SiUpIn"** (the B2C\_1\_ fragment is automatically added)
2. When user sign up, I would like to ask for **Given Name**, **Surname Name**, **Email Address**, **Display Name**, **Job Title** and **Country/Region** 
	{% asset_img "Select sign-up attributes.png" "Select sign-up attributes" %}
3. After sign in, I would like to have **Display Name**, **Country/Region** and **Job Title** to be included in the claim. In addition, I want to know the **idp** and if **newUser** is true, so select them.
	{% asset_img "Select application claims.png" "Select application claims" %}
4. Done
	{% asset_img "News quality.png" "News quality" %}

# Create and register your WebAPI #
## Register your WebAPI ##
Follow the steps in [Azure Active Directory B2C: Register your application](https://docs.microsoft.com/en-us/azure/active-directory-b2c/active-directory-b2c-app-registration) to register a web api named **B2CEchoWebAPI**
{% asset_img "Register Web Api.png" "Register Web API" %}
Note:
- Enable the **Web App/Web API** setting for the web api.
- **Reply URL** to **http://localhost:5000/** as we will run the web api there.
- HTTP protocol is allowed as far as it is for localhost. If it is external, we have to use HTTPS. 
- Even the **App ID URI** is marked as optional, this is needed to construct the scopes that are configured in you single page application's code

## Setup policy ##
Once Web API is registered, open the app's **Published Scopes** blade and add any extra scopes you want.
{% asset_img "Published scopes.png" "Published scopes" %}
Note:
- The scope is used for controlling permissions: an access token defines the permissions that are granted to the bearer of the token. The permissions are defined by you (the API owner) and you control what happens when your API receives a token with that permission. 
- In this case, I define 3 permission levels: **"read"**, **"write"** and **"performXYZ"**.
- When the API receives a token that has the "read" value in the scope, the API will do actions that I think are okay for a user that has a "read" permission.
- Microsoft document mentioned that there is a default scope **"user_impersonation"**, but it is not mandatory. AAD B2C doesn't care what the permission values are. It simply ensures that scopes that are requested are valid and then generates a proper token when they are valid. It is up to you what you want your API to do when it receives an access token with a permission called "user_impersonation". The "user_impersonation" scope is there by default because there needs to be at least one scope defined when a user requests a token, and you can use the "user_impersonation" to be that scope.
- By default, applications are granted the ability to access the user's profile via the **"openid"** permission, and generate refresh tokens via the **"offline_access"** permission. But you do NOT need to specify them here.

Write down the **AppID URI** and **Published Scopes values**, You will need them in your client application code. The format for calling will be "https://{tenent}/{AppID URI}/{scope value}", for example "https://luconsultingb2c.onmicrosoft.com/B2CEchoWebAPI/performXYZ".


## Create a Nodejs based web api ##
In this case, I am using a forked version of [Microsoft sample code](https://github.com/Azure-Samples/active-directory-b2c-javascript-nodejs-webapi), with small modification. You can access it at https://github.com/linkcd/active-directory-b2c-javascript-nodejs-webapi.

### Packages ###
It is using the common [passport](http://passportjs.org/) and [passport-azure-ad](https://github.com/AzureAD/passport-azure-ad) for AAD strategies.

### Code for authentication ###
(full code is at https://github.com/linkcd/active-directory-b2c-javascript-nodejs-webapi/blob/master/index.js)
```js
var express = require("express");
var passport = require("passport");
var BearerStrategy = require('passport-azure-ad').BearerStrategy;

//our tenent
var tenantID = "luconsultingb2c.onmicrosoft.com"; 

//client id of registered web api: "B2CEchoWebAPI"
var clientID = "f40734c1-5990-47fc-91b5-deceebac0089"; 

//our defined policy, include Linkedin 
var policyName = "B2C_1_SiUpIn"; 

var options = {
    identityMetadata: "https://login.microsoftonline.com/" + tenantID + "/v2.0/.well-known/openid-configuration/",
    clientID: clientID,
    policyName: policyName,
    isB2C: true,
    validateIssuer: true,
    loggingLevel: 'info',
    passReqToCallback: false
};

var bearerStrategy = new BearerStrategy(options,
    function (token, done) {
        // Send user info using the second argument
        done(null, {}, token);
    }
);

var app = express();

app.use(passport.initialize());
passport.use(bearerStrategy);
```

Then define API endpoint
```js
app.use(function (req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Authorization, Origin, X-Requested-With, Content-Type, Accept");
    next();
});

app.get("/hello",
    passport.authenticate('oauth-bearer', {session: false}),
    function (req, res) {
        var claims = req.authInfo;
        console.log('User info: ', req.user);
        console.log('Validated claims: ', claims);
        
	//do this ONLY if the required scope include "read"
        if (claims['scp'].split(" ").indexOf("read") >= 0) {
            // Service relies on the name claim.  
            res.status(200).json({'name': claims['name']});
        } else {
            console.log("Invalid Scope, 403");
            res.status(403).json({'error': 'insufficient_scope'}); 
        }
    }
);
```

Now run it at local
{% asset_img "Run webapi on localhost.png" "Run webapi on localhost" %}

And confirm that the endpoint is protected
{% asset_img "Unauthorized access to the api.png" "Unauthorized access to the api" %}

Now the Web API part is done, let's move to the client part.

#  Create and register your client app #

## Register your client app ##
Follow the steps in [register your single page application in your B2C tenant](https://docs.microsoft.com/azure/active-directory-b2c/active-directory-b2c-app-registration#register-a-web-application), so that your client has its own Application/client ID. 
{% asset_img "Register client app.png" "Register client app" %}
Note:
- Enable the **Web App/Web API** setting for the web api.
- **Reply URL** to **http://localhost:6420/** as we will run the client app there.
- HTTP protocol is allowed as far as it is for localhost. If it is external, we have to use HTTPS. 

## Grant the client app access to the web API ##
{% asset_img "Grant client app API access.png" "Grant client app API access" %}

## Create the client app ##
Again, I am using a forked version of [Microsoft sample code](https://github.com/Azure-Samples/active-directory-b2c-javascript-msal-singlepageapp), you can find it at https://github.com/linkcd/active-directory-b2c-javascript-msal-singlepageapp
```js
<script class="pre">
    // The current application coordinates were pre-registered in a B2C tenant.
    var applicationConfig = {
        clientID: 'df8f3cb5-b668-4e11-a8ca-ad4f78cb87f4',
        authority: "https://login.microsoftonline.com/tfp/luconsultingb2c.onmicrosoft.com/b2c_1_siupin",
	
	//use scope "read", as it is required in the Web API (see the webapi code in above)
        b2cScopes: ["https://luconsultingb2c.onmicrosoft.com/B2CEchoWebAPI/read"],
        webApi: 'http://localhost:5000/hello',
    };
</script>
```

# Test #
{% asset_img "login with linkedin.gif" "login with linkedin" %}

Look at the claim properties
{% asset_img "Claim properties.png" "Claim properties" %}
As you can see that most of the user properties are from my Linkedin profile. Since this is the first time I signin, the **newUser** is true.

Also verify that the new user is created in AAD B2C
{% asset_img "All users in AAD B2C.png" "All users in AAD B2C" %}

EOF.

# ref #
1. [https://docs.microsoft.com/en-us/azure/active-directory-b2c/active-directory-b2c-reference-spa](https://docs.microsoft.com/en-us/azure/active-directory-b2c/active-directory-b2c-reference-spa "Single-page app sign-in by using OAuth 2.0 implicit flow")

 
