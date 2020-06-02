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
tail -n +2 dir-contents.txt | awk ' { printf "%-8s %-5s %-5s %-7s %-20s\n", $5, $6 , $7, $8, $9} ' > formatted.txt

###---Create file list---###
cat formatted.txt | awk ' { print $5 } ' > files.txt
number_of_files=$(wc -l files.txt | awk ' { print $1 } ')

###---Create metadata files & hash if needed---###
prog=1
mkdir -p metadata-files
cat files.txt | while read line;
do
        if [[ -f "metadata-files/$line.txt" ]]
        then
                echo "Metadata Export File Already Exists for $line..."
        else
                #This line is more accurate but sometimes misses potential duplicates with slightly different metadata
		#exiftool $1/"$line" -php | sed /"SourceFile"/d | sed /"FileName"/d | sed /"Date"/d > metadata-files/"$line".txt

                exiftool $1/"$line" -php | sed /"SourceFile"/d | sed /"FileName"/d | sed /"Date"/d | sed /"ExifByteOrder"/d | sed /"ThumbnailImage"/d | \
		sed /"ThumbnailLength"/d | sed /"ThumbnailOffset"/d | sed /"About"/d | sed /"LastKeywordXMP"/d | sed /"OffsetSchema"/d | \
		sed /"Padding"/d | sed /"Subject"/d  | sed /"ComponentsConfiguration"/d | sed /"YCbCrPositioning"/d | sed /"ExifVersion"/d > metadata-files/"$line".txt

		echo "Exporting/Hashing Metadata for $line------("$prog" / "$number_of_files")"
                hash=$(md5 metadata-files/"$line".txt | awk ' { print $4 } ')
                echo "$hash--$1/$line" >> hashlist.txt
        fi
        ((prog+=1))
done

###---Check for duplicate hashes & match to filename---###
load
echo "Scanning Hash Values for Matches"
load
true > dups-preclean.txt
cat hashlist.txt | awk -F "--" ' { print $1 } ' | sort | uniq -d | while read line
do
	group=$(grep "$line" hashlist.txt | awk -F "--" ' { print $2 } ')
	for i in $group
	do
		echo -n "$i ==%%==> " >>  dups-preclean.txt
	done
	echo  >> dups-preclean.txt
done
cat dups-preclean.txt | sed s/" ==%%==> $"//g > RESULTS-METAHASH.txt

###---Clean up---###

mkdir -p meta-hash-logs
mv files.txt meta-hash-logs
mv formatted.txt meta-hash-logs
mv hashlist.txt meta-hash-logs
mv dir-contents.txt meta-hash-logs
mv metadata-files meta-hash-logs
mv dups-preclean.txt meta-hash-logs

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
cat RESULTS-METAHASH.txt | while read line
do
	formatted=$(echo $line | tr ' ==%%==> ' '\n')
	for i in "$formatted"
	do
		mv $i review-folder	
	done
	echo "Press Enter When Ready:"
	echo
	read input </dev/tty
	mv review-folder/* $1
done
