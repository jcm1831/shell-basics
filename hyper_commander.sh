#! /usr/bin/env bash

function print_menu() {
    echo 
    echo "------------------------------"
    echo "| Hyper Commander            |"
    echo "| 0: Exit                    |"
    echo "| 1: OS info                 |"
    echo "| 2: User info               |"
    echo "| 3: File and Dir operations |"
    echo "| 4: Find Executables        |"
    echo "------------------------------"
}

function print_file_menu() {
    echo
    echo "---------------------------------------------------"
    echo "| 0 Main menu | 'up' To parent | 'name' To select |"
    echo "---------------------------------------------------"
}

function print_file_options() {
    echo
    echo "---------------------------------------------------------------------"
    echo "| 0 Back | 1 Delete | 2 Rename | 3 Make writable | 4 Make read-only |"
    echo "---------------------------------------------------------------------"  
}

function os_info() {
    uname --nodename --operating-system 
}

function user_info() {
    whoami
}

function file_operations() {    
    while : ; do

    files=(*)
    list_files "${files[@]}"

    print_file_menu

    # read input from terminal
    read -r input

    # check if input is subdirectory/file from current directory
    input_copy="$input"
    if echo "${files[@]}" | grep -qw "$input"; then
        if [ -f "$input" ]; then
            input='file'
        elif [ -d "$input" ]; then
            input='directory'
        fi 
    fi                

    case "$input" in

        0)  
                break
                ;;

        'up')
                cd ..
                parent_files=(*)
                list_files "${parent_files[@]}"
                ;;

        'name')
                echo "Not implemented!"
                ;;

        'file') 
                while : ; do
                    
                    print_file_options
                    read -r option 

                    case "$option" in

                        0)  
                            break
                            ;;

                        1)
                            rm -r "$input_copy"
                            echo -e "$input_copy has been deleted."
                            break
                            ;;
                            
                        2)
                            echo "Enter the new file name: "
                            read -r new_filename
                            mv "$input_copy" "$new_filename"
                            echo -e "$input_copy has been renamed as $new_filename"
                            break
                            ;;
                            
                        3)
                            chmod 666 "$input_copy"
                            echo -e "Permissions have been updated."
                            ls -l "$input_copy"
                            break
                            ;;

                        4)
                            chmod 664 "$input_copy"
                            echo -e "Permissions have been updated."
                            ls -l "$input_copy"
                            break
                            ;;

                        *)
                            echo "Invalid input!" 
                            ;;


                    esac

                done

                ;;

        'directory') 
                cd "$input_copy" || return
                dir_files=(*)
                list_files "${dir_files[@]}"
                ;;        

        *)
                echo "Invalid input!" 
                ;;

    esac

    done 
}

function list_files() {
    files="$1"
    echo -e "\nThe list of files and directories:"
    for item in "${files[@]}"; do
      if [ -f "$item" ]; then
        echo "F $item"
      elif [ -d "$item" ]; then
        echo "D $item"  
      fi
    done
}

function find_executables() {
    echo "Enter an executable name:"
    read -r name
    echo
    if command -v "$name" > /dev/null; then

        echo -e "Located in: $(which $name)\n"
        
        echo -e "Enter arguments: "
        read -r arguments
        $name $arguments

    else
        echo -e "The executable with that name does not exist!\n"        
    fi 
}

echo "Hello $USER!"

while : ; do

print_menu

# read input from terminal
read -r action

case "$action" in

    0)  
        echo
        echo "Farewell!"
        break
        ;;
    1)
        os_info
        ;;
    2)
        user_info
        ;;
    3)
        file_operations
        ;;
    4)
        find_executables
        ;;
    *)
        echo "Invalid option!" 
        ;;

esac

done