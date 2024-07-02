#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "Script is running with root privileges."

# Define log and password file paths
LOG="/var/log/user_management.log"
PASSWORD="/var/secure/user_passwords.csv"

# Create log file if it doesn't exist
echo "Checking if log file exists..."
if [ ! -f $LOG ]; then
  echo "Log file does not exist, creating now..."
  sudo touch $LOG
  sudo chmod 644 $LOG
  echo "Log file created successfully."
else
  echo "Log file already exists."
fi

# Check if the secure directory exists, if not create it
echo "Checking if secure directory exists..."
if [ ! -d "/var/secure" ]; then
    echo "Secure directory /var/secure does not exist, creating now..."
    sudo mkdir -p /var/secure
    sudo chmod 700 /var/secure  # Set directory permissions securely
    echo "Secure directory created."
fi

# Create password file if it doesn't exist
echo "Checking if password file exists..."
if [ ! -f $PASSWORD ]; then
  echo "Password file does not exist, creating now..."
  sudo touch $PASSWORD
  sudo chmod 600 $PASSWORD
  if [ -f $PASSWORD ]; then
    echo "Password file created successfully."
  else
    echo "Failed to create password file."
  fi
else
  echo "Password file already exists."
fi

# Function to log messages
log_action() {
    local message=$1
    echo "$(date +'%Y-%m-%d %H:%M:%S') : $message" >> $LOG
}

# Function to generate a random password
generate_password() {
    local password_length=12
    local password=$(tr -dc 'A-Za-z0-9!@#$%^&*()_+{}|:<>?=' < /dev/urandom | head -c $password_length)
    echo $password
}

# Verify that the input file exists
if [ ! -f "$1" ]; then
    echo "Error: Input file not found."
    exit 1
fi

# Read the input file and process each line
echo "Starting to process input file..."
while IFS=';' read -r user groups; do
    # Remove whitespace
    user=$(echo $user | xargs)
    groups=$(echo $groups | xargs)
    
    echo "Processing user: $user with groups: $groups"
    
    if id "$user" &>/dev/null; then
        log_action "User $user already exists. Skipping creation."
        echo "User $user already exists, skipping..."
        continue
    fi
    
    # Create user with home directory and personal group
    useradd -m -s /bin/bash $user
    log_action "Created user $user with home directory."
    
    # Add user to additional groups if specified
    if [ -n "$groups" ]; then
        IFS=',' read -ra GROUP_ARRAY <<< "$groups"
        for group in "${GROUP_ARRAY[@]}"; do
            group=$(echo $group | xargs)
            if ! getent group $group > /dev/null 2>&1; then
                groupadd $group
                log_action "Created group $group."
            fi
            usermod -aG $group $user
            log_action "Added user $user to group $group."
        done
    fi
    
    # Generate and set password
    password=$(generate_password)
    echo "$user:$password" | chpasswd
    log_action "Set password for user $user."
    
    # Save username and password to the password file
    echo "$user,$password" >> $PASSWORD
done < "$1"

log_action "User creation process completed."
echo "User creation process completed."
