#!/bin/bash

percent=$(cat ~/Desktop/threshold.txt)
number_of_files=$(wc -l ~/Desktop/ls-hexad | awk ' { print $1 } ')
prog=1
cat ~/Desktop/ls-hexad | while read file1
do
#       echo "Job 4------Scanning Hex...("$prog" / "$number_of_files")"
	echo "("$prog" / "$number_of_files")" > ~/Desktop/job4-status.txt
        cat ~/Desktop/ls-hex.txt | sed s/^"$file1"// | sed /"^$"/d | while read file2
        do
                cl=$(comm -12 ~/Desktop/hexdumps/"$file1" ~/Desktop/hexdumps/"$file2" | wc -l | sed s/" "//g)
                tl=$(wc -l ~/Desktop/hexdumps/$file1 | awk '{ print $1 }')
                score=$(echo "scale=2; ($cl/$tl*100)" | bc)
                score=$(echo $score | cut -d "." -f1)
                #echo "Score is $score"
                if [[ $score -ge $percent ]]
                then
                        #echo "Files $file1 ===> $file2 are $score"%" similar"
                        echo "$file1 =$score%==> $file2" >> ~/Desktop/duplicates.txt
                fi
        done
        ((prog+=1))
done
