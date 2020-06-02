#!/bin/bash

###---Define functions--###
clear
function load(){
        for i in range {1..3}
        do
                echo "."
                echo
                sleep .001
        done
}

function status(){
running_scans=$(ps -ef | grep ./scan | wc -l | awk ' { print $1 } ')
#echo "Running: $running_scans"
	until [[ $running_scans == "1" ]]
	do
		j1=$(cat ~/Desktop/job1-status.txt)
    		j2=$(cat ~/Desktop/job2-status.txt)
     		j3=$(cat ~/Desktop/job3-status.txt)
    		j4=$(cat ~/Desktop/job4-status.txt)
		clear
		echo "			Jobs Status"
		echo
		echo "---------------------------------------------------------------"
		echo "| JOB 1----------$j1"
        	echo "---------------------------------------------------------------"
        	echo "| JOB 2----------$j2"
        	echo "---------------------------------------------------------------"
        	echo "| JOB 3----------$j3"
        	echo "---------------------------------------------------------------"
        	echo "| JOB 4----------$j4"
        	echo "---------------------------------------------------------------"
		echo
		load
		echo "			Live Report"
		tail -n5 ~/Desktop/duplicates.txt
		sleep 10
		running_scans=$(ps -ef | grep ./scan | wc -l | awk ' { print $1 } ')
	done
}

###---Verify user has supplied files---###
if [[ $1 == "" ]]
then
	echo "Please specify target directory"
	exit 0
fi

###---Set similarity threshold to consider files duplicates---###
echo "What should the threshold percentage be to consider files duplicates?"
echo
echo "Enter a Percentage:"
read percent
echo $percent > ~/Desktop/threshold.txt
load

###---Hex dump files---###
ls $1 > ~/Desktop/ls.txt
mkdir -p ~/Desktop/hexdumps
ls -l $1 | awk ' { print $9 } ' | sed /"^$"/d > ~/Desktop/files-list.txt
number_of_files=$(wc -l ~/Desktop/files-list.txt | awk ' { print $1 } ')
prog=1
cat ~/Desktop/ls.txt | while read line
do
	if [[ -f ~/Desktop/hexdumps/$line.txt ]]
	then
                echo "Hex dump already exists..."
	else
		echo "Dumping Hex...("$prog" / "$number_of_files")"
		load
		hexdump $1/$line > ~/Desktop/hexdumps/$line.txt
	fi
	((prog+=1))
done

###---Calculate similarity score---###
ls ~/Desktop/hexdumps > ~/Desktop/ls-hex.txt
true > ~/Desktop/duplicates.txt
fourth=$(($number_of_files/4))
#echo "25% is $number_of_files // 4 OR $fourth"
split -l$fourth ls-hex.txt ls-hex
./scan1.bash & ./scan2.bash & ./scan3.bash & ./scan4.bash & status

###---Clean up---###
mkdir -p ~/Desktop/percent-sim-logs
mv ~/Desktop/ls.txt ~/Desktop/percent-sim-logs
mv ~/Desktop/ls-hex.txt ~/Desktop/percent-sim-logs
mv ~/Desktop/files-list.txt ~/Desktop/percent-sim-logs
mv ~/Desktop/hexdumps ~/Desktop/old-hexdumps
load 
mv ls-hexa* ~/Desktop/percent-sim-logs
mv ~/Desktop/job*-status.txt ~/Desktop/percent-sim-logs
mv ~/Desktop/threshold.txt ~/Desktop/percent-sim-logs
echo "Completed"
echo

###---Process files---###
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
		./Process-Results.bash duplicates.txt $1
                ;;
esac
