make
FILES=../test_gen/inputs/*
OFILE=../test_gen/outputs/
OOFILE=../test_gen/outputs/approx
i=0
for f in $FILES
do
    echo "Processing file: $f"
    ./a.out < $f > $OFILE$i
    #echo $OFILE$i
    i=$((i + 1))
done

echo "[Approximate Answer] [DP answer]"
i=0
for f in $FILES
do
    echo "Testing file: $f"
    python ../test.py < $f > $OOFILE$i
    diff $OOFILE$i $OFILE$i
    i=$((i+1))
done
