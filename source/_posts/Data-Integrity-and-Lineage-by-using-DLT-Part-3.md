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
We want to address above challenges, and help everyone to gain benefits of data integrity and lineage. Therefore, we have built "**Data Lineage Service**" application. Developers and companies can apply this technology without deep understanding of IOTA and MAM protocol. It can be used either as a standalone application, or a microservice that integrates with existing systems.

The key functions are:
- Wrapped IOTA MAM protocol to well-known HTTP(s) protocol as standard Restful API, with swagger definition. Developers do not need to worry about MAM protocol and it technical details, but focus on the normal data pipeline.
- Reusable web interface for lineage visualization.
- User-friendly interface for submitting data integrity and lineage information to DLT.
- Built-in functionalities for addressing common issues such as caching and monitoring.
- It is [open-sourced on github](https://github.com/veracity/data-lineage-service) with MIT license.

<!-- more -->

Also, for one who simply wanna try it out in the live environment, we are hosting this service that connects to the live DLT environment (IOTA tangle mainnet). 

As a live environment, it allows anyone to:
- Submit and receive integrity/lineage information with the live IOTA tangle mainnet, without maintain his/her own infrastructure.
- Outsource Proof-of-work (PoW) from clients to the service. Our host environment is taking care of the PoW on the server side. It helps IoT devices with low computing power (such as Raspberry PI) to submit information to DLT without consuming local resources. This also helps to improve the submission throughput (Number of submission per second). 
- All functions can be done via either web browser or restful APIs.
- **Zero cost** for testing and building Proof-of-Concept applications with real-world DLT. 

## Source code of Data-Lineage-Service
The source code is hosted in Github: https://github.com/veracity/data-lineage-service

## Live environment
The live demo environment can be found at https://datalineage-viewer.azurewebsites.net
This live environment is backed by IOTA public network (public IOTA nodes). Feel free to use it (either GUI or API swagger) to store your integrity and lineage data into IOTA mainnet, as well as visualize the existing data. 

The API Swagger is at https://datalineage-viewer.azurewebsites.net/swagger/ 

Screenshot:
{% asset_img "datalineage-screenshot.png" "Screenshot of data lineage view" %}

## Real World Demo: Real-time data integrity on IoT device
By using this service, an IoT device can ensure the integrity of its IoT data stream. As a demo, I have a raspberry pi with [sense hat](https://www.raspberrypi.org/products/sense-hat/) that is reporting temperature as well as saving the integrity information to DLT. The integrity information can be read at [here](https://thetangle.org/mam/UZFQPIFSPRNEXLGYLKQIFUZNZWLSQCUWBFHRWLBJDKIANJLKRMEYAMEPFEFHQBTENPSLPQBKKCVGYLMUN) from DLT. 
{% youtube uL5f_d1Np20 %}
Therefore, the data consumer of this temperature sensor can be confident that:
- the temperature report (and the report timestamp) is not tampered  
- it is indeed from *this* raspberry pi 
- this data integrity information can be included into the downstream data lineage

The source code of this demo is at https://github.com/linkcd/data-integrity-on-pi

# Performance testing and results
From day 1, the performance of DLT is a known issue. By expanding this technology into the IoT and real-time data exchanging world, the performance can be a blocking issue. This is also the reason that we started look into IOTA in the beginning, hope its performance can meet the need.

We have conducted the performance testing in 3 iterations:
1. Using a public IOTA node
2. Using our own self-hosted IOTA node
3. Using self-hosted IOTA node but outsource the PoW to https://powsrv.io/

In each iteration, we tested performance both for reading and writing. The testing code is also open-sourced at github https://github.com/veracity/IOTA-MAM-performance-testing

**Test results (on 20.09.2018)**
{% asset_img "Performace testing.png" "Performance testing" %}

**Conclusion**:
- Performance of **reading** is OK (0.5 second per read), as far as you have a stable IOTA node (either self-host or from a provider)
- Outsource the PoW to dedicated service providers such as powsrv.io can significantly improve the performance of **writing**, but the best result allows us to do about 15 transactions per minute. 

# Next step
In veracity we are researching and building **Data Integrity and Lineage as a Service (DILAAS)**  to bring down the barriers for both data providers and data consumers. DILAAS offers:
1. A cloud service for managing and exchanging data integrity and lineage information between parties.
2. Standard HTTP(s) API, without building competence of backend DLT, such as MAM programming. It helps to reduce the development cost and boost the onboard progress.
3. Visualization of data integrity and lineage information.
4. Managed infrastructure that offers stable IOTA network accessibility. 
4. Seed/Identity management, for properly managing the seeds/identifies in the secure environment.

**Other articles in this series:**
- [Part 1](http://feng.lu/2018/09/25/Data-Integrity-and-Lineage-by-using-DLT-Part-1/)
- [Part 2](http://feng.lu/2018/10/03/Data-Integrity-and-Lineage-by-using-DLT-Part-2/) 
- Part 3 (this article)


  