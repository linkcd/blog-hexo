---
title: Implementing Secret-less Access to Azure and AWS with Azure Managed Identities and AWS IAM
date: 2024-09-18 14:49:21
tags:
- Security
- Azure
- AWS
- Idp
- IAM 
- Managed Identity
- Entra ID
--- 
## 1. User case
Nowadays, it is common for companies to operate in multi-cloud environments, such as Azure and AWS. They often use Microsoft Entra ID (formerly Azure Active Directory) as their centralized identity provider (IdP), managing identities for both **human users** and **applications**. They would like to use the Entra ID identities to access resources in AWS.

Establishing human user identity access across Azure and AWS is straightforward. The IT department can use [AWS IAM Identity Center](https://aws.amazon.com/iam/identity-center/) to allow users from Microsoft Entra ID to sign-in to the AWS Management Console with Single Sign-On (SSO) via their browser. This integration simplifies authentication, offering a seamless and secure user experience across both Azure and AWS environments. For more information, you can read [this document](https://docs.aws.amazon.com/singlesignon/latest/userguide/idp-microsoft-entra.html).

However, the browser-based SSO approach for human users does not apply to applications.

For applications, developers follow security best practices by using cloud-native IAM (Identity and Access Management) mechanisms to manage resource access. In AWS, this mechanism is [AWS IAM](https://aws.amazon.com/iam/), while in Azure, it is typically [Azure Managed Identity](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview). For example, by leveraging Azure Managed Identity, developers can build applications in Azure without the need to manage secrets or keys.

This approach is known as **secretless access** to cloud resources. 

AWS IAM and Azure Managed Identity work well within their respective platforms, but there are cross-cloud scenarios where a workload in one cloud needs to access resources in another. For instance, an Azure Function might need to save data to both an Azure Storage account and an AWS S3 bucket for cross-cloud backup. The Azure Function uses Managed Identity to access the Azure Storage account. For accessing S3, the developer could create an IAM user and store the IAM user credentials. However, there is a better way to achieve secretless access to both Azure and AWS resources using the same Azure Managed Identity.

{% asset_img "problem.png" "The problem of using Azure Managed Identity to access S3" %}

## 2. Solution
In AWS, there are multiple ways to request temporary, limited-privilege credentials by using [AWS Security Token Service (AWS STS)](https://docs.aws.amazon.com/STS/latest/APIReference/welcome.html), such as [AssumeRoleWithSAML](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithSAML.html) and [AssumeRoleWithWebIdentity](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html).

The post will explain how to use [AssumeRoleWithWebIdentity](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html.) and [IAM Web Identity Role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html) to extend the permissions of the same Azure Managed Identity to also access AWS resources.  

We will build an Azure Function with a managed identity, either User-Assigned Managed Identity (UAMI) or System-Assigned Managed Identity (SAMI), to read objects from both an Azure Storage account and an AWS S3 bucket. This same managed identity will work in both Azure and AWS, eliminating the need to manage additional secrets such as AWS IAM user credentials.

The source code is published at github https://github.com/linkcd/Secretless-cross-cloud-access

{% asset_img "architecture.png" "Architecture" %}

<!-- more -->

## 3. Step by step instruction
### 3.1 Create Azure functions and managed identities
1. Create function **CrossCloudAccessFunction-SAMI**: System-Assigned Managed Identity (SAMI)
  - In the management panel, enable SAMI
{% asset_img "azure function sami.png" "" %}

2. Create function **CrossCloudAccessFunction-UAMI**: User-Assigned Managed Identity (UAMI)
  - Create a UAMI named *UAMI-CrossCloudAccess-Identity* 
  - Assign the identity *UAMI-CrossCloudAccess-Identity* to Azure function *CrossCloudAccessFunction-UAMI*
{% asset_img "azure function uami.png" "" %}

Note: it is possible to have multiple UAMI or mix between UAMI/SAMI for one Azure function. Depends on which credential (either SAMI, or one of the UAMIs) you use for calling API, you will have different permission to access different resources, depends on what credential you create in the code.

### 3.2 Look for the Object IDs of SAMI and UAMI
We need to take note of the Object IDs of the SAMI and UAMI. These IDs will be used when assign access to an Azure application role. We also need to take note of the Entra ID tenant ID.

1. **SAMI** Object ID
- Go to Azure Portal -> Entra ID -> Enterprise applications
- Remove the filter "Application type == Enterprise applications"
- Search for the name of Azure Function with SAMI: *CrossCloudAccessFunction-SAMI*
- Take note of the Object ID. In this case "SAMI-object-id-a43c24bd12f5" 
{% asset_img "SAMI object id.png" "" %}

2. **UAMI** Object ID
- Go to Azure Portal -> Managed Identity -> *UAMI-CrossCloudAccess-Identity*
- You can directly get the client ID of UAMI in its own property page. 
- In this case, it is "UAMI-object-id-0293fe81ee59"
{% asset_img "UAMI object id.png" "" %}

3. Get Entra ID tenant 
- [Find your Entra ID tenant ID](https://learn.microsoft.com/en-us/entra/fundamentals/how-to-find-tenant)
{% asset_img "tenant id.png" "" %}


### 3.3 Create Azure application and assign managed identities to its role 
1. Go to Azure Portal -> Entra Id -> Enterprise applications -> New Application 
2. Select "Create your own application" and name it as "AWS-Federation-App"
{% asset_img "create new entra app.png" "" %}
3. (**Important**) Turn on the "User assignment required" to make sure only identities assigned to the application can get a token for the application audience. It means users and other apps or services must first be assigned this application before being able to access it.
{% asset_img "enable assignment required.png" "" %}
4. Create an application role "AssumeAWSRole"
{% asset_img "create application role.png" "" %}
5. Add an Application ID URI "api://AWS-Federation-App"
{% asset_img "create app id uri.png" "" %}
6. Finally, assign the managed identities access to the application role 
Follow the steps in the [document](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-to-assign-app-role-managed-identity?pivots=identity-mi-app-role-powershell) to assign the managed identities access to the application role 
```powershell
# Your tenant ID (in the Azure portal, under Azure Active Directory > Overview).
$tenantID = '<tenant-id>'

Connect-MgGraph -TenantId $tenantId -Scopes 'Application.Read.All','Application.ReadWrite.All','AppRoleAssignment.ReadWrite.All','Directory.AccessAsUser.All','Directory.Read.All','Directory.ReadWrite.All'

# the managed identity object Id of SAMI or UAMI
$managedIdentityObjectId = "SAMI-object-id-a43c24bd12f5" #SAMI
# $managedIdentityObjectId = "UAMI-object-id-0293fe81ee59" #UAMI

# The name of the server app that exposes the app role.
$serverApplicationName = "AWS-Federation-App" #Entra ID Enterprise App Name

# The name of the app role that the managed identity should be assigned to.
$appRoleName = 'AssumeAWSRole' 

# Look up the details about the server app's service principal and app role.
$serverServicePrincipal = (Get-MgServicePrincipal -Filter "DisplayName eq '$serverApplicationName'")
$serverServicePrincipalObjectId = $serverServicePrincipal.Id
$appRoleId = ($serverServicePrincipal.AppRoles | Where-Object {$_.Value -eq $appRoleName }).Id

# Assign the managed identity access to the app role.
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $serverServicePrincipalObjectId -PrincipalId $managedIdentityObjectId -ResourceId $serverServicePrincipalObjectId -AppRoleId $appRoleId
```
7. Verify that the UAMI and SAMI are users of the application
{% asset_img "entra id app users.png" "" %}

### 3.4 Setup federation between the Azure application role and AWS IAM
1. Go to AWS console, then head to IAM
2. Click "Identity providers" and add an "OpenID Connect" provider
3. **Provider URL**: https://sts.windows.net/[your-azure-tenant-id]/ (note: make sure you add "/" at the end of the URL) 
4. **Audience**: Application ID URI "api://AWS-Federation-App"
{% asset_img "add idp to aws.png" "" %}

### 3.5 Create AWS S3 bucket and related AWS IAM Role for accessing S3
1. Create an AWS S3 bucket
2. Go to AWS IAM, create new Role for access S3
3. **Trusted entity**: the OpenID Connect Idp that we just created
4. **Audience**: "api://AWS-Federation-App"
{% asset_img "s3 role 1.png" "" %}
5. Assigning the s3 read-only permission (**NOTE: It grants the read-only permission to ALL s3 buckets. Do NOT use it in your production workload**)
{% asset_img "s3 role 2.png" "" %}
6. Name this role as "**S3AccessRoleFromAzure**"
{% asset_img "s3 role 3.png" "" %}
7. Take notes of ARN of these AWS IAM Roles. Azure function need it for assuming the role.
  - arn:aws:iam::[YOUR_AWS_ACCOUNT_NUMBER]:role/S3AccessRoleFromAzure
  {% asset_img "sa role arn.png" "" %}

### 3.6 Create Azure storage account and setup permission for managed identities
1. Create an Azure storage account and upload some test files into a container named *mycontainer*.
2. In the storage account management panel, grant UAMI and SAMI “Storage Blob Data Contributor/Owner” Role 
(Note, the simple “Owner” role of storage account top level is NOT enough for read/write blobs in container), see [document](https://learn.microsoft.com/en-us/azure/storage/common/storage-auth-aad-app?tabs=dotnet))

### 3.7 Update Azure function source code 
Now we got everything ready, time to work on the source code of Azure functions.

Both SAMI and UAMI based functions use the [same code base](https://github.com/linkcd/Secretless-cross-cloud-access/tree/main/AzureFunction), as there are only a difference of getting AzureCredential between SAMI and UAMI. If you know for sure which type of managed identity you are using, you can remove the if/else condition to optimize the code.

In addition to the [run.csx](https://github.com/linkcd/Secretless-cross-cloud-access/blob/main/AzureFunction/run.csx), also use [function.proj](https://github.com/linkcd/Secretless-cross-cloud-access/blob/main/AzureFunction/function.proj) to include AWS SDK for calling AWS APIs.

screenshot of run.csx
{% asset_img "azure function run csx.png" "run.csx" %}

screenshot of function.proj
{% asset_img "azure function proj.png" "function.proj" %}

### 3.8 Test
1. Now we have files both in Azure storage account and in AWS S3
{% asset_img "azure files.png" "" %}
{% asset_img "s3 files.png" "" %}

2. Call the Azure Functions
Use the sample input Json for [UAMI](https://github.com/linkcd/Secretless-cross-cloud-access/blob/main/AzureFunction/sample-request-UAMI.json) and [SAMI](https://github.com/linkcd/Secretless-cross-cloud-access/blob/main/AzureFunction/sample-request-SAMI.json) when you are calling the Azure Functions. (Remember to replace the placeholder parameters with correct values.)

The azure function prints the JWT in the log, it looks like
``` json
{
  "aud": "api://AWS-Federation-App",
  "iss": "https://sts.windows.net/<azure-tenant-id>/",
  "idp": "https://sts.windows.net/<azure-tenant-id>/",
  "appid": "<managed-identity-client-id>",
  "oid": "<managed-identity-object-id>",
  "roles": [
    "AssumeAWSRole"
  ],
  "sub": "<managed-identity-object-id>",
  ...
}
``` 
3. Successfully load data from both Azure and S3
{% asset_img "demo screenshot.png" "" %}

## Conclusion
By following this post, you can continue using Entra ID as a single IdP, covering both AWS and Azure. This approach not only reduces management overhead but also enhances security in a multi-cloud scenario.

## Also read:
- [Access AWS resources using Azure AD Managed Identity](https://blog.identitydigest.com/azuread-access-aws/)
- [Automating OpenID Connect-Based AWS IAM Web Identity Roles with Microsoft Entra ID](https://aws.amazon.com/blogs/apn/automating-openid-connect-based-aws-iam-web-identity-roles-with-microsoft-entra-id/)


###### Disclaimer
*This blog is intended solely for educational purposes and reflects the personal views and opinions of the author. The content provided here is not intended to be, nor should it be construed as, official guidelines or professional advice on security matters. Readers are encouraged to seek professional guidance for specific security concerns. The author assumes no responsibility or liability for any errors or omissions in the content of this blog.*


