# User Creation Script

This repository contains a bash script `create_users.sh` that reads a text file containing the employee’s usernames and group names, creates the users and groups as specified, sets up home directories with appropriate permissions and ownership, generates random passwords for the users, and logs all actions to `/var/log/user_management.log`. Additionally, the script securely stores the generated passwords in `/var/secure/user_passwords.csv`.

## Usage

1. Ensure the script is executable:

    chmod +x create_users.sh
 

2. Run the script with the text file as an argument:
   
    sudo ./create_users.sh <name-of-text-file>
   
## Logging

All actions performed by the script are logged in `/var/log/user_management.log`.

## Password Storage

Generated passwords are stored securely in `/var/secure/user_passwords.csv`, which is only readable by the file owner.

## Requirements

- The script must be run as root.


## Notes

- If a user already exists, the script skips the creation of that user.
- The script handles multiple groups for users, delimited by commas.


