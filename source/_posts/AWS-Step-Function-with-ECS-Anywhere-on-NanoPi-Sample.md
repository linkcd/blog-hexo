---
title: AWS Step Functions with ECS Anywhere on NanoPi Sample
date: 2022-02-02 14:31:24
tags:
- AWS
- Step Functions
- ECS Anywhere
- Nano Pi
- IoT
---
This is a demo solution that is using [AWS Step Functions](https://aws.amazon.com/step-functions/) and [ECS Anywhere](https://aws.amazon.com/ecs/Anywhere/) to complete a simple data processing task by using cloud orchestration (Step Functions) and local computing resources (a NanoPi). 

## Data flow
1. User upload a file to a s3 bucket
2. S3 triggers step functions via cloudtrail and event bridge
3. Event bridge triggers a step function state machine
4. State machine triggers a ECS Anywhere task to download the file from s3 to local (to do some processing), if file name matches condition

## Architecture
{% asset_img "architecture.png" "architecture" %}

## NanoPi that runs ECS Anywhere
{% asset_img "nanopi.jpg" "nano pi" %}
[NanoPi Neo2](https://wiki.friendlyarm.com/wiki/index.php/NanoPi_NEO2) with LED hat in my home office, running AWS ECS Anywhere.

<!-- more -->

## Source code
All source code can be found at https://github.com/linkcd/step-function-with-ecs-Anywhere-example

## 1. Build a docker image as the ECS Anywhere task
As in this demo, the ecs Anywhere is running on a Nanopi, it should be build on the Pi as it is ARM architecture
```bash
# In nano pi ssh
cd ./container-for-ecs-task
docker build -t linkcd/s3downloader:arm .
docker login
docker push linkcd/s3downloader:arm 
```
Then push to public repository so ECS cluster can download (public docker hub or private ECR)

## 2. Setup ECS Anywhere and tasks
- Setup ECS Anywhere cluster on Nanopi
- Create an ECS execution role that has permission to download file from s3
- Create an ECS task (see [ecs-task-definition.json](https://github.com/linkcd/step-function-with-ecs-Anywhere-example/blob/master/ecs-task-definition.json)) that refers to linkcd/s3downloader:arm image

## 3. Create a step function state machine
- Create a state machine (see [state-machine-definition.json](https://github.com/linkcd/step-function-with-ecs-Anywhere-example/blob/master/state-machine-definition.json))
- As we need to wait for ecs task finish, step function requires permission as in [here](https://docs.aws.amazon.com/step-functions/latest/dg/ecs-iam.html)
- Follow [the steps](https://docs.aws.amazon.com/step-functions/latest/dg/tutorial-cloudwatch-events-s3.html) for setting up s3 triggers step functions via cloudtrail and event bridge

### 3.1 ECS task details:
#### (1). Start: 
The s3 upload event is captured by cloudtrail, which triggers and pass the event data to step function. 
#### (2). Extract S3 event 
This PASS step extract the needed info (bucket name and file key). Output is
```json
{
  "bucketName": "the_bucket_name_from_event",
  "fileKey": "the_file_key_from_event"
}
```
#### (3). Choice
The CHOICE step check the file key and trigger the ECS task ONLY IF the file key matches "demo*.txt"
#### (4). ECS RunTask
This ECS RunTask update the input paramater (adding s3:// prefix to bucket name), then pass the parameters to ecs Anywhere task via environment variables.
#### (5). End
Once the ecs Anywhere task is finished, the downloaded file can be found in the ecs Anywhere local file system (in this case, the file is in /data)

## 4. Side notes
In ECS RunTask in Step Functions, override command cannot pass multiple parameters. In our case we would like to use aws cli docker for simple aws cli s3 download. However if we override the command to "s3 cp x y" in ECS RunTask step in State Machine, these 4 parts will NOT be passed as individual 4 parameters but ONE parameter that contains all. AWS cli cannot accept that. 

Incorrect value that passed via override command 
```json
  "Args": [
      "s3 cp x y"
  ]
```
Correct call if we directly use aws cli docker from terminal
```json
  "Args": [
      "s3",
      "cp",
      "x",
      "y",
  ]
```
Therefore we use environment variables to make sure we can pass parameters to ecs container task separately (it means we have to use [our own container](https://github.com/linkcd/step-function-with-ecs-Anywhere-example/blob/master/container-for-ecs-task/Dockerfile))