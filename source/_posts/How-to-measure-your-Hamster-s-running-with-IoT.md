---
title: How to measure your Hamster's running with wireless IoT
date: 2020-08-05 11:29:43
tags:
- Hamster
- IoT
- Data Analytics
- Home Assistant
- Python
- Jupyter Notebook
- Zigbee
---
We recently welcomed a new family member QiuQiu (a girl [Syrian/Golden hamster)](https://en.wikipedia.org/wiki/Golden_hamster) home. She seems to enjoyed the new environment  fairly well, but she is a quite girl - does not show much activities during the day time.

Of course we understand hamsters are nocturnal animals, which means they are sleeping in daytime and become more active at night. But I started wondering how she was doing during the nights, especially how much she ran on the hamster wheel. 

Lets do something about it.

{% asset_img "Qiuqiu.jpg" "This is Qiuqiu with her wheel" %}
Picture: Qiuqiu with her wheel

# Hardware
There are many possible ways to track the hamster wheel. 
1. **Wired solution, attach wire and switch to the wheel**
It should work pretty straight forward, but I am not a fan of having wires to through the cage for connecting to the computer. Also Qiuqiu will definitely chew on the wires. 
2. **Wireless solution, with computer vision**
This can be a pretty cool idea: Draw a mark (e.g. a red X) on the wheel, then place a camera (ie. [AWS DeepLens](https://aws.amazon.com/deeplens/)) to run some computer vision tasks, for counting the wheel cycle. 
I like this idea because it requires minimal work on the wheel and no dangerous for the hamster at all. But there also are some challenges such as how to ensure the image quality if there is no light in the room, or the wheel is running too fast to get a stable high quality image.
3. **Wireless solution, with wireless sensor**
This is what I did - need to attach a sensor on the wheel, but it is so small that can be well protected in a shell. I decided to use zigbee protocol as I already have a smart home system that is well integrated. 

## Needed hardware 
1. Sensor: [Aqara Door and Window Sensor](https://www.aqara.com/us/door_and_window_sensor.html)
2. Zigbee gateway: [Conbee II](https://www.phoscon.de/en/conbee2)
3. PC/Laptop/Raspberry Pi

## Installation
### 1. Place the sensor 
Carefully place the sensor on the wheel and the body, make sure when wheel spins, the magnet on the wheel has a small but close enough gap with the sensor body. Used lego part for some adjustments.   
{% asset_img "installing_sensor.jpg" "Installing sensor" %}

### 2. Test with realtime sensor reading
Before we continue, I would like to test in action, to make sure the gap is OK. It is possible monitor realtime reading of the sensor, by using the Conbee API. 
I wrote a simple web app ([source code](/2020/08/05/How-to-measure-your-Hamster-s-running-with-IoT/hamsterwheel_realtime.html)) with javascript and WebSocket, to visualize the realtime reading. THe WebSocket API is provided by the Conbee application, see the document [here].(https://dresden-elektronik.github.io/deconz-rest-doc/websocket/)

{% asset_img "realtime_reading1.gif" "" %}

Under the hood:
{% asset_img "realtime_reading2.gif" "" %}

### 3. Mount the protective shell
I made a protective shell from a spare plastic box, and mounted on the wheel. Therefore Qiuqiu cannot chew on the sensors. I even made a small hold on the shell to easily use a stick to press the reset button on the sensor, without remove the whole thing.
{% asset_img "mount_shell.jpg" "Mount the shell" %}