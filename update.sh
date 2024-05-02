#!/usr/bin/env bash

while true; do
    echo "Student Roll Number:"
    read roll_num

    echo "Student Name:"
    read name 

    exam=""
    marks=""
    match_name=$(grep -i "$roll_num" main.csv | awk -F, '{print $2}' )

    if [ -n "$match_name" ];then 
        if [ "$name" == "$match_name" ]; then                         # given name should match the name correspondig to roll num 
            echo "Which exam do you want to change marks?"
            read exam
            echo "Changed marks:"
            read marks
        else
            echo "Roll Number is not matching to name. Please provide correct name!"   # name didn't match 
            continue
        fi
    else
        echo "Given roll number is not listed on the course"               # roll num didn't matched
        continue
    fi

    if [ -e "$exam.csv" ]; then                                             # first updating the corresponding exam file 
        sed -i "s/^$roll_num,.*/$roll_num,$name,$marks/I" "$exam.csv"            # if the exam name is correct then change the marks
    else
        echo "Please provide correct exam name!"                                # exam name is incorrect, i.e. file is not corret then exit 
        continue
    fi

    exam_field_num=$(awk -F, -v exam="$exam" 'NR==1 {for (i=1; i<=NF; i++) if ($i == exam) {print i; exit}}' main.csv) # figuring out which field has the correspondin name 

    student=$(grep -i "$roll_num" main.csv)                                     # extracting the student's information whose marks I want to update  

    corrected_student=$(echo "$student" | awk -v field="$exam_field_num" -v marks="$marks" 'BEGIN {FS=OFS=","} {for (i=1; i<=NF; i++) if(i == field) $i=marks} 1')
                                            # storing the corrected marks, here 1 in the end of awk says it to print the modified fields
    sed -i "s/^$roll_num,.*/$corrected_student/I" main.csv          # updating the main.csv file 

    echo "Do you want to continue updating marks(y/n)?"
    read choice
    if [ "$choice" != "y" ];then
        exit 0
    fi
done