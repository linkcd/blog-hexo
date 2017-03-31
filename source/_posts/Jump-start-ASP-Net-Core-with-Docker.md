---
title: Jump-start ASP.Net Core with Docker
date: 2017-03-31 20:15:27
tags:
	- Docker
	- ASP.Net Core
---
# Environment Setup #
I have a typical developers environment: Windows 10 Enterprise X64 (Version *1511*, OS build *10586.839*). Installed DotNet Core *1.0.1* and VS Code. In VS Code there are two extension installed. 
{% asset_img "VS Code extensions.png" "VS Code extensions" %}

## Enable Hyper-V ##
VirtualBox is no longer needed! Simply enable the Hyper-V on on Windows 10 by running powershell commands (as Administrator)
```bash
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
DISM /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V
```
You might need to change the BIOS setting. Read more at [here](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v).

**Note**:
The [document from Docker](https://docs.docker.com/docker-for-windows/troubleshoot/#virtualization-must-be-enabled) also mentioned that the virtualization must be enabled, and said you can verify it in the Task Manager. However, I can not find "Virtualization" label in my Task Manager. But the following steps work fine anyway. 


## Install Docker ##
Head to [Docker official site](https://www.docker.com/), download and install Docker for Windows. The version I installed was *17.03.1-ce, build c6d412e Community Edition*, via Edge channel. 

Lets verify it.
{% asset_img "Verify docker.png" "Verify Docker" %}

<!-- more -->

# Build ASP.Net Core Application #
With (new version of) dotnet core, you can simply use command line for creating an web application. 
```bash
C:\Private>md aspnetcore_docker
C:\Private>cd aspnetcore_docker
C:\Private\aspnetcore_docker>dotnet new mvc
C:\Private\aspnetcore_docker>dotnet restore
```

Open this foler with VS Code. If it asked to add "Required assets to build and debug", click Yes.
{% asset_img "Source code in VS Code.png" "Source code in VS Code" %}


## Debug and verify ##
You can F5 to make sure the source code works.
{% asset_img "Running from local.png" "Running from local" %}

If you saw error as below:
{% asset_img "Error in Launchjson file.png" "Error in Launch.json" %}

double check your auto-generated .vscode\launch.json file. It should looks like below
```Csharp
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": ".NET Core Launch (web)",
            "type": "coreclr",
            "request": "launch",
            "preLaunchTask": "build",
            "program": "${workspaceRoot}/bin/Debug/netcoreapp1.1/aspnetcore_docker.dll",
            "args": [],
            "cwd": "${workspaceRoot}",
            "stopAtEntry": false,
            "launchBrowser": {
                "enabled": true,
                "args": "${auto-detect-url}",
                "windows": {
                    "command": "cmd.exe",
                    "args": "/C start ${auto-detect-url}"
                },
                "osx": {
                    "command": "open"
                },
                "linux": {
                    "command": "xdg-open"
                }
            },
            "env": {
                "ASPNETCORE_ENVIRONMENT": "Development"
            },
            "sourceFileMap": {
                "/Views": "${workspaceRoot}/Views"
            }
        },
        {
            "name": ".NET Core Attach",
            "type": "coreclr",
            "request": "attach",
            "processId": "${command:pickProcess}"
        }
    ]
}
```

## Publish ##
Once you are happy with your app, compile it with Release mode and save the package to "Publish" folder
```bash
C:\Private\aspnetcore_docker>dotnet publish -c Release -o Publish
```
{% asset_img "Publish folder.png" "Publish folder" %}
You can also run it without VS code
```bash
C:\Private\aspnetcore_docker\Publish>dotnet aspnetcore_docker.dll
```

# Run the application in Docker #
## Create the dockerfile ##
Be familiar with VS Code short-cut "Ctrl+Shift+P" to popup the Command Palette, then start typing "Docker "
{% asset_img "Access shortcuts in Command Palette.png" "Access shortcuts in Command Palette" %}

The add dockerfile command will generate 3 files at current root folder:
- 	Dockerfile
- 	docker-compose.yml
- 	docker-compose.debug.yml
**Note**:
We only need to work with Dockerfile in this case. You can even remove these 2 yml files.

### Understand the dockerfile ###
By default the Dockerfile is like below
{% asset_img "Default Dockerfile.png" "Default Dockerfile" %}

We will change it to:
```bash
FROM microsoft/aspnetcore:1.1.1
LABEL Name=aspnetcore_docker Version=0.0.1 
ARG source=Publish
WORKDIR /app
EXPOSE 80
COPY $source .
ENTRYPOINT dotnet aspnetcore_docker.dll
```
Translate to English, it can be read as 
1. **FROM**: This image is based from the "mother image" **microsoft/aspnetcore:1.1.1**. This image already contains all the dependencies for running .NET Core on Linux, which is prefect for us. 
2. **LABEL**: Add metadata to this image.
3. **ARG**: Set an variable named "source", and its value is "**Publish**". It is pointing to the published application binary files on local file system. This folder was created by us in above steps.  
4. **WORKDIR**: Set the work directory to "**/app**" inside of the container, which is a Linux system. 
5. **EXPOSE**: tells Docker to expose port **80** on the container.
6. **COPY** application binary files from "**Publish**" folder in local system to the work directory "**/app**" in container. 
7. **ENTRYPOINT**: Set the command to execute when the container starts up. It is the same way that you run this application locally in Windows 10.
(For detailed document, click [here](https://docs.docker.com/engine/reference/builder/)) 

## Build Docker image ##
Again Ctrl+Shift+P to build docker image:
{% asset_img "Build image.png" "Build image" %}
It helps you to write this command (pay attention to the " ." at the end)
```bash
docker build -f Dockerfile -t aspnetcore_docker:latest .
```
{% asset_img "Output of image build.png" "Output of image build" %}

Verfiy that Docker has this image
{% asset_img "Image list.png" "Image list" %}

## Run it from Docker! ##
```bash
docker run -d -p 8090:80 -t aspnetcore_docker:latest
```
- "**-d**": Run container in background and print container ID
- "**-p 8090:80**": Map port 8090 on the host machine to port 80 of the container (Port 80 was specified in Dockerfile)
- "**-t**": Specify the image 

{% asset_img "Run in Docker.png" "Run in Docker" %}

Now you are running ASP.NET Core from Docker
{% asset_img "App in Docker.png" "ASP.NET Core is running in Docker" %}
