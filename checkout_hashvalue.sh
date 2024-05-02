#!/usr/bin/env bash

remote_Repo=$(head -n 1 remote_repo_name.sh)
remote_File="$remote_Repo/.git_log"

match_count=$(grep -c "$hash_value" "$remote_File")
    
if [ "$match_count" -gt 1 ]; then                               # check for the possibility if two commit messages are same
    echo "Error:Two different hash values starts with same prefix:)"
    exit 1
fi

if [ "$match_count" -eq 1 ]; then

    hash_value=$(grep "$hash_value" "$remote_File" | awk -F',' '{print $1}')

fi 
    
rm -f *.csv                                  # removing csv files of current directory to get back the older version of csv files 

cp -r "$remote_Repo"/"$hash_value"/* ./        # copies all the contents of files of the given commit to current directory
