#!/usr/bin/env bash

extract_student_info() {
    for file in $(ls *.csv | grep -v -e main.csv -e temp.csv); do
        awk -F, 'NR>1 {print $1 "," $2}' "$file"
    done > temp.csv
}

remove_duplicate_lines() {
    input_file="$1"
    output_file="$2"
    
    awk '!seen[tolower($1)]++' "$input_file" > "$output_file"
    first_line="Roll_Number,Name"  
    sed -i "1i$first_line" main.csv  # inserting first line into main.csv
}


add_Marks(){
    # Iterate over each line in main.csv starting from the second line
    tail -n +2 main.csv | while IFS=, read -r roll_num name; do 
        # Initialize marks as 'a' indicating marks not found initially
        marks='a'

        # Iterate over exam files
        for file in *.csv; do
            # Exclude main.csv and temp.csv
            if [ "$file" != "main.csv" ] && [ "$file" != "temp.csv" ]; then
                # Check if roll number exists in the current exam file
                if grep -q -i "$roll_num" "$file"; then
                    # Extract marks corresponding to the roll number
                    marks=$(grep -i "$roll_num" "$file" | awk -F',' '{print $NF}')
                    break  # Break the loop once marks are found
                fi
            fi
        done
        
        # Append marks to the corresponding line in main.csv
         sed -i "s/^$roll_num,.*/$roll_num,$name,$marks/" main.csv
    done 
    
}


touch main.csv
touch temp.csv
echo "Roll_Number,Name" > main.csv
extract_student_info
input_file="temp.csv"
output_file="main.csv"
remove_duplicate_lines "$input_file" "$output_file"
rm -f temp.csv
add_Marks