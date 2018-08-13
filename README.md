# Description
This repository is the definition of OpenMRS community infrastructure (infra-as-code).
We are using terraform to generate network infra, Openstack VMs (Jetstream IU and TACC), DNS and backup resources.

You can also check <https://github.com/bmamlin/jetstream-api-cli.git> to check the results in Openstack.

This repository can generate documentation for all VMs created, and it's deployed to
<https://docs.openmrs.org/infrastructure/vms.html> and <https://docs.openmrs.org/infrastructure/vms.json>

Check [Provision new machine](https://github.com/openmrs/openmrs-contrib-itsmresources/wiki/Provision-new-machine) and [Guidelines for New Servers](https://github.com/openmrs/openmrs-contrib-itsmresources/wiki/Guidelines-for-New-Servers) for more details on how to create machines (these docs are not public).



# Requirements
## Credentials
Before you can use this repository, you need:
  - TACC (Jetstream) credentials - check internal wiki for Jetstream access details
  - Be included in git crypt in this repository (to access secrets)


## Software
You need to have installed:
  - [git-crypt](https://github.com/AGWA/git-crypt/blob/master/INSTALL.md)
  - ruby (2.0+)
  - thor (`gem install thor`)

# Development environment setup
To install terraform and initial setup (needed only once)
```
$ ./build.rb install

# add your TACC credentials to conf/openrc-personal
$ vi conf/openrc-personal

# verify file is not encrypted
$ cat conf/openrc

# to init terraform in all VMs (takes time)
$ ./build.rb init_all

# to init terraform in a single VM (e.g. narok)
$ ./build.rb init narok
```

To undo the changes from the previous commands:
```
$ ./build.rb clean
```

To create a new stack _test_:
```
$ ./build.rb create test
```

To run terraform plan (and see what changed on your stack) on a _base-network_ stack:
```
$ ./build.rb plan base-network/
```

To run terraform apply (and apply changes to a stack) on a _base-network_ stack:
```
$ ./build.rb apply base-network/
```

To see all available commands:
```
$ ./build.rb
```


Forcing a VM to be reprovisioned (and keep the data volume):
```
$ ./build.rb taint-vm <stack>
$ ./build.rb plan <stack>
$ ./build.rb apply <stack>
```

To SSH a machine before running ansible:
```
$ ssh -i conf/provisioning/ssh/terraform-api.key root@<machine>
```
After ansible, you should use your regular user.

To completely destroy a VM (and its data volume):

- Edit `modules/single-machine/vm.tf` and edit `prevent_destroy = true` to `prevent_destroy = false`
- Run:
```
$ ./build.rb terraform <stack> "destroy"
```
- Undo changes to `modules/single-machine/vm.tf`


To generate and update VM documentation:
```
$ ./build docs
$ ./build plan docs
$ ./build apply docs
```

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

## Cannot run null_resources via SSH after first ansible run
Ansible configures and secures our SSH configuration, so root cannot SSH anymore.

Change `./global-variables` and use your username and (passphrase-less) key. Do not commit this change.



# Gotchas
  - DNS CNAME records cannot be imported by terraform, so they have to be deleted in our DNS server before using them in a stack.
  - Updating a DNS resource doesn't work in terraform, it appears to be a bug. You need to either delete and create, or change manually.
  - Don't use the DNS redirect. It doesn't support HTTPS.
  - Use _/etc/ansible/facts.d/_ files to export data to ansible. If the files should be modified, you can do it manually.

# Resources needed by Terraform
Some resources are necessary to run terraform, so they were created manually:
  - S3 bucket to keep terraform state (versioned)
  - User to interact with bucket (access via bucket policy)
  - DNS domains (not defined in terraform provider)
