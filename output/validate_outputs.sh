validationfile='validation_output'
checkfile='check.out'
if [ -f "$checkfile" ]; then
    rm -f $checkfile
fi
inputfiles=(`ls -v ../inputs/*.in`)
outputfiles=(`ls -v ./*.out`)
for ((i=0;i<${#inputfiles[@]};++i)); do
    inputfile="${inputfiles[$i]}"
    outputfile="${outputfiles[$i]}"
    echo 'Validating' $inputfile 'with input file' $outputfile;
    python ../python/scorer_single.py $inputfile $outputfile >> $checkfile
done;
echo 'Diffing' $validationfile 'and' $checkfile
diff $validationfile $checkfile
echo 'Done'
