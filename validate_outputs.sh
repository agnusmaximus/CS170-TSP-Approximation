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
inputfiles=(`ls -1 ./processed/*.in | sort -k1.13n`)
outputfiles=(`ls -1 ./exact_solutions/*.out | sort -k1.19n`)
validationfiles=(`ls -1 ./exact_solutions/*.out_validation | sort -k1.19n`)
for ((i=0;i<${#inputfiles[@]};++i)); do
    inputfile="${inputfiles[$i]}"
    outputfile="${outputfiles[$i]}"
    validationfile="${validationfiles[$i]}"
    echo 'Validating' $inputfile 'with input file' $outputfile 'with validation file' $validationfile
    python ./code/python/scorer_single.py $inputfile $outputfile > $checkfile
    cat $outputfile >> $checkoutputfile
    diff -u --ignore-all-space $checkfile $validationfile
done;
#echo 'Diffing' $validationfile 'and' $checkfile
#diff $validationfile $checkfile
#echo 'Done'
#echo 'Making sure' $alloutputfile 'is the accumulation of individual .outs'
#diff $checkoutputfile $alloutputfile
#echo 'Done'
