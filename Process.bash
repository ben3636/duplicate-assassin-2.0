#!/bin/bash

if [[ $1 == "" ]] || [[ $2 == "" ]]
then
	echo "Usage: ./Process.bash [results file] [target dir]"
	exit 0
fi

###---Review candidates---###
mkdir -p review-folder
mkdir -p process-logs
cat $1 | while read line
do
	echo $line | tr ' ==%%==> ' '\n' > group.txt
	cat group.txt | sed /^$/d | while read line
	do
		mv $2/$line review-folder	
	done
	echo "Press Enter When Ready:"
	echo
	read input </dev/tty
	mv review-folder/* $2
done
mv group.txt process-logs
