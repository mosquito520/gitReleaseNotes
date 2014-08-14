#!/bin/bash

if [ -n "$1"]; then
    Output_TAG=$1
fi

Tag_list=`git tag|tac` #Get tag list and reverse it
if [ "$?" -ne 0 ]
then
    echo "Terminate!!!!!"
fi

for Tag in $Tag_list 
do
    echo ">>>$Tag"
done
