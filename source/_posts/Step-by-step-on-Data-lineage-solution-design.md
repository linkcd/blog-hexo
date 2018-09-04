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
Previously we discussed the data integrity and lineage solution (at here), and I got lots of positive feedback from the community. 

In this article is to give a deep dive of the solution, step by step.

# Example 
Let's look at an example.

Alice is sending messages (ie. files) to Bob. The messages were sent via insecure channel, such as http-based data transfer, ftp, file share or even an usb stick.

{% asset_img "Alice sends msg to Bob.png" "Alice sends msg to Bob" %}


**Solution**: There are mainly 2 ways to ensure it, such as encryption (symmetric or asymmetric) and/or hashing. (A nice articles for comparing hashing and encryption can be found at [here](https://www.ssl2buy.com/wiki/difference-between-hashing-and-encryption).)

In below, we will look at different challenges and improve the solution.  

### Challenge 1: The messages were not tampered by man-in-the-middle
#### Encryption Solution 1.0 (either Symmetric or Asymmetric)
{% asset_img "Sending msg with encryption.png" "Sending msg with encryption" %}
- **Pro**: With encryption is pretty straight forward: Either use symmetric or asymmetric key, Alice and Bob can encrypt and decrypt messages without worrying data tampering. 
- **Con**: However, this requires key management, both for Alice and Bob.

#### Hashing Solution 1.0
{% asset_img "Sending msg with hash.png" "Sending msg with hashing" %}
- **Pro**: Does not require key management for both Alice and Bob.
- **Con**: With hashing, it requires an additional data flow for passing hash values from Alice to Bob. It actually requires the same security mechanism as the normal data flow. 

#### new Hashing Solution 1.1 (with a trusted area)
We can address this by introducing a trusted area for Alice. For example, Alice also publish the hash values of the messages on https://alice.com. Bob can verify the message by compare the hash values. It is also OK to make the trusted area public, as  hash value is irreversible - nobody can obtain the data by using the hash value, they can only check the message integrity. 

This solution is sort of adding a secured "safeguard" track on the side, to help verifying the data flowing in the insecure channel. 
 
{% asset_img "Sending msg with hash with trust area.png" "Sending msg with hash with trust area" %}
- **Pro**: Does not require key management for both Alice and Bob. Solved the problem for protecting hash value data flow.

**Conclusion: *Encryption Solution 1.0* and *Hashing Solution 1.1* can fulfill the requirement #1**

### Challenge 2: The messages that Bob received, are indeed from Alice
#### new Encryption Solution 1.1 (Asymmetric)  
This normally requires asymmetric encryption: Alice encrypts the message with her private key, and Bob decrypts it with Alice's public key.  Therefore Bob is confident that Alice is the message author. 
{% asset_img "Sending msg with asymmetric encryption.png" "Sending msg with asymmetric encryption" %}

#### same Hashing Solution 1.1 (with a trusted area)
Hashing Solution 1.1 can also meet this requirement, simply counting on ONLY Alice can write into the trusted area.
{% asset_img "Can trust message with hash.png" "" %}

**Conclusion: *Encryption Solution 1.1* and *Hashing Solution 1.1* can fulfill both the challenge #1 and #2**

### Challenge3: Once Alice sent out a message, she cannot deny the message was sent out, the message's origin nor the original content
 
{% asset_img "Bobs problem.png" "Bobs problem" %} 
(click to enlarge the picture)

The requirement **#3** is actually interesting: it provides Bob and Carol an immutable trackability back to the messsage sender (also known as **data provider**). Therefore, it also increase the acceptance of Alice's messages (also known as her **data service**). 

In our context of **data integrity**, we would like to have a solution that fulfill of the these 3 requirements. 

Solution evltion
Requiremnt #2 is pretty strangt forward: Whenever Alice sends out a message, she also send out a hash value of the message. With any good hash function, such as SHA512, Bob and Carol can easily compare the hash value from Alice and the hash value they own calculated based on the received message.

x