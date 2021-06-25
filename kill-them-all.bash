#!/bin/bash
bois=$(ps -ef | grep ./scan | awk ' { print $2 } ')
for i in {1..2}
do
	for i in $bois
	do
		echo "Killing...$i"
		kill $i
	done
done
