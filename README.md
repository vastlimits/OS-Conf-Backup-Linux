# Linux Config File Version Control and Backup on GitHub

A simple script that enables a powerful workflow: manage all configuration files on your Linux machines with Git and back them up on GitHub or any other version control host.

This is how it's used:

- Create a private GitHub repository for each machine's backup.
- Run the script on a Linux machine. It copies all configuration files (and/or anything else you want to backup) to a local Git repository.
- Push the changes from a machine's local repository to GitHub.

# Preparation (Once per Machine You Want to Backup)

These preparation steps only need to be done once on each machine whose configuration you want to backup. [Check out how to perform a backup below](#performing-a-backup).

## Local Backup Directory

Create a backup data directory, assign write permissions to the `adm` group and set the group ID so that all files created in the directory get the `adm` group:

    sudo mkdir -p /backup/data
    sudo chown -R root:adm /backup/
    sudo chmod -R 774 /backup/
    sudo chmod -R g+s /backup

Clone the backup script from its public repository into the `bin` subdirectory and make it executable:

    git clone https://github.com/vastlimits/OS-Conf-Backup-Linux.git /backup/bin
    chmod 774 /backup/bin/copy_files.sh

##  Git Configuration

If this is the first time you are using Git on this machine, configure your username and email:

    git config --global user.name "your name"
    git config --global user.email "email@domain.com"

Create a Git repository in the backup data directory:

    cd /backup/data
    git init

## SSH Keypair

Create an SSH keypair to be used as GitHub deploy keys. We'll use the computername as key comment, leave the passphrase empty and move the generated keypair to the new repository. We also limit access to the owner or pushing to GitHub is blocked:

    cd /backup/data
    ssh-keygen -t rsa -b 4096 -C "www1-ubuntu"
    mkdir /backup/data/.ssh
    mv ~/.ssh/id_* /backup/data/.ssh/
    chgrp adm .ssh/id_*
    chmod 600 .ssh/id_*

## GitHub Repository

Create the private GitHub repository:

- Create a new private repository for the current machine's configuration backup.
- Add the public key file `/backup/data/.ssh/id_rsa.pub` as a deploy key to the new repository.

Add the GitHub remote repository and push:

    git remote add origin git@github.com:YOUR_ORGANIZATION/YOUR_REPOSITORY.git

## Configure What to Backup

The script copies every file or directory listed in the source file `/backup/config/backup_src.txt`. Globbing (including recursive wildcard expansion) is enabled. The recommended default content for the backup source file is the following:

    /etc/**/*.conf

Create the backup sources file:

    mkdir /backup/config
    nano /backup/config/backup_src.txt
    [paste the file content and save the file]

## Set the SSH Key Per Repository

Normally, the SSH keys used by Git are configured once per user. In this case, however, we want to specify the keys per repository.

Configure Git to use the new SSH key for this repository:

    git config core.sshCommand "ssh -i /backup/data/.ssh/id_rsa -F /dev/null"

# Performing a Backup

Run the script:

    /backup/bin/copy_files.sh

Commit to the local repository and push to GitHub:

    git add --all
    git commit
    git push -u origin --all

# References

- Inspiration: https://www.laggner.at/config-file-backup-with-git/
