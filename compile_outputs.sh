compiledfiles=(`ls -1 ./compiled_outs/*.out | sort -k1.17n`)
totaloutput=./answer.out
if [ -f "$totaloutput" ]; then
    rm -f $totaloutput
fi
echo 'Length: '${#compiledfiles[@]}
for ((i=0;i<${#compiledfiles[@]};++i)); do
    f="${compiledfiles[i]}"
    cat $f | sed 's/[ \t]*$//' >> $totaloutput
done
