#!/bin/bash

#  Script.sh
#  
#
#  Created by Iliana on 14/4/24.
#  CONFS=(512_4_128 512_4_256 512_8_64 512_8_128 512_8_256 1024_8_64 1024_8_128 1024_8_256 1024_16_64 1024_16_128 1024_16_256 2048_16_64 2048_16_128 2048_16_256)
Outputs="/home/iliana/Downloads/parsec-3.0/parsec_workspace/l2_outputs"
results="/home/iliana/Downloads/parsec-3.0/parsec_workspace/l2_mean_results"
# List of configurations
CONFS=(512_4_128 512_4_256 512_8_128 512_8_256 1024_8_128 1024_8_256 1024_16_128 1024_16_256 2048_16_128 2048_16_256)

# Iterate over each configuration
for conf in "${CONFS[@]}"; do

    # We set the Internal Field Separator to '_'(we need this to store variables using read)
    IFS='_'

    # Read the parameters into variables
    read size associativity bsize <<< "$conf"

    # Store the parameters into variables
    L2_cache_size="$size"
    L2_associativity="$associativity"
    L2_block_size="$bsize"

    # Print the stored variables
    echo "L2 cache size: $L2_cache_size"
    echo "L2 associativity: $L2_associativity"
    echo "L2 block size: $L2_block_size"

    # Initialization of the sums we will need to calculate the mean
    IPC_sum=0
    MPKI_sum=0
    files_count=0
    
    # Create the output file
    out_file="${results}/L2_${L2_cache_size}_${L2_associativity}_${L2_block_size}_mean_values.txt"
    
    echo "L2-Data Cache" >> "$out_file"

    # Write the parameters into the output file
    echo "Size(KB): $L2_cache_size" >> "$out_file"
    echo "Block Size(B): $L2_block_size" >> "$out_file"
    echo "Associativity: $L2_associativity" >> "$out_file"

    #pattern to match filenames
    pattern="L2_$(printf "%04d" "$L2_cache_size")_$(printf "%02d" "$L2_associativity")_$(printf "%03d" "$L2_block_size").out"
    echo "Pattern: $pattern"

    # Iterate over files in the directory
    for file in "${Outputs}"/*; do
        # Check if the filename matches the pattern
        if [[ "$file" =~ $pattern ]]; then
            # If it matches, take the information we need reading from the file
            total_instructions=$(grep "Total Instructions:" "$file" | awk '{print $3}')
            #total_cycles=$(grep "Total Cycles:" "$file" | awk '{print $3}')
            IPC=$(grep "IPC:" "$file" | awk '{print $2}')
            total_misses=$(grep "L2-Total-Misses:" "$file" | awk '{print $2}')
            
            # Calculate MPKI
            cM=$(echo "${total_misses} * 1000" | bc)
            MPKI=$(echo "${cM} / ${total_instructions}" | bc)
            
            # Add IPC and MPKI to the total sum
            ipc_inverted=$(bc -l <<< "scale=6; 1 / ${IPC}")
            IPC_sum=$(bc <<< "${IPC_sum} + ${ipc_inverted}")
            MPKI_sum=$(bc <<< "${MPKI_sum} + ${MPKI}")
            
            # Increasing of files_count. At the end it should be 8 as we have 8 different benchmarks
            ((files_count++))
        fi
    done
    
    # For each triplet(10 in total) we calculate mean IPC and mean MPKI for the 8 benchmarks
    mean_IPC=$(bc <<< "scale=6; ${files_count} / ${IPC_sum}")
    mean_MPKI=$(bc <<< "scale=6; ${MPKI_sum} / ${files_count}")
    #LC_NUMERIC="C" mean_MPKI=$(awk "BEGIN {printf \"%.6f\", $MPKI_sum / $files_count}")
    
    
    # Store the results in the output file created
    echo "For this triplet in L2 and for all ${files_count} files we found that: " >> "$out_file"
    echo "Mean IPC: ${mean_IPC}" >> "$out_file"
    echo "Mean MPKI: ${mean_MPKI}" >> "$out_file"
done

