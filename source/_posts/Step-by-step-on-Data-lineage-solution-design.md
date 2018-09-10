---
title: 'Step by step: Data lineage solution design'
date: 2018-09-02 20:33:49
tags:
- IOTA
- Data Lineage
- Data Integrity
- IoT
- DLT
- Distributed Ledger Technology
- Tangle
---
# Introduction #
Veracity is designed to help companies unlock, qualify, combine and prepare data for analytics and benchmarking. The data is from all type of sources, such as sensor and edge devices, production systems, historical databases and and human inputs. Data is generated, transferred, processed and stored, from one system to another system, one company to another company.

Given the complicity of the entire life-cycle of the data, both [data integrity](https://en.wikipedia.org/wiki/Data_integrity) and [data lineage](https://en.wikipedia.org/wiki/Data_lineage) are key issues that we must address. Both Data integrity and data lineage form the foundation of trust.
{% asset_img "Data integrity lineage and trust.png" "Data lineage is built on top of data integrity" %}

In this series of articles, we are going to look at different challenges and evolve the solution.  

# Data Integrity
Let's start with a basic example: 
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

With encryption solution, although Bob can prove the buggy version of message #2 is from Alice, but he cannot prove that Alice sent out the buggy version on Monday.

**In general, Bob (and we) need an immutable history that provides immutable traceability of data, such as when and what data was sent and processed.** 

It definitely helps provides data consumers like Bob, but here is benefits for well-behaved data providers as well: By offering the immutable history, it increases the data's acceptance from that providers, as well as increases  values of the provider.

## Iteration #3 - introduce DLT as immutable history
[Distributed Ledger Technology](https://en.wikipedia.org/wiki/Distributed_ledger) (DLT) shows its potential capacity to become the neutral and trustworthy 3rd party in data integrity (also data lineage) world, as it has the following key features:
- Data Immutable 
As the data is replicated in all nodes in the DLT network, it means that the data is immutable, even the author cannot modify his/her records once it is confirmed in ledgers.
- Decentralized
The ledger network is decentralized, means all participators have the same copy of the data, including Alice and Bob, for example.  
- Built-in authentication  
In order to send data to the ledger, the author has to use his/her private key. It provides the built-in authentication for identifying who is the author of that data/transaction. 
 
#### 3.1 Encrypted message within DLT
As DLT does support built-authentication, it is not need for use asymmetric(public/private) key for identity purpose. You can still use symmetric key for protecting the message from unauthorized access.  
However, there are some limitations for using DLT as the secured channel. The biggest one is the size limitation of the message. For example, bitcoin size limitation is 1 MB and ethereum is about similar size. For lots of the cases, this limitation is show-stopper.

Therefor, the hashing solution with DLT is more realizable. See below.

#### 3.2 Hashing with DLT
{% asset_img "Hashing solution with dlt.png" "Hashing solution with dlt" %} 
By only putting hash value of the messages into DLT, we can solve the size limitation issue. 
It means:
1. Alice continue sending the messages via insecure channels.
2. Meanwhile, Alice send the hash values of the message into DLT.
	1. All hash values that Alice sent to DLT, is signed by Alice's private key. So everyone knows it was author (Alice), the original message's digest and when the data was sent (timestampe).
3. Once Bob received the message via insecure channel, he can 
	1. Find the transaction that contains the hash value for that message from DLT
	2. By check the transaction's metadata, Bob can check the author and timestampe.
	3. By check the hash value from that transaction, Bob can verify the message content is not tampered.
4. Also, it is impossible for Alice wanna replace a old hash value. So Bob is protected from an immutable history. 

# Data Lineage

The goal of [data lineage](https://en.wikipedia.org/wiki/Data_lineage) is to track data over its entire lifecycle, to gain a better understanding of what happens to data as it moves through the course of its life. It increases trust and acceptance of result of data process. It also helps to trace errors back to the root cause, and comply with laws and regulations. You can easily compare this with the traditional supply chain of raw materials in manufacturing industry and/or logistic industry. 

For example, Bob is running a data process. This process takes inputs from Alice, then produces results. The results are sent to Carol.
- Bob produces result #X, based on inputs from Alice #1 and #2.
- Bob produces result #Y, based on input from Alice #3.

{% asset_img "Question of data lineage.png" "Question of data lineage" %} 

For Carol, some typical questions are:
1. What inputs Bob used for producing the results #X and #Y?
2. Do these inputs also have another inputs? If yes, what are they?
3. Is there a way to have to full picture of the whole data process lifecycle, without asking Bob (and every upstream) in the supply chain? 


Also for Bob, 