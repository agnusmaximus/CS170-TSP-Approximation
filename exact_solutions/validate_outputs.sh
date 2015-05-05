validationfile='validation_output'
alloutputfile='all_output'

checkfile='check.out'
checkoutputfile='checkalloutput.out'
if [ -f "$checkfile" ]; then
    rm -f $checkfile
fi
if [ -f "$checkoutputfile" ]; then
    rm -f $checkoutputfile
fi
inputfiles=(`ls -1 ../inputs/*.in | sort -k1.11n`)
outputfiles=(`ls -1 ./*.out | sort -k1.3n`)
for ((i=0;i<${#inputfiles[@]};++i)); do
    inputfile="${inputfiles[$i]}"
    outputfile="${outputfiles[$i]}"
    echo 'Validating' $inputfile 'with input file' $outputfile;
    python ../code/python/scorer_single.py $inputfile $outputfile >> $checkfile
    cat $outputfile >> $checkoutputfile
done;
echo 'Diffing' $validationfile 'and' $checkfile
diff $validationfile $checkfile
echo 'Done'
echo 'Making sure' $alloutputfile 'is the accumulation of individual .outs'
diff $checkoutputfile $alloutputfile
echo 'Done'
