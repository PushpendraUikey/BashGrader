#!/usr/bin/env bash

remote_Repo=""                                      # variable to access remote repository 
remote_File=""                                      # variable to use .git_log file 

if [ ! -d "$repository" ]; then                            # if directory is not present then make one,
    mkdir -p "$repository"
fi

remote_Repo="$repository"

echo "$remote_Repo" > remote_repo_name.sh

remote_File="$remote_Repo/.git_log"

touch "$remote_File"