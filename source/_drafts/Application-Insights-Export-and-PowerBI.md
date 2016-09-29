---
title: Application Insights Export and PowerBI
tags:
  - Azure
  - Application insights
  - Monitoring
  - PowerBI
  - DevOps
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
According to the document, the **Path Pattern** property of input should follow format yourApplicationInsightName)_(yourkey)/(yourTelemtryType)/*{date}/{time}*.

The *gateway-appinsight-production_(the key)* part can be simply copied from the storage account page. 
{% asset_img "Path in storage account.png" "Path in storage account" %}

However, due to some unknown reason, if you specify *{date}/{time}*, it always failed to get input. 

{% asset_img "Error in sampling input data.png" "Error in sampling input data" %} 

Error message:
*No events found for 'ai-pageviews'. Start time: Thursday, September 29, 2016, 1:00:00 AM End time: Friday, September 30, 2016, 1:00:00 AM Last time arrival: Thursday, January 1, 1970, 1:00:00 AM Diagnostics: While sampling data, no data was received from '1' partitions.*

Fortunately, as we need ALL telemetry data at anytime, the workaround is to remove the *{date}/{time}* part. So, the new Path Pattern is "(yourApplicationInsightName)_(yourkey)/(yourTelemtryType)/"

### Input of PageViews and Availability ### 
{% asset_img "setup input.png" "setup input" %} 

Path Pattern: 
	- PageViews: *gateway-appinsight-production_(the key)/PageViews/*
	- Availability: *gateway-appinsight-production_(the key)/Availability/*

You can also make sure that these inputs are correct by testing the sample data.

## Setup outputs ##

### Create an Azure SQL database ###

### Create table schema ###


## Setup transferring ##



### Input of Availability ###

# Play with the data #



Today in MyDNVGL we are using two systems for monitoring the performance of MyDNVGL, especially the API.
- [Keen.IO](https://keen.io)
- Azure toolset
 - Application Insight
 - Storage account
 - Streaming Analytics
 - Azure SQL database
 - Power BI

### Comparison
| | Keen.IO | Application Insight | Azure toolset | 
|---|:---:|:---:|:---:| 
| Track custom events| x |x| x (1) | 
| Track .Net runtime performance |  |x | x (1) |
| Availability test| | x | x (1) |
| Proactive alert | | x | x (1) |
| Historical data| x || x (2) |
| self-service dashboard | x | x | x (1,3) |

    (1) Application Insight
    (2) Storage Account + Streaming Analytics + Azure SQL database
    (3) Power BI (desktop or web)

### Price (per month)
| | Keen.IO | App Insight | Azure toolset incl. App Insight| 
|---|---:|---:|---:|
|100k|$20|0|$28|
|1m|$125|0|$28|
|4m|$300|0|$28|
|8m|$600|$24,5|$64|
|15m|$1000|$24,5|$64| 
|30m|?|$50,8|$91|
|50m|?|$99,5|$155|
|70m|?|$134,5|$191|
Note: If we go with PowerBI Pro, the extra cost will be $9.99 per person per month

ref:
 - Calculator  is at [here](https://dnvgl-gssit.visualstudio.com/MyDNVGL/_git/MyDNVGLAnalysis?path=%2FAzure%20price.xlsx&version=GBmaster&_a=contents)
 - https://keen.io/plans/self-service/
 - https://azure.microsoft.com/en-us/pricing/details/application-insights/
 - https://azure.microsoft.com/en-us/pricing/details/storage/blob/
(Note: In azure, 1 event data size is about 1kb, therefore 1m event is about 1GB.)
 - https://azure.microsoft.com/en-us/pricing/details/stream-analytics/
 - https://azure.microsoft.com/en-us/pricing/details/sql-database/
 - https://powerbi.microsoft.com/en-us/pricing/

#Using Application Insight
## Setup Application Insight
1. In VS2015 (update 3), right click below web projects for adding Application Insight support, which will automatically added Nuget packages for Application Insight.
 * Web
 * MyWebAPI
2. Create Application Insight instance in environment corresponding  resource group in Azure. Each resource group has two instances for tracking above 2 web application separately.
3. Ensure in source code we are reading correct instrumentation keys.

*Note that currently we are manually creating all resource groups and services instance such as Application Insight and Streaming Analytics. It can be improved by using Infrastructure as Code approach.*

## Benefits of using Application Insight
Out of box support:
- Track .Net runtime performance
- Track custom events (require application code update. It was done by [task3203](https://dnvgl-gssit.visualstudio.com/MyDNVGL/_workitems?id=3203) and [task3316](https://dnvgl-gssit.visualstudio.com/MyDNVGL/_workitems?id=3316)
- Availability test (require creation of web testing scripts. The scripts in in MyDNVGLAnalytics solution)
- Alert service
- Self-service dashboard and analytic tools

## Limitation of Application Insight
Limited historical data storage, regardless plan 
- Raw data: 7 days
- Aggregated data: 90 days
 

# Enable historical data for Application Insight
To overcome the 7/90 day limitations of Application Insight, we can 
1. The Export button at the top of a metrics or search blade lets you transfer tables and charts to an Excel spreadsheet. 
2. Analytics provides a powerful query language for telemetry, and also can export results. (Currently only support 7 days raw data)
3. Enable Continuous Export (**Selected approach**)

## Setup telemetry data export to Azure SQL database
- Enable continuous export to a storage account https://azure.microsoft.com/en-us/documentation/articles/app-insights-export-telemetry/
- Setup a streaming analytic job for transferring data from storage account to a Azure Database (can follow steps in https://azure.microsoft.com/en-us/documentation/articles/app-insights-export-power-bi/)
- Notes:
 - Input: it was named as "input". The **path prefix pattern** is "(yourApplicationInsightName)_(yourkey)/Event/". For now i cannot specify  the data and time without error.
 - Query for custom event: 
        SELECT
        A.internal.data.id as ID
        , A.context.data.eventTime as EventTime
        ,GetRecordPropertyValue(GetArrayElement(A.context.custom.dimensions, 0),'ElapsedMilliseconds') as ElapsedMilliseconds
        ,GetRecordPropertyValue(GetArrayElement(A.context.custom.dimensions, 1),'AbsoluteUri') as AbsoluteUri
        ,GetRecordPropertyValue(GetArrayElement(A.context.custom.dimensions, 2),'UserId') as UserId
        ,GetRecordPropertyValue(GetArrayElement(A.context.custom.dimensions, 3),'Action') as Action
        ,GetRecordPropertyValue(GetArrayElement(A.context.custom.dimensions, 4),'AccountId') as AccountId
        ,GetRecordPropertyValue(GetArrayElement(A.context.custom.dimensions, 5),'ContractName') as ContractName
        ,GetRecordPropertyValue(GetArrayElement(A.context.custom.dimensions, 6),'AccountName') as AccountName
        INTO 
        [mywebapi-ai-event-output]
        FROM [input] A
 
 - Query for pageviews:
        SELECT
        A.internal.data.id as ID
        , A.context.data.eventTime as EventTime
        ,GetRecordPropertyValue(GetArrayElement(A.[view], 0),'Name') as Name
        ,GetRecordPropertyValue(GetArrayElement(A.[view], 0),'url') as url
        ,GetRecordPropertyValue(GetRecordPropertyValue(GetArrayElement(A.[view], 0),'durationMetric'), 'value') as [duration]
        ,A.context.device.type as device_type
        ,A.context.device.osVersion as device_OS
        ,A.context.device.deviceName as device_name
        ,A.context.device.deviceModel as device_model
        ,A.context.device.browser as browser
        ,A.context.device.browserVersion as browser_version
        ,A.context.location.continent as client_continent
        ,A.context.location.country as client_country
        ,A.context.location.province as client_province
        ,A.context.location.city as client_city
        INTO 
        [pageviews-output]
        FROM [pageviews-input] A
        
        *Sometimes you got weird maxlength issue, therefore there is another workaround*
        SELECT
        A.internal.data.id as ID
        , A.context.data.eventTime as EventTime
        ,SUBSTRING(GetRecordPropertyValue(GetArrayElement(A.[view], 0),'Name'), 1, 50) as Name
        ,SUBSTRING(GetRecordPropertyValue(GetArrayElement(A.[view], 0),'url'), 1, 300) as url
        ,GetRecordPropertyValue(GetRecordPropertyValue(GetArrayElement(A.[view], 0),'durationMetric'), 'value') as [duration]
        ,SUBSTRING(A.context.device.type, 1, 15) as device_type
        ,SUBSTRING(A.context.device.osVersion, 1, 15) as device_OS
        ,SUBSTRING(A.context.device.deviceName, 1, 15) as device_name
        ,SUBSTRING(A.context.device.deviceModel, 1, 15) as device_model
        ,SUBSTRING(A.context.device.browser, 1, 15) as browser
        ,SUBSTRING(A.context.device.browserVersion, 1, 20) as browser_version
        ,SUBSTRING(A.context.location.continent, 1, 15) as client_continent
        ,SUBSTRING(A.context.location.country, 1, 15) as client_country
        ,SUBSTRING(A.context.location.province, 1, 15) as client_province
        ,SUBSTRING(A.context.location.city, 1, 15) as client_city
        INTO 
        [pageviews-output]
        FROM [pageviews-input] A


 - Output: It was named as "mywebapi-ai-event-output". The output of this job is not PowerBI but a Azure database. You will have to manually create the target table
        DROP table [dbo].[mywebapi-ai-events]
        CREATE TABLE [dbo].[mywebapi-ai-events]
        (
            [ID] varchar(50),
            EventTime varchar(50),
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
        
        DROP table [dbo].[mygateway-ai-pageviews]
        CREATE TABLE [dbo].[mygateway-ai-pageviews]
        (
            [ID] varchar(50),
            EventTime datetime,
            name varchar(50),
            url varchar(300),
            duration float,
            device_type varchar(15),
            device_OS varchar(15),
            device_name varchar(15),
            device_model varchar(15),
            browser varchar(15),
            browser_version varchar(20),
            client_continent varchar(15),
            client_country varchar(15),
            client_province varchar(15),
            client_city varchar(15),
            CONSTRAINT [PK_Source_pageViews] PRIMARY KEY CLUSTERED   
            (
            [ID] ASC  
            )
        )



# Analytics
 - Application Insight OOTB dashboard (see Application Insight blade in Azure portal) 
 - Application Insights Analytics tool (see https://azure.microsoft.com/en-us/documentation/articles/app-insights-analytics/) 
 - PowerBI
 
## Using PowerBI
You can use 
- PowerBI desktop, then upload to web
- PowerBI web 

### Creating a time series
In order to show the data in time series, we will have to create a temporary dataset, which contains hour-by-hour time series in last 2 days.
    DROP FUNCTION PreviousHourSeries;
    GO

    CREATE FUNCTION PreviousHourSeries()
    RETURNS @ret TABLE (HourlySeries datetime)
    AS 
    BEGIN

    declare 
        @EndTime datetime = dateadd(HOUR, datediff(HOUR, 0, getdate()), 0),
        @StartTime datetime = DATEADD(DAY, -2, dateadd(HOUR, datediff(HOUR, 0, getdate()), 0)) --include previous 2 days    


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

###Start working on PowerBI
1. You will connect PowerBI desktop to Azure SQL database, at least to connect below 2 datasets: The event table and the time series table.
2. Format the eventTime column in a format that can join with time series table. You will have to remove the second part in the time, such as
      In event dataset, added a new column as: EventTimeInHourFormat = FORMAT([EventTime]; "yyyy-mm-dd HH:00")
      
      In timeseries dataset, add the a column with the same format as above:  HourlySeriesInFormat = FORMAT([HourlySeries]; "yyyy-mm-dd HH:00") 
3. Manage the relastionship between these 2 datasets
4. Start creating charts. Remember to set HourlySeriesInFormat to "show item without data", and hide data that HourlySeriesInFormat is Blank (means it is out of the timeseries scope. too old)
      


 
 
