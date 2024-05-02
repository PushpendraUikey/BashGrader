#!/bin/bash

#<--------------------------------------------------------------------------------------------------------------------->#
add_Marks() {
    for file in $(ls *.csv | grep -v -e main.csv); do
        filename="${file%.csv}"
        first_line=$(head -n 1 main.csv )
        # line=$(echo $first_line | tr -d '\n')
        sed -i "s/^$first_line$/${first_line},${filename}/" main.csv
        
        while IFS=, read -r roll_num name; do
            if [[ ! "$roll_num" =~ "Roll_Number" ]]; then
                marks=$(awk -F, -v roll_num="$roll_num" '{ if(tolower($1) == tolower(roll_num)) print $NF }' "$file")
                if [ -n "$marks" ]; then
                    sed -i "/^$roll_num,/ s/$/,$marks/" main.csv
                else
                    sed -i "/^$roll_num,/ s/$/,a/" main.csv
                fi
            fi
        done < main.csv
    done
}
#<------------------------------------------------------------------------------------------------------------>#
#!/bin/bash

# sed -i '1d' $(ls *.csv | grep -v main.csv)
# header="Roll_Number,Name,Marks"
# sed -i "1i\\$header" $(ls *.csv | grep -v main.csv)
touch main.csv

csv_files="$(ls *.csv | grep -v main.csv)"

# Loop through each CSV file
for file in $csv_files; do
    filename="${file%.csv}"

    if [ ! -s main.csv ]; then
        read -r header < main.csv
    else
        header="Roll_Number,Name"
    fi

    header="$header,$filename"

    sed -i "1c\\$header" main.csv  # change new header into the main file 

    while IFS=, read -r roll_num name marks; do
        # Check if the RollNum exists in main.csv
        if grep -q "^$roll_num," main.csv; then
            # If RollNum exists, append or update the line with the new marks
            # sed -i "s/^$roll_num,.*/$roll_num,$name,$marks/" main.csv
            sed -i "/^$roll_num/s/$/,${marks}/" main.csv
        else
            # If RollNum doesn't exist, append the line
            echo "$roll_num,$name,$marks" >> main.csv
        fi
    done < <(tail -n +2 "$file")
done



#<--------------------------------------------------------------------------------------------------------->#

    if [ -z "$remote_Repo" ]; then                    # Checks if the string remote_Repo is empty
        echo "Error: First initialise git_init." 
        exit 1
    fi

    rand_num=$(generate_random_number)                # generating random num using function
    rand_num=$((rand_num))                            # converting it to a numeric 

    mkdir -p "$remote_Repo/$rand_num"                 # making a folder to create current version of all the files.

    cp * "$remote_Repo/$rand_num/"                    # storing current files to remote repo 

    last_commit=""
    
    #if [ -s "$remote_Repo/.git_log" ]; then            # checking whehther the file has any hash value or not(if the file is not empty) 
    if [ -s "$remote_File" ]; then 

        last_commit=$(tail -n 1 "$remote_File" | awk '{print $1}')  # checking the last commit to check for modified files 
                                                                             # saved the files in the folder with names as hash-value
    fi 

    if [ -n "$last_commit" ]; then                                  # check if the string is non empty 
    # if [ ! -z "$last_commit" ]; then                              # checking if the last_commit is not empty string 
        diff -qr . "$remote_Repo"/"$last_commit" | grep -E '^Files .* differ$' | awk '{print $2}' | awk -F/ '{print $NF}'    # check the files which differ in contents, i.e. modified 
                                                                    # -q for brief summary, and -r for recursively
    fi 

    echo "$rand_num,$3" >> "$remote_File"
    
#<------------------------------------------------------------------------------------------------------------------>#

add_Marks(){
    for file in $(ls *.csv | grep -v main.csv); do
        filename="${file%.csv}"

        first_line=$(head -n 1 main.csv)
        sed -i -e "s/$first_line/$first_line,$filename/I" main.csv

        while IFS=, read -r line; do 
            IFS=, read -r -a data <<< "$line"   # split line into array 
            marks=$(awk -F, -v roll_num="${data[0]}" '{ if(tolower($1) == tolower(roll_num)) print $NF }' "$file" | tr -d '\n')
            if [ -n "$marks" ]; then 
                awk -v line="$line" -v marks="$marks" -v OFS=',' '$0 == line {$0 = $0 "," marks} 1' main.csv > temp.csv && mv temp.csv main.csv
            else 
                awk -v line="$line" -v OFS=',' '$0 == line {$0 = $0 ",a"} 1' main.csv > temp.csv && mv temp.csv main.csv
            fi 
        done < <(tail -n +2 main.csv) 
    done
}

