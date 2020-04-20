#!/bin/bash  
#Require library: jq
webapi='https://datalineage-viewer.azurewebsites.net/api/publish'
###############################################################
# Norwegian police station
seed1="seed:YMWCOSQBLSREVKHUGGOV9BLQIARPEUTOHTDRK"
r1=$(curl -X POST "${webapi%?}"  -H "accept: application/json" -H "${seed1%?}" -H "Content-Type: application/json" -d '{"dataPackageId": "police#123", "ownerMetadata":"Norwegian police station", "wayOfProof": "copy of original text", "valueOfProof": "2018 20. februar 13:00: En liten bilulykke utenfor Esso bensinstasjon paa Billingstadsletta 9, 1396 Billingstad. Bilskade: 5000 NOK." }')
echo "$r1"
address1=$(jq '.mamAddress' <<< "$r1")
echo "police station data integrity address:" $address1
###############################################################
# Translator
seed2="seed:YMWCOSQBLSRYNVAIJXS9UTMQEHWOV9BLQIARPEUTOHTDRK"
r2=$(curl -X POST "${webapi%?}"  -H "accept: application/json" -H "${seed2%?}" -H "Content-Type: application/json" -d '{"dataPackageId": "translator#789", "ownerMetadata":"Transaltor Jan Erik ", "wayOfProof": "copy of original text", "valueOfProof": "2018 Feb 20th, 13:00PM: A small car accident outside of Esso gas station at Billingstadsletta 9, 1396 Billingstad.Car damage: 5000 NOK.", "inputs":['"${address1%?}"'] }')
address2=$(jq '.mamAddress' <<< "$r2")
echo "transaltor data integrity address:" $address2
###############################################################
# Currency service provider
seed3="seed:YMWCOSQBLSREEEVGEWOV9BLQIARPEUTOHTDRK"
r3=$(curl -X POST "${webapi%?}"  -H "accept: application/json" -H "${seed3%?}" -H "Content-Type: application/json" -d '{"dataPackageId": "NordeaBank#20180220", "ownerMetadata":"Nordea Bank", "wayOfProof": "copy of original text", "valueOfProof": "5000 NOK = 643.60 US Dollar" }')
address3=$(jq '.mamAddress' <<< "$r3")
echo "currency service data integirty address:" $address3
###############################################################
# Map provider
seed4="seed:YMWCOSQBLSRYNVAIJEEEEVGMFCS9UXNBLQIARTDRK"
r4=$(curl -X POST "${webapi%?}"  -H "accept: application/json" -H "${seed4%?}" -H "Content-Type: application/json" -d '{"dataPackageId": "GoogleMap#ABCD", "ownerMetadata":"Google Map", "wayOfProof": "copy of original text", "valueOfProof": "http://map.google.com/1234" }')
address4=$(jq '.mamAddress' <<< "$r4")
echo "map service data integirty address:" $address4
###############################################################
#Custmoer report
seed5="seed:YMWCOSQBLSRYNVAIJXEREZMXZKNG9HWOV9BLQIARPEUTOHTDRK"
r5=$(curl -X POST "${webapi%?}"  -H "accept: application/json" -H "${seed5%?}" -H "Content-Type: application/json" -d '{"dataPackageId": "lufeng#001", "ownerMetadata":"Lu Feng ", "wayOfProof": "copy of original text", "valueOfProof": "Car accident report: 2018 Feb 20th, 13:00PM. Location: Billingstadsletta 9, Billingstad, Norway. Damage amount: 643.60 USD. Attached the map http://map.google.com/1234", "inputs":['"${address2%?}"', '"${address3%?}"','"${address4%?}"'] }')
address5=$(jq '.mamAddress' <<< "$r5")
echo "insurance form data integrity address:" $address5