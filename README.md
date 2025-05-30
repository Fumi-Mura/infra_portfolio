# This is my Terraform sample

## System configuration chart

todo

## Directory structure

Pattern A is adopted in this repository.
Pattern B used if resources are few, or files under env can be combined into a single main.tf file.
The selection criterion depends on which unit the tfstate file is divided into.
The more resources are managed in one state file, the longer the execution time when plan/apply, etc. without specifying a target.
Too much division makes it hard to write source code, but the more resources you have, the greater the benefit.

If you further divide environments/{env} into ecr/・/ecs, etc., it is not possible to pass values between modules as shown below (directory design depends on the concept of tfstate division).
Instead, terraform_remote_state source or data source should be used.
The terraform_remote_state is a reference from the state, so there is no need to call the API. data resource is not misaligned with the real resource entity.
If there are many directories, it may be easier to manage them by creating a integrate file with reference data directly under environments/{env}.
(In some cases, it is safer to use the data source because terraform_remote_state may not be able to read the old tfstate if the format is changed when tf is updated.)

### Pattern A

```sh
.
├── environmets/
│   ├── dev/
│   │   ├── ecr/
│   │   │   ├── main.tf
│   │   │   ├── backend.tf
│   │   │   ├── provider.tf
│   │   │   └── terraform.tf
│   │   └── ecs/
│   ├── stg/
│   └── prd/
└── modules/
    ├── ecr/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── ecs/
```

### Pattern B

```sh
.
├── environments/
│   ├── dev/
│   │   ├── ecr.tf # If resources are few,  together them in main.tf is ok.
│   │   ├── ecs.tf
│   │   ├── backend.tf
│   │   ├── provider.tf
│   │   └── terraform.tf
│   ├── stg/
│   └── prd/
└── modules/
    ├── ecr/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── ecs/
```

## Naming rule

### Resource name

```sh
name = {env}-{service_name}-{role}-{resource_name} # ex: dev-fumis-pf-oidc-iam-role
```

### Module user side name

Follow resource name rule.

```sh
module "{role}_{resource_name}" # ex: module "oidc_iam_role"
```

## Outside source code control

- S3 bucket for terraform.tfstate
  - If use CFn(terraform/aws/tfstate/tfstate_s3_bucket.yml)
- AWS Organizations
  - Enable Organizations
  - Terraform not yet supported
- IIC
  - Enable IIC
  - Enable sent OTP when Create UserAPI
  - Enable mfa
  - Sent verify Email(success sent email when manual make user...?)
  - Terraform not yet supported
- SSM Parameter Store
  - ${email_local_pert} added manually

## Tools

- tfenv(manage Terraform version)
- tflint
- trivy
- terraform-docs
- Infracost
- direnv
- aqua
- draw.io

## Static Analysis

### TFLint

```sh
terraform-sample $ tflint --recursive --format compact
# The error below appears in the module. Ignore it ok because it is specified on the use side. (Even if set the disable setting in tflint.hcl, the error appears...)
# terraform_required_providers, terraform_required_version
```
