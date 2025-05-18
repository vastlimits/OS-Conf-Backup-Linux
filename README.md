# Linux Config File Version Control and Backup on GitHub

A simple script that enables a powerful workflow: manage all configuration files on your Linux machines with Git and back them up on GitHub or any other version control host.

This is how it's used:

- Create a private GitHub repository for each machine's backup.
- Run the script on a Linux machine. It copies all configuration files (and/or anything else you want to backup) to a local Git repository.
- Push the changes from a machine's local repository to GitHub.

For more background information, see this [blog post](https://helgeklein.com/blog/linux-config-file-version-control-backup-on-github/).

# Preparation (Once per Machine You Want to Backup)

These preparation steps only need to be done once on each machine whose configuration you want to backup. [Check out how to perform a backup](#performing-a-backup).

## Local Backup Directory

Create a backup data directory, assign write permissions to the `adm` group and set the group ID so that all files created in the directory get the `adm` group:

```bash
sudo mkdir -p /backup/data
sudo chown -R root:adm /backup/
sudo chmod -R 774 /backup/
sudo chmod -R g+s /backup
```

Clone the backup script from its public repository into the `bin` subdirectory and make it executable:

```bash
git clone https://github.com/vastlimits/OS-Conf-Backup-Linux.git /backup/bin
chmod 774 /backup/bin/copy_files.sh
```

## New or Existing GitHub Repository

In the following sections, some steps differ depending on whether you're setting up a new GitHub backup repository or re-using an existing GitHub backup repository (e.g., after a machine reinstallation). I'll mark commands that are specific to one of the two scenarios with **New Repo** and **Existing Repo**, respectively.

## SSH Keypair

### Create or Re-use a Keypair

Create an SSH keypair to be used as GitHub deploy keys. We'll use the computername as key comment, leave the passphrase empty and move the generated keypair to the new repository. We also limit access to the owner or pushing to GitHub is blocked:

```bash
cd /backup
mkdir /backup/.ssh

### New repo:
ssh-keygen -t rsa -b 4096 -C "COMPUTERNAME"
mv ~/.ssh/id_* /backup/.ssh/

### Existing repo:
# Copy the private and public keys (id_rsa and id_rsa.pub) to the /backup/.ssh/ directory, e.g., via SCP

chgrp adm .ssh/id_*
chmod 600 .ssh/id_*
```

##  Git Configuration

If this is the first time you are using Git on this machine, configure your username and email:

```bash
git config --global user.name "your name"
git config --global user.email "email@domain.com"
```

Work around the Git error "fatal: detected dubious ownership in repository at '/backup/data'"

```bash
git config --global --add safe.directory /backup/data
```

Configure Git to use the SSH key for the backup repository:

```bash
cd /backup/data
git config core.sshCommand "ssh -i /backup/.ssh/id_rsa -F /dev/null"
```

## GitHub Repository

### New Repo

Create a Git repository in the backup data directory:

```bash
cd /backup/data
git init
```

Create the private GitHub repository:

- Create a new private repository for the current machine's configuration backup.
- Add the public key file `/backup/data/.ssh/id_rsa.pub` as a deploy key to the new repository.

Add the GitHub remote repository and push:

```bash
git remote add origin git@github.com:YOUR_ORGANIZATION/YOUR_REPOSITORY.git
```

### Existing Repo

Clone the existing GitHub repository:

```bash
cd /backup/data
git clone git@github.com:YOUR_ORGANIZATION/YOUR_REPOSITORY.git .
```

## Configure What to Backup

The script copies every file or directory listed in the source file `/backup/config/backup_src.txt`. Globbing (including recursive wildcard expansion) is enabled. The recommended default content for the backup source file is the following:

    /backup/.ssh
    /backup/config/backup_src.txt
    /etc/**/*.conf
    /etc/ssh/sshd_config

Create the config directory:

```bash
mkdir /backup/config
```

### New Repo

Create the backup sources file:

```bash
nano /backup/config/backup_src.txt
# Paste the file content into nano and save the file
```

### Existing Repo

Copy the backup sources file from the backup to the original location:

```bash
cp /backup/data/backup/config/backup_src.txt /backup/config/ 
```

# Performing a Backup

Run the script:

```bash
cd /backup/data/
sudo /backup/bin/copy_files.sh
```

Commit to the local repository and push to GitHub:

```bash
sudo git add --all
git commit
git push -u origin --all
```

# References

- Inspiration: https://www.laggner.at/config-file-backup-with-git/
