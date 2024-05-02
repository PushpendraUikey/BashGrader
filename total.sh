#!/bin/bash

read -r header < main.csv   # read header
header="$header,total"

while IFS=, read -r fields; do  # fields contains unknown number of marks column

    IFS=, read -r -a marks <<< "$fields" # Split the fields into array.

    total_marks=0

    for mark in "${marks[@]}"; do
        if [[ $mark =~ ^[0-9]+$ ]]; then             # if numerical then add
            total_marks=$((total_marks + mark))
        fi
    done

    fields="$fields,$total_marks"
     
    echo "$fields"
#    echo "$rollnum,$name,$fields,$total_marks"
done < <(tail -n +2 main.csv) > temp_file.csv       # skip the header, and read file

echo "$header" > main.csv

cat temp_file.csv >> main.csv   #append the data back to main 

rm temp_file.csv
