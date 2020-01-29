#!/bin/sh

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Build the project.
hugo -t hugo-theme-cactus-plus

# Go To Public folder
cd public

# pull before commit
git pull origin master

# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come Back up to the Project Root
cd ..

# pull before commit
git pull origin master

# blog repository Commit & Push
git add .
git commit -m "$msg"

git push origin master
