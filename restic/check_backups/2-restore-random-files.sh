#!/usr/bin/env bash

set -eu

target='./rest_tmp'


if [ $# -eq 0 ]
then
  cat <<- EOF
	usage: "$0" inputfile
	inputfile: new line delimited text file with the list of files to restore
	EOF
  exit -1
else
  inputfile="$1"
fi


numfiles=$(wc -l "$inputfile")
# thanks https://serverfault.com/a/351633
size=$(while read -r filename ;  do stat -c '%s' "$filename" ; done < "$inputfile" | awk '{total+=$1} END {print total}' | numfmt --to=iec)

echo "restoring $numfiles files, total of $size to $target"

export $(grep -v '^#' '.env' | xargs)
repo="s3:https://s3.amazonaws.com/backup-restic-bucket"
restic_resp=$(restic -r "$repo" snapshots latest -c -q --json --path '/mnt/dados/Imagens')
snap=$(jq -r '.[0]["id"]' <<< "$restic_resp" )
datetime=$(jq -r '.[0]["time"]' <<< "$restic_resp" )
echo "got data from restic:"
echo "  repo:     $repo"
echo "  snapshot: $snap"
echo "  at:       $datetime"
echo

mkdir -p "$target"
restic -r "$repo" restore "$snap" --target "$target" --include-file "$inputfile" -v
