#!/bin/bash

###---Define functions---###
clear
function load(){
        for i in range {1..3}
        do
                echo "."
                echo
                sleep .02
        done
}

###---Initialize files---###
true > variations.txt
true > candidates.txt
true > RESULTS-SIMNAME.txt

###---Verify user input---###
if [[ $1 == "" ]]
then
	echo "Please specify target dir"
	exit 0
fi

###---Get target dir contents---###
ls -TSl $1 > ls.txt
cat ls.txt | awk ' { print $10 } ' | sed /^$/d > names.txt
number_of_files=$(wc -l names.txt | awk ' { print $1 } ')

###---Find files with similar names---###
prog=1
cat names.txt | while read line
do
	with_ext=$line
	without_ext=$(echo $line | sed s/"\...."//g)
	ext=$(echo $line | sed s/".*\."/\./g)
	echo "Scanning...($prog / $number_of_files)"
	find $1 -name "*$without_ext*$ext" > variations.txt
	if [[ $(wc -l variations.txt | awk ' { print $1 } ') = 1 ]]
	then
		:
	else
		cat variations.txt | sed s/"$1\/"//g | while read var
		do
			if [[ $with_ext != $var ]]
			then
				echo "$with_ext ==%%==> $var" >> candidates.txt
			fi
		done
		echo >> candidates.txt
	fi
	((prog+=1))
done

###---Verify matches by checking dates & times---###
echo "Verifying Candidate Pairs..."
echo
prog=1
number_of_files=$(cat candidates.txt | sed /^$/d | wc -l | awk ' { print $1 } ')
cat candidates.txt | sed /^$/d | while read pair
do
	echo "Verifying Pair------($prog / $number_of_files)"
	c1=$(echo $pair | awk -F " ==%%==> " ' { print $1 } ')
        c2=$(echo $pair | awk -F " ==%%==> " ' { print $2 } ')
	d1=$(cat ls.txt | grep " $c1" | awk ' { print $6,$7,$8,$9 } ')
        d2=$(cat ls.txt | grep " $c2" | awk ' { print $6,$7,$8,$9 } ')
	if [[ "$d1" == "$d2" ]]
	then
		echo "$pair" >> RESULTS-SIMNAME.txt
	fi
	((prog+=1))
done

###---Clean up---###
mkdir -p sim-name-logs
mv names.txt sim-name-logs
mv variations.txt sim-name-logs
mv ls.txt sim-name-logs
mv candidates.txt sim-name-logs

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
cat RESULTS-SIMNAME.txt| while read line
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
mv group.txt sim-name-logs
echo
echo "Completed"