#<--------------------------------------------------------------------------------------------------------------->#

# Create an array to store the CSV files in the current directory, excluding main.csv
csv_files=(*.csv)
csv_files=(${csv_files[@]//*main.csv})

# Check if there are at least two CSV files
if [ "${#csv_files[@]}" -lt 2 ]; then
    echo "Error: At least two CSV files are required."
    exit 1
fi

# Create a temporary directory to store sorted CSV files
temp_dir=$(mktemp -d)

# Iterate over the CSV files, sort them, and save sorted versions in the temporary directory
for csv_file in "${csv_files[@]}"; do
    sort -t',' -k1,1 -o "$temp_dir/$csv_file" "$csv_file"
done

# Create a temporary file to store intermediate results
temp_file=$(mktemp)

# Copy the first sorted CSV file to the temporary file
cp "$temp_dir/${csv_files[0]}" "$temp_file"

# Iterate over the remaining sorted CSV files and join them with the temporary file
for ((i = 1; i < ${#csv_files[@]}; i++)); do
    join -t, -a 1 -a 2 -e "NA" -o 0,1.2,2.2 "$temp_file" "$temp_dir/${csv_files[$i]}" > "$temp_file.tmp" && mv "$temp_file.tmp" "$temp_file"
done

# Rename the temporary file to main.csv
mv "$temp_file" main.csv

# Remove the temporary directory
rm -rf "$temp_dir"

echo "Combined data saved in main.csv"


#<-------------------------------------------------------------------------------------------------------------->#

touch main.csv && \
    for file in $(ls *.csv | grep -v main.csv); do
        filename="${file%.csv}"
        if [ ! -s main.csv ]; then
            tail -n +2 "$file" >> main.csv
        else
            awk 'BEGIN{FS=","} NR == 1 {print $0 "," FILENAME} NR > 1 {
                if (FNR == NR) {
                    file[tolower($1)] = $NF   # Convert first field to lowercase and store in array
                } else {
                    current_field = tolower($1)   # Convert first field to lowercase for comparison
                    if (current_field in file) {
                        print $0 "," file[current_field]
                    } else {
                        print $0 "," "a"   # Insert "a" if first field does not match
                    }
                }
            }' "$file" >> temp && mv temp main.csv
        fi 
    done



#<------------------------------------------------------------------------------------------------------>#


#if [ $1 == "combine" ]; then
 #   touch main.csv
  #  for file in $(ls *.csv); do
   #     filename="${file%.csv}"
    #    if [ -s main1.csv ];then
     #       cat $file > main.csv
      #  else
       #     awk 'BEGIN{FS=","} NR == 1 {print $0 "," FILENAME} NR > 1 {
        #        if (FNR == NR) {
         #       file[FNR] = tolower($1)   # Convert first field to lowercase and store in array
          #          } else {
           #     current_field = tolower($1)   # Convert first field to lowercase for comparison
            #    for (i in file) {
             #   if (current_field == file[i]) {
              #      print $0 "," $NF
               #         }
                #    }
                #}
            #}' main.csv $file > temp && mv temp main.csv
       # fi 
    #done
#fi

#extract_unique_roll(){
 #   Roll=()
  #  for file in $(ls *.csv | grep -v main.csv); do
   #     awk -F, '{if(Roll[tolower($1)]>0){
    #        Roll[tolower($1)]++
     #   }else{
      #      print $1 "," $2 
       #     Roll[tolower($1)]++
        #}
        #}' "$file" >> main.csv
    #done
#}


#<----------------------------------------------------------------------------------------------------------->#


extract_unique_roll() {
    declare -A Roll  # Declare an associative array
    for file in *.csv; do
        [[ $file == "main.csv" ]] && continue  # Skip main.csv
        
        while IFS=, read -r fields; do
            IFS=, read -r -a field <<< "$fields"  # Split the fields into array

            ${field[0]}=$(echo "${field[0]}" | tr -d '[:space:]')

            if [[ ${Roll[${field[0]}]} -eq 0 ]]; then
                echo "${field[0]},${field[1]}"
                Roll[${field[0]}]=1  # Mark the roll number as encountered
            fi
        done < "$file"

    done > main.csv  # Redirect output to main.csv outside the loop
}