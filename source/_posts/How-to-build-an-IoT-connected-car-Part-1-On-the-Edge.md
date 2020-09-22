---
title: 'How to build an IoT connected car - Part 1: On the Edge'
date: 2020-09-15 10:38:12
tags:
- IoT
- Data Analytics
- Azure IoT Hub
- Azure IoT Edge
- Car
- GPS
- OBD2
- Raspberry Pi
---
Previously I wrote a blog about how to {% post_link How-to-measure-your-Hamster-s-running-with-IoT 'measure hamster via IoT wheel' %}. This reminds me another personal project I did back to the winter of 2018/2019, for measuring car performance. 


{% asset_img "Thumbnail.png" "Thumbnail" %} 

<!-- more -->
# Other articles in this series:
- Part 1 (this article):
Talk about the hardware/software running on the edge (the car) for collecting data.
- {% post_link How-to-build-an-IoT-connected-car-Part-2-Data-Analytics-in-the-Cloud 'Part 2' %}:
Talk about how to get insight from the data with different analytic tools.

# 1. Overview on the edge
## 1.1 Hardware
- OBD2 USB connector
[OBD2](https://en.wikipedia.org/wiki/On-board_diagnostics) is an interface/protocol that is available for 1996 and newer vehicles. It reports [various telemetries](https://en.wikipedia.org/wiki/OBD-II_PIDs) of the vehicle.
- USB GPS dongle
For collecting location information
- Raspberry Pi
Running Linux, Azure IoT Edge runtime and hosting 2 modules (OBD and GPS location)
- USB Wifi dongle
For connecting mobile phone hotspot
- Mobile phone 
For realtime data uploading to the cloud via 4G
- Power bank (optional)
For powering up raspberry pi. Alternatively, you can use a 12V->5V adapter to use the car battery.

## 1.2 Software
- Azure IoT Edge
- Docker
- Python

## 1.3 Dataflow and Architecture
{% asset_img "hardware architecture.png" "Hardware architecture" %}

# 2. Developing IoT Edge modules
## 2.1 Introduction
### 2.1.1 Design Principles
As there are many possible situations can happen on the edge, such as disconnection from OBD2 connector, or loss of GPS signal (when going through an underground tunnel), the modules are built with the following principles:
- Design for failure 
- Auto healing

In addition, the modules are built into docker containers, together with Azure IoT Edge runtime, which makes it easier to deploy.

### 2.1.2 Source code
All source code can be found at https://github.com/linkcd/IoTCar

### 2.1.3 Sample data
This edge device (raspberry pi + OBD connector + GPS dongle) reports the following data per second:
{% asset_img "sample-data.png" "sample data" %}

## 2.2 GPS location module - details
[Source code](https://github.com/linkcd/IoTCar/tree/master/modules/LocatorModule)

With a USB GPS dongle, it is quite easy to get the location information by using tools such as [GPSD](https://gpsd.gitlab.io/gpsd/index.html).

### 2.2.1 You have to dev/test in the field, not only in the office
I immediately met the first challenge: The USB GPS dongle requires a good open sky view to work well. The one that I used does not have an antenna, so I need to put the whole thing (raspberry pi + GPS dongle) outside of the building (or at least outside of the window).

Remind you that it was winter in Norway during that time, and I was not a fan of typing keyboard in the snow with -5 degrees. 

Firstly, I have tried do this in my car: parked the car in an outdoor parking slot, put the raspberry pi on the dashboard and remote desktop to it. Well, it worked, GSP signal was strong, but it was quite difficult to type any keys behind the steering wheel :)
{% asset_img "GPS-in-car-small.png" "Testing GPS in the car" %}

But soon I figured out a better solution on my balcony (see below picture), and that worked perfectly (as far as the wifi signal is good and the power bank battery did not die from the low temperature)
{% asset_img "gps-programming-in-winter.png" "programming GPS in winter" %}

Now I can work from a warm cozy place and deal with the GPS data that is collected from the "cold box". 

### 2.2.2 Working with GPS data with python
The GPS receiver reports data as [NMEA sentences](https://www.gpsinformation.org/dale/nmea.htm#nmea), and we are combining [GGA](https://www.gpsinformation.org/dale/nmea.htm#GGA) and [RMC](https://www.gpsinformation.org/dale/nmea.htm#RMC). 
```bash
# GGA 
$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47
# RMC
$GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W*6A
```
Here we are using a python lib [pynmea2](https://github.com/Knio/pynmea2) for handling the NMEA sentences, the detailed logic can be found at [source code here](https://github.com/linkcd/IoTCar/blob/master/modules/LocatorModule/gpsreader.py#L66).

In addition, we need to do some [small math](https://github.com/linkcd/IoTCar/blob/master/modules/LocatorModule/gpsreader.py#L27) for calculating the correct latitude and longitude, otherwise you will find your car was driving in the ocean :)
```python
# The latitude is formatted as DDMM.ffff and longitude is DDDMM.ffff where D is the degrees and M is minutes plus the fractional minutes. 
# So, 1300.8067,N is 13 degrees 00.8067 minutes North and the longitude of 07733.0003,E is read as 77 degrees 33.0003 minutes East.
# Converting to degrees you would have to do this: 13 + 00.8067/60 for latitude and 77 + 33.0003/60 for the longitude.
# ##NMEA outputs in a human readable DDDMM.mmmm format NOT DECIMAL DEGREES
# 3746.03837
# 37 46.03837
# 37 + (46.03837 / 60)
# result = 37 + 0.7673062

segments = value.split('.')
if len(segments[0]) == 4:
    #lanitude
    degree = segments[0][:2]
else:
    #longtitude
    degree = segments[0][:3]

minute = round(Decimal(segments[0][-2:] + "." + segments[1])/60, 6)
```

Finally, this module reports the following data per second
```json
{
    "series": [
        {
            "mag_variation": "",
            "geo_sep": "39.1",
            "num_sats": 5,
            "fixed_time": "20:33:21",
            "geo_sep_units": "M",
            "horizontal_dil": "2.21",
            "longitude_dir": "E",
            "mag_var_dir": "",
            "gps_speed": 0.242,
            "altitude_units": "M",
            "true_course": null,
            "latitude": "11.111111",
            "fixed_full_timestamp": "2019-02-26 20:33:21",
            "latitude_dir": "N",
            "fixed_date": "2019-02-26",
            "gps_quality": 1,
            "longitude": "22.222222",
            "altitude": 93.4
        }
    ],
    "deviceId": "FengsDevice_GPS",
    "timestamp": "2019-02-26 20:33:21"
}
```

## 2.3 OBD2 module - details
[Source code](https://github.com/linkcd/IoTCar/tree/master/modules/OBDModule)

### 2.3.1 You cannot do it in the field, do it on an emulator instead
Programming/debugging OBD2 can be difficult - after all I do not want to be programming while driving. Instead of hiring a driver and typing the keyboard on the passenger seat, it is better to use an ODB emulator to emulate all telemetries (and error codes) of the car.

#### OBD2 Emulator
Lucky I am not alone who has the same problem during OBD development. There are professional and affordable emulators on [Aliexpress](https://www.alibaba.com/product-detail/Professional-OBD2-Emulator-Tool-for-OBD_62315028570.html) and [Taobao](https://item.taobao.com/item.htm?spm=a230r.1.14.37.532d3fe1POSTRH&id=613000775363&ns=1&abbucket=12#detail) (BTW The price on Taobao is 1/3 as Aliexpress!).  The detailed features can be found at [here](OBD emulator features.jpg). My respects to the designers of this emulator - you are life savers!

{% asset_img "OBD emulator 3.png" "OBD emulator" %}
{% asset_img "OBD emulator1.jpg" "OBD emulator" %}

### 2.3.2 Design for failure and auto healing
Now, with the emulator and python [obd lib](https://pypi.org/project/obd/), it is easy to collect the telemetries of the car.

However, the library does not take care of failures and auto-healing, which we need to do it ourselves, otherwise the code just throw exceptions and stop working.

Thanks to the emulator, it is easy to test all corner scenarios, such as disconnect the ODB and reconnect while "the engine" is still running, in a safe environment. That is impossible to test/debug with real car.

The following code snippet ensures the modules works with different scenarios and self-healing:
- Car is powered off
- Car is powered on but engine is not started yet
- Engine starts
- Engine is stopped but car is still powered on
- OBD receiver is disconnected (e.g lost bluetooth signal)

```python
def getVehicleTelemtries(deviceId):
    global connection
    if(not connection.is_connected()):
        print("No connecting to the car, reconnecting...")
        connection = obd.OBD(fast=True) 
    try:
        # Use library to get readings...
        
        if(telemtryDic["RPM"] == 0):
            print("Cannot read RPM, reconnecting...")
            connection = obd.OBD(fast=True) 
            return None
        else:
            return buildJsonPayload(deviceId, telemtryDic)

    except Exception as e:
        print("Error with OBDII, error: " + str(e) + ". Reconnecting...")
        connection = obd.OBD(fast=True)
        return None
```
{% asset_img "ODB connection in car.jpg" "obd connection in car" %}

Finally, this module reports the following data per second:
```python
{
  "series": [
    {
      "SPEED": 56,
      "RPM": 2830.75,
      "RUN_TIME": 639,
      "ABSOLUTE_LOAD": 0.0,
      "SHORT_FUEL_TRIM_1": -21.09375,
      "TIMING_ADVANCE": 0.0,
      "INTAKE_PRESSURE": 0,
      "LONG_FUEL_TRIM_1": 18.75,
      "INTAKE_TEMP": 0,
      "THROTTLE_POS": 37.64705882352941,
      "OIL_TEMP": 16,
      "MAF": 655.35,
      "RELATIVE_THROTTLE_POS": 0.0,
      "COOLANT_TEMP": 0,
      "ENGINE_LOAD": 45.490196078431374
    }
  ],
  "timestamp": "2019-02-20 19:27:11.705387",
  "deviceId": "FengsDevice_OBD"
}
```
### 2.3.3 Tips: Considering use 'Real Time Clock' or RTC board for your Pi
As Raspberry PI does not have an RTC, the system clock was reset after each power-on. If it has an internet connection, it will fetch the correct date-time from internet, with some delay.

In the current logic, both GPS and OBD modules are using the system clock as the event timestamp. Therefore, if the Pi failed to have internet connection (happened often with mobile hotspot) or sending data before system clock is updated due to delay, the event timestamp will be incorrect.

To overcome this issue, you can install a RTC (Real Time Clock) to the Raspberry Pi, such as [this](https://learn.adafruit.com/adding-a-real-time-clock-to-raspberry-pi) and [this](https://thepihut.com/blogs/raspberry-pi-tutorials/17209332-adding-a-real-time-clock-to-your-raspberry-pi).

I end up with a [UPS-18650 Raspberry pi UPS Power Expansion Board With RTC](https://www.tindie.com/products/rachel/ups-18650-for-raspberry-pi/). It comes with a power bank AND a built-in RTC. It is design and built by [ACE design studio](https://www.tindie.com/stores/rachel/) in China, and I am very happy about it. Definitely buy more from them next time.

{% asset_img "Pi with RTC.png" "Raspberry Pi with UPS power expansion board and LoRa/GPS Hat" %}
(Picture: My to-be-tested Raspberry Pi with UPS power expansion board and LoRa/GPS Hat.Hopefully it can use LoRa network connections to replace 4G)

# 3. Put things together and send to Azure
## 3.1 Config on the edge
Now we have 2 modules and we have built them into 2 docker images (in variables ${MODULES.OBDModule.arm32v7} and ${MODULES.LocatorModule.arm32v7}). I was hosting them in the dockerhub but it can also be hosted in any private registration.

For now we did not do any computing on the edge but simply forward them to Azure Iot Hub (see [here](https://github.com/linkcd/IoTCar/blob/96501440601ced4e2e4d18f3e37d24905591c718/deployment.template.json#L96))
```json
"$edgeHub": {
      "properties.desired": {
        "schemaVersion": "1.0",
        "routes": {
          "OBDModuleToIoTHub": "FROM /messages/modules/OBDModule/outputs/* INTO $upstream",
          "LocatorModuleToIoTHub": "FROM /messages/modules/LocatorModule/outputs/* INTO $upstream"
        },
        "storeAndForwardConfiguration": {
          "timeToLiveSecs": 7200
        }
      }
    }
```

More info can be found in the [deployment.template.json](https://github.com/linkcd/IoTCar/blob/master/deployment.template.json).

## 3.2  Visualization in the cloud
Now we 2 module docker images running on the Raspberry Pi and sending data to Azure IoT Edge runtime. The Raspberry Pi has wifi connection to mobile phone 4G hotspot and forwarding the data to Azure IoT Hub in realtime. 

With Azure IoT Hub and [Azure Time Series Insights(TSI)](https://azure.microsoft.com/en-us/services/time-series-insights/), we can now visualize the data:

{% asset_img "TSI sample.png" "Azure Time Series Insight sample" %}

This is a quick example of data analytics for the IoT car. In the {% post_link How-to-build-an-IoT-connected-car-Part-2-Data-Analytics-in-the-Cloud 'second part' %} of the series, I will talk more about the data analytics part (including TSI, DataBrick ++) in the cloud.

{% post_link How-to-build-an-IoT-connected-car-Part-2-Data-Analytics-in-the-Cloud 'Continue reading part 2' %}