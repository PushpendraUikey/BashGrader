#!/usr/bin/env bash

if [ "$1" == "combine" ]; then
    ./combine.sh

elif [ "$1" == "upload" ]; then                       # copies files into current directory 
    if [ $# -eq 2 ]; then
        cp "$2" ./
    else
        echo "Error: provide valid path"
    fi

elif [ "$1" == "total" ]; then 
    bash total.sh

elif [ "$1" == "git_init" ]; then
    if [ $# -eq 2 ]; then
        export repository="$2"
        if [ -z "$repository" ]; then                              # check if directory is not given
            echo "Provide the directory path."
            exit 1
        fi
        ./git_init.sh
    else
        echo "Usage: bash submission.sh git_init <remote_repository>"
    fi

elif [ "$1" == "git_commit" ] && [ "$2" == "-m" ]; then
    if [ $# -eq 3 ]; then
        export message="$3"
        ./git_commit.sh
    else
        echo "Usage: bash submission.sh git_commit -m <message>"
    fi

elif [ "$1" == "git_checkout" ] && [ "$2" == "-m" ]; then 
    if [ $# -eq 3 ]; then
        export message="$3"
        ./checkout_message.sh
    else 
        echo "Usage: bash submission.sh git_checkout -m <message>"
    fi

elif [ $# -eq 2 ] && [ "$1" == "git_checkout" ]; then 
    export hash_value="$2"
    ./checkout_hashvalue.sh

elif [ "$1" == "update" ]; then
    ./update.sh
fi

