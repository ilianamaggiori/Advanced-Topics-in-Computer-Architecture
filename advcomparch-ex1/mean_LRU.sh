#!/bin/bash

#  Script.sh
#  
#
#  Created by Iliana on 13/4/24.
#  
Outputs="/home/iliana/Downloads/parsec-3.0/parsec_workspace/LRU_outputs"
results="/home/iliana/Downloads/parsec-3.0/parsec_workspace/LRU_mean"
# List of configurations
CONFS=(32_4_64 32_8_64 64_4_64 64_8_64 128_4_64)

# Iterate over each configuration
for conf in "${CONFS[@]}"; do

    # We set the Internal Field Separator to '_'(we need this to store variables using read)
    IFS='_'

    # Read the parameters into variables
    read size associativity bsize <<< "$conf"

    # Store the parameters into variables
    L1_cache_size="$size"
    L1_associativity="$associativity"
    L1_block_size="$bsize"

    # Print the stored variables
    echo "L1 cache size: $L1_cache_size"
    echo "L1 associativity: $L1_associativity"
    echo "L1 block size: $L1_block_size"

    # Initialization of the sums we will need to calculate the mean
    IPC_sum=0
    MPKI_sum=0
    files_count=0
    
    # Create the output file
    out_file="${results}/L1_${L1_cache_size}_${L1_associativity}_${L1_block_size}_mean_values.txt"
    
    echo "L1-Data Cache" >> "$out_file"

    # Write the parameters into the output file
    echo "Size(KB): $L1_cache_size" >> "$out_file"
    echo "Block Size(B): $L1_block_size" >> "$out_file"
    echo "Associativity: $L1_associativity" >> "$out_file"

    #pattern to match filenames
    pattern="rand_rep_L1_$(printf "%04d" "$L1_cache_size")_$(printf "%02d" "$L1_associativity")_$(printf "%03d" "$L1_block_size").out"
    echo "Pattern: $pattern"

    # Iterate over files in the directory
    for file in "${Outputs}"/*; do
        # Check if the filename matches the pattern
        if [[ "$file" =~ $pattern ]]; then
            # If it matches, take the information we need reading from the file
            total_instructions=$(grep "Total Instructions:" "$file" | awk '{print $3}')
            #total_cycles=$(grep "Total Cycles:" "$file" | awk '{print $3}')
            IPC=$(grep "IPC:" "$file" | awk '{print $2}')
            echo "IPC = $IPC"
            total_misses=$(grep "L1-Total-Misses:" "$file" | awk '{print $2}')
            
            # Calculate MPKI
            cM=$(echo "${total_misses} * 1000" | bc)
            MPKI=$(echo "${cM} / ${total_instructions}" | bc)
            
            # Add IPC and MPKI to the total sum
            ipc_inverted=$(bc -l <<< "scale=6; 1 / ${IPC}")


            echo "for iteration $files_count IPC_sum= $IPC_sum and 1/IPC = $ipc_inverted " 
            IPC_sum=$(bc <<< "${IPC_sum} + ${ipc_inverted}")
            MPKI_sum=$(bc <<< "${MPKI_sum} + ${MPKI}")
            
            # Increasing of files_count. At the end it should be 8 as we have 8 different benchmarks
            ((files_count++))
        fi
    done
    
    # For each triplet(13 in total) we calculate mean IPC and mean MPKI for the 8 benchmarks
    mean_IPC=$(bc <<< "scale=6; ${files_count} / ${IPC_sum}")
    mean_MPKI=$(bc <<< "scale=6; ${MPKI_sum} / ${files_count}")
    
    # Store the results in the output file created
    echo "For this triplet in L1 and for all ${files_count} files we found that: " >> "$out_file"
    echo "Mean IPC: ${mean_IPC}" >> "$out_file"
    echo "Mean MPKI: ${mean_MPKI}" >> "$out_file"
done


