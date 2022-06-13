#!/bin/bash
set -e
GIT_CURL_VERBOSE=1
printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# delete old contents
rm -rf public/*

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

git remote -v 

git pull --rebase origin master
#if ! timeout 5 9 git pull --rebase origin master; then
#  git remote rm origin
#  git remote add origin git@github.com:liawne/liawne.github.io.git
#fi

# Push source and build repos.
git push -f origin master || exit 1
