#!/bin/bash

#  Script.sh
#  
#
#  Created by Iliana on 14/4/24.

Outputs="/home/iliana/Downloads/parsec-3.0/parsec_workspace/pref_outputs"
results="/home/iliana/Downloads/parsec-3.0/parsec_workspace/pref_mean_results"
# List of configurations

N=(1 2 4 8 16 32 64)
# Iterate over each configuration
for n in "${N[@]}"; do
	#echo "n= $n"
    # We set the Internal Field Separator to '_'(we need this to store variables using read)
    IFS='_'

    read lines <<< "$n"
    # Store the parameters into variables
    L2_pref="$n"
    echo "L2_pref = $L2_pref"
    #L2_cache_size="$size"
    #L2_associativity="$associativity"
    #L2_block_size="$bsize"

    # Print the stored variables
    #echo "L2 cache size: $L2_cache_size"
    #echo "L2 associativity: $L2_associativity"
    #echo "L2 block size: $L2_block_size"

    # Initialization of the sums we will need to calculate the mean
    IPC_sum=0
    MPKI_sum=0
    files_count=0
    
    # Create the output file
    out_file="${results}/L2prf_${L2_pref}_mean_values.txt"
    
    echo "Prefetching" >> "$out_file"

    # Write the parameters into the output file
    #echo "Size(KB): $L2_cache_size" >> "$out_file"
    #echo "Block Size(B): $L2_block_size" >> "$out_file"
    #echo "Associativity: $L2_associativity" >> "$out_file"
     echo "N: $L2_pref" >> "$out_file"
    #pattern to match filenames
    pattern="L2prf_$(printf "%02d" "$L2_pref").out"
    echo "Pattern: $pattern" 

    # Iterate over files in the directory
    for file in "${Outputs}"/*; do
        # Check if the filename matches the pattern
        if [[ "$file" =~ $pattern ]]; then
            # If it matches, take the information we need reading from the file
            total_instructions=$(grep "Total Instructions:" "$file" | awk '{print $3}')
            
            IPC=$(grep "IPC:" "$file" | awk '{print $2}')
            
            total_misses=$(grep "L2-Total-Misses:" "$file" | awk '{print $2}')
            echo "L2-total-misses: $total_misses"
            # Calculate MPKI
            cM=$(echo "${total_misses} * 1000" | bc)
            echo "cM = $cM"
            #MPKI=$(echo "${cM} / ${total_instructions}" | bc)
            MPKI=$(bc <<< "scale=6; ${cM} / ${total_instructions}")
            echo "MPKI = $MPKI"
            # Add IPC and MPKI to the total sum
            ipc_inverted=$(bc -l <<< "scale=6; 1 / ${IPC}")
            IPC_sum=$(bc <<< "${IPC_sum} + ${ipc_inverted}")
            MPKI_sum=$(bc <<< "${MPKI_sum} + ${MPKI}")
            echo "MPKI sum = $MPKI_sum"
            # Increasing of files_count. At the end it should be 8 as we have 8 different benchmarks
            ((files_count++))
        fi
    done
    
    # For each N we calculate mean IPC and mean MPKI for the 8 benchmarks
    mean_IPC=$(bc <<< "scale=6; ${files_count} / ${IPC_sum}")
    mean_MPKI=$(bc <<< "scale=6; ${MPKI_sum} / ${files_count}")

    
    
    # Store the results in the output file created
    
    echo "Mean IPC: ${mean_IPC}" >> "$out_file"
    echo "Mean IPC: $mean_IPC"
    echo "Mean MPKI: ${mean_MPKI}" >> "$out_file"
done

