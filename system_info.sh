#!/bin/bash

# Function to run a command and validate exit code
function run_command {
    $1 &> "$2"

    # Check the exit code of the command
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to run '$1'"
        exit 1
    else
        echo "Command '$1' ran succesfully."
    fi
    
    # Parse the disk usage output to extract the path and usage percentage
    if [ "$1" == "df -h /" ]; then
            disk_path=$(awk 'NR==2{print $NF}' disk_usage.txt)
            disk_usage=$(awk 'NR==2{print $5}' disk_usage.txt)
            echo "Disk usage for $disk_path: $disk_usage"
            echo
    fi

    # Check that the output file was created
    if [[ ! -f "$2" ]]; then
        echo "Error: Output file '$2' was not created"
        exit 1
    else
        echo "Output file '$2' created succesfully."
        echo "========================================================"
    fi
}

# Function to compress files and send over network
function send_files {
    tar -czf system_info.tar.gz ps_info.txt memory_usage.txt disk_usage.txt dmesg.txt
    
    # Check that the compressed file was created
    if [[ ! -f "system_info.tar.gz" ]]; then
        echo "Error: Compressed file 'system_info.tar.gz' was not created"
        exit 1
    else
        echo "Compressed file 'system_info.tar.gz' succesfully created"
        echo
    fi
    
    # User input for SSH transfer
    read -p "Enter IP address of remote machine: " IP
    read -p "Enter username for remote machine: " USER
    read -p "Enter destination path for output files: " DEST_PATH
    echo

    # Send the compressed file over SSH using scp
    scp system_info.tar.gz $USER@$IP:$DEST_PATH

    # Check that the file was successfully transferred
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to transfer compressed file to destination"
        exit 1
    else
        echo "Compressed file transfered to destination succesfully"
    fi
    
    # Clear Info
    rm system_info.tar.gz ps_info.txt memory_usage.txt disk_usage.txt dmesg.txt
}

# Run the specified commands and output to files
run_command "ps aux" "ps_info.txt"
run_command "free -m" "memory_usage.txt"
run_command "df -h /" "disk_usage.txt"
run_command "dmesg" "dmesg.txt"

# Send the files over the network
send_files
