Duplicate Assassin 2.0

Modules:

1. Duplicate-Scan
	-Finds true duplicate files via md5 hash
	-Fast and accurate but misses duplicates that vary slightly

2. Find-Blank-Files
	-Finds "blank" or shadow copies of files that are all 0's in the hex and moves them to a folder

3. Reset-Dates
	-Uses 'exiftool' to look for original date and times and reset the files RMAC metadata accordingly

4. Size-Date-Duplicate-Scan
	-Finds files with identical sizes/dates and moves them to folder

5. Meta-Hash-Duplicate-Scan
	-Exports metadata of files using 'exiftool' and hashes the text file
	-Good for finding duplicates that have different names/sizes but still retain much of the same metadata

6. Similar-Name-Duplicate-Scan
	-Finds files that share parts of their names and verifies matches with date/time data

7. Percent-Sim-Duplicate-Scan
	-Most rigorous scan, used to find extremely elusive duplicates
	-Hexdumps files to text files and calculates how similar they are by percentage
	-This is extremely intensive and time consuming with larger targets
	-Each file is compared to every other file so ETC grows exponentially with the number of target files
	-Uses four children jobs to go faster, you will need to run kill-them-all.bash to stop them before they finish

8. Process-Results
	-Used to run through results files from module 7 and move groups of potential duplicates through a "review" folder
	-User presses enter to move whatever is left in review folder to a folder called "Originals" and advance to the next set
	-User deletes what they don't want to keep from each set leaves what they do in place for the script to relocate to "Originals"
