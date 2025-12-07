# Backup Scripts

My personal backup scripts for home server, shared in case anyone needs examples
Following hte 3-2-1 (+) backup rule for most important things - photos are in the cellphone they have been taken from + server in 2 locations (+ google photos in most cases), other things may be in the server (2 HDDs) + AWS.
As of 2025, I spend around 3 to 4 euros/month for around 350 GB of data


## local scripts

`backup_dados_main.sh`

uses `rsync` to copy data to a separate disk (no versioning or anything fancy)

## AWS

`./restic` folder

uses [resticprofile](https://creativeprojects.github.io/resticprofile/index.html) to back things up to AWS, with versioning multiple snapshots and all.
