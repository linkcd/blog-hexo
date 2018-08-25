---
title: 'Step by step: Data integrity and lineage solution design'
date: 2018-08-23 20:33:49
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

In this arctile is to give a deep dive of the solution, step by step.

# Data Integrity #
Let's look at an example.

Alice is sending messages (ie. files) to Bob and Carol. The messages were sent via unsecured channels, such as http-based data transfer, file share or even an usb stick.  

For Bob and Carol, they need to make sure that:
1. Tthe messages that they received, are indeed from Alice. 
2. The messages were not tampered by man-in-the-middel.
3. Once Alice sent out a message, she cannot deny the message's origin nor the original content. 

The requirement **#3** is actually interesting: it provides Bob and Carol an immutable trackability back to the messsage sender (also known as **data provider**). Therefore, it also increase the acceptance of Alice's messages (also known as her **data service**). 

In our context of **data integrity**, we would like to have a solution that fulfill of the these 3 requirements. 

Solution evltion
Requiremnt #2 is pretty strangt forward: Whenever Alice sends out a message, she also send out a hash value of the message. With any good hash function, such as SHA512, Bob and Carol can easily compare the hash value from Alice and the hash value they own calculated based on the received message.

x