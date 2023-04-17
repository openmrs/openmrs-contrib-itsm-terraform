# IU Jetstream2's API Command Line Tool

Get started quickly with IU Jetstream2's API using Docker. Assuming you have [Docker](https://www.docker.com) and [docker-compose](https://docs.docker.com/compose/install/) installed, you can use the IU Jetstream API without any additional installation.

## Requirements

- Assumes you have Jetstream2 access
- Assumes your personal openrc credentials have been placed into `../conf/openrc-personal`

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
