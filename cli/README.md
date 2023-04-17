# IU Jetstream2's API Command Line Tool

Get started quickly with IU Jetstream2's API using Docker. Assuming you have [Docker](https://www.docker.com) and [docker-compose](https://docs.docker.com/compose/install/) installed, you can use the IU Jetstream API without any additional installation.

## Configuration

You will need a few settings from your openrc files to configure your API access.

First, copy `jetstream.env.sample` to `jetstream.env`. You will need to enter some settings into this file that you can get from your `openrc` file. Per 
[the Jetstream2 documentation](https://docs.jetstream-cloud.org/ui/cli/auth/), you can obtain your openrc file as follows:

1. Log into
   [ https://js2.jetstream-cloud.org]( https://js2.jetstream-cloud.org) using XSEDE 
   Globus Auth authentication. The first time you login, you'll need to grant 
   permission to Globus. Log in with your XSEDE credentials. You should end up on  
   the Horizon dashboard.
2. If it's not already selected, select your allocation within the dropdown at the top.
3. Navigate to Identity > Application > Create Application Credentials
4. Enter name like "<Your name> Jetstream2 API credential"
5. Create a secure secret ([long passphrase](https://www.useapassphrase.com/) or [UUID](https://www.uuidgenerator.net/)). 
   Don't use a personal password, since this will be stored in free text within your 
   openrc file.
6. Set an expiration date (e.g., 1-2 years from now). If you don't set an expiration 
   date, the credential will only be valid for one day.
7. Leave Roles and Access Rules blank and Unrestricted unchecked.
8. Create the application credential and download your openrc file.

Within the `openrc.sh` file, you will find the settings needed for your 
`jetstream.env` file.

Replace all instances of `???` in the `jetstream.env` file:

- The value of `OS_AUTH_URL` from your `openrc.sh` file
- The values for `OS_APPLICATION_CREDENTIAL_ID` and `OS_APPLICATION_CREDENTIAL_SECRET` 
  from your `openrc.sh` file.

## Running OpenStack

```bash
$ ./cli.sh
```

This should build the jetstream2 docker image (the first time you run it) and then 
place you at a command prompt at which you can begin using the OpenStack tools. You 
can validate it's working by testing the `os flavor list` command to list out 
available flavors of server instances:

```bash
# os flavor list
+----+-----------+--------+------+-----------+-------+-----------+
| ID | Name      |    RAM | Disk | Ephemeral | VCPUs | Is Public |
+----+-----------+--------+------+-----------+-------+-----------+
| 1  | m3.tiny   |   3072 |   20 |         0 |     1 | True      |
| 2  | m3.small  |   6144 |   20 |         0 |     2 | True      |
| 3  | m3.quad   |  15360 |   20 |         0 |     4 | True      |
| 4  | m3.medium |  30720 |   60 |         0 |     8 | True      |
| 5  | m3.large  |  61440 |   60 |         0 |    16 | True      |
| 7  | m3.xl     | 128000 |   60 |         0 |    32 | True      |
| 8  | m3.2xl    | 256000 |   60 |         0 |    64 | True      |
+----+-----------+--------+------+-----------+-------+-----------+
```