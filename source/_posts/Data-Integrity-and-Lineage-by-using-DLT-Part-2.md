---
title: Data Integrity and Lineage by using DLT, Part 2
date: 2018-10-03 20:14:40
tags:
- IOTA
- Data Lineage
- Data Integrity
- IoT
- DLT
- Distributed Ledger Technology
- Tangle
---

In previous article, we have discussed different approaches for solving the data integrity and lineage challenges, and concluded that the "**Hashing with DLT**" solution is the direction we will move forward. In this article, we will have deep dive into it.

## Which DLT to select?
There are many available DLT platforms nowadays, but not all of them are suitable for Big Data or IoT scenarios, such as:
1. We are tracking logical data entities (bits, files or data streams) instead of physical entities (coal, car parts or packages).
2. The granularity of data has much more detailed scale in IoT and Big Data world. One example is, tracking every single piece of coal from a carrier ship sounds crazy, but tracking every data signal from thousands sensors from the very same ship is quite common. 
2. We need to use DLT to handle large volume of transactions within a short time period (e.g. send 1000 data points from one device to another device per minute) 
3. We need to use DLT to store large amount of data (e.g. data integrity information of thousands of sensors)
4. Cannot afford high transaction fee

## IOTA - the selected DTL for exploring 
Therefore, [IOTA](https://www.iota.org) becomes an outstanding DTL compares to other platforms, by offering the following key features:
1. Higher performance and scalability: Thanks to tangle data structure
2. Zero Transaction Fee: Machine to Machine micropayments. This way machines can pay each other for certain services and resources.


*This is not an article of introducing IOTA, but you can learn more from https://www.iota.org*

In addition, it provides a protocol named [Masked Authenticated Messaging (MAM)](https://blog.iota.org/introducing-masked-authenticated-messaging-e55c1822d50e) that easily fit into our solution. 
1. One person or application creates a private seed (such as private key). The seed shall not be shared with others.
2. One seed can create one unique MAM channel in IOTA tangle, then write messages into it.
3. The messages contain data such as json objects.
4. The private seed ensures that only the seed owner is authorized to write messages in the channel. Therefore the origin of the messages is trusted by others.
5. Once the message was written into channel, the message is replicated and stored in all nodes in DLT. It means the message is immutable.
6. The message can be fetched from MAM by using the MAM address.
7. Once you know a MAM address in the channel, you can go through all addresses (and fetch their messages) that follows the known address.  

Therefore, Alice can publish the hash values like the following diagram 
{% asset_img "Hashing with MAM channel.png" "" %}

### Sample code for sending MAM message to channel 
There is a sample code for sending message into IOTA tangle at https://github.com/linkcd/IOTAPoC/blob/master/tangleWriter.js from [my repository](https://github.com/linkcd/IOTAPoC).

This code simply:
1. Generates a random seed and create a public MAM channel
2. Accepts inputs from keyboard and send it to tangle as json format
3. Once the message was sent do tangle, anyone can query the tangle and read it from the public channel. But none can change it since it is immutable. You can read the MAM message by using a good tool https://thetangle.org/mam.

{% asset_img "MAM sample code.png" "Sample code for sending message to IOTA tangle" %}


# Design principles and conceptual entities
First, lets agree some design principles and conceptual entities
## 1. Self-service verification process
The verification process of both data integrity and data lineage should be self-service. It means that all verification information should be available to public. Data provider should not be bothered by this process. 
*(Technically it is possible to have permission control of the verification process, it means that data provider has to response to the ad-hoc verification requests)*

## 2. Data lineage verification is an add-on on the side of the main data-flow 
It means that data lineage will not impact the existing data flow, nor become bottleneck. 

## 3. Conceptual entities
### 3.1 Data Source 
- A sensor, person, application that generates data package (s)
- Has 0 or more inputs (upstream data source)
- Has 1 or more outputs (downstream data source)
- A company can have more than one data sources

### 3.2 Data Package 
An atomic unit in data flow from one data source to another data source. For example:
- A data point (23 degree at 10:30am), or
- A file (json, xml)
- Files (1.json, 2.json…10.json…)
- Data rows in a database (row #1 to row #10 in table “employee”)

### 3.3 Data Package Id 
The unique ID of a data package in the scope of a data source. A typical data package id is a number, a GUID or a time-stamp.

### 3.4 Data Stream 
Data stream is data package series from the same data source. It contains more than more packages and their IDs.

# Solution Part 1: Data Integrity
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


# resources #
### Masked Authenticated Messaging (MAM) ###
Masked Authenticated Messaging (MAM) was introduced by IOTA in Nov 2017. The high level description can be found at [here](https://blog.iota.org/introducing-masked-authenticated-messaging-e55c1822d50e).
Besides, some deep dive information of Tangle transaction and MAM can be found at:
- [IOTA: MAM Eloquently Explained](https://medium.com/@abmushi/iota-mam-eloquently-explained-d7505863b413)
- [IOTA blogs by Louie Lu](https://blog.louie.lu/category/crypto/iota/) (in Chinese)
- [IOTA research group](https://hackmd.io/c/rkpoORY4W/%2Fs%2Fr1r3gowFf) (in Chinese)
- Javascript lib of MAM: https://github.com/iotaledger/mam.client.js 
- [MAM deep dive (youtube)](https://www.youtube.com/watch?v=Nnwn_o_ZBFU)