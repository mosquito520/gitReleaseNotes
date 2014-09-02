#!/bin/bash

Output_Filename_Prefix="ReleaseNotes"
Output_Header_Prefix="${PWD##*/} Release Notes"

if [ -n "$1" ]; then
    if [ "$1" == "/all" ]; then
        Output_Filename="$Output_Filename_Prefix.md"
        Output_Header="$Output_Header_Prefix"
    elif [ "$1" == "/html" ]; then
        shopt -s nullglob
        for mdfile in *.md; do
            file=$( basename "$mdfile" )
            html_filename=$(printf "%s.html" "$file")
            cat > $html_filename <<EOL
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>$file</title>
    <style>
EOL
            cat ~/bin/gitReleaseNotes/style.css >> $html_filename
            cat >> $html_filename <<EOL
    </style>
    <body>
EOL
            markdown2 $mdfile >> $html_filename
            cat >> $html_filename << EOL
    </body>
</html>
EOL
        done
        exit
    else
        Output_TAG=$1
        Output_Filename=$(printf "%s-%s.md" "$Output_Filename_Prefix" "$1")
        #Output_Header=$(printf "%is %s" "$Output_Header_Prefix" "$1")
        Output_Header="$Output_Header_Prefix"
    fi
else
    script_name=`basename $0`
    echo "usage: $script_name [<tag_name>|/all|/html]"
    echo
    echo -e "\t<tag_name>\tOutput specific tag commit history"
    echo -e "\t/all\t\tOutput all tag commit history"
    echo -e "\t/html\t\tConvert markdown to html with style"
    exit
fi

Tag_list=($(git tag|tac)) #Get tag list and reverse it
if [ "$?" -ne 0 ]
then
    echo "Git return error $?, Terminate!!!!!"
fi

echo "$Output_Header" > $Output_Filename
echo "=====================" >> $Output_Filename

len_Tag_list=${#Tag_list[*]}

for ((i = 0 ; i < "${len_Tag_list}"; i++)); do
    next=$((i+1))
    if [ "$Output_TAG" = "" ]; then
        if [ "$next" -lt "$len_Tag_list" ]; then
            Commit_list=$(git log --graph --pretty=format:'%s' --abbrev-commit --date=relative ${Tag_list[$next]}..${Tag_list[$i]})
        else
            Commit_list=$(git log --graph --pretty=format:'%s' --abbrev-commit --date=relative ${Tag_list[$i]})
        fi
    else
        if [ "$Output_TAG" = "${Tag_list[$i]}" ]; then
            Commit_list=$(git log --graph --pretty=format:'%s' --abbrev-commit --date=relative ${Tag_list[$next]}..${Tag_list[$i]})
        else
            continue
        fi
    fi

    # Output tag name as second tier header
    echo "${Tag_list[$i]}" >> $Output_Filename
    echo "---------------------" >> $Output_Filename

    # change delimiter (IFS) to new line.
    IFS_BAK=$IFS
    IFS=$'\n'
    # Output each line
    for j in $Commit_list; do
        j=${j//\_/\\\_}
        j=${j//\(/\\\(}
        j=${j//\)/\\\)}
        echo $j >> $Output_Filename
    done
    IFS=$IFS_BAK
    
    # Leave blank
    echo "" >> $Output_Filename
done
