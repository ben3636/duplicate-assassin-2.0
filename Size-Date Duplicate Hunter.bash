#!/bin/bash

clear
###---Define functions---###
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
load
echo "Scanning In Progress"
load

###---Format contents file (leave only name, date, and size)---###
cat dir-contents.txt | awk ' { printf "%-8s %-5s %-5s %-7s %-20s\n", $5, $6 , $7, $8, $9} ' > formatted.txt

###---Initialize files---###
true > size-duplicates.txt
true > date-duplicates.txt
true > combined.txt
true > RESULTS-SIZEDATE.txt

###---Find potential duplicates by file size---### 
cat formatted.txt | awk ' { print $1 } ' | sort | uniq -d > duplicate-sizes.txt
cat duplicate-sizes.txt | while read line;
do
	cat formatted.txt | grep $line >> size-duplicates.txt
done

###---Find potential duplicates by date---###
cat formatted.txt | awk ' { printf "%-5s %-5s %-4s\n", $2, $3, $4 } ' | uniq -d > duplicate-dates.txt
cat duplicate-dates.txt | while read line;
do
        cat formatted.txt | grep "$line" >> date-duplicates.txt
done

###---Combine size & date Duplicates---###
cat size-duplicates.txt | awk ' { printf "%-8s %-5s %-5s %-4s\n", $1, $2, $3, $4 } ' | sed /^$/d  >> combined.txt
cat date-duplicates.txt | awk ' { printf "%-8s %-5s %-5s %-4s\n", $1, $2, $3, $4 } ' | sed /^$/d >> combined.txt
cat combined.txt | sort | uniq -d > dups-preclean1.txt
cat dups-preclean1.txt | while read line
do
	size=$(echo $line | awk ' { print $1 } ')
	d1=$(echo $line | awk ' { print $2 } ')
	d2=$(echo $line | awk ' { print $3 } ')
	d3=$(echo $line | awk ' { print $4 } ')
	#echo "|$size  $d1   $d2    $d3|" 
	grep "$size  $d1   $d2    $d3" formatted.txt > results.txt
	if [[ $(cat results.txt) != "" ]]
	then
		#echo $results
		cat results.txt | while read line
		do
			name=$(echo $line | awk ' { print $5 } ')
			echo -n "$name ==%%==> " >> dups-preclean2.txt
		done
		echo >> dups-preclean2.txt
	fi
done
cat dups-preclean2.txt | while read line
do
	echo $line > wc.txt
	if [[ $(wc wc.txt | awk ' { print $2 } ') -gt 2 ]]
	then
		echo $line | sed s/" ==%%==>$"//g >> RESULTS-SIZEDATE.TXT
	fi
done


###---Move extra files to log directory---###
mkdir -p date-size-logs
mv duplicate-sizes.txt date-size-logs
mv duplicate-dates.txt date-size-logs
mv combined.txt date-size-logs
mv size-duplicates.txt date-size-logs
mv date-duplicates.txt date-size-logs
mv formatted.txt date-size-logs
mv dir-contents.txt date-size-logs
mv dups-preclean*.txt date-size-logs
mv wc.txt date-size-logs
mv results.txt date-size-logs

###---Ask if user wants to review matches---###
echo "Would you like to process results now?"
echo
echo "Y/N"
read choice
case $choice in
        [Nn] )
                exit 0
                ;;
        [Yy] )
                load
                ;;
esac

###---Review candidates---###
mkdir -p review-folder
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
mv group.txt date-size-logs