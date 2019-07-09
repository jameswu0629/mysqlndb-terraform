# mysqlndb-terraform

Terraform for deploying MySQL NDB Cluster on GCP

## Getting Started

This instruction will get you the information how to setup your environment and deploy a small set of MySQL NDB Cluster on Google Cloud.

### Platform

- Tested on 16.04.1-Ubuntu
- Terraform v0.12.0

### Prerequisites
#### Create your own credentials.json

> Create a service account from IAM

![Alt text](https://drive.google.com/uc?export=view&id=1EFd6V7BGlHKPOSsP0Xf-Kcr5Ib3aOfwX "Create a service account: terraform-user")

> Role as a Project Owner

![Alt text](https://drive.google.com/uc?export=view&id=1FS3UMR5giQyG6_PiCFqypo47d5gGk465 "Create a service account: terraform-user")

> Create and download the key in JSON format

![Alt text](https://drive.google.com/uc?export=view&id=1z-Hm7jnAKDr_8iIiFNcIRBApGYgG5ikH "Create a service account: terraform-user")
