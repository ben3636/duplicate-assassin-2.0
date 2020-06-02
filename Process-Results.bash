#!/bin/bash

###---Verify user has supplied file and directory---###
if [[ $1 == "" ]]
then
	echo "Usage: ./Process-Results.bash (file) (dir)"
	exit 0
fi

if [[ $2 == "" ]]
then
	echo "Usage: ./Process-Results.bash (file) (dir)"
	exit 0
fi

###---Create folders---###
mkdir -p ~/Desktop/review-folder

###---Initialize groups file---###
echo "" > dup-groups.txt

###--Loop through output file to find duplicate groups---###
cat $1 | sed /^$/d | while read line
do
	echo "" > dup-set.txt						#INITIALIZE SET FILE
	file1=$(echo $line | awk -F ".=.*%==> " ' { print $1 } ')	#SET FILE1
        file2=$(echo $line | awk -F ".=.*%==> " ' { print $2 } ')	#SET FILE2
	echo $file1 >> dup-set.txt					#ECHO FILE1 TO SET FILE
	echo $file2 >> dup-set.txt					#ECHO FILE2 TO SET FILE
	cat $1 | sed /^$/d | grep "$file1" | while read results		#SEARCH OUTPUT FILE FOR ALL OTHER OCCURRENCES OF FILE1
	do
		result1=$(echo $results | awk -F ".=.*%==> " ' { print $1 } ')	#SET RESULT1
                result2=$(echo $results | awk -F ".=.*%==> " ' { print $2 } ')	#SET RESULT2
		echo $result1 >> dup-set.txt					#ECHO RESULT1 TO FILE
		echo $result2 >> dup-set.txt					#ECHO RESULT2 TO FILE
	done
	sorted_dups=$(cat dup-set.txt | sort | uniq)		#READ IN THE SET AND STRIP OUT DUPLICATES
	for i in $sorted_dups					#LOOP THROUGH FILES AND ECHO TO FILE AS ONE LINE SEPARATED BY "==="	
	do
		echo -n "$i===" >> dup-groups.txt
	done
	echo "" >> dup-groups.txt				#BEGIN NEWLINE IN MASTER LIST
done

###---Clean up groups list and move files to staging area---###
cat dup-groups.txt | sed s/===$// > groups-preclean.txt		#STRIP OUT UNNEEDED FIELD SEPARATORS AT END OF LINES AND ECHO TO FILE
cat groups-preclean.txt | sort | uniq > groups.txt		#STRIP OUT DUPLICATE LINES FROM MASTER LIST AND ECHO TO NEW FILE
cat groups.txt | sed s/".txt"//g | while read line		#LOOP THROUGH MASTER LIST AND MOVE FILES TO STAGING AREA FOR REVIEW
do
	files=$(echo $line | tr '===' '\n')
	for i in $files
	do
		mv $2/$i ~/Desktop/review-folder
	done
	echo "Press Enter When Ready:"
	echo
	read input </dev/tty					#WAIT FOR USER INPUT TO CONTINUE
	mv ~/Desktop/review-folder/* $2				#MOVE WHATEVER USER HAS LEFT TO ORIGINAL FOLDER
	clear
done

###---Clean up leftover files---###
mkdir -p process-logs
mv groups-preclean.txt process-logs
mv groups.txt process-logs
mv dup-set.txt process-logs
mv dup-groups.txt process-logs

if [[ $(ls review-folder) == "" ]]
then
	mv review-folder process-logs
fi