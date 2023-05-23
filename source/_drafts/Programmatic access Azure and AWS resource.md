**Blog**
-- Participators: Feng Lu and Martin Pagel

Titles:
- Azure hosted applications access AWS services without managing any secrets
- Using the same Azure managed identity to access both Azure and AWS services secretlessly

Backup titles:
- Using Azure managed identity to access AWS services without managing secrets
- Programmatic access Azure and AWS services without managing any secrets


Many organizations are establishing their multi-cloud strategy across Azure and AWS. Today the IT departments are using Azure Active Directory (Azure AD) as the identity provider (idp), for managing all user credentials and application Service principals.

The organization need to access the resources from both Azure and AWS cloud providers in a secure and manageable way. There are 2 type of access across different cloud providers:

1. An end-user need to access service by using a browser on the laptop, such as access Azure Portal or AWS console. This can be done easily by using [AWS IAM Identity Center (Successor to AWS Single Sign-On)](https://aws.amazon.com/iam/identity-center/). 

2. An application need to programmatically access services across Azure and AWS

This article is to demonstrate an approach programmatically access service across Azure and AWS, but without managing any secrets such as Azure client secrets and AWS IAM user key and secrets.


### Setup
- An application is hosted in azure, such as Azure App service or Azure Function. 
- It is using [managed identities in azure](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) to secure communication between services in Azure.

### Goal
- The application need to the use the same managed identity in azure to securely communicate with AWS resources.  

