#!/bin/bash

clear
###---Define Functions---###
clear
function load(){
        for i in range {1..3}
        do
                echo "."
                echo
                sleep .02
        done
}


###---Verify user input---###
if [[ $1 == "" ]]
then
	echo "Please specify target dir"
	exit 0
fi

###---List directory contents to file---###
ls -l $1 > dir-contents.txt

###---Format contents file (leave only name, date, and size)---###
cat dir-contents.txt | awk ' { printf "%-8s %-5s %-5s %-7s %-20s\n", $5, $6 , $7, $8, $9} ' > formatted.txt

###---Loop and look for files with lots of zeros---###
mkdir -p "Blank-Files"
cat formatted.txt | awk ' { print $5 } ' > files-to-check.txt
number_of_files=$(wc -l files-to-check.txt | awk ' { print $1 } ')
prog=1
cat files-to-check.txt | while read line;
do
	hex=$(hexdump -d -n256 $1/"$line" | grep "0000000")
	echo "Scanning------("$prog" / "$number_of_files")"
	if [[ $hex == "0000000   00000   00000   00000   00000   00000   00000   00000   00000" ]]
	then
		mv $1/"$line" Blank-Files/
		echo "Found One..."
	else
		echo
	fi
	((prog+=1))
done

###---Clean up---###
mkdir -p hex-hunter-logs
mv formatted.txt hex-hunter-logs
mv files-to-check.txt hex-hunter-logs
mv dir-contents.txt hex-hunter-logs
load
echo "Completed"
