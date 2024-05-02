#!/usr/bin/env python3

import csv

# ./combine.py            # script runs for python3 series only, for identifying unique roll numbers

def remove_duplicate_lines(input_file, output_file):
    # Read input CSV file
    with open(input_file, 'r') as file:
        reader = csv.reader(file)
        lines = list(reader)

    # Convert roll numbers to lowercase for case-insensitive comparison
    unique_lines = []
    seen_roll_numbers = set()
    for line in lines:
        roll_number = line[0].strip().lower()  # Convert roll number to lowercase
        if roll_number not in seen_roll_numbers:
            seen_roll_numbers.add(roll_number)
            unique_lines.append(line)

    # Remove duplicate lines
    '''unique_lines = []
    for line in lines:
        if line not in unique_lines:
            unique_lines.append(line)
'''

    # Write unique lines to output CSV file
    with open(output_file, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerows(unique_lines)

# Example usage
input_file = 'temp.csv'
output_file = 'main.csv'
remove_duplicate_lines(input_file, output_file)
