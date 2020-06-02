#!/bin/bash

mkdir -p dup-scan-logs
###---Verify user has supplied target directory---###
if [[ $1 == "" ]]
then
	echo "Please Specify a Target Directory"
	exit 0
fi

###---Initialize files---###
echo "" > ~/Desktop/dups.txt

###---Find duplicates---###
find $1 -type f -exec md5 '{}' ';' | awk ' { print $4 } ' | sort | uniq -d > ~/Desktop/hash.txt
find $1 -type f -exec md5 '{}' ';' > ~/Desktop/output.txt
cat ~/Desktop/hash.txt | while read line
do
	dups=$(cat ~/Desktop/output.txt | grep $line | awk ' { print $2 } ')
	echo $dups >> ~/Desktop/dups.txt
	echo $dups
done

if [[ $(cat dups.txt) == "" ]]
then
	echo "No Duplicates Found"
	mv dups.txt dup-scan-logs
else
	echo "Duplicates Found, see dup.txt"
fi
mv hash.txt dup-scan-logs
mv output.txt dup-scan-logs