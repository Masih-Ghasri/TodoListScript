#!/bin/bash

command=$1

case "$command" in
    "add")
        # Initialize variables for add command
        title=""
        priority="L"  # Default priority is Low

        # Process arguments using while and shift
        shift  # Skip the "add" command
        while [ $# -gt 0 ]; do
            case "$1" in
                -t|--title)
                    if [ -n "$2" ]; then
                        title="$2"
                        shift 2
                    else
                        echo "Option -t|--title Needs a Parameter"
                        exit 1
                    fi
                    ;;
                -p|--priority)
                    if [ -n "$2" ]; then
                        if [ "$2" = "L" ] || [ "$2" = "M" ] || [ "$2" = "H" ]; then
                            priority="$2"
                            shift 2
                        else
                            echo "Option -p|--priority Only Accept L|M|H"
                            exit 1
                        fi
                    else
                        echo "Option -p|--priority Needs a Parameter"
                        exit 1
                    fi
                    ;;
                *)
                    shift
                    ;;
            esac
        done

        # Check if title is provided
        if [ -z "$title" ]; then
            echo "Option -t|--title Needs a Parameter"
            exit 1
        fi

        # Add task to tasks.csv
        echo "0,$priority,\"$title\"" >> tasks.csv
        ;;
    "list")
        # Check if tasks.csv exists and is not empty
        if [ -s tasks.csv ]; then
            # Read tasks.csv line by line with line number
            awk -F, '{print NR " | " $1 " | " $2 " | " $3}' tasks.csv
        fi
        ;;
    "clear")
        # Clear tasks.csv by truncating it
        : > tasks.csv
        ;;
    "find")
        # Check if search term is provided
        if [ -z "$2" ]; then
            echo "Find command requires a search term"
            exit 1
        fi
        # Search for tasks containing the search term in the title (case-insensitive)
        if [ -s tasks.csv ]; then
            awk -F, -v search="$2" 'tolower($3) ~ tolower(search) {print NR " | " $1 " | " $2 " | " $3}' tasks.csv
        fi
        ;;
    "done")
        # Check if task ID is provided
        if [ -z "$2" ]; then
            echo "Done command requires a task ID"
            exit 1
        fi
        task_id=$2
        # Check if tasks.csv exists and is not empty
        if [ -s tasks.csv ]; then
            # Check if task ID is valid
            line_count=$(wc -l < tasks.csv)
            if [ "$task_id" -le 0 ] || [ "$task_id" -gt "$line_count" ]; then
                echo "Invalid task ID"
                exit 1
            fi
            # Update the task status to done (1)
            awk -v id="$task_id" -F, 'NR==id {$1=1} {print $0}' OFS=, tasks.csv > temp.csv
            mv temp.csv tasks.csv
        else
            echo "No tasks found"
            exit 1
        fi
        ;;
    *)
        echo "Command Not Supported!"
        exit 1
        ;;
esac
