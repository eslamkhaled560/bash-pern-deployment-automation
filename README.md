# Session 2 - Gathering System Information

**Presented to:**    
_Omar Mohsen_    

**Presented by:**   
_Islam Khaled_    

25 April 2023

-----------------------------------------
### The Script:

What I'm going to do here is to move the ```compressed file``` from ```WSL (Windows Subsystem Linux)``` to a ```Virtual Machine``` on VMware.

The original script is provided [system_info.sh](https://github.com/eslamkhaled560/Sprints-Tasks/blob/main/5-%20DevOps%20Fundmentals/S_BS_02%20Writing%20A%20Script%20To%20Gather%20Information%20About%20The%20Linux%20env/system_info.sh) , 
and here is the code inside the script:
```
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
```

-------------------------
### Before Running Script:

Getting the IP address of the VM (destination):

![image](https://user-images.githubusercontent.com/54172897/234338790-b7af2d60-fb4e-4631-8ec4-8627c33ddaba.png)

Making sure everything is ready in the destination location:

![image](https://user-images.githubusercontent.com/54172897/234853704-c56b6cac-eecb-4a3a-8212-9b496b91fa1c.png)

![image](https://user-images.githubusercontent.com/54172897/234339111-49c0da53-562c-4221-ae1e-9fc7d619a411.png)

-------------------------
### Script Output:

On WSL (Windows Subsystem Linux):

![image](https://user-images.githubusercontent.com/54172897/234340505-68ca7c14-70c5-43a7-a06f-72fa86e86e28.png)

**Clarification**:
> WSL is a very simple system so that lots of system files isn't available,      
> Like ```/var/log/dmesg``` file.

![image](https://user-images.githubusercontent.com/54172897/234542380-aaa29836-4d4c-4a2c-9fe9-90f8e184dd1e.png)

> That's why I used ```dmesg``` command:

![image](https://user-images.githubusercontent.com/54172897/234542763-31afbb49-dfcf-4052-88bd-ed9330ab283b.png)
![image](https://user-images.githubusercontent.com/54172897/234550466-02841241-6942-4c18-aaca-8b0f804fd94b.png)

-------------------------
### After Running Script:

![image](https://user-images.githubusercontent.com/54172897/234341104-a1ff76d2-ed7e-4e04-8e9e-861a8b064c0e.png)
![image](https://user-images.githubusercontent.com/54172897/234544245-9d0b2fdd-8a7e-40d4-a139-bdfc16ec3932.png)

-------------------------
