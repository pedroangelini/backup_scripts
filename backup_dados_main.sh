#!/usr/bin/env bash
set -u


logfile="/srv/var/logs/backup_scripts/sync_dados.log"

declare -a src_arr=(
    "/mnt/dados/z_backup_script"
    "/mnt/dados/Imagens"
    "/mnt/dados/Backups"
    "/mnt/dados/BackupsToCloud"
    "/mnt/dados/Books"
    "/mnt/dados/immich-library/library"
    "/mnt/dados/immich-library/backups"
    "/mnt/dados/server_docs"
    "/mnt/dados/datalake"
)
dest="/srv/backups/"

excludelist="/srv/backup_scripts/excludelist.txt"

# ensure the path to the log file exists
mkdir -p "$(dirname "$logfile")"

echo "" >> $logfile
for src in "${src_arr[@]}"
do
    echo "--------------------------------------------" | tee -a $logfile
    echo "$(date -Is)" "- ** backing up $src using rsync with -ahiv and excludelist.txt" | tee -a $logfile
    rsync -ahiv --log-file=$logfile --exclude-from="$excludelist" "$src" "$dest"
done


exit $?
