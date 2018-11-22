#!/bin/bash

# Project-specific variables
packages=("sth-core" "sth-app")	# The packages (the order is important)
mainclass="sth.app.App"			# The class to be executed

# Main variables
location="$(pwd)"						# Where the shell is
work_dir="$(realpath $(dirname $0))" 	# Where the project is
src_dirs=()								# The source directories (will be set later)
test_dir="$work_dir/tests/"						# Default tests directory
classpath="/usr/share/java/po-uuilib.jar"		# Default classpath
common=".*A-([0-9]{2,3})-([0-9]{2,3})-M-ok\."	# Regex for the test files

# Test variables
input="in"
import="import"
output="outhyp"
expected="out"
logfile="$location/results.txt"

# Set the working directory and test directory in case the user provided them
while getopts s:t: flag;
do
	case $flag in
		# -s : specifies the source directory
		s)
			work_dir=$(realpath $OPTARG)
			;;
		# -t : specifies the test directory
		t)
			test_dir="$(realpath $OPTARG)/"
			;;
		\?)
			echo "Invalid option: -$flag"
			;;
	esac
done

# Add the source directories according to the project directory and update the classpath
for package in "${packages[@]}"
do
	src_dirs+=("$work_dir/$package")
	classpath+=":$work_dir/$package/$package.jar"
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
function run_tests {
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
		commonfile=${inputfile%$input}
		commonfilename="$(basename $commonfile)"
		
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
		echo -e "TEST: $commonfile\n\tOPTIONS:\n\t\t$javaoptions" >> $logfile
		expectedfile=${commonfile/$commonfilename/expected\/$commonfilename$expected}
		
		if [[ $return_code -ne 0 ]]
		# Java error (ex: missing Main class)
		then
			echo -e "\tFailed!\n\t\tReturn code: $return_code" >> $logfile
			failed=$((failed+1))
		
		elif [[ ! -f $expectedfile ]]
		# Expected file not found
		then
			echo -e  "\tFailed!\n\t\tExpected output file not found: $expectedfile" >> $logfile
			failed=$((failed+1))
		
		else
		# Executed properly, compare the obtained output to the expected
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
echo "Classpath: $classpath"

compile
run_tests

exit 0
