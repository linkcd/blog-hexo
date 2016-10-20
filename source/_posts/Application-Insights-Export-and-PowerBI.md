---
title: Application Insights Export and PowerBI
tags:
  - Azure
  - Application insights
  - Monitoring
  - PowerBI
  - DevOps
date: 2016-10-15 14:36:25
---

# Introduction # 
Application Insight is a great tool for monitoring your application. However, there is a limitation regarding historical data: Regardless [the different plans](https://azure.microsoft.com/en-us/pricing/details/application-insights/), you can only have: 
- 7 days raw data, includes access to all telemetry data points collected by application insights
- 90 days aggregated data, includes access to telemetry data points aggregated at hourly/daily levels

This article will demonstrate how to use the continuous data export to overcome this limitation, as well as use PowerBI for future web analytic.

<!-- more -->
# Export the data#
There is [a nice document](https://azure.microsoft.com/en-us/documentation/articles/app-insights-export-telemetry/) for enabling the continues export from Application Insights.

## Create a  storage account##
Currently, Application Insights can only export to a **classic** storage account. When you are creating it, I suggest to use "**Standard-LRS**" with **Cold** tier. This is simply because we use storage account as a temporary storage place, before we move everything to a database.

## Configure the export settings ##
In this case, we are exporting two types:
- Availability 
- Page View.
{% asset_img "export settings.png" "Export settings" %} 

Once it is done and the telemetry data started exporting, you should be able to see folders in the blob container in storage account. One folder is mapping to one data type in above export setting.
{% asset_img "Folders in blob.png" "Folders in Blob container" %} 

Take a closer look at the folder content. Below screenshot shows the PageViews data between 12am to 1pm on 28th of Sept.
{% asset_img "Blob file list.png" "Blob files in the folder" %}

Something keep in mind: 
- The date and time are UTC and are when the telemetry was deposited in the store - not the time it was generated.
- Each blob is a text file that contains multiple '\n'-separated rows. 
- It contains the telemetry processed over a time period of roughly half a minute. It means that each folder will have about 100 to 120 files.
- Each row represents a telemetry data point such as a request or page view.
- Each row is an JSON document. The detailed data structure can be found at [here](https://azure.microsoft.com/en-us/documentation/articles/app-insights-export-data-model/).

With the nice [Azure Storage Account Explorer](http://storageexplorer.com/), it is pretty easy to check the content of the blob file.
{% asset_img "Page view record in blob file.png" "" %} 
Please note that Application Insights also implemented the same logic as [IP Anonymization](https://support.google.com/analytics/answer/2763052?hl=en) in Google Analytics. For all IP address that is collected by Application Insights, last octagon is anonymized to 0 (you can see the highlighted in above screenshot). 

# Transfer and store the data#
They are many ways to transfer the data out from storage account. Here we are going to use [Streaming Analytics](https://azure.microsoft.com/en-us/services/stream-analytics/).

Once the streaming analytic instance was created, setup the inputs. We will need 2 inputs for both Availability and PageViews. This is because their data structures are different, and requires different handling.

## Setup inputs ##

### Talk about the Path Pattern first ###
According to [the document](https://azure.microsoft.com/en-us/documentation/articles/app-insights-export-power-bi/), the **Path Pattern** property of input should follow format (yourApplicationInsightName)_(yourkey)/(yourTelemtryType)/*{date}/{time}*.

Firstly, the *(yourApplicationInsightName)_(yourkey)* part can be simply copied from the storage account page. 
{% asset_img "Path in storage account.png" "Path in storage account" %}

Secondly, please note that the *yourTelemtryType* (in this case, PageViews and Availability) is case sensitive!

Finally, make sure the date format is "YYYY-MM-DD", not the default "YYYY/MM/DD". 

### Input of PageViews and Availability ### 
{% asset_img "setup input.png" "setup input" %} 

### Test the sample data ###
You should always verify the input settings by test the sample data. For example, if we forgot the set data format, you will get below error.
{% asset_img "Error in sampling input data.png" "Error in sampling input data" %} 

** Keep the downloaded sample data for later usage **
{% asset_img "Download sample data.png" "Download sample data" %}

Error message:
*No events found for 'ai-pageviews'. Start time: Thursday, September 29, 2016, 1:00:00 AM End time: Friday, September 30, 2016, 1:00:00 AM Last time arrival: Thursday, January 1, 1970, 1:00:00 AM Diagnostics: While sampling data, no data was received from '1' partitions.*

## Setup outputs ##
### Create an Azure SQL database ###
Let's create an Azure SQL database. In this case I have created one with the cheapest plan: 40 NOK/Month, and up to 2GB storage. 
Make sure you setup the firewall that allows
- Azure service access. It will be used by Streaming Analytic Job and Power BI.
- Your client IP address. You will need that for creating tables.
{% asset_img "Setup SQL DB and Firewalls.png" "Setup SQL DB and Firewalls" %} 
 
### Create table schema ###
According to the [telemetry data structure definition](https://azure.microsoft.com/en-us/documentation/articles/app-insights-export-data-model/), you can create a DB table that stores the telemetry data which you are interested.

#### Availability ####
Now let's create a table that stores [availability](https://azure.microsoft.com/en-us/documentation/articles/app-insights-export-data-model/#availability). 
You can follow above document, or simply have a look at the data you have, and only pickup the fields that you need, as below (Needed fields are highlighted)
{% asset_img "Needed fields in availability.png" "Needed fields in availability" %} 

```sql
CREATE TABLE [dbo].[ai-availability]
(
    [ID] varchar(50),
    timestamp datetime,
    name varchar(50),
    location varchar(50),
	message varchar(300),
	duration float,
    CONSTRAINT [PK_Source_availability] PRIMARY KEY CLUSTERED   
    (
    [ID] ASC  
    )
)
```

#### PageViews ####
{% asset_img "Needed fields in pageviews.png" "Needed fields in pageviews" %}
```sql
CREATE TABLE [dbo].[ai-pageviews]
(
    [ID] varchar(50),
    timestamp datetime,
    name varchar(50),
    url varchar(300),
    duration float,
	operation_Name varchar(100),
    device_type varchar(25),
    device_OS varchar(25),
    device_name varchar(25),
    device_model varchar(25),
    browser varchar(25),
    browser_version varchar(25),
    client_country varchar(25),
    client_province varchar(25),
    client_city varchar(25),
    CONSTRAINT [PK_Source_pageViews] PRIMARY KEY CLUSTERED   
    (
    [ID] ASC  
    )
)
```
### Setup outputs in Streaming Analytic ###
{% asset_img "setup output.png" "Setup output to SQL database" %}

## Setup transferring ##
Now we are ready to setup the transferring query.

At this moment, the new Azure portal does not support query test (always grayed out), so let's head to Azure classic portal, and test our query. 
The detailed input data structure can be found in the previously downloaded sample file.

{% asset_img "Sample content.png" "Sample content" %} 

### Setup query ###
Below query will transfer telemetry data of both Availability and Pageviews.
```sql
SELECT
    A.internal.data.id as ID
    ,GetRecordPropertyValue(GetArrayElement(A.[availability], 0), 'testTimestamp') as [TimeStamp]
    ,GetRecordPropertyValue(GetArrayElement(A.[availability], 0), 'testName') as name
    ,GetRecordPropertyValue(GetArrayElement(A.[availability], 0), 'runLocation') as location
    ,GetRecordPropertyValue(GetArrayElement(A.[availability], 0), 'message') as message
    ,GetRecordPropertyValue(GetRecordPropertyValue(GetArrayElement(A.[availability], 0), 'durationMetric'), 'value') as [Duration]
INTO
    [output-ai-availability]
FROM
    [input-ai-availability] A

SELECT
    P.internal.data.id as ID
    , P.context.data.eventTime as [TimeStamp]
    ,GetRecordPropertyValue(GetArrayElement(P.[view], 0),'Name') as Name
    ,GetRecordPropertyValue(GetArrayElement(P.[view], 0),'url') as url
    ,GetRecordPropertyValue(GetRecordPropertyValue(GetArrayElement(P.[view], 0),'durationMetric'), 'value') as [duration]
    ,p.context.operation.name as operation_name
    ,P.context.device.type as device_type
    ,P.context.device.osVersion as device_OS
    ,P.context.device.deviceName as device_name
    ,P.context.device.deviceModel as device_model
    ,P.context.device.browser as browser
    ,P.context.device.browserVersion as browser_version
    ,P.context.location.country as client_country
    ,P.context.location.province as client_province
    ,P.context.location.city as client_city
INTO 
    [output-ai-pageviews]
FROM [input-ai-pageviews] P

```

### Verify the query ###
Use the test function to ensure the query is OK.
{% asset_img "Test query with sample data.png" "Test query with sample data" %}

### Test run ###
Now it's time to have a test run: start your stream analytic job and pay attend to the input vs output numbers: they should be approximately 1:1.
{% asset_img "Stream analytic monitoring.png" "Stream analytic monitoring" %}
 
If not, check the logs:
{% asset_img "Error log in stream analytic job.png" "Error log in stream analytic job" %}

As you can see, the problem is the string we got from input is too long. A quick fix is to reduce the length during the transfering as below:
```sql
SELECT
    P.internal.data.id as ID
    , P.context.data.eventTime as [TimeStamp]
    ,SUBSTRING(GetRecordPropertyValue(GetArrayElement(P.[view], 0),'Name'), 1, 50) as Name
    ,SUBSTRING(GetRecordPropertyValue(GetArrayElement(P.[view], 0),'url'), 1, 300) as url
    ,GetRecordPropertyValue(GetRecordPropertyValue(GetArrayElement(P.[view], 0),'durationMetric'), 'value') as [duration]
    ,SUBSTRING(p.context.operation.name, 1, 100) as operation_name
    ,SUBSTRING(P.context.device.type, 1, 15) as device_type
    ,SUBSTRING(P.context.device.osVersion, 1, 15) as device_OS
    ,SUBSTRING(P.context.device.deviceName, 1, 15) as device_name
    ,SUBSTRING(P.context.device.deviceModel, 1, 15) as device_model
    ,SUBSTRING(P.context.device.browser, 1, 15) as browser
    ,SUBSTRING(P.context.device.browserVersion, 1, 20) as browser_version
    ,SUBSTRING(P.context.location.country, 1, 15) as client_country
    ,SUBSTRING(P.context.location.province, 1, 15) as client_province
    ,SUBSTRING(P.context.location.city, 1, 15) as client_city
INTO 
    [output-ai-pageviews]
FROM [input-ai-pageviews] P
```

Now you are done with the stream analytic part, and all telemetry data will be continuously exported to your Azure SQL database. 

# Visualize your data #
PowerBI is a good tool for data visualization and sharing.

Before we dive into PowerBI, we will have to do some preparation as below: 
## Creating a time series ##
In order to show the data in time series, we will have to create a temporary dataset, which contains hour-by-hour time series in last 7 days.
```sql
DROP FUNCTION PreviousHourSeries;
GO

CREATE FUNCTION PreviousHourSeries()
RETURNS @ret TABLE (HourlySeries datetime)
AS 
BEGIN

declare 
    @EndTime datetime = dateadd(HOUR, datediff(HOUR, 0, getdate()), 0),
    @StartTime datetime = DATEADD(DAY, -7, dateadd(HOUR, datediff(HOUR, 0, getdate()), 0)) --include previous 7 days    


;WITH cSequence AS
(
    SELECT
    @StartTime AS StartRange, 
    DATEADD(HOUR, 1, @StartTime) AS EndRange
    UNION ALL
    SELECT
    EndRange, 
    DATEADD(HOUR, 1, EndRange)
    FROM cSequence 
    WHERE EndRange <= @EndTime
    --WHERE DATEADD(HOUR, 0, EndRange) <= @EndTime
)
/* insert into tmp_IRange */
INSERT INTO @ret SELECT StartRange FROM cSequence  OPTION (MAXRECURSION 0);
RETURN;
END;
GO
```

## Start working on PowerBI ## 
1. You will connect PowerBI desktop to the Azure SQL database, includes pageviews and availability tables, plus the time series function.
{% asset_img "Connect tables from PowerBI.png" "Connect tables from PowerBI" %}
2. Format the timestamp column in a format that can join with time series table.
	{% asset_img "Add column in PowerBI.png" "Add column in PowerBI" %}
	You will have to remove the hours from the timestamp, such as
	Availability:  TimeStampInHourFormat = FORMAT('ai-availability'[timestamp], "yyyy-mm-dd HH:00")
	PageViews: TimeStampInHourFormat = FORMAT('ai-pageviews'[timestamp], "yyyy-mm-dd HH:00")
	PreviousHourSeries:  HourlySeriesInFormat = FORMAT([HourlySeries], "yyyy-mm-dd HH:00")  
3. Manage the relationship between them
4. Start creating charts. Remember to set HourlySeriesInFormat to "show item without data", and hide items that HourlySeriesInFormat is Blank (means it is out of the time series scope. It is too old)
      


 
 
