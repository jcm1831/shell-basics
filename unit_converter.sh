#!/usr/bin/env bash

filename="definitions.txt"

function convert_units() {
    # check if definitions file exists
    linecount=$(cat "$1" 2> /dev/null | wc -l)
    if [[ (-f "$1") && ("$linecount" -gt 0) ]]; then
        echo -e "Type the line number to convert units or '0' to return"
        print_file $1
        while : ; do
            read -e line_to_convert
            if [[ ("$line_to_convert" -le "$linecount") && ("$line_to_convert" -ge 0) && (-n "$line_to_convert") ]]; then
                if [[ ($line_to_convert == 0) ]]; then 
                    return 1
                else 
                    # get defintion for conversion
                    line=$(sed "${line_to_convert}!d" "$1")
                    read -a definition <<< "$line"
                    factor="${definition[1]}"
                    # get value for conversion
                    echo -e "Enter a value to convert:"
                    read -a value
                    num_regex="[+-]?[0-9]+(\.[0-9]+)?$"
                    while [[  !($value =~ $num_regex) ]]; do
                        echo -e "Enter a float or integer value!"
                        read -a value
                    done
                    # do conversion
                    result=$(echo "scale=2; $factor * $value" | bc -l) 
                    printf "Result: %s\n" "$result"
                    return 0
                fi
            else
                echo -e "Enter a valid line number!"
            fi
        done
    else
        echo -e "Please add a definition first!"
    fi
}

function add_definition() {
    while : ; do
        # read input
        echo -e "Enter a definition:"
        read -a definition
        num_params="${#definition[@]}"
        conv="${definition[0]}"
        factor="${definition[1]}"

        # check if definition is valid; add it to file if correct, print an error message otherwise
        conv_regex="^[a-z]+_to_[a-z]+"
        num_regex="[+-]?[0-9]+(\.[0-9]+)?$"
        if [[ ($num_params -eq 2) && ($conv =~ $conv_regex) && ($factor =~ $num_regex) ]]; then
            # linecount=$(( $(cat $1 | wc -l) + 1 ))
            echo "${conv} ${factor}" >> "$1"
            break
        else
            echo -e "The definition is incorrect!"    
        fi
    done
}

function delete_defintion() {
    # check if definitions file exists
    linecount=$(cat $1 2> /dev/null | wc -l)
    if [[ (-f "$1") && (linecount > 0) ]]; then
        echo -e "Type the line number to delete or '0' to return"
        print_file $1
        while : ; do
            read -e line_to_delete
            if [[ ("$line_to_delete" -le "$linecount") && ("$line_to_delete" -ge 0) && (-n "$line_to_delete") ]]; then
                if [[ ($line_to_delete == 0) ]]; then 
                    return 1
                else 
                    sed -i "${line_to_delete}d" "$1"
                    linecount=$(( linecount - 1 ))
                    return 0
                fi
            else
                echo -e "Enter a valid line number!"
            fi
        done
    else
        echo -e "Please add a definition first!"
    fi
}

function print_file() {
    linecount=1
    while IFS= read -r line; do
        echo "${linecount}. ${line}"
        linecount=$(( linecount + 1))
    done < $1
}

function print_menu() {
    echo
    echo "Select an option"
    echo "0. Type '0' or 'quit' to end program"
    echo "1. Convert units"
    echo "2. Add a definition"
    echo "3. Delete a definition"
}

echo -e "Welcome to the Simple converter!"
while : ; do

print_menu

# read input from terminal
read -a action

case "$action" in

    0 | 'quit')       
        echo "Goodbye!" 
        break
        ;;
    1)     
        convert_units "$filename"
        ;;
    2)     
        add_definition "$filename"
        ;;
    3)     
        delete_defintion "$filename"
        ;;
    *)     
        echo "Invalid option!" 
        ;;

esac
done