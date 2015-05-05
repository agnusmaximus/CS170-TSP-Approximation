FILES=./inputs/*
outpath=./approx_solutions/
for fullfile in $FILES
do
filename=$(basename "$fullfile")
extension="${filename##*.}"
filename="${filename%.*}"
outfile=$outpath$filename".out"
echo "input: "$fullfile
echo "output: "$outfile
./code/SA/a.out < $fullfile > $outfile
done
