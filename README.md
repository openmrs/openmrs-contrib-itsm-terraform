# Description
This repository is the definition of OpenMRS community infrastructure (infra-as-code).
We are using terraform to generate network infra, Openstack VMs (Jetstream IU and TACC), DNS and backup resources.

You can also check <https://github.com/bmamlin/jetstream-api-cli.git> to check the results in Openstack. 

# Requirements
## Credentials
Before you can use this repository, you need:
  - TACC (Jetstream) credentials - check internal wiki for Jetstream access details
  - Be included in git crypt in this repository (to access secrets)


## Software
You need to have installed:
  - [git-crypt](https://github.com/AGWA/git-crypt/blob/master/INSTALL.md)
  (use `git crypt status` to verify your access to encrypted files)
  - ruby (2.0+)
  - thor (`gem install thor`)

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

To create a new stack _test_:
```
./build.rb create test
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


Forcing a VM to be reprovisioned:
```
./build.rb terraform <stack> "taint -module single-machine openstack_compute_instance_v2.vm"
./build.rb terraform <stack> "taint -module single-machine null_resource.mount_data_volume"
./build.rb terraform <stack> "taint -module single-machine null_resource.provision"
./build.rb terraform <stack> "taint -module single-machine null_resource.ansible"
./build.rb plan <stack>
./build.rb apply <stack>
```

To SSH a machine before running ansible:
```
ssh -i conf/provisioning/ssh/terraform-api.key root@<machine>
```
After ansible, you should use your regular user.


# Repository organisation
  - _build.rb_: build helper (thor) file
  - _conf/_ : configuration files and authentication files
  - _conf/template-stack_: base files used when creating new stacks
  - _conf/provisioning_: keys and helpers to run ansible when provisioning a machine. Each
  - _modules/_: terraform modules
  - _modules/single-machine_: terraform module to generate a machine, with a A DNS record.
  - _global-variables.tf_: global terraform variables symlinked on each stack
  - _base-network/_ : stack basic infrastructure (network, subnets, routers)
  - _other-stacks/_: each machine should have a directory defined in here. Each folder should be a different state/stack file.

Each stack should be more or less:
  - _main.tf_: terraform resources
  - _outputs.tf_: stack outputs (can be used by other stacks as input params)
  - _variables.tf_: terraform variables
  - _global-variables.tf_: symlink to the top level global file.

# Troubleshooting

## Could not create DNS entries
- Verify that the entry doesn't already exist in our DNS provider.

## Ansible over SSH / File resources/ Remote exec not working after ansible aplied

That's caused by SSH server configuration incompatible with terraform.

 - Edit `/etc/ssh/sshd_config`:
```
KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256
```
 - Restart sshd  `service sshd restart`


# Guidelines
  - For OpenMRS, we have used city names from Cameroon and Kenya for most of our server names.
  - Within Jetstream, all server names should be in the form ${OS_PROJECT_NAME}-servername by Jetstream convention. More details on Jetstream can be found in <https://github.com/openmrs/openmrs-contrib-itsmresources/wiki/Provider-Jetstream>.
  - Check <https://github.com/openmrs/openmrs-contrib-itsmresources/wiki/Migration-to-Jetstream> for more details on migration to terraform/jetstream.
  - Note that DNS CNAME records cannot be imported by terraform, so they have to be deleted in our DNS server before using them in a stack.

# Resources needed by Terraform
Some resources are necessary to run terraform, so they were created manually:
  - S3 bucket to keep terraform state (versioned)
  - User to interact with bucket (access via bucket policy)
  - DNS domains (not defined in terraform provider)
