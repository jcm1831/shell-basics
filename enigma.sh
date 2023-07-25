#!/usr/bin/env bash

function print_menu() {
    echo
    echo "0. Exit"
    echo "1. Create a file"
    echo "2. Read a file"
    echo "3. Encrypt a file"
    echo "4. Decrypt a file"
}

function create_file() {
    echo "Enter the filename:"
    read -r filename
    filename_regex='^[a-zA-Z.]+$'
    if [[ ("$filename" =~ $filename_regex) ]]; then 
        
        echo "Enter a message:"
        read -r msg

        msg_regex='^[A-Z ]+$'
        if [[ ("$msg" =~ $msg_regex) ]]; then
            echo "$msg" > "$filename"
            echo "The file was created successfully!"
        else 
            echo "This is not a valid message!"
        fi


    else
        echo "File name can contain letters and dots only!"        
    fi
}

function read_file() {
    echo "Enter the filename:"
    read -r filename

    if [[ (-f "$filename") ]]; then
        echo "File content:"
        cat "$filename"
    else
        echo "File not found!"
    fi
}

function caesar_encrypt() {
    echo "Enter the filename:"
    read -r filename

    if [[ (-f "$filename") ]]; then
        
        msg=$(cat "$filename" | tr '[A-Z]' '[D-ZA-C]')
        echo "$msg" > "$filename.enc"
        rm -r "$filename"
        echo "Success"

    else
        echo "File not found!"
    fi
}

function caesar_decrypt() {
    echo "Enter the filename:"
    read -r filename

    if [[ (-f "$filename") ]]; then
        
        msg=$(cat "$filename" | tr '[D-ZA-C]' '[A-Z]')
        echo "$msg" > "${filename%.*}"
        rm -r "$filename"
        echo "Success"

    else
        echo "File not found!"
    fi
}

function ssl_encrypt() {
    echo "Enter the filename:"
    read -r filename

    if [[ (-f "$filename") ]]; then
        
        echo "Enter password:"
        read -r password

        openssl enc -aes-256-cbc -e -pbkdf2 -nosalt -in "$filename" -out "$filename.enc" -pass pass:"$password" &>/dev/null
        exit_code=$?
        if [ "$exit_code" -eq 0 ]; then
            rm -r "$filename"
            echo "Success"
        else
            echo "Fail: $exit_code"
        fi

    else
        echo "File not found!"
    fi 
}

function ssl_decrypt() {
    echo "Enter the filename:"
    read -r filename

    if [[ (-f "$filename") ]]; then

        echo "Enter password:"
        read -r password
        
        openssl enc -aes-256-cbc -d -pbkdf2 -nosalt -in "$filename" -out "${filename%.*}" -pass pass:"$password" &>/dev/null
        exit_code=$?
        if [ "$exit_code" -eq 0 ]; then
            rm -r "$filename"
            echo "Success"
        else
            echo "Fail: $exit_code"
        fi

    else
        echo "File not found!"
    fi 
}

echo "Welcome to the Enigma!"

while : ; do

print_menu

# read input from terminal
echo "Enter an option:"
read -r option

case "$option" in

    0)
        echo "See you later!"
        break
        ;;
    
    1)
        create_file
        ;;
    
    2)  
        read_file
        ;;
    
    3)
        ssl_encrypt
        ;;
    
    4)
        ssl_decrypt
        ;;
    
    *)  

        echo "Invalid option!"
        ;;

esac

done