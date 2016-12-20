---
title: Work with custom event in Application Insights
date: 2016-11-06 19:40:15
tags:
  - Azure
  - Application Insights
  - Monitoring
  - PowerBI
  - DevOps
---
Application Insights can offer you lots of built-in telemetries such as Page Views and Exceptions. But quite often we need to track some customize/business performances. Some examples that we are using now are:
- SharePoint crawled items from content source X
- Daily usage of a web application of all users from company ABC
- Usage and performance of different version of API

To meet these challenges, Application Insights [offers API](https://docs.microsoft.com/en-us/azure/application-insights/app-insights-api-custom-events-metrics) for custom event and metrics.

In this article I will show how to monitor and analysis API performance by using custom events, including export it into external database for archiving and future analysis.   

<!-- more -->
# Report events #
Our ASP.Net Web API application is already instrumented with Application Insights. The goal is to also report the performance and usage of API in below format.

By following the [documentation](https://docs.microsoft.com/en-us/azure/application-insights/app-insights-api-custom-events-metrics), we have below code in the server side for sending the performance data of each API request:

{% codeblock lang:c# %}
var properties = new Dictionary<string, string>{
    { "ElapsedMilliseconds", apiCall.ElapsedMilliseconds.ToString()},
    { "ContractName", apiCall.ContractName},
    { "AbsoluteUri", apiCall.AbsoluteUri},
    { "Action", apiCall.Action },
    { "UserId", apiCall.UserId },
    { "AccountId", apiCall.AccountId },
    { "AccountName", apiCall.AccountName }
};
_appInsightTelemetryClient.TrackEvent(apiCall.ContractName + " - " + apiCall.Action, properties);
{% endcodeblock %}

Then you can verify the raw data you got in Application Insights
{% asset_img "Custom events in search window.png" "Custom events in search window" %} 

And also in the analytics
{% asset_img "Custom events in analytics window.png" "Custom events in analytics window" %} 

You can see that all customized attributes in this event are in **customDimensions** object.

# Analysis events #
From here, you can run analytic queries, such as

### Find the 5 most slowest API actions in last 24 hours ###
```bash
customEvents 
| where timestamp >= ago(24h) 
| extend action = tostring(customDimensions.["Action"])
| extend ElapsedSeconds = todouble(customDimensions.["ElapsedMilliseconds"]) / 1000
| summarize avg(ElapsedSeconds) by action
| top 5 by avg_ElapsedSeconds desc
| render barchart 
```
{% asset_img "The 5 most slowest API actions in last 24 hours.png" "The 5 most slowest API actions in last 24 hours" %}

### Find the most popular API actions in last 7 days ###
```bash
customEvents 
| where timestamp >= ago(7d) 
| extend action = tostring(customDimensions.["Action"])
| summarize count() by action
| order by count_ desc 
| render barchart 
```
{% asset_img "Most popular API actions in last 7 days.png" "Most popular API actions in last 7 days" %}


### Percentile of one action "GetUser" in last 7 days ###
```bash
customEvents
 | where timestamp >= ago(7d)
 | where customDimensions.["Action"] == "GetUser" 
 | extend ElapsedSeconds = todouble(customDimensions.["ElapsedMilliseconds"]) / 1000
 | summarize percentiles(ElapsedSeconds, 50, 90, 95) by bin(timestamp, 1h) 
 | render timechart
```
{% asset_img "Percentile of one action in last 7 days.png" "Percentile of one action in last 7 days" %}

# Export to SQL database #
As I described in my previous blog [Application Insights Export and PowerBI](/2016/10/15/Application-Insights-Export-and-PowerBI/), you can export custom event telemetry data to a SQL database. 

### Create the database table ###
```sql
CREATE TABLE [dbo].[mywebapi-ai-events]
 (
     [ID] varchar(50),
     [TimeStamp] varchar(50),
     ElapsedMilliseconds varchar(20),
     AbsoluteUri varchar(300),
     [UserId] varchar(200),
     [Action] varchar(100),
     [AccountId] varchar(200),
     ContractName varchar(200),
     AccountName varchar(200),
     CONSTRAINT [PK_Source] PRIMARY KEY CLUSTERED   
     (
     [ID] ASC  
     )
 )
```
### Setup input in Streaming Analytics ###
{% asset_img "Input.png" "Input" %}

### Setup output in Streaming Analytics ###
{% asset_img "Output.png" "Output" %}

### Setup query in Streaming Analytics ###
```sql
SELECT
    C.internal.data.id as ID
    , C.context.data.eventTime as [TimeStamp]
    ,GetRecordPropertyValue(GetArrayElement(C.context.custom.dimensions, 0),'ElapsedMilliseconds') as ElapsedMilliseconds
    ,GetRecordPropertyValue(GetArrayElement(C.context.custom.dimensions, 1),'AbsoluteUri') as AbsoluteUri
    ,GetRecordPropertyValue(GetArrayElement(C.context.custom.dimensions, 2),'UserId') as UserId
    ,GetRecordPropertyValue(GetArrayElement(C.context.custom.dimensions, 3),'Action') as Action
    ,GetRecordPropertyValue(GetArrayElement(C.context.custom.dimensions, 4),'AccountId') as AccountId
    ,GetRecordPropertyValue(GetArrayElement(C.context.custom.dimensions, 5),'ContractName') as ContractName
    ,GetRecordPropertyValue(GetArrayElement(C.context.custom.dimensions, 6),'AccountName') as AccountName
INTO 
    [output-ai-apicustomevents]
FROM [input-ai-apicustomevents] C
```
Also see some dicussion [here](http://stackoverflow.com/questions/31528147/export-custom-event-dimensions-to-sql-from-application-insights-using-stream-ana)

### Finally the data will be stored in database ###
{% asset_img "Events in database.png" "Events in database" %}

