---
title: Data Lineage by using IOTA
date: 2018-03-21 11:22:13
tags:
- IOTA
- Data Linage
- Data Integrity
- IoT
- DLT
---
If we say "Data is the new oil", then [data lineage](https://en.wikipedia.org/wiki/Data_lineage) is an issue that we must to solve. Various data sets are generated (most likely by sensors), transferred, processed, aggregated and flowed from upstream to downstream. 

The goal of data lineage is to track data over its entire lifecycle, to gain a better understanding of what happens to data as it moves through the course of its life. It increases trust and acceptance of result of data process. It also helps to trace errors back to the root cause, and comply with laws and regulations.

{% asset_img "Data lineage visualization.png" "Example of data lineage visualization, for Report 1, 2 and 3" %}

You can easily compare this with the traditional supply chain of raw materials in manufacturing industry and/or logistic industry. However, compares to the traditional industries, data lineage are facing new challenges.

<!-- more -->

## Data lineage challenges ##
Some top challenges are:
- We are tracking logical entities (bits, files or data streams) instead of physical entities (coal, car parts or packages). 
- The granularity of data has much more detailed scale in IoT and Big Data world. One example is, tracking every single piece of coal from a carrier ship sounds crazy, but tracking every data signal from thousand sensors from the every same ship is quite common. 
- Also, protecting logical entities is even harder in the cyberspace, both in data transportation and storage.

In addition, 
- Data lineage is built on top of [data integrity](https://en.wikipedia.org/wiki/Data_integrity), which has to be solved first.
- We need a neutral and trustworthy 3rd-party for keeping both **data integrity** and **data lineage** information, as most likely the upstream (supplier) and downstream (consumer) are different organization.    
 
## Technologies ##
[Distributed Ledger Technology](https://en.wikipedia.org/wiki/Distributed_ledger) (DLT) shows its potential capacity to become the neutral and trustworthy 3rd party in data lineage world, as it has the following key features:
- Data Immutable 
- Decentralized 

But not all DLT are suitable for Big Data or IoT scenarios, when we have, for example, following requirements:
1. Need to use DLT to store large amount of data (e.g. data integrity information of thousand of sensors)
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

# Design principles #
Data integrity is the foundation of data lineage 
Can be addressed separately 
Data lineage verification is a self-service for the requester
All verification data should be available to public 
Data provider should not be bothered
Verification chain is one-way
Downstream is depending on upstream
Upstream has no knowledge of downstream
Data lineage verification is an add-on on the side of the main data flow
It means that data lineage will not impact the existing business process, nor become bottleneck
