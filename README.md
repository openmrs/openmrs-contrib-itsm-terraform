# Description
This repository is the definition of OpenMRS community infrastructure (infra-as-code).
We are using terraform to generate Openstack, DNS and other resources.

# Requirements
## Credentials
Before you can use this repository, you need:
  - TACC (Jetstream) credentials
  - Be included in git crypt in this repository (to access secrets)

## Software
You need to have installed:
  - [git-crypt](https://github.com/AGWA/git-crypt/blob/master/INSTALL.md)
  (use `git crypt status` to verify your access to encrypted files)
  - ruby (2.0+)
  - thor (`gem install thor`)

# Repository organisation
  - _build.rb_: build helper (thor) file
  - _conf/_ : configuration files and authentication files
  - _modules/_: terraform modules
  - _global-variables.tf_: global terraform variables symlinked on each stack
  - _base-network/_ : stack basic infrastructure (network, subnets, routers)
  - _other-stacks/_: each machine should have a directory defined in here. Each folder should be a different state/stack file.

Each stack should be more or less:  
  - _main.tf_: terraform resources
  - _outputs.tf_: stack outputs (can be used by other stacks as input params)
  - _variables.tf_: terraform variables
  - _global-variables.tf_: symlink to the top level global file.

# Development environment setup
To install terraform and initial setup (needed only once)
```
./build.rb install   
# add your TACC credentials to conf/openrc-personal
./build.rb init
```

To undo the changes from the previous commands:
```
./build.rb clean
```

To run terraform plan (and see what changed on your stack) on a _base-network_ stack:
```
./build.rb plan base-network/  
```

To run terraform apply (and apply changes to a stack) on a _base-network_ stack:
```
./build.rb apply base-network/  
```

To see all available commands:
```
./build.rb
```

# Resources used by Terraform
Some resources are necessary to run terraform, so they were created manually:
  - S3 bucket to keep terraform state (versioned)
  - User to interact with bucket (access via bucket policy)
  - DNS domains (not defined in terraform provider)
