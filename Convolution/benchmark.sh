#!/bin/bash

cd src-java
output=$(java Main <<< "cat.png")
cd ..

cat kernels/kernel6.txt src-java/output.txt >> input.txt


input_file="../input.txt"


benchmark() {
    local program=$1
    local input_file=$2

    start_time=$(date +%s.%N)
    $program < $input_file > /dev/null
    end_time=$(date +%s.%N)
    execution_time=$(echo "$end_time - $start_time" | bc)
    printf "%0.5f\t  " "$execution_time"
}

# Print table header
echo "|  Program   | Exec. Time  |"
echo "|------------|-------------|"

cd src-asm
echo "| x86 packed | $(benchmark "./run.sh convolution-packed" "$input_file") |"
cd ../src-java
echo "|    java    | $(benchmark "java Convolution" "$input_file") |"
cd ..



rm input.txt src-java/output.txt