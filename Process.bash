#!/bin/bash
###---Review candidates---###
mkdir -p review-folder
mkdir -p process-logs
cat RESULTS-SIZEDATE.txt | while read line
do
	echo $line | tr ' ==%%==> ' '\n' > group.txt
	cat group.txt | sed /^$/d | while read line
	do
		mv $1/$line review-folder	
	done
	echo "Press Enter When Ready:"
	echo
	read input </dev/tty
	mv review-folder/* $1
done
mv group.txt process-logs