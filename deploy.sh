#!/bin/bash

hugo

cd public

git add .

msg="building mysite `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

git push origin master