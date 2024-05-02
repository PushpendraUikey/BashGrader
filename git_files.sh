elif [ "$1" == "git_init" ]; then

    if [ -z "$2" ]; then                # check if directory is not given
        echo "Provide the directory path."
        exit 1
    fi

    if [ -e ".git" ]; then
        echo "A git repository already exists."
    else
        git init || exit                # if not exists then initialise one
    fi


    if [ -d "$2" ]; then                # checks if directory is present there or not.

        if [ -e "$2/.git" ]; then        # checks if .git already there
            git remote add origin "$2" || exit
            exit 1
        fi

        cd "$2" || exit                 # if first fails then exit 
        git init --bare  || exit 
        cd -  || exit 

    else
        mkdir -p "$2"
        cd "$2" || exit
        git init --bare || exit 
        cd - || exit 
    fi

    remote_Repo="$2"

    remote_File="$remote_Repo/.git_log"

    touch "$remote_File"

    git remote add origin "$2" || exit 

elif [ "$1" == "git_commit" ] && [ "$2" == "-m" ]; then 
    if [ ! -e ".git" ]; then
        echo "Error: initialise git in the current folder"
        exit 1
    fi

    git diff --name-only HEAD^                      # to show modified files

    git add .

    git commit -m "$3"

    git push origin main

    rand_num=$(generate_random_number)                # generating random num using fun
    rand_num=$((rand_num))                             # converting it to a numeric 

    last_commit=$(git log -1 --format="%H")             # real # value for the last commit

    echo "$rand_num,$3,$last_commit" >> "$remote_Repo/.git_log"

elif [ "$1" == "git_checkout" ] && [ "$2" == "-m" ]; then 
    match_count=$(grep -c "$3" "$remote_File")

    if [ "$match_count" -gt 1 ]; then
        echo "Two commit message are same:)"
        exit 1
    fi
    if [ "$match_count" -eq 1 ]; then
        hash_value=$(grep "$3" "$remote_File" | awk -F',' '{print $3}')         # -F with the grep can be used to match exactly 



# if [ -s "$remote_Repo/.git_log" ]; then            # checking whehther the file has any hash value or not(if the file is not empty) 
        
       # last_commit=$(tail -n 1 "$remote_Repo/.git_log" | awk '{print $1}')  # checking the last commit to check for modified files 
                                                                             # saved the files in the folder with names as hash-value
# fi 
#modified_files=""
# if [ -n "$last_commit" ]; then                                  # check if the string is non empty 
# if [ ! -z "$last_commit" ]; then                              # checking if the last_commit is not empty string 
#       modified_files=$(diff -qr . "$remote_Repo"/"$last_commit" | grep -E '^Files .* differ$' | awk '{print $2}' | awk -F/ '{print $NF}')    # check the files which differ in contents, i.e. modified 
                                                                    # -q for brief summary, and -r for recursively
# fi 

# if [ -n "$modified_files" ]; then
#        echo "Please first commit the changes, It will lost otherwise."
#        exit 1
# fi 
