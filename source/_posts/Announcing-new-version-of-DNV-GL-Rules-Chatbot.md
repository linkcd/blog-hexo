---
title: Announcing new version of DNV GL Rules Chatbot
date: 2017-01-07 20:45:31
tags:
  - chatbot
  - artificial intelligence 
  - machine learning 
  - Microsoft Language Understanding Intelligent Service
  - prototype
  - SharePoint PnP
---
I am happy to announce the new version of DNV GL Rules Chatbot is ready now. The key new features are below:
-  Support full text search (based on SharePoint Search)
-  Indexing DNV GL rules documents with enhanced metadata
-  Customized ranking  
-  Upgraded to Bot Framework 3.0
-  Supported new channel: Microsoft Teams

**URL**:
https://dnvgl-rules-bot.azurewebsites.net
<!-- more -->

# live preview #
{% iframe "https://webchat.botframework.com/embed/dnvgl_rules_chatbot?s=KQCouIDFcKo.cwA.SbA.42Rxpjge3qYjONDPZGkMDzpHy5RDTGtZhDlXyAZ9BOU" %}

# Demo #
{% youtube ZldjgwI9BL8 %}

# Architect Overview #
The architect of the chat bot is shown in below
{% asset_img "architect overview.png " "Architect overview of chat bot" %}

