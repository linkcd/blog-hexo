---
title: Change Git color
date: 2016-08-27 14:53:04
tags:
  - Git
---
Git has a default color schema for showing information. However, sometimes it is difficult to read (especially for color blind people), such as below
{% asset_img "Difficult to read the dark red text.png" "Difficult to read the dark red text" %}

You can modify the color schema by editing the C:\Users\yourname\.gitconfig file as below

<!-- more -->
```bash
[color]
  ui = true
[color "status"]
  added = yellow
  changed = green
  untracked = cyan
```

Now it is much easier to read.
{% asset_img "Easier to read.png" "Easier to read" %}

Done.

