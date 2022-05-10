#!/bin/bash
set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Build the project.
hugo --minify # if using a theme, replace with `Hugo -t <YOURTHEME>`

# Go To Public folder
cd public

# Add changes to git.
git add .

# Commit changes.
msg="Published on $(date +'%Y-%m-%d %H:%M:%S')"
if [ -n "$*" ]; then
    msg="$*"
fi

git commit -m "$msg"

git pull --rebase origin master || exit 1

# Push source and build repos.
git push -f origin master || exit 1
