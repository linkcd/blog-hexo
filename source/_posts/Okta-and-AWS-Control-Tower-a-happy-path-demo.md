---
title: Okta and AWS Control Tower - a happy path demo
date: 2021-11-17 20:17:08
tags:
- Okta
- AWS Control Tower
- AWS SSO
- SSO
- AWS
---
This is a [happy path](https://en.wikipedia.org/wiki/Happy_path) demo of setting up [Okta](https://www.okta.com/) as the Idp for [AWS Control Tower](https://aws.amazon.com/controltower/) (via [AWS SSO](https://aws.amazon.com/single-sign-on/)). 
**Goal**: To utilize users and groups in Okta to manage AWS control tower.

{% asset_img "title.jpg" "title" %}

# 1. Create a brand new Control Tower instance 
In this demo, we create the AWS Control Tower instance in a brand new AWS account. During this process, control tower creates several services/components, such as AWS Organizations, AWS SSO, default organizations unit (OU) "Security" and 2 AWS accounts “Log Archive” and “Audit”. 

In the AWS SSO, some default SSO user groups are created for managing Control Tower:
{% asset_img "default SSO user groups.jpg" "default SSO user groups" %}

The default admin user for organization management account is “AWS Control Tower Admin”.
{% asset_img "default master user1.jpg" "default master user1" %}

Detailed user info
{% asset_img "default master user2.jpg" "default master user2" %}

And it belongs to 2 groups: **AWSAccountFactory** and **AWSControlTowerAdmins**
{% asset_img "default master user3.jpg" "default master user3" %}

<!-- more -->

# 2. Setup Okta and use it as the idp of AWS SSO
## 2.1 Create an environment of Okta]
For this demo, we are using a [free developer plan of Okta](https://developer.okta.com/signup/).

## 2.2 Setup Okta as the idp of AWS SSO
Follow the steps in the following document, to use Okta as the idp of AWS SSO. 
**Note that you need to check steps from _both_ documentation to make sure the integration and user provisioning works.**

### 2.2.1 Basic hand-shake, import metadata file from Okta to AWS SSO
**Steps**: [How to Configure SAML 2.0 for AWS Single Sign-on](https://saml-doc.okta.com/SAML_Docs/How-to-Configure-SAML-2.0-for-AWS-Single-Sign-on.html)
{% asset_img "config saml2 for aws sso.jpg" "config saml2 for aws sso" %}

### 2.2.2 Config provisioning and other settings in AWS SSO
**Steps**: [Configure provisioning for Okta in AWS SSO](https://docs.aws.amazon.com/singlesignon/latest/userguide/okta-idp.html)        
{% asset_img "Config provisioning and other settings in AWS SSO.jpg" "Config provisioning and other settings in AWS SSO" %}

## 2.3 The basic setup is ready, but not for users and groups yet
After the basic hand-shake between AWS SSO and Okta, the AWS SSO is now using Okta.
{% asset_img "AWS SSO is now using Okta.jpg" "AWS SSO is now using Okta" %}

In Okta groups UI, you can see identical groups as in AWS SSO are created in Okta. The **Everyone** is a default Okta user group.
{% asset_img "identical groups as in AWS SSO are created in Okta.jpg" "identical groups as in AWS SSO are created in Okta" %}

**Note**: you **cannot** add/remove users to it, as it says “This group is managed automatically by Okta, so you cannot edit it or modify its membership.”
{% asset_img "readonly user groups.jpg" "readonly user groups" %}

# 3. Setup Okta users and groups, push them to AWS SSO

## 3.1 Create user and groups in Okta
Lets create some test users:
{% asset_img "test users.jpg" "test users" %}

We also create user groups in Okta
- **AWS-CT-Admin-Okta-Group**, has 1 user: **Feng** 
- **AWS-CT-Developers-Okta-Group** has 2 users: **Alice** and **Bob** 
{% asset_img "user groups in okta.jpg" "user groups in okta" %}

However, they are not appearing in AWS SSO user list. There is still no Okta user nor Okta group.
{% asset_img "no okta users yet.jpg" "no okta users yet" %}

In order to user the users from Okta, these users need to be assigned to **AWS SSO Application** in Okta.

## 3.2 Assign users and/or groups in Okta
Go to Okta -> Application -> AWS SSO, in **Assignments** tab, you can either assign individual users or user groups. In this screenshot, all users are assigned to AWS SSO via Group (see the **Type** column).
{% asset_img "assign okta users to sso app.jpg" "assign okta users to sso app" %}

Soon, you can see these 3 users appear in AWS SSO interface.
{% asset_img "okta users now in sso.jpg" "okta users now in sso" %}

The detailed info. Note that it was created and updated by **SCIM**.
{% asset_img "okta user detailed info.jpg" "okta user detailed info" %}

Now you can assign them into AWS account, so the user can login to AWS console via login to Okta.
{% asset_img "grant permission to okta user.jpg" "grant permission to okta user" %}

## 3.3 Push groups from Okta to AWS SSO
Now we can grant permission for individual Okta users. But how about Okta group? These new okta groups are not available in AWS SSO yet. And the groups with identical names from AWS SSO is not helping, as we cannot add users into it.
{% asset_img "missing okta group.jpg" "missing okta group" %}

To solve this, we need to push the Okta groups to AWS SSO by setting up the “**Push Groups**”.

Go Okta > Application > AWS SSO, in tab “**Push Groups**”, here you can push group by name, or setup roles for batch pushing.

In this demo, we setup a rule named "Pust-AWS-Related-Groups" for pushing any group that starts with “**AWS-**”
{% asset_img "push group rule.jpg" "push group rule" %}

Soon, these groups were pushed to AWS SSO:
{% asset_img "group push logs.jpg" "group push logs" %}

{% asset_img "okta groups available now.jpg" "okta groups available now" %}

Now you can also grant permission to groups, such as every Okta user in **AWS-CT-Admin-Okta-Group** now have permission as AWS control tower admin.
{% asset_img "grant permission to groups.jpg" "grant permission to groups" %}

EoF.