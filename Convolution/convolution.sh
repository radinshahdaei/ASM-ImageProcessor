#!/bin/bash

clear

echo "
                ██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗                   
                ██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝                   
                ██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗                     
                ██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝                     
                ╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗                   
                 ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝                   
                                                                                                 
                        ████████╗ ██████╗     ████████╗██╗  ██╗███████╗                          
                        ╚══██╔══╝██╔═══██╗    ╚══██╔══╝██║  ██║██╔════╝                          
                           ██║   ██║   ██║       ██║   ███████║█████╗                            
                           ██║   ██║   ██║       ██║   ██╔══██║██╔══╝                            
                           ██║   ╚██████╔╝       ██║   ██║  ██║███████╗                          
                           ╚═╝    ╚═════╝        ╚═╝   ╚═╝  ╚═╝╚══════╝                          
                                                                                                 
     ██████╗ ██████╗ ███╗   ██╗██╗   ██╗ ██████╗ ██╗     ██╗   ██╗████████╗██╗ ██████╗ ███╗   ██╗
    ██╔════╝██╔═══██╗████╗  ██║██║   ██║██╔═══██╗██║     ██║   ██║╚══██╔══╝██║██╔═══██╗████╗  ██║
    ██║     ██║   ██║██╔██╗ ██║██║   ██║██║   ██║██║     ██║   ██║   ██║   ██║██║   ██║██╔██╗ ██║
    ██║     ██║   ██║██║╚██╗██║╚██╗ ██╔╝██║   ██║██║     ██║   ██║   ██║   ██║██║   ██║██║╚██╗██║
    ╚██████╗╚██████╔╝██║ ╚████║ ╚████╔╝ ╚██████╔╝███████╗╚██████╔╝   ██║   ██║╚██████╔╝██║ ╚████║
     ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝  ╚═══╝   ╚═════╝ ╚══════╝ ╚═════╝    ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
                                                                                                 
                    ██████╗ ██████╗  ██████╗      ██╗███████╗ ██████╗████████╗                   
                    ██╔══██╗██╔══██╗██╔═══██╗     ██║██╔════╝██╔════╝╚══██╔══╝                   
                    ██████╔╝██████╔╝██║   ██║     ██║█████╗  ██║        ██║                      
                    ██╔═══╝ ██╔══██╗██║   ██║██   ██║██╔══╝  ██║        ██║                      
                    ██║     ██║  ██║╚██████╔╝╚█████╔╝███████╗╚██████╗   ██║                      
                    ╚═╝     ╚═╝  ╚═╝ ╚═════╝  ╚════╝ ╚══════╝ ╚═════╝   ╚═╝                      
"

read -p "Do you want to continue? [Y/n]: " continue_input

# Convert the input to lowercase (optional)
continue_input=$(echo "$continue_input" | tr '[:upper:]' '[:lower:]')

# Check if the input is empty or starts with "y"
if [[ -z "$continue_input" || "$continue_input" == "y" ]]; then
    echo "Continuing with the script..."
    sleep 3

else
    echo "Exiting the script..."
    sleep 3
    exit 0
fi

clear

file_found=false

while [ "$file_found" = false ]; do
    echo -n "Please enter the name of your PNG file: "
    read filename

    if [ -f "$filename" ] && [[ "$filename" == *.png ]]; then
        file_found=true
    else
        echo "Invalid file. Please enter the name of a valid PNG file."
        echo
    fi
done

cd src-java

echo "Running Java on your image..."
output=$(java Main <<< "$filename")

cd ..

clear

echo "Kernels:"
echo "  1: Identity"
echo "  2: 3x3 Blur"
echo "  3: 5x5 Blur"
echo "  4: Sharpen"
echo "  5: 3x3 Gaussian Blur"
echo "  6: 5x5 Gaussian Blur"
echo "  7: Edge detection"

valid_input=false

while [ "$valid_input" = false ]; do
    echo -n "Please pick a kernel: "
    read number

    if [[ "$number" =~ ^[1-7]$ ]]; then
        valid_input=true
    else
        echo "Error: Please enter a number between 1 and 7."
        echo
    fi
done

filename="kernel$number.txt"

> input.txt
> output.txt
cat kernels/$filename src-java/output.txt >> input.txt

cd src-asm

echo "Running ASM program on your image..."
./run.sh convolution-packed < ../input.txt >> ../output.txt

cd ..

clear

cd src-java

echo "Creating output image as \"output.png\"..."
java Convertor
sleep 3
clear

cd ..

rm -r input.txt output.txt src-java/output.txt