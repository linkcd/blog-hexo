---
title: Using python to organize pictures
date: 2017-06-07 19:46:05
tags: 
-	Python
-	Scripting
---
## Problem ##

Having several digital cameras is fun: you can have different photography experiences. 

However, organizing  pictures is far less interesting, especially if you do not have a consistent process (like naming convention) for archiving. After several years, I end up with hundred thousand pictures sitting in messy huge folders:

- Nikon_Pictures
- Backup_SDCard01
- 100_0302
- DCIM_From_Old_Phone
- 100CANON
- Backup-Photo
- etc...

The most tricky part, is that I have so many duplicate pictures everywhere due to inconsistent archiving during years. It is so messy that I never dare to manually clean them up. 

{% asset_img "keep-calm-and-organize.png " "picture credit: news.heart.org" %}

Naturally, the knowledge of programming came to my rescue. This time, it is Python.

<!-- more -->

## Solution ##
Long story short, I am using **Python 3**, and a lib **exifread** for extracting exif data from pictures.

You can install exifread by running below command
```bash
pip install exifread
```

Then, here comes the ~100 line of code:
- **sourceRootFolder** and **targetRootFolder** specify the source and target folders (sorry, I am too lazy to parametric them)
- It extracts camera model and create a folder with same name, such as **NIKON D40**. It also works with smart phones, like **Nokia 925**. 
- It extracts picture date, then create sub-folder with YYYY-MM format.
- Move the picture to that sub-folder. If there is already a file with same file name in the target folder, move this file to a backup folder. If the backup folder also have the same file, do nothing.
- It never delete any pictures. 

```python
import exifread
import os
import pdb
import shutil

sourceRootFolder = "c:\\data\\source_photo"
targetRootFolder = "c:\\data\\photo_archive"


def Do(root):
    for dirpath, dirnames, filenames in os.walk(root):
        for f in filenames:
             filepath = dirpath + "\\" + f
             processFile(filepath, f)

def processFile(sourceFilePath, filename):
    targetFolder = getTargetFolder(sourceFilePath, filename)
    processMoveBusiness(sourceFilePath, targetFolder, filename)

def getTargetFolder(filepath, filename):
    currentFile = open(filepath, 'rb')
    tags = exifread.process_file(currentFile)

    cameraTag = "Image Model"
    if cameraTag in tags:
        camera = str(tags[cameraTag])
        if not camera:
            camera = "Unknown"
    else:
        camera = "Unknown"

    shootTimeTag = "EXIF DateTimeOriginal"
    #shootTimeTag = "EXIF DateTimeDigitized"
    if shootTimeTag in tags:
        shootTime = str(tags[shootTimeTag])
        if not shootTime:
            shootTime = "0000:00 0000:0000"
    else:
        shootTime = "0000:00 0000:0000"
        #pdb.set_trace()

    dateArray = shootTime.split(" ")[0].split(":")
    year = dateArray[0]
    month = dateArray[1]
    return targetRootFolder + "\\" + camera.strip() + "\\" + year + "-" + month
    
def processMoveBusiness(sourceFilePath, targetFolder, filename):
    targetFolderBackup = targetFolder + "\\backup"
    #make sure target folders exits
    if not os.path.isdir(targetFolder):
        os.makedirs(targetFolder)

    firstAttemptFilePath = targetFolder + "\\" + filename
    print(firstAttemptFilePath)
    if os.path.isfile(firstAttemptFilePath):
        #check if we can move to the backup
        attemptToBackupFilePath = targetFolderBackup + "\\" + filename
        if os.path.isfile(attemptToBackupFilePath):
            #have the same file in the backup folder
            #do nothing
            print ("------[skip]:" + sourceFilePath)
        else:
            #move to backup 
            if not os.path.isdir(targetFolderBackup):
                os.makedirs(targetFolderBackup)
            
            shutil.move(sourceFilePath, attemptToBackupFilePath)
            print (">>>>>>[backup]:" + sourceFilePath)

    else:
        #normal move
        shutil.move(sourceFilePath, firstAttemptFilePath)
        print ("[move]:" + sourceFilePath)


Do(sourceRootFolder)
```

After 20 min, everything is neat! Happy scripting!




