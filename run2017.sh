#!/bin/bash

# Global variables, classpath may need to be user-defined
location="$(pwd)"
workdir="$(realpath $(dirname $0))" # Only used when the user doesn't use the flags
src_dirs=("$workdir/mmt-core/" "$workdir/mmt-app/")
test_dir="$workdir/Tests-ei-daily-201711101726/"
classpath="/usr/share/java/po-uuilib.jar"
mainclass="mmt.app.App"
common=".*A-([0-9]{2,3})-([0-9]{2,3})\."
input="in"
import="import"
output="outhyp"
expected="out"
logfile="$location/results.txt"

# Set the working directory and test directory in case the user provided them
while getopts s:t: flag;
do
	case $flag in
		s)
			src_root=$(realpath $OPTARG)
			if [[ ! -d "$src_root" ]]
			then
				echo "Source directory $src_root does not exist"
				exit 1
			fi
			dirs=("mmt-core/" "mmt-app/")
			src_dirs=()
			for dir in "${dirs[@]}"
			do
				src_dirs+=("$src_root/$dir")
			done
			;;
		t)
			test_dir="$(realpath $OPTARG)/"
			;;
		\?)
			echo "Invalid option: -$flag"
			;;
	esac
done

# Test if the directories (provided or implicit) exist
all_dirs=("${src_dirs[@]}" "$test_dir")
for dir in "${all_dirs[@]}"
do
	if [[ ! -d "$dir" ]]
	then
		echo "Directory $dir does not exist"
		exit 1
	fi
done

# Set the classpath according to the directories
classpath+=":${src_dirs[0]}mmt-core.jar:${src_dirs[1]}mmt-app.jar"

# Run the java compiler for the project packages
function compile {
	for dir in "${src_dirs[@]}"
	do
		make -C "$dir"
		if [[ $? -ne 0 ]]
		then
			echo -e "\nCompilation failed on package ""$dir""\n"
			exit 1
		fi
	done
}

# Run the tests
function test {
	# Go inside the test directory (to avoid filling whatever directory you're in with junk)
	cd "$test_dir"
	# Clear up the log file and reset the counters
	echo -n "" > $logfile
	failed=0
	passed=0
	echo -e "\nRunning tests...\n"

	for inputfile in `find $test_dir -regextype posix-extended  -regex "$common$input" | sort`
	do
		# Find the common substring for this test
		#commonfile=$(echo $inputfile | cut -d '.' -f 2 -s | cut -d '/' -f '2' -s)
		commonfile=${inputfile%in}

		# Create (or clear) the output file for this test
		outputfile="$commonfile$output"
		#echo "" > $outputfile
		javaoptions="-cp $classpath -Din=$inputfile -Dout=$outputfile"

		# Find and add an import file for this test, if it exists
		importfile="$commonfile$import"
		if [ -f $importfile ]
		then
			javaoptions+=" -Dimport=$importfile"
		fi

		# Run the test, save the return code
		java $javaoptions $mainclass
		return_code="$?"
		echo -e "TEST: $commonfile\n\tOPTIONS: $javaoptions" >> $logfile
		if [[ return_code -ne 0 ]]
		# Java error (ex: missing Main class)
		then
			echo -e "\tFailed!\n\t\tReturn code: $return_code" >> $logfile
			failed=$((failed+1))
		else
		# Compare the obtained output to the expected
			expectedfile="$commonfile$expected"
			differences=`diff -w $outputfile $expectedfile`
			if [[ -z $differences ]]
			then
				echo -e "\tPassed!\n" >> $logfile
				passed=$((passed+1))
			else
				echo -e "\tFailed!" >> $logfile
				differences=`echo -e "$differences" | sed 's/^/\t\t/'`
				echo -e "$differences\n" >> $logfile
				failed=$((failed+1))
			fi
		fi
	done

	# Print the results on stdout and append them to the logfile
	result="Passed:$passed\nFailed:$failed"
	sed "1s/^/$result\n\n/" -i $logfile
	echo -e $result"\nSee file '$logfile' for more information"
	cd $location
}

echo "Source directories: ${src_dirs[@]}"
echo "Test directory: $test_dir"
echo $classpath
compile
test

exit 0
