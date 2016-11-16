#!/bin/bash

classpath="-cp $(JAVADIR)/po-uilib.jar:../project/pex-core/pex-core.jar:../project/pex-app/pex-app.jar"
mainclass="edt.textui.TextEditor"
common=".*/A-([0-9]{3})-([0-9]{3})-M-ok."
input="in"
import="import"
output="outhyp"
expected="out"
logfile="results.txt"
tempfile="temp"

make -C ../project/
echo -n "" > $logfile
failed=0
passed=0
echo -e "\nRunning tests\n"
for inputfile in `find . -regextype posix-extended  -regex "$common""$input" | sort`
do
	commonfile=$(echo $inputfile | cut -d '.' -f 2 -s)
	outputfile=".$commonfile.$output"
	echo "" > $outputfile
	javaoptions="-Din=$inputfile -Dout=$outputfile"
	
	importfile=".$commonfile.$import"
	if [ -f $importfile ]
	then
		javaoptions="-Dimport=$importfile $javaoptions"
	fi
		
	java $javaoptions $classpath $mainclass
	
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
result="Passed:$passed\nFailed:$failed" 
sed "1s/^/$result\n\n/" -i $logfile
echo -e $result"\nSee file '$logfile' for more information"

exit 0
