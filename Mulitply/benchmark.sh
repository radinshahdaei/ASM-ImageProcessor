#!/bin/bash


benchmark() {
    local program_command="$1"
    local intput="$2"
    local nano=0

    local num_times="$3"

    for ((i=1; i<=num_times; i++))
    do
        output=$($program_command < "$2")
        
        value=$(echo $output | grep -oE '[0-9]+')
        
        nano=$((nano + value))
    done

    micro=$(bc <<< "scale=2; $nano / 1000")
    average=$(bc <<< "scale=2; $micro / $num_times")

    echo "$average"
}

num_times="$1"

printf "%-15s| %-15s\n" "Program" "Average Time (ms)"

cd src-asm
printf "%-15s | %-15s\n" "x86 normal 3×3" "$(benchmark "./multiply-normal" "../input-n3.txt" "$num_times")"
printf "%-15s | %-15s\n" "x86 normal 5×5" "$(benchmark "./multiply-normal" "../input-n5.txt" "$num_times")"
cd ..

cd src-asm
printf "%-15s | %-15s\n" "x86 packed 3×3" "$(benchmark "./multiply-packed" "../input-n3.txt" "$num_times")"
printf "%-15s | %-15s\n" "x86 packed 5×5" "$(benchmark "./multiply-packed" "../input-n5.txt" "$num_times")"
cd ..


cd src-java
printf "%-15s | %-15s\n" "Java 3×3" "$(benchmark "java Multiply" "../input-n3.txt" "$num_times")"
printf "%-15s | %-15s\n" "Java 5×5" "$(benchmark "java Multiply" "../input-n5.txt" "$num_times")"
cd ..