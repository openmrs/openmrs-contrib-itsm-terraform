# Initial setup
Create bucket manually on AWS (versioned)

# Each person
Get added to git crypt
Get TACC creds
Get AWS creds (with write access to the bucket)


brew install terraform
brew install git-crypt
cp conf/openrc-personal-example /conf/openrc-personal
And edit it

```
source ./conf/openrc
cd base
terraform init
```



```
source ./conf/openrc
terraform plan
```
