#!/bin/bash

# Global variables, classpath may need to be user-defined
classpath="-cp /usr/share/java/po-uuilib.jar:../pex-core/pex-core.jar:../pex-app/pex-app.jar"
mainclass="pex.app.App"
common=".*A-([0-9]{3})-([0-9]{3})-M-ok\."
input="in"
import="import"
output="outhyp"
expected="out"
logfile="results.txt"

function compile {
	make_dirs=("../pex-core/" "../pex-app/")
	for dir in "${make_dirs[@]}"
	do
		make -C "$dir"
		if [[ $? -ne 0 ]]
		then
			echo -e "\nCompilation failed on package ""$dir""\n"
			exit 1
		fi
	done
}

function test {
	echo -n "" > $logfile
	failed=0
	passed=0
	echo -e "\nRunning tests...\n"
	for inputfile in `find . -regextype posix-extended  -regex "$common""$input" | sort`
	do
		# Find the common substring for this test
		commonfile=$(echo $inputfile | cut -d '.' -f 2 -s | cut -d '/' -f '2' -s)
		
		# Create (or clear) the output file for this test
		outputfile="$commonfile.$output"
		echo "" > $outputfile
		javaoptions="$classpath -Din=$inputfile -Dout=$outputfile"
		
		# Find and add an import file for this test, if it exists
		importfile="$commonfile.$import"
		if [ -f $importfile ]
		then
			javaoptions="-Dimport=$importfile $javaoptions"
		fi
		
		# Run the test
		java $javaoptions $classpath $mainclass
		
		# Compare the obtained output to the expected
		expectedfile="./expected/$commonfile.$expected"
		echo -e "TEST: $commonfile\n\tOPTIONS:$javaoptions" >> $logfile
		differences=`diff $outputfile $expectedfile`
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
	done
	
	# Print the results on stdout and append them to the logfile
	result="Passed:$passed\nFailed:$failed" 
	sed "1s/^/$result\n\n/" -i $logfile
	echo -e $result"\nSee file '$logfile' for more information"
}

compile
test

exit 0
