#!/usr/bin/env bash

extract_student_info(){                                                 # function to take all students info in one file 
    for file in $(ls *.csv | grep -v -e main.csv -e temp.csv); do       # don't iterate through main and temp csv's 
        awk -F, 'NR>1{print $1 "," $2}' "$file"
    done > temp.csv
}

remove_duplicate_lines() {                                              # function to remove duplicate name/rollnums from file 
    input_file="$1"
    output_file="$2"
    
    awk '!seen[tolower($1)]++' "$input_file" > "$output_file"
                                    #  If a line hasn't been seen before (!seen[$0] evaluates to true), it prints the line
                                    # it also checks for case insensitiveness in the rollnums
    first_line="Roll_Number,Name"  
    sed -i "1i$first_line" main.csv  # inserting first line into main.csv
}

add_Marks(){
    for file in $(ls *.csv | grep -v -e main.csv); do            # exclude main.csv from iteration

        filename="${file%.csv}"                                  # name of the exam i.e. file 

        first_line=$(head -n 1 main.csv )
                                                                # line=$(echo $first_line | tr -d '\n')
        sed -i "s/^$first_line$/${first_line},${filename}/" main.csv

        while IFS=, read -r line; do 
            IFS=, read -r -a data <<< "$line"                     # split line into array 
                                                                  # marks=$(grep tolower("$data[0]") "$file" | awk -F, '{ print $NF }' )
            marks=$(awk -F, -v roll_num="${data[0]}" '{ if(tolower($1) == tolower(roll_num)) print $NF }' "$file")
                                                                  # here -v flag for variable, and if any line of file matche, print the marks 
            if [ -n "$marks" ]; then                              # if the marks is not empty
                sed -i "s/^$line$/${line},${marks}/" main.csv
            else 
                sed -i "s/^$line$/${line},a/" main.csv
            fi 
        done < <(tail -n +2 main.csv)                             # start checking marks from second line,
    done
}

touch main.csv
touch temp.csv                                                      # temporary file created to store students info
echo "Roll_Number,Name" > main.csv                                  # even if after uploading run combine it will run appropriately
extract_student_info                                                # extract the information of students from all the csv files.
input_file="temp.csv"
output_file="main.csv"
remove_duplicate_lines "$input_file" "$output_file"

rm -f temp.csv                                                      # remove the temp file 
add_Marks