---
title: Building a Very Slow Movie Player
date: 2021-12-04 11:23:19
thumbnail: /2021/12/04/Building-a-Very-Slow-Movie-Player/thumbnail.jpg
tags:
  - Raspberry Pi
  - e-paper
  - DIY
  - SVMP
  - Amazon Lookout for Vision
  - Movie
---
Inspired by [Bryan Boyer](https://medium.com/s/story/very-slow-movie-player-499f76c48b62) and [Tom Whitwell](https://debugger.medium.com/how-to-build-a-very-slow-movie-player-in-2020-c5745052e4e4), I am building a Very Slow Movie Player (VSMP).

{% asset_img "vsmp-demo.gif" "vsmp demo" %}

With VSMP, 
- Kiki's Delivery Service (running time 1h42m): takes 7 days to play (with 1 frame per 20 seconds, as in above demo)
- Laputa: Castle in the Sky (running time 2h4m): takes 2 months to play (with 1 frame per 120 seconds, as default setting)

<!-- more -->
# 1. Hardware
- Raspberry Pi Zero WH (Zero W with Headers)
- [Waveshare e-paper 7.5 inch with Hat](https://www.waveshare.net/wiki/7.5inch_e-Paper_HAT)
- IKEA Photo Frame

All can be assembled together easily.

Front view
{% asset_img "front.png" "the front" %}
Zoom in details
{% asset_img "detail.png" "the detail" %}
The back
{% asset_img "back.png" "the back" %}




# 2. Installation
## 2.1 Raspberry Pi Zero
Install standard Raspberry OS. I am using the 32bit bulleyes with desktop version, but someone suggested to use lite version for Raspberry Pi Zero. Read more [here](https://github.com/TomWhitwell/SlowMovie/wiki/Hardware).

For install pi with headless wifi, read how-to [here](https://desertbot.io/blog/headless-raspberry-pi-zero-w-2-ssh-wifi-setup-mac-windows-10-steps).
```bash
touch /Volumes/boot/ssh
touch /Volumes/boot/wpa_supplicant.conf
```
Content of wpa_supplicant.conf
```json
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
scan_ssid=1
ssid="your_wifi_ssid"
psk="your_wifi_password"
}
```
**Note:** It is a good practice to disable the default user "Pi", but [VSMP installation script](https://github.com/TomWhitwell/SlowMovie) from Tom Whitwell is using hard-coded "Pi" home path, so to keep it simple, keep "Pi" user but DEFINITELY update the default password. I also run it in a guest wifi that it has no access to rest of my network devices. 

## 2.2 Install VSMP files
There are many implementations of VSMP:
- https://github.com/TomWhitwell/SlowMovie (I am using this one, works with my e-paper by default)
- https://github.com/robweber/vsmp-plus (This one provides nice web interface for controlling, but it crashes all the time in my setup)
- https://github.com/rec0de/vsmp-zero (For e-paper 7.8inch, 1872×1404 resolution, with embedded controller IT8951, communicating via USB/SPI/I80 interface)

**Note:** You can test your e-ink by running omni-epd-test. In my case, I do the following
```bash
omni-epd-test -e waveshare_epd.epd7in5_V2
```
The [omni-epd](https://github.com/robweber/omni-epd#displays-implemented) is a part of the installation.

# 3. Prepare the movie
## 3.1 If you need convert mkv to mp4
```bash
# assume you have ffmpeg installed on your mac
for f in *.mkv; do ffmpeg -i "$f" -c copy "${f%.mkv}.mp4"; done
```
Read more examples at [here](https://gist.github.com/jamesmacwhite/58aebfe4a82bb8d645a797a1ba975132).

## 3.2 Remove sound track for reducing the file size
```bash
# assume you have ffmpeg installed on your mac
for f in *.mp4; do ffmpeg -i "$f" -c copy -an "${f%.mp4}-nosound.mp4"; done
```
Read more about "-an" parameter at [here](https://superuser.com/questions/268985/remove-audio-from-video-file-with-ffmpeg).

## 3.3 Copy files to Pi
```bash
# from movie folder
scp *.mp4 pi@YOUR_PI_HOST_NAME:/home/pi/SlowMovie/Videos/
```

# 4. Play
## 4.1 VSMP as a service
By default [VSMP](https://github.com/TomWhitwell/SlowMovie/wiki/Content-reviews:-What-makes-a-good-slow-movie%3F) is enabled as a service. 

Edit the slowmovie.conf file to specify parameters such as video locations and start frame
```bash
# Edit the config file
vi slowmovie.conf

## Content of slowmovie.conf ##
random-frames = False
delay = 120
increment = 4
contrast = 2.0
epd = waveshare_epd.epd7in5_V2
directory = /home/pi/SlowMovie/Videos
timecode = False
## End of content ##

## Restart the service
sudo systemctl restart slowmovie
sudo systemctl enable slowmovie
```

## 4.2 Manually run
If you want to [manually run command](https://github.com/TomWhitwell/SlowMovie#running-from-the-shell), REMEMBER to disable the service.

If you run it manually, considering use [tmux](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/) to ensure the session continues after you log off.

Example:
```bash
# Stop services
sudo systemctl stop slowmovie
sudo systemctl disable slowmovie

# enter tmux session
tmux

# Manual run in tmux session window
cd SlowMovie
python3 slowmovie.py -f ./Videos/Kiki.mp4 -d 20 -s 19970 #delay 20 sec, start from 19970 frame
```

# 5. Bonus content
## 5.1 What to play
Wondering what to play? Read [Content reviews: What makes a good slow movie](https://github.com/TomWhitwell/SlowMovie/wiki/Content-reviews:-What-makes-a-good-slow-movie%3F). I am a big fan of [Studio Ghibli](https://www.ghibli.jp/) so that is my choice. 

Also you might want to re-encode the videos as [here](https://github.com/TomWhitwell/SlowMovie/wiki/Preparing-Video-Files).

## 5.2 Shoot a video for your VSMP
You can use iphone time-lapse to record your VSMP to see how it works. However, iphone time-lapse will sometimes capture some e-paper refresh, when the screen is all white or black. To remove these bad frames from your video, do following (ref [#1](https://gist.github.com/loretoparisi/a9277b2eb4425809066c380fed395ab3), [#2](https://stackoverflow.com/questions/10225403/how-can-i-extract-a-good-quality-jpeg-image-from-a-video-file-with-ffmpeg))
```bash
# extract all frames from iphone time-lapse video
mkdir img
ffmpeg -i time-lapse.MOV -qscale:v 2 -r 30/1 img/img%03d.jpg #iphone time-lapse video is 30 fps, second best output img quality

# remove bad frames
# manual or using ML such as Amazon Lookout For Vision

# regenerate the video from frames
ffmpeg -framerate 30 -pattern_type glob -i 'img/*.jpg'  output.mov

# slow it down if needed
ffmpeg -i output.mov -filter:v "setpts=1.3*PTS" output_slow.mov
```

Example of using [Amazon Lookout for Vision](https://aws.amazon.com/lookout-for-vision/) for detecting bad frames, but that is another story.
{% asset_img "Lookout for vision.png" "the back" %}

# 6. Slightly longer demo
{% youtube VIQjtaqm8Ps %}

