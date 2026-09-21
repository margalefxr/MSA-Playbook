#!/bin/bash
MESSAGE=${1:-"auto: update playbook notes"}
git add .
git commit -m "$MESSAGE"
git push origin master
