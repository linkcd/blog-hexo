---
title: Data Integrity and Lineage by using DLT, Part 3
date: 2019-01-03 11:08:30
tags:
- IOTA
- Data Lineage
- Data Integrity
- IoT
- DLT
- Distributed Ledger Technology
- Tangle
---

**Other articles in this series:**
- [Part 1](http://feng.lu/2018/09/25/Data-Integrity-and-Lineage-by-using-DLT-Part-1/)
- [Part 2](http://feng.lu/2018/10/03/Data-Integrity-and-Lineage-by-using-DLT-Part-2/) 
- Part 3 (this article)

# Recap
In the second part of this series, we have went though both the detailed technical design that is based on IOTA. Some quick recap are:
1. Use MAM protocol for interacting with IOTA Tangle.
2. Defined the core data schema (4 mandatory fields: "dataPackageId", "wayOfProof" , "valueOfProof" and "inputs"). 

Although the core data schema is quite easy to implement, companies and developers might meet some challenges to get started, such as:
1. Developers need to build the knowledge of IOTA and MAM protocol.
2. Need to build user interface for data lineage visualization.
3. Companies most likely need to setup and maintain their dedicated infrastructure (Web server that runs IOTA server code, database, resource to perform Proof-of-Work, connection to neighbor nodes in IOTA network, etc), as public nodes from community are not stable.  


# Data Lineage Service - an open source application to get you started 
We want to address above challenges, and help everyone to gain benefits of data integrity and lineage. Therefore, we have built "**Data Lineage Service**" application. Developer and companies can apply this technology without deep understanding of IOTA and MAM protocol. It can be used either as a standalone application, or a microservice that integrates with existing systems.

The key functions are:
- Wrapped IOTA MAM protocol to well-known HTTP(s) protocol as standard Restful API, with swagger definition. Developers do not need to worry about MAM protocol and it technical details, but focus on the normal data pipeline.
- Reusable web interface for lineage visualization.
- User-friendly interface for submitting data integrity and lineage information to DLT.
- Built-in functionalities for addressing common issues such as caching and monitoring.
- It is [open-sourced on github](https://github.com/veracity/data-lineage-service) with MIT license.

Also, for one who simply wanna try it out in the live environment, we are hosting this service that connects to the live DLT environment (IOTA tangle mainnet). 

As a live environment, it allows anyone to:
- Submit and receive integrity/lineage information with the live IOTA tangle mainnet, without maintain his/her own infrastructure.
- Outsource Proof-of-work (PoW) from clients to the service. Our host environment is taking care of the PoW on the server side. It helps IoT devices with low computing power (such as Raspberry PI) to submit information to DLT without consuming local resource. This also helps to improve the submission throughput (Number of submission per second). 
- All functions can be done via either web browser or restful APIs.
- **Zero cost** for testing and building Proof-of-Concept applications with real-world DLT. 

## Source code
https://github.com/veracity/data-lineage-service

## Live environment
https://datalineage-viewer.azurewebsites.net
This live environment is backed by our dedicated infrastructure (IOTA node). We hope to provide more stable connection to IOTA mainnet, but there is no service level agreement yet.

# Real world demo - real-time data integrity on IoT device
By using this service, an IoT device can ensure the integrity of its IoT data stream. As a demo, I have a raspberry pi with [sense hat](https://www.raspberrypi.org/products/sense-hat/) that is reporting temperature as well as saving the integrity information to DLT. The integrity information can be read at [here](https://thetangle.org/mam/UZFQPIFSPRNEXLGYLKQIFUZNZWLSQCUWBFHRWLBJDKIANJLKRMEYAMEPFEFHQBTENPSLPQBKKCVGYLMUN) from DLT. 
{% youtube uL5f_d1Np20 %}
Therefore, the data consumer of this temperature sensor can be confident that:
- the temperature report (and the report timestamp) is not tampered  
- it is indeed from *this* raspberry pi 
- this data integrity information can be included into the downstream data lineage

The source code of this demo is at https://github.com/linkcd/data-integrity-on-pi


# Closer look at 
g
# Demo and source code

# Performance test result

# Known issues and how DILaaS helps

 







1. Standard http(s) protocol for any developers to submit/receive data integrity and lineage information, without dealing with MAM protocol. As far as the developer knows HTTP(s) API and JSON format, he/she is ready to build data integrity and lineage into the product
2. A basic data lineage visualization that can be reused in different applications.

In addition, for addressing challenge #3, we are also managing our dedicated IOTA node and host the web application on the top of it.



You can start trying submit and receive data integrity and lineage information via APIs from at https://datalineage-viewer.azurewebsites.net/swagger/ 

 

-------------------------------------------------------------------------------------------


4. Managing seeds for data sources in a secure manner.


In veracity we are researching and building **Data Integrity and Lineage as a Service (DILAAS)**  to bring down the barriers for both data providers and data consumers. DILAAS offers:
1. A cloud service for managing and exchanging data integrity and lineage information between parties.
2. Standard HTTP API, without building competence of backend DLT, such as MAM programming. It helps to reduce the development cost and boost the onboard progress.
3. Visualization of data integrity and lineage information.
4. Managed infrastructure that offers stable IOTA network accessibility. 
4. Seed/Identity management, for properly managing the seeds/identifies in the secure environment.



  