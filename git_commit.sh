#!/usr/bin/env bash

remote_Repo=$(head -n 1 remote_repo_name.sh)
remote_File="$remote_Repo/.git_log"

generate_random_number(){                            # function generates the random number 
    local random_number=""
    for (( i=0; i<16; i++ )); do
        random_digit=$(( RANDOM % 10 ))                         # Random digit [0-9]
        random_number="${random_number}${random_digit}"         # Append digit 
    done
    echo "$random_number"
}

if [ -z "$remote_Repo" ]; then                    # Checks if the string remote_Repo is empty
    echo "Error: First initialise git_init." 
    exit 1
fi

rand_num=$(generate_random_number)                # generating random num using function
rand_num=$((rand_num))                            # converting it to a numeric 

mkdir -p "$remote_Repo/$rand_num"                 # making a folder to create current version of all the files.

cp -r *.csv "$remote_Repo/$rand_num/"                    # storing current files to remote repo 

last_commit=""
    
        #if [ -s "$remote_Repo/.git_log" ]; then            # checking whehther the file has any hash value or not(if the file is not empty) 
if [ -s "$remote_File" ]; then 

    last_commit=$(tail -n 1 "$remote_File" | awk -F, '{print $1}')  # checking the last commit to check for modified files 
                                                                             # saved the files in the folder with names as hash-value
fi 

if [ -n "$last_commit" ]; then                                  # check if the string is non empty 
# if [ ! -z "$last_commit" ]; then                              # checking if the last_commit is not empty string 
    diff -qr . "$remote_Repo/$last_commit" | grep -E '^Files .* differ$' | awk '{print $2}' | awk -F/ '{print $NF}'    # check the files which differ in contents, i.e. modified 
                                                                    # -q for brief summary, and -r for recursively
fi 

echo "$rand_num,$message" >> "$remote_File"