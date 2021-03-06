---
title: Data Integrity and Lineage by using IOTA
date: 2018-04-16 11:22:13
tags:
- IOTA
- Data Lineage
- Data Integrity
- IoT
- DLT
- Distributed Ledger Technology
- Tangle
---

### Edit log:###
2018.09.25
This article is now expanded to an article series, where we have more detailed discussion and open-source code, [check them out!](http://feng.lu/2018/09/25/Data-Integrity-and-Lineage-by-using-DLT-Part-1/)  

2018.08.26 - Updated the data schema:
1. Have an unified format that covers both lightweight format and standard format, but more flexible and self-explained.
2. Specified mandatory fields and optional field in the format. For example, Timestamp is now an optional field.

# Introduction #
If we say "Data is the new oil", then [data lineage](https://en.wikipedia.org/wiki/Data_lineage) is an issue that we must to solve. Various data sets are generated (most likely by sensors), transferred, processed, aggregated and flowed from upstream to downstream. 

The goal of data lineage is to track data over its entire lifecycle, to gain a better understanding of what happens to data as it moves through the course of its life. It increases trust and acceptance of result of data process. It also helps to trace errors back to the root cause, and comply with laws and regulations.

{% asset_img "Data lineage visualization.png" "Example of data lineage visualization, for Report 1, 2 and 3" %}

You can easily compare this with the traditional supply chain of raw materials in manufacturing industry and/or logistic industry. However, compares to the traditional industries, data lineage are facing new challenges.

<!-- more -->

## Data lineage challenges ##
Some top challenges are:
- We are tracking logical entities (bits, files or data streams) instead of physical entities (coal, car parts or packages). 
- The granularity of data has much more detailed scale in IoT and Big Data world. One example is, tracking every single piece of coal from a carrier ship sounds crazy, but tracking every data signal from thousands sensors from the very same ship is quite common. 
- Also, protecting logical entities is even harder in the cyberspace, both in data transportation and storage.

In addition, 
- Data lineage is built on top of [data integrity](https://en.wikipedia.org/wiki/Data_integrity), which has to be solved first.
- We need a neutral and trustworthy 3rd-party for keeping both **data integrity** and **data lineage** information, as most likely the upstream (supplier) and downstream (consumer) are different organization.    
 
## Technologies ##
[Distributed Ledger Technology](https://en.wikipedia.org/wiki/Distributed_ledger) (DLT) shows its potential capacity to become the neutral and trustworthy 3rd party in data lineage world, as it has the following key features:
- Data Immutable 
- Decentralized 

But not all DLT are suitable for Big Data or IoT scenarios, when we have, for example, following requirements:
1. Need to use DLT to store large amount of data (e.g. data integrity information of thousands of sensors)
2. Need to use DLT to handle large volume of transactions within a short time period (e.g. send 1000 data points from one device to another device per minute) 
3. Cannot afford high transaction fee

Therefore, IOTA becomes an outstanding DTL compares to other blockchain platform, by offering the following features:
1. Data Integrity/Security: All data cryptographically secured in a Tangle. This data can be made visible to certain parties.
2. Zero Transaction Fee: Machine to Machine micropayments. This way machines can pay each other for certain services and resources.
3. Full scalability: Thanks to tangle data structure 

*This is not an article of introducing IOTA, but you can learn more from https://www.iota.org/ and https://blog.iota.org and IOTA channel in Discord.*

But most importantly, it brings Masked Authenticated Messaging (MAM) which fits into our need for data integrity and data lineage.

### Masked Authenticated Messaging (MAM) ###
Masked Authenticated Messaging (MAM) was introduced by IOTA in Nov 2017. The high level description can be found at [here](https://blog.iota.org/introducing-masked-authenticated-messaging-e55c1822d50e).
Besides, some deep dive information of Tangle transaction and MAM can be found at:
- [IOTA: MAM Eloquently Explained](https://medium.com/@abmushi/iota-mam-eloquently-explained-d7505863b413)
- [IOTA blogs by Louie Lu](https://blog.louie.lu/category/crypto/iota/) (in Chinese)
- [IOTA research group](https://hackmd.io/c/rkpoORY4W/%2Fs%2Fr1r3gowFf) (in Chinese)
- Javascript lib of MAM: https://github.com/iotaledger/mam.client.js 
- [MAM deep dive (youtube)](https://www.youtube.com/watch?v=Nnwn_o_ZBFU)


# Solution Deep Dive # 

## Design principles ##
### 1. Data integrity is the foundation of data lineage ###
Data Integrity is the prerequisite of Data Lineage, and they can be addressed separately. 
{% asset_img "Data integrity lineage and trust.png" "Data lineage is built on top of data integrity" %}

### 2. Self-service verification process###
The verification process of both data integrity and data lineage should be self-service. It means that all verification information should be available to public. Data provider should not be bothered by this process. 
*(Technically it is possible to have permission control of the verification process, it means that data provider has to response to the ad-hoc verification requests)*

### 3. Data lineage verification is an add-on on the side of the main data-flow ###
It means that data lineage will not impact the existing data flow, nor become bottleneck. 


## Conceptual Entities ##
### Data Source ###
- A sensor, person, application that generates data package (s)
- Has 0 or more inputs (upstream data source)
- Has 1 or more outputs (downstream data source)
- A company can have more than one data sources

### Data Package ###
An atomic unit in data flow from one data source to another data source. For example:
- A data point (23 degree at 10:30am), or
- A file (json, xml)
- Files (1.json, 2.json…10.json…)
- Data rows in a database (row #1 to row #10 in table “employee”)

### Data Package Id ###
The unique ID of a data package in the scope of a data source. A typical data package id is a number, a GUID or a time-stamp.

### Data Stream ###
Data stream is data package series from the same data source. It contains more than more packages and their IDs.

## Solution Part 1: Data Integrity ##
**Goal: One can verify the integrity of data packages from a data source.**

### Step A. Data source creates a MAM channel for publishing integrity information ###
Data source creates a public MAM public channel by using its private seed. The private seed ensures only the the data source can publish information into that channel, and so the channel is trusted by others.

### Step B. Decide your integrity information content ###
In order to allow the consumer to verify the integrity, you need to provide enough information to make it possible. Therefore you need to decide what information should be stored in the tangle as json object.

#### Mandatory fields #### 
All object must have the following core fields. All of them are **mandatory**.
```json
{
	datapackageId: string,
	wayofProof:string,
	valueOfProof:string
}
```
| Field  | Description   | Example  |
|---|---|---|
| **datapackageId** | The package ID is used for querying the data lineage info from the channel. Data source decides the ID format, such as integer or GUID. Different channels can have the same package ID. |  "123456" |
| **wayofProof** | Information about how to verify the integrity based on valueOfProof. For example, it explains the used hash algorithms (SHA1 or SHA2 or others), or it simply copied the data package content into field valueOfProof.  | "SHA256(packageId, original-data-content)"  |
| **valueOfProof**  | The value of the proof, such as hash value, or the copy of the data content in clear text. | (hash value or data itself) |

**Case 1**
A temperature sensor decides to use timestamp as package Id, and since the data point is small and not confidential, it decides to put the data point as clear text in the integrity information object. 

Therefore, at 2012-08-29 11:38:22, the temperature is 20 degree. It sends the integrity json into its own MAM channel:
```json
{
	datapackageId: "1346236702",
	wayofProof:"copy of original data",
	valueOfProof:"20"
}
```
**Case 2**
An application generates big csv files and pass to the down stream. all csv files have an unique file name. Since we do not have do expose the csv file itself, either due to confidentiality or huge file size, it decides to use hash value in the integrity json. The hash function can be one of the [Secure Hash Algorithms](https://en.wikipedia.org/wiki/Secure_Hash_Algorithms), such as SHA-512/256. This application decide to hash the file content together with the filename.

therefore, for file with unique name "file075.csv", the application computed the hash based on **SHA256("file075.csv"+":"+filecontent.string())**, which is "8c20f3d24...43a6cfb7c4"
```json
{
	datapackageId: "file075.csv",
	wayofProof:"SHA256("file075.csv"+":"+filecontent.string())",
	valueOfProof:""8c20f3d24...43a6cfb7c4"
}
```

#### Use hash for reducing calls to tangle ###
The hash is also useful if you wanna reduce the data sent to tangle. For example, a data source is generating a small file per second. However, pushing data to tangle in every second can be a performance bottleneck. If the data source pack all files of every 10 minutes into one, assign an ID and compute the hash value of this data trunk, it can still publish integrity data into tangle but with much lower frequency.  

#### Extend it with optional fields #### 
In addition to the above mandatory fields, you can extend the json object by adding more additional fields for fitting your logic. 

For example, for case 1, you can add a field "location" for storing the location of that sensor, and "sensorType" of sensor type.  These fields will be tightly coupled with these core fields, and stored in the tangle.
```json
{
	datapackageId: "1346236702",
	wayofProof:"copy of original data",
	valueOfProof:"20",
	location:"Oslo",
	sensorType:"temperature sensor XY200",
	...
	additionalField:...
	...
}
```

**Note**
"timestamp" is not a mandatory field, as all transactions in Tangle already has a system timestamp shows when the data was submitted to the tangle. You can add "timestamp" field to store when the original data was collected.

### Step C. Data source send data integrity information to the channel ###
Data source sends data or hash value of the data to the MAM channel (IOTA tangle), it ensures:
1. Data verification information is immutable  
2. Can verify the integrity with or without have access to data itself (hash)
3. Performance is acceptable (assuming IOTA can handle large volume of data from devices)
4. No extra cost due to zero transaction fee

#### Demo code of sending MAM message to channel ####
You can have a look at the sample code of sending message into IOTA tangle at https://github.com/linkcd/IOTAPoC/blob/master/tangleWriter.js from [my repository](https://github.com/linkcd/IOTAPoC).

This code simply:
1. Generate a random seed and create a public MAM channel
2. Accept inputs from keyboard and send it to tangle as json format
3. Once the message was sent do tangle, everyone can query the tangle and read it. But none can change it since it is immutable. You can read the MAM message by using a good tool https://iota-mam-explorer.now.sh/.

{% asset_img "MAM sample code.png" "Sample code for sending message to IOTA tangle" %}


### Step D. Data source publish information of the channel ###
Data source publish (on web site or equivalent) the following information for anyone who wants to verify the integrity:
1. Root address of the MAM channel (NOT the private seed!)



### Step E. Data consumer to verify the integrity ###
If a data consumer would like to verify the data he/she got from the data source is not tampered, the consumer can:  
1. Obtain the MAM channel root address of the data source
2. read the "wayOfProof" to understand how to check the "valueOfProof" field. 
For example:
	- if "wayOfProof" is "copy of original data", then simply compare the value from tangle and value from received package.
	- if "wayOfProof" is "SHA256("file075.csv"+":"+filecontent.string())", the perform the same hash locally, the compare the result with the value from "valueOfProof"


## Overview of data integrity workflow ##
{% asset_img "Workflow.png" "Click to enlarge the workflow of data integrity" %}

## Solution Part 2: Data Lineage ##

### A case study ###
Lets look at an real life case: 

You as an American tourist was having an vacation in Norway. You were driving a car and had a great experience of the fjord. Unfortunately you had a small accident outside of a gas station, and the car windshield was damaged (but lucky, no one has been injured). The local police station was informed and issued a form (in Norwegian!) about this accident. 

Now you would like to report this to your insurance company. 
{% asset_img "Report an accident.png" "Report an accident" %}

Most likely the insurance company would like to know if they can trust the damage report. You can of course explain that the data flow is:
1. The police station in Norway issued a statement in Norwegian **"2018 20. februar 13:00: En liten bilulykke utenfor Esso bensinstasjon på Billingstadsletta 9, 1396 Billingstad. Bilskade: 5000 NOK."** 
2. Since the US based insurance company only accept documents in English, a translation provider helped to translated this statement from Norwegian to English: **"2018 Feb 20th, 13:00PM: A small car accident outside of Esso gas station at Billingstadsletta 9, 1396 Billingstad.Car damage: 5000 NOK. "**
3. The next step is to convert the currency **5000 NOK** to US Dollar, according to the currency rate of 2018 Feb 20th, as well as provide a map for describing the location of the accident. Therefore a currency converter and a geolocation service provider were involved for providing data. 

{% asset_img "How the report was created.png" "How the report was created" %}

If we can store and verify this flow (data lineage of the report), it will:
1. Provide full traceability of the end-to-end process
2. Save huge cost from insurance company by reducing the time consuming manual verification process
3. Immutable histories of all inputs of the report. It also help to identify responsibility of any false input.
4.   

### Solution Design ###
On the top of the data integrity layer that we discussed above, it is easy to extend the format to build the data lineage layer. 

Now we extend the format to include an optional field **inputs**, which is an array of MAM addresses. These addresses represent the data integrity information of all inputs of the current data package.  

Depends on if you have any input, **inputs** is optional. You can ignore this field, or have this field but the value is null.

#### Extent the format to include inputs ####
```json
{
	datapackageId: string,
	wayofProof:string,
	valueOfProof:string,
	inputs: [array-of-input-addresses],
	...
	additionalField:...
	...
}
```
By using the additional **inputs** field, it is easy to establish the follow data lineage flow:
{% asset_img "Data lineage flow.png" "Click to enlarge the data lineage flow" %}

It means that
1. The insurance company can verify the report#33 is indeed from the report generator and it was not tampered.
2. By following the inputs fields, the insurance company can also find all upstream and data origin in report#33, and verify the integrity of them as well.  
3. It also helps, for example, if there is a mistake of the currency convert from NOK to USD, it is the currency converter, not the report generator (customer), to take the responsibility. 

# Conclusion #  
Data integrity and data lineage play important roles in the coming data-first era. By using DLT, especially IOTA, it is possible to build the infrastructure of them. However, we have to keep in mind, even IOTA looks promising, it is under development, and it is not production ready. We will continue our investigation and collaboration with IOTA team/communities to continue this journey. 


    