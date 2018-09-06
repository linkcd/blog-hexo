---
title: 'Step by step: Data lineage solution design'
date: 2018-09-02 20:33:49
tags:
- IOTA
- Data Linage
- Data Integrity
- IoT
- DLT
- Distributed Ledger Technology
- Tangle
---
# Introduction #
If we say "Data is the new oil", then both [data integrity](https://en.wikipedia.org/wiki/Data_integrity) and [data lineage](https://en.wikipedia.org/wiki/Data_lineage) are key issues that we must solve. Various data sets are generated (most likely by sensors), transferred, processed, aggregated and flowed from upstream to downstream. 

The goal of data lineage is to track data over its entire lifecycle, to gain a better understanding of what happens to data as it moves through the course of its life. It increases trust and acceptance of result of data process. It also helps to trace errors back to the root cause, and comply with laws and regulations.

{% asset_img "Data lineage visualization.png" "Example of data lineage visualization, for Report 1, 2 and 3" %}

You can easily compare this with the traditional supply chain of raw materials in manufacturing industry and/or logistic industry. However, compares to the traditional industries, data lineage are facing new challenges.

# Example 
Let's look at an example.

Alice is sending messages (ie. files) to Bob. The messages were sent via insecure channel, such as http-based data transfer, ftp, file share or even an usb stick.

{% asset_img "Alice sends msg to Bob.png" "Alice sends msg to Bob" %}

## Basic requirements:
There are 2 basic requirements for any data communication:
**1. The messages were not tampered by man-in-the-middle.**
**2. The messages that Bob received, are indeed from Alice.**

There are mainly 2 ways to ensure it, such as encryption and/or hashing. (A nice articles for comparing hashing and encryption can be found at [here](https://www.ssl2buy.com/wiki/difference-between-hashing-and-encryption).)

## Iteration #1
In iteration 1 we focus on solving requirement #1: *The messages were not tampered by man-in-the-middle.* We either use encryption or hashing.

#### 1.1 Using Encryption (with symmetric or asymmetric key)
{% asset_img "Sending msg with encryption.png" "Sending msg with encryption" %}
- **Pro**: With encryption is pretty straight forward: Either use symmetric or asymmetric key, Alice and Bob can encrypt and decrypt messages without worrying data tampering. 
- **Con**: However, this requires key management, both for Alice and Bob.

#### 1.2 Using Hashing
{% asset_img "Sending msg with hash.png" "Sending msg with hashing" %}
- **Pro**: Does not require key management for both Alice and Bob.
- **Con**: With hashing, it requires an additional data flow for passing hash values from Alice to Bob. It actually requires the same security mechanism as the normal data flow. 

We can address the Con by introducing a trusted area for Alice. For example, Alice also publish the hash values of the messages on https://alice.com. Bob can verify the message by compare the hash values. It is also OK to make the trusted area public, as  hash value is irreversible - nobody can obtain the data by using the hash value, they can only check the message integrity. 

This solution is sort of adding a secured "safeguard" track on the side, to help verifying the data flowing in the insecure channel. 

{% asset_img "Sending msg with hash with trust area.png" "Sending msg with hash with trust area" %}
- **Pro**: Does not require key management for both Alice and Bob. Solved the problem for protecting hash value data flow.

## Iteration #2
In iteration #2, in additional to requirement #1, we also need to also fulfill requirement #2:  *The messages that Bob received, are indeed from Alice.*

#### 2.1 Using Encryption (with Asymmetric key)  
This normally requires asymmetric encryption: Alice encrypts the message with her private key, and Bob decrypts it with Alice's public key.  Therefore Bob is confident that Alice is the message author. 
{% asset_img "Sending msg with asymmetric encryption.png" "Sending msg with asymmetric encryption" %}

#### 2.2 Using Hashing (with a trusted area), same as iteration #1
Hashing solution with a trusted area can also meet this requirement, simply counting on ONLY Alice can write into the trusted area.
{% asset_img "Can trust message with hash.png" "" %}

## Conclusion of iteration #1 and #2
For ensuring the basic requirements, both solutions work:
- Using Encryption (with asymmetric key), and
- Using Hashing (with trusted area)


## Challenge of Immutable History
Now we introduce a interesting but real challenge: **Once Alice sent out a message, she cannot deny the message was sent out, the message's origin nor the original content**.

It can be explained by the following example:
{% asset_img "Bobs problem.png" "Bobs problem" %} 
(click to enlarge the picture)

At this point, these above solutions that we have so far cannot help Bob. For example, Alice can replace both the message and the hash value in [https://alice.com](#).  

{% asset_img "Alice replaces both message and its hash.png" "Alice replaces both message and its hash" %} 

We need a solution that provides Bob an immutable traceability back to the message sender (also known as **data provider**). It of course provides benefits for data consumer (Bob)， but if data provider (Alice) can offer it, it also increase the acceptance and value of the **data service** (Alice).



## Iteration #3


But if we can make the stored hash value immutable, Bob's problem can be solved. 






The immutable data store can be the Distributed Ledger Technology (DLT).

{% asset_img "Hashing solution with dlt.png" "Hashing solution with dlt" %} 

