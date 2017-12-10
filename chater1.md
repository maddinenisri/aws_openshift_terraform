## Install terraform, if not exists
```
brew install terraform
```

## Install awscli, if not exists
```
brew install awscli
```
## Create "~/.aws/aws-credentials.tfvars" aws credentials details ( Note:- Don't use current directory, to avoid accendtal checkin)
Note:- Credential Id has full permissions to create, read and destroy infrastructure.
```
provider = {
  access_key_id="<AWS_ACCESS_KEY>"
  secret_key="<AWS_SECRET_KEY>"
  region="<region>"
}
```
## Create "provider-config.tf" file in current directory
```
provider "aws" {
    access_key = "${var.provider["access_key"]}"
    secret_key = "${var.provider["secret_key"]}"
    region     = "${var.provider["region"]}"
}
```






