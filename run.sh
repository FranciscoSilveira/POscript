#!/bin/bash

classpath="-cp ../project/edt-textui/edt-textui.jar:../project/edt-core/edt-core.jar:/usr/share/java/edt-support.jar:/usr/share/java/po-uilib.jar"
mainclass="edt.textui.TextEditor"
common=".*/A-([0-9]{3})-([0-9]{3})-M-ok."
input="in"
import="import"
output="outhyp"
expected="out"
logfile="results"
tempfile="temp"

make -C ../project/
echo -n "" > $logfile

for inputfile in `find . -regextype posix-extended  -regex "$common""$input" | sort`
do
	echo "INPUT: ""$inputfile"
	commonfile=$(echo $inputfile | cut -d '.' -f 2 -s)
	outputfile=".$commonfile.$output"
	echo "OUTPUT: $outputfile"
	javaoptions="-Din=$inputfile -Dout=$outputfile"
	
	importfile=".$commonfile.$import"
	if [ -f $importfile ]
	then
		echo "IMPORT: ""$importfile"
		javaoptions="-Dimport=$importfile $javaoptions"
	fi
	echo "JAVAOPTIONS: $javaoptions"
	
	java $javaoptions $classpath $mainclass
	
	expectedfile="./expected/$commonfile.$expected"
	echo "TEST: $commonfile" >> $logfile
	
	differences=`diff $outputfile $expectedfile`
	if [[ -z $differences ]]
	then
		echo -e "\tPassed!\n" >> $logfile
	else
		echo -e "\tFailed!" >> $logfile
		echo -e "$differences" > $tempfile
		sed 's/^/\t\t/' -i $tempfile
		cat $tempfile >> $logfile
		echo -e "\n" >> $logfile
	fi
	rm -f $tempfile
	
	echo ""
done

exit 0
