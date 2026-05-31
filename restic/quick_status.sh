#!/bin/env bash



STATUS_FILE='/srv/var/logs/backup_scripts/restic-status.json'

echo "- last backup started: $(jq '.profiles.home_assistant.backup.time' $STATUS_FILE)"
echo "- last check started: $(jq '.profiles.home_assistant.check.time' $STATUS_FILE)"

/home/pedro/.local/bin/yq -r '.profiles | keys[] as $profile | "{\"\($profile)\":  {\"backup_success\": \"\(.[$profile].backup.success)\" , \"check_success\": \"\(.[$profile].check.success)\"}}"' \
    $STATUS_FILE \
        | jq --slurp '.' \
        | /home/pedro/.local/bin/yq -o yaml -P

