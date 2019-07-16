#!/bin/bash

# Sample
gcloud source repos create default

# Git ClI
git init
git config credential.helper gcloud.sh

git remote add origin https://source.developers.google.com/p/$DEVSHELL_PROJECT_ID/r/default

git config --global user.email "[EMAIL_ADDRESS]"
git config --global user.name "[USERNAME]"

git add .
git commit -m "Initial commit"
git push origin master

# Create Dev Branch
git checkout -b new-feature

# Adjust Jenkins File
nano JenkinsFile

# def project = 'REPLACE_WITH_YOUR_PROJECT_ID'
# def appName = 'gceme'
# def feSvcName = "${appName}-frontend"
# def imageTag = "gcr.io/${project}/${appName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"

# Adjust html.go
nano html.go

# <div class="card blue"> ====> <div class="card orange">

# Adjust Main.go
nano main.go

# const version string = "1.0.0" ====> const version string = "2.0.0"

# Start Deploy
git add Jenkinsfile html.go main.go
git commit -m "Version 2.0.0"
git push origin new-feature

