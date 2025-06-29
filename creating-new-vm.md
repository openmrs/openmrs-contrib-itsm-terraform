# Creating a new machine

## Empty machine
1. Choose a [name and tier](https://github.com/openmrs/openmrs-contrib-itsmresources/wiki/Guidelines-for-New-Servers)
2. run `./build.rb create <vm-name>`
3. edit `variables.tf` and update all values needed. Ensure ansible is _not_ enabled
4. if this machine has backups, edit `output.tf` and uncomment the section about AWS keys
5. edit `global-variables.tf` file with the latest image for Ubuntu 22 available [console](https://js2.jetstream-cloud.org/project/images). The image ID is constantly being updated
6. running `./build.rb plan <vm-name>` and `./build.rb apply <vm-name>` should create the machine. This machine does _not_ have regular SSH users yet, but can be accessible via :
```
$ ssh -i conf/provisioning/ssh/terraform-api.key root@<machine>
```
7. run `./build.rb docs`, `./build.rb plan docs` and `./build.rb apply docs` to update documentation
8. Commit and push changes in this repo


## Running ansible for the first time
When running terraform for the first time, it will create files in `/etc/ansible/facts.d/` w, so these variables can be picked by ansible later on. This files may not be updated by terraform changes. 

1. Go to Ansible repo, and add this machine into the inventories and host vars (both encrypted and not). Commit the changes and push them to the `master` branch in github
2. Change the `variables.tf` to run ansible. `./build.rb plan <vm-name>` and `./build.rb apply <vm-name>` should apply ansible for the first time
3. From now on, all ansible runs can be as usual. Check [docker compose docs](https://github.com/openmrs/openmrs-contrib-itsmresources/wiki/How-to-deploy-new-docker-compose-application) if you are deploying a docker-compose based app
