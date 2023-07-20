#!/usr/bin/env bash

function print_menu() {
    echo
    echo "0. Exit"
    echo "1. Play a game"
    echo "2. Display scores"
    echo "3. Reset scores"
    echo "Enter an option:"
}

function play_game() {
    score=0
    correct_answers=0

    # ask for players name
    echo "What is your name?" 
    read -r player

    # get username and password
    endpoint_credentials="http://127.0.0.1:8000/download/file.txt"
    curl -so ID_card.txt $endpoint_credentials
    user=$(grep -oP '(?<="username": ")[^"]*' ID_card.txt)
    password=$(grep -oP '(?<="password": ")[^"]*' ID_card.txt)

    # connect to other endpoint
    endpoint_msg="http://127.0.0.1:8000/login"
    curl -su "$user:$password" -c cookie.txt $endpoint_msg

    while : ; do
        # connect to game endpoint
        endpoint_game="http://127.0.0.1:8000/game"
        response=$(curl --cookie cookie.txt $endpoint_game)
        question=$(echo "$response" | sed 's/.*"question": *"\{0,1\}\([^,"]*\)"\{0,1\}.*/\1/')
        answer=$(echo "$response" | sed 's/.*"answer": *"\{0,1\}\([^,"]*\)"\{0,1\}.*/\1/')
        echo -e "$question"

        echo "True or False?"
        read -r players_answer

        if [ "$players_answer" == "$answer" ]; then

            # increment score by 10
            score=$(( score + 10 ))
            correct_answers=$(( correct_answers + 1 ))
        
            # output random success response
            RANDOM=4096
            responses=("Perfect!" "Awesome!" "You are a genius!" "Wow!" "Wonderful!")
            idx=$((RANDOM % 5))
            echo "${responses[$idx]}"
            echo

        elif [ "$players_answer" != "$answer" ]; then
        
            echo "Wrong answer, sorry!"
            echo "$player you have $correct_answers correct answer(s)."
            echo "Your score is $score points."
            break

        else

            echo "Invalid answer"
            return 1

        fi
    done

    # save current score and correct answers in file
    date=$(date '+%Y-%m-%d')
    echo "User: ${player}, Score: ${score}, Date: ${date}" >> "$1"
}



function display_scores() {
    linecount=$(cat "$1" 2> /dev/null | wc -l)
    if [[ (-f "$1") && ("$linecount" -gt 0) ]]; then
        echo "Player scores"
        cat "$1"
    else
        echo "File not found or no scores in it!"
    fi
}

function reset_scores() {
    linecount=$(cat "$1" 2> /dev/null | wc -l)
    if [[ (-f "$1") && ("$linecount" -gt 0) ]]; then
        rm -r "$1"
        echo "File deleted successfully!"
    else
        echo "File not found or no scores in it!"
    fi
}

filename="scores.txt"
echo -e "Welcome to the True or False Game!"
while : ; do

print_menu

# read input from terminal
read -r action

case "$action" in

    0)       
        echo "See you later!" 
        break
        ;;
    1)     
        play_game "$filename"
        ;;
    2)     
        display_scores "$filename"
        ;;
    3)     
        reset_scores "$filename"
        ;;
    *)     
        echo "Invalid option!" 
        ;;

esac

done