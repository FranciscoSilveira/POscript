#!/bin/bash

classpath="-cp ../project/edt-textui/edt-textui.jar:../project/edt-core/edt-core.jar:/usr/share/java/edt-support.jar:/usr/share/java/po-uilib.jar"
mainclass="edt.textui.TextEditor"
common=".*/A-([0-9]{3})-([0-9]{3})-M-ok."
input="in"
import="import"
output="outhyp"
expected="out"
logfile="results"

make -C ../project/
echo -n "" > $logfile

for inputfile in `find . -regextype posix-extended  -regex "$common""$input"`
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
		echo -e "$differences" > temp_do_not_fucking_touch
		sed 's/^/\t/' -i temp_do_not_fucking_touch
		sed '1d' -i temp_do_not_fucking_touch
		cat temp_do_not_fucking_touch >> $logfile
		echo -e "\n" >> $logfile
	fi
	rm -f temp_do_not_fucking_touch
	
	echo ""
done

exit 0
