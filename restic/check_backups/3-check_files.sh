#!/usr/bin/env bash
set -eu


if [ $# -eq 0 ]
then
  cat <<- EOF
	usage: $0 inputfile
	inputfile: new line delimited text file with the list of files to check
	EOF
  exit 1
else
  inputfile="$1"
fi

errors=0

while read -r original
do
    echo "--------------"
    echo "$original"
    restored="./rest_tmp$original"
    size_original="$(stat -c %s "$original")"
    size_rest="$(stat -c %s "$restored")"
    hash_original="$(md5sum "$original" | cut -d' ' -f1)"
    hash_rest="$(md5sum "$restored" | cut -d' ' -f1)"
    # echo $restored $size_original $size_rest $hash_original $hash_rest
    if [ "$size_original" -eq "$size_rest" ]
    then
	echo "size ok $size_original"
    else
	((errors++))
	echo "size mismatch $size_original != $size_rest"
    fi
    if [ "$hash_original" = "$hash_rest" ]
    then
        echo "hash ok $hash_original"
    else
	((errors++))
        echo "hash mismatch $hash_original != $hash_rest"
    fi
done < "$inputfile"

echo "--------------"
echo "errors: $errors"

