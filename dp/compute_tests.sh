make
FILES=../test_gen/inputs/*
OFILE=../test_gen/outputs/
i=0
for f in $FILES
do
    echo "Processing file: $f"
    ./a.out < $f > $OFILE$i
    #echo $OFILE$i
    i=$((i + 1))
done
