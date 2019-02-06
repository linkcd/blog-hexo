---
title: Customize social sharing on Linkedin via API
date: 2019-02-06 20:34:51
tags:
- Linkedin
- Social Sharing
- API
- OAuth
- Postman
---
# Problem:
Nowadays it is pretty common to share articles on social media such as Facebook and Linkedin. Thanks to the widely implemented [Open Graph](http://ogp.me/) protocol, sharing is no long just a dry url, but with enrich text and thumbnails.

However, there are still some web pages that do not have Open Graph implemented, which significantly reduces the readers' willingness for clicking it. 

{% asset_img "With vs without thumbnails.png" "With vs without thumbnails" %}

In addition, even you introduced the Open Graph tags as a hotfix, some times you will have wait for approximately 7 days for linkedin crawler to refresh the preview caching, as mentioned in [linkedin documentation](https://developer.linkedin.com/docs/share-on-linkedin): 

> *The first time that LinkedIn's crawlers visit a webpage when asked to share content via a URL, the data it finds (Open Graph values or our own analysis) will be cached for a period of approximately 7 days.* 
> *This means that if you subsequently change the article's description, upload a new image, fix a typo in the title, etc., you will not see the change represented during any subsequent attempts to share the page until the cache has expired and the crawler is forced to revisit the page to retrieve fresh content.*

Some solutions are [here](https://support.strikingly.com/hc/en-us/articles/214364928-LinkedIn-or-Facebook-Share-Image-Not-Updating) and [here](https://www.linkedin.com/pulse/how-clear-linkedin-link-preview-cache-ananda-kannan-p/), but they are more like a workaround. 


# Solution:
We can overcome this issue by using linkedin API, which provide huge flexibility for customizing the sharing experiences. 

<!-- more -->

## 1. Create an application in Linkedin
Head to https://www.linkedin.com/developers/ and create an application. As showed in the screenshot, I created an application named "Linkedin Poster". Take notes on **Client ID** and **Client Secret**, set the **Redirect URLs** as https://www.getpostman.com/oauth2/callback.

{% asset_img "Linkedin App.png" "Linkedin App" %}

## 2. Generate OAuth token in Postman
Use postman application to generate OAuth 2.0 token (Authorization Code Flow). The detailed documentation is [here](https://docs.microsoft.com/en-us/linkedin/shared/authentication/authorization-code-flow?context=linkedin/consumer/context). 

{% asset_img "Postman.png" "Postman authorization" %}
- Auth URL: https://www.linkedin.com/oauth/v2/authorization
- Access Token URL: https://www.linkedin.com/oauth/v2/accessToken 
- Call back: https://www.getpostman.com/oauth2/callback (same as in the linkedin app setting)
- Scope: "r_basicprofile w_member_social" (need "w_member_social" as we need to post)

Login to generate token
 {% asset_img "Login.png" "Login to generate token" %}


## 3. Get user id from linkedin
In order to post articles in LinkedIn via API, we need to provide the user id. 
Make a GET request to API https://api.linkedin.com/v1/people/~:(id), make sure the token from step 2 is included. The result is something like below:
```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<person>
    <id>ABCDEF-z8x</id>
</person>
```

## 4. Customize your article sharing via API
Ref to the [documentation](https://docs.microsoft.com/en-us/linkedin/marketing/integrations/community-management/shares/share-api#post-shares) it is pretty straightforward for customizing the shared content. 

In my case, I would like to share http://feng.lu/archives/ (which does not have Open Graph) with  [a nice archive picture](http://feng.lu/2019/02/06/Customize-social-sharing-on-Linkedin-via-API/archives.jpg).

POST to https://api.linkedin.com/v2/shares with body:
```json
{
    "content": {
        "contentEntities": [
            {
                "entityLocation": "http://feng.lu/archives/",
                "thumbnails": [
                    {
                        "resolvedUrl": "http://feng.lu/2019/02/06/Customize-social-sharing-on-Linkedin-via-API/archives.jpg"
                    }
                ]
            }
        ],
        "title": "Article archives of feng.lu"
    },
    "distribution": {
        "linkedInDistributionTarget": {}
    },
    "owner": "urn:li:person:MY_LINKEDIN_ID",
    "text": {
        "text": "Checkout my blog archives! Hopefully you will find it useful. :)"
    }
}
```

Checkout the result:
{% asset_img "Result.png" "Result on LinkedIn" %}

# Conclusion:
By using LinkedIn API, we can easily customize the sharing experience with your professional networks. It does not only overcome the challenges such as missing Open Graph implementation, but also can improve the social media campaign experience and better integration with CMS.