## 1. Bot framework and channels ##
[Bot framework](https://docs.botframework.com/en-us/) out-of-the-box supports several conversation channels, but you might noticed that they are more consumer based channels. Skype for Business, for example, is not supported at this moment. 

## 2. Chatbot Web API application in Azure ##

Chatbot Web API is a simple standard ASP.Net Web API project. It has two key class:
- MessagesController
- RulesAndStandardsDialog

### MessagesController class ###
This is the end-point for listening all incoming messages, and forward to **RulesAndStandardsDialog** class
	```Csharp
	[BotAuthentication]
	public class MessagesController : ApiController
	{
	    /// <summary>
	    /// POST: api/Messages
	    /// Receive a message from a user and reply to it
	    /// </summary>
	    /// 
	
	    public async Task<HttpResponseMessage> Post([FromBody]Activity activity)
	    {
	        ConnectorClient connector = new ConnectorClient(new Uri(activity.ServiceUrl));
	        if (activity != null && activity.Type == ActivityTypes.Message)
	        {
	            await Conversation.SendAsync(activity, () => new DNVGLBot.Controllers.RulesAndStandardsDialog());
	        }
	        else
	        {
	            return null; //HandleSystemMessage
	        }
	        return new HttpResponseMessage(System.Net.HttpStatusCode.Accepted);
	    }
	
	}
	```

### RulesAndStandardsDialog class ###
This class is responsible for consuming the result from LUIS web service and perform actual task. For example, *[LuisIntent("bot.intent.search")]* attribute means that the SearchDocument function will be called once the bot.intent.search intent was identified by LUIS.
	{% codeblock lang:c %}
	[LuisModel("YOUR-LUIS-MODEL-ID", "YOUR-SUBSCRIPTION-ID")]
	[Serializable]
	public class RulesAndStandardsDialog: LuisDialog<object>
	{
		//Some lines of code were omitted 
	
	    [LuisIntent("bot.intent.search")]
	    public async Task SearchDocument(IDialogContext context, LuisResult result)
	    {
	        string keywords = TryFindKeywords(result);
	
	        if (!string.IsNullOrEmpty(keywords))
	        {
	            await DoSearch(context);
	        }
	        else
	        {
	            await context.PostAsync("Sorry, I can not find any keywords, please try again.");
	            context.Wait(MessageReceived);
	        }
	   }
	
	    [LuisIntent("bot.help")]
	    public async Task Help(IDialogContext context, LuisResult result)
	    {
	        await context.PostAsync(GetHelpMessage());
	        context.Wait(MessageReceived);
	    }
	
	    [LuisIntent("bot.about")]
	    public async Task About(IDialogContext context, LuisResult result)
	    {
	        await context.PostAsync(GetAboutMessage());
	        context.Wait(MessageReceived);
	    }
	}

	{% endcodeblock %}


## 3. Storage account in Azure ##
Chatbot is using Azure storage account (table) for storing end user profiles, such as Full name, email address and subscribed rules codes. It is not a mandatory component for the bot, but simply an user profile database.

## 4. Luis in Cognitive services ##
Luis model is the brain of the chat bot. It is pretty easy to setup and training it without programming skill. Based on the experience, 100 sample inputs can produce a reasonable AI.

{% asset_img "training luis model.png" "Training Luis model" %}

**Tips**: Remember to re-publish Luis endpoint once a while during the training process, otherwise the client (bot) won't pick up the newly trained sample.

## 5. Search engine in SharePoint ##
Once Luis has identified the search intent and the to-be-search keywords, the information will be passed to the search engine for query. In this case, the search engine is SharePoint.

All rules pdf files are indexed by SharePoint search engine - it provides good support for full text search and meta-data enhancement (via Content Enrichment Web Service during the indexing process). 

Using a search engine is the biggest improvement compares to older version, where the search logic was simply matching words in rules title. 

I am using [SharePoint PnP framework](https://github.com/SharePoint/PnP) to handle [the authentication](https://github.com/SharePoint/PnP-Sites-Core/blob/master/Core/SAML%20authentication.md) to the on-premise SharePoint farm, which is protected by ADFS. Also, I have learned from our expert [Mikael Svenson](http://www.techmikael.com/2013/10/adding-freshness-boost-to-sharepoint.html) to add the freshness boost to the result. 

Unfortunately built-in date variables do not work in C#/KeywordQuery scenario, therefore I have rewrite the code as below:
```Csharp
string samlSite = "https://SHAREPOINTURL";

//XRank for boosting fresh content
string daysAgo580 = DateTime.Now.AddDays(-580).ToString("yyyy-MM-dd");
string daysAgo365 = DateTime.Now.AddDays(-365).ToString("yyyy-MM-dd");
string daysAgo180 = DateTime.Now.AddDays(-180).ToString("yyyy-MM-dd");
string daysAgo90 = DateTime.Now.AddDays(-90).ToString("yyyy-MM-dd");
string daysAgo60 = DateTime.Now.AddDays(-60).ToString("yyyy-MM-dd");
string daysAgo30 = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
string daysAgo16 = DateTime.Now.AddDays(-16).ToString("yyyy-MM-dd");
string daysAgo7 = DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd");
string daysAgo1 = DateTime.Now.AddDays(-1).ToString("yyyy-MM-dd");
string daysAgo0 = DateTime.Now.ToString("yyyy-MM-dd");

OfficeDevPnP.Core.AuthenticationManager am = new OfficeDevPnP.Core.AuthenticationManager();
using (ClientContext ctx = am.GetADFSUserNameMixedAuthenticatedContext(samlSite, "USERNAME", "PASSWORD", "DOMAIN", "STS", "IDPID"))
{
    KeywordQuery keywordQuery = new KeywordQuery(ctx);
    keywordQuery.QueryText = string.Format("((((((((({0} contentsource:\"dnvglrules\" XRANK(cb=1) title:\"{0}\")  XRANK(cb=04922713399625873E-17) write>{1}) XRANK(cb=026792479063910794E-18) write>{2}) XRANK(cb=06696008382287308E-17) write>{3}) XRANK(cb=10720794384750529E-17) write>{4}) XRANK(cb=08336806307198713E-17) write>{5}) XRANK(cb=16669442125999617E-17) write>{6}) XRANK(cb=3107141114146401E-16) write>{7}) XRANK(cb=15680891749553738E-17) write>{8}) XRANK(cb=03222684602729131E-17) write>{9}", keyword, daysAgo580, daysAgo365, daysAgo180, daysAgo90, daysAgo60, daysAgo30, daysAgo7, daysAgo1, daysAgo0);

    keywordQuery.RowLimit = 5; //return 5 results everytime, since the dialog screen will be small, e.g. from a mobile
    keywordQuery.StartRow = startRow;
    SearchExecutor searchExecutor = new SearchExecutor(ctx);

    ClientResult<ResultTableCollection> results = searchExecutor.ExecuteQuery(keywordQuery);
    ctx.ExecuteQuery();

    return results;
    
}
```
 
# Side notes for developer on Windows 10 ##
1. Enabling Identity Foundation Framework on windows 10
One of the dependency component of the PnP nuget package is Identity Foundation Framework. You cannot download an installer for windows 10, but simply enable the feature in windows 10. 
Go to Control Panel -> Uninstall a Program on the menu -> Turn Windows Features On or Off -> Check "Windows Identity Framework 3.5"

2. Install Microsoft.IdentityModel.Extensions.dll library
Another dependency is Microsoft.IdentityModel.Extensions.dll. Download 32-bit [here](http://download.microsoft.com/download/0/1/D/01D06854-CA0C-46F1-ADBA-EBF86010DCC6/MicrosoftIdentityExtensions-32.msi) and 64-bit [here](http://download.microsoft.com/download/0/1/D/01D06854-CA0C-46F1-ADBA-EBF86010DCC6/MicrosoftIdentityExtensions-64.msi).

 

# Final notes #
**Security** is important aspect for any bot service, therefore pay extra attention about how you expose data via your bot service. (Read more at [here](http://mashable.com/2016/04/23/messenger-bot-security)) 

It also the same for the **privacy** of your end users. 



