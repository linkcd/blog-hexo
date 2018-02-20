---
title: Running IOTA Full Node
date: 2018-02-19 22:29:05
tags:
  - IOTA
  - DTL
  - Distributed Ledger Technology
  - blockchain
  - Fullnode
---

I have been looking at [IOTA](https://www.iota.org/) since last winter, as it seems promising for IoT, Machine-to-Machine Micro-payments and Data Market scenarios.

Installing an IOTA light wallet is pretty straightforward, but running a full node is not. But thanks to the great [playbook](http://iri-playbook.readthedocs.io/en/master/introduction.html), I managed to setup a Virtual Private Server to run as an IOTA full node. 
- 4 cores CPU 
- 8 GM memory
- SSD 
- Hosted 24/7 in a data center in Western Europe

## Setup steps ##
- Followed the steps in [playbook](http://iri-playbook.readthedocs.io/en/master/introduction.html)
- Enabled remote access for the node, so the light wallet can connect to it.
- Setup firewall rules to allow IOTA node talking to internet
- Setup DNS to make the node more friendly for my neighbors
- Found good neighbors from IOTA Discord #nodesharing channel 
	Tips: go to #rank-yourself  and type "!rank fullnode", then you'll get access to the #nodesharing channel 

## Screenshots ##
{% asset_img "Grafana dashboard.png " "Grafana dashboard for IOTA node" %}
{% asset_img "Grafana dashboard 2.png " "Grafana dashboard for IOTA node" %}

Overview of connected neighbors
{% asset_img "IOTA Node Peer Manager.png " "IOTA Node Peer Manager" %}

Find your place on the net: http://field.carriota.com/
{% asset_img "IOTA Field.png " "Screenshot of IOTA field" %}

Also, connect the wallet to the our node
{% asset_img "Wallet.png " "Connect wallet to our node" %}


## Build the community ##
If you are looking for neighbors, or would like to connect your wallet to this node, please feel free to let me know. 
If you would like to donate, please use the following address. :)
```
MBCGRU9NLP9UPPRGXANYPDZQPCEBXFULNCVLLMWQDGJXSUUFILIS9ETTTIOEXHRPRLCMDUTVQXOEWMFLDROSGKXETB
``` 

EoF.
