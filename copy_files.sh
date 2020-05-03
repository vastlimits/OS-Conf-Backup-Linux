#!/bin/bash

# Remove all previously copied files and folders (excluding metadata) in the current (backup) directory
find /backup/data -maxdepth 1 -mindepth 1 -not -iname ".git" | xargs --no-run-if-empty rm -r

# Copy the files and directories on the list to the current (backup) directory
# xargs does not start a shell, so we need to do it ourselves or globbing won't be available
# Enable globstar (two asterisks = recurse into subdirectories) and include files starting with a dot in filename expansion
cat /backup/config/backup_src.txt | xargs -I % bash -c "shopt -s globstar dotglob; cp --parents -R % ."
