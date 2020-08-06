---
title: How to measure your Hamster's running with wireless IoT
date: 2020-08-05 19:30:43
thumbnail: /2020/08/05/How-to-measure-your-Hamster-s-running-with-IoT/thumbnail.jpg
tags:
- Hamster
- IoT
- Data Analytics
- Home Assistant
- Python
- Jupyter Notebook
- Zigbee
---
We recently welcomed our new family member Qiuqiu (球球) (a girl [Syrian/Golden hamster)](https://en.wikipedia.org/wiki/Golden_hamster) home. She seems to enjoy the new environment  fairly well, but she is a quiet girl - does not show much activities during the day time.

Of course we understand hamsters are nocturnal animals, which means they are sleeping in day time and become more active at night. But I started wondering how she was doing during the nights, especially how much she ran on the hamster wheel. 

Let's do something about it.

{% asset_img "Qiuqiu.jpg" "This is Qiuqiu with her wheel" %}
Picture: Qiuqiu with her wheel

<!-- more -->

# 1. Hardware
There are many possible ways to track the hamster wheel. 
1. **Wired solution, attach wire and switch to the wheel**
It should work pretty straight forward, but I am not a fan of having wires going through the cage for connecting to the computer. Also Qiuqiu will definitely chew on the wires. 
2. **Wireless solution, with computer vision**
This can be a pretty cool idea: Draw a mark (e.g. a red X) on the wheel, then place a camera (ie. [AWS DeepLens](https://aws.amazon.com/deeplens/)) to run some computer vision tasks, for counting the wheel cycle. 
I like this idea because it requires minimal work on the wheel and no dangerous for the hamster at all. But there also are some challenges such as how to ensure the image quality if there is no light in the room, or the wheel is running too fast to get a stable high quality image.
3. **Wireless solution, with wireless sensor**
This is what I did - need to attach a sensor on the wheel, but the sensor is so small that can be well protected in a shell. I decided to use zigbee protocol as I already have a smart home system that is well integrated. 

## 1.1 Needed hardware 
1. Sensor: [Aqara Door and Window Sensor](https://www.aqara.com/us/door_and_window_sensor.html)
2. Zigbee gateway: [Conbee II](https://www.phoscon.de/en/conbee2)
3. PC/Laptop/Raspberry Pi

## 1.2 Installation
### 1.2.1 Place the sensor 
Carefully place the sensor on the wheel and the body, make sure when wheel spins, the magnet on the wheel has a small but close enough gap with the sensor body. Used lego part for some adjustments.   
{% asset_img "installing_sensor.jpg" "Installing sensor" %}

### 1.2.2 Test with realtime sensor reading
Before we continue, I would like to test in action, to make sure the gap is OK. It is possible monitor realtime reading of the sensor, by using the Conbee API. 
I wrote a simple web app ([source code](/2020/08/05/How-to-measure-your-Hamster-s-running-with-IoT/hamsterwheel_realtime.html.txt)) with javascript and WebSocket, to visualize the realtime reading. The WebSocket API is provided by the Conbee application, see the document [here](https://dresden-elektronik.github.io/deconz-rest-doc/websocket/).

{% asset_img "realtime_reading1.gif" "" %}

Under the hood:
{% asset_img "realtime_reading2.gif" "" %}

### 1.2.3 Mount the protective shell
I made a protective shell from a spare plastic box, and mounted on the wheel. Therefore Qiuqiu cannot chew on the sensor. I even made a small hole on the shell to easily use a stick for pressing the sensor reset button, without remove the whole thing.

{% asset_img "mount_shell.jpg" "Mount the shell" %}

# 2. Software
## 2.1 Manual data export
The BeeCon 2 is a USB-based zigbee gateway that can be attached to a PC or raspberry pi. It talks to the zigbee mesh network and receives signals from sensors. For example, the sensor on the wheel send the following json payload, one for "close" event (magnet and sensor are closed) and another one for "open" event (magnet and sensor are parted). Logically one open-close event pair indicates a finished cycle:
```json
{
	"e": "changed",
	"id": "3",
	"r": "sensors",
	"state": {
		"lastupdated": "2020-08-05T17:32:37.102",
		"open": false
	},
	"t": "event",
	"uniqueid": "00:15:8d:00:04:5c:d8:d3-01-0006"
} 
{
	"e": "changed",
	"id": "3",
	"r": "sensors",
	"state": {
		"lastupdated": "2020-08-05T17:32:37.227",
		"open": true
	},
	"t": "event",
	"uniqueid": "00:15:8d:00:04:5c:d8:d3-01-0006"
}
```
By connecting Conbee gateway with [Home Assistant](https://www.home-assistant.io/) via [deCONZ integration](https://www.home-assistant.io/integrations/deconz/), it is fairly easy to export the data as a CSV file. (I plan to build a data pipeline with time series database in the later stage, but for now let's stay with manual data export.)

{% asset_img "exported_csv.png" "Exported CSV" %}
    Picture: exported csv, with 4 columns

## 2.2 Data analytics
### 2.2.1 Data loading and transformation
Now it is time for having some python/jupyter notebook fun. Here we are going to use https://www.kaggle.com/. You can read more comparison of online jupyter notebook hosting at [here](https://www.dataschool.io/cloud-services-for-jupyter-notebook/).

{% asset_img "Data load and transformation.png" %}
The above code snippet does:
1. Load CSV file into pandas DataFrame, with needed 2 columns *'last_changed' and 'state'*
3. During loading, parse datetime and also set *last_changed* as index
3. Convert fixed string value "on"/"off" in *'state'* to digital 0/1 in *'finshedOneRound'* that can be used for plot

### 2.2.2 Check the raw data and noises 
Let's take a look at the raw data. The first thing I noticed is the "noise" of each cycle. As the door-window close sensor is not designed for tracking a spin, whenever a cycle finished, instead of report simple 2 events: on and off, it actually generates a sequence of events: **on-off-on-off-on-off**. This is a "noise" that we need to take care of.  

it is worth noting that not all cycles follow the same pattern. For example, the 3rd red circle on the screenshot shows an exception: it only has one "on-off" event pair. 

{% asset_img "Raw data visualization.png" "Raw data visualization" %}

### 2.3 Noise reduction by rolling window calculations
We need a way to "group" the multiple events ("on-off-on-off-on-off") into one event that indicates a cycle, but we cannot group by a fixed pattern as there are exceptions (as we mentioned above). 

After some quick research and testing, without diving into hard-core data science part, I found the [rolling window calculation](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.rolling.html) can be a solution for our case.

Lets set the rolling windows to 150 ms - it is "magic number" that  works good with the raw data. It purely depends on how fast the hamster runs. 
{% asset_img "rolling_window.png" "" %}

Lets visualize the rolling calculation results.
```python
import plotly.graph_objects as go

fig = go.Figure()

fig.add_trace(go.Scatter(x=df.index, y=df['finshedOneRound'], name='raw'))
fig.add_trace(go.Scatter(x=df.index, y=df['finshedOneRound_rolled'], mode='lines+markers', name='rolling'))

fig.update_xaxes(rangeslider_visible=True)
fig.update_yaxes(tick0=0, dtick=1)

fig.show()
```
Now you can see that the result of rolling calculation does generate unique markers for each cycle (the green circles), and it works for different patterns in the raw data!
{% asset_img "rolling_window_visualization.png" "" %}

Extract the markers (where rolling result == 1) into a new dataframe df_cycle_log for the next step.
```python
df_cycle_log = df.loc[df["finshedOneRound_rolled"] == 1]
```


### 2.4 Calculation and visualization for the final result
I would like to know:
- When did Qiuqiu run?
- How far did she run?
- What was the speed?
- What kind of running pattern she has? (sprint or marathon?)

Lets do some match and populate the results:
```python
import math

def get_distance_by_wheel_cycle_count(cycle_count):
    diameter = 0.2 #the wheel diameter is 20cm
    return cycle_count * diameter * math.pi

def get_speed_in_KMh(traveled_range_in_m, run_time_in_sec):
    return traveled_range_in_m / run_time_in_sec * 3.6 #(1m/s = 3.6 km/h)

def get_speed_by_cycle_count(cycle_count, run_time_in_sec):
    distance = get_distance_by_wheel_cycle_count(cycle_count) 
    return get_speed_in_KMh(distance, run_time_in_sec)

#Aggreate the cycle counts every 30sec, popluate the data
run_time_segment = "30s"

df_result = pd.DataFrame()
df_result["cycle_count"] = df_cycle_log["finshedOneRound_rolled"].resample(run_time_segment).count()
df_result["distance"] = df_result["cycle_count"].apply(get_distance_by_wheel_cycle_count)
df_result["speed_km"] = df_result["cycle_count"].apply(lambda count: get_speed_by_cycle_count(count, 30))
```
Then plot
```python
import plotly.graph_objects as go
from plotly.subplots import make_subplots
# Create figure with secondary y-axis
fig = make_subplots(specs=[[{"secondary_y": True}]])

#fig.add_trace(go.Scatter(x=df_result.index, y=df_result['cycle_count'], name="wheel count"))
fig.add_trace(go.Scatter(x=df_result.index, y=df_result['speed_km'], name="speed(km/h)"), secondary_y=False)
fig.add_trace(go.Scatter(x=df_result.index, y=df_result["distance"].cumsum()/1000, name="distance(km)"), secondary_y=True)

fig.update_xaxes(rangeslider_visible=True)

fig.show()
```

{% asset_img "final_chart.png" "" %}

Conclusion from the result:
- **When did Qiuqiu run?**
She mainly ran for about 4 hours, between 21:30 and 01:30 UTC time (or 23:30 and 03:30 Oslo time).
- **How far did she run?**
During these 4 hours, she ran about 7.74 KM (12315 cycles). 
- **What was the speed?**
Average speed was about 3KM/h, with a peak 3.7 KM/h.
- **What kind of running pattern she had? (sprint or marathon?)**
She typically ran 5 minutes sprints, and took 2 min small breaks between them.

According to the internet, Qiuqiu is not the fastest runner ([a hamster can run up to 5-9 KM/h](https://firsthamster.com/how-much-how-fast-hamsters-run/)), and also ran slightly less than [average range 9 KM](https://en.wikipedia.org/wiki/Hamster_wheel) in that evening. 

Of course the speed/range can vary from hamster to hamster, and this is data for one evening. The next step is to build a fully automated data pipeline with time series database, create some Grafana dashboards with daily/weekly baseline for long term tracking. 

Thanks for the reading.

{% asset_img "qiuqiu_running.gif" %}