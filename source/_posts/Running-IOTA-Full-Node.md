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
- 2 cores CPU 
- 4 GM memory
- SSD 
- Hosted 24/7 in a data center in Western Europe

{% asset_img "IOTA Field.png " "Connected full nodes in IOTA field map" %}

<!-- more -->

## Setup steps ##
- Followed the steps in [playbook](http://iri-playbook.readthedocs.io/en/master/introduction.html)
- Enabled remote access for the node, so the light wallet can connect to it.
- Setup firewall rules to allow IOTA node talking to internet
- Setup DNS to make the node more friendly for my neighbors
- Found good neighbors from IOTA Discord #nodesharing channel 
	Tips: go to #rank-yourself  and type "!rank fullnode", then you'll get access to the #nodesharing channel 

## Security! ##
There are lots of things you need to think about when you are hosting a 24/7 server on the internet. [This blog](https://x-vps.com/blog/?p=188) and [Security Hardening](http://iri-playbook.readthedocs.io/en/master/securityhardening.html) section provides a good guideline. 
- Use SSH key access
- Disable password authentication 
- Disable SSH root access

In addition, if you are using the [playbook installer ](http://iri-playbook.readthedocs.io/en/master/getting-started-quickly.html), you basically have the default user name and ports for your full node.** IT IS IMPORTANT TO CHANGE THEM!** Otherwise the attacker only need to crack the password, as they already know your user name (**iotapm**) and your ports.

### Update user name and password in bash ###
```bash
nano /opt/iri-playbook/group_vars/all/iotapm.yml
#update the following values
iotapm_nginx_user: new_user_account
iotapm_nginx_password: 'a-strong-password' 	

nano /opt/iri-playbook/group_vars/all/z-override-iotapm.yml
#update the following values
iotapm_nginx_user: new_user_account
iotapm_nginx_password: 'a-strong-password'
```
[reference](http://iri-playbook.readthedocs.io/en/master/installation.html#set-access-password) 

You can perform the following steps after you completed the installer.

### Update nginx user ###
1. Remove the default user iotpm
```bash
htpasswd -D /etc/nginx/.htpasswd iotpm
```
2. Create new user
```bash
htpasswd /etc/nginx/.htpasswd new_user_account
```

### Update system account in grafana ###
1. Stop grafana-server:
```bash
systemctl stop grafana-server
```
2. Delete grafana’s database:
```bash
rm -f /var/lib/grafana/grafana.db
```
3. Edit /etc/grafana/grafana.ini, set correct values for admin_user and admin_password (from above step)
4. Start grafana-server:
```bash
systemctl start grafana-server
```
5. re-install grafana by using iric, select "update monitoring"

[reference](http://iri-playbook.readthedocs.io/en/master/troubleshooting.html#http-error-401-unauthorized-when-running-playbook) 

## Screenshots ##
{% asset_img "Grafana dashboard.png " "Grafana dashboard for IOTA node" %}
{% asset_img "Grafana dashboard 2.png " "Grafana dashboard for IOTA node" %}

Overview of connected neighbors
{% asset_img "IOTA Node Peer Manager.png " "IOTA Node Peer Manager" %}

The node in the map: http://field.carriota.com/
{% asset_img "My node in field map.png " "My node in field map" %}

Also, connect the wallet to the our node
{% asset_img "Wallet.png " "Connect wallet to our node" %}


## Build the community ##
If you are looking for neighbors, or would like to connect your wallet to this node, please feel free to let me know. 
If you would like to donate, please use the following address. :)
```
LPQRSZKJM9IRXHMUYJZQLKMAKJHJQDERJWIPSLKCYAPXVZPGEWG9QDXQUNTXCMZYLLIHPHGULVGFIAZAWDFECWYKGC
``` 

EoF.
