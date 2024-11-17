#!/bin/bash

#  Script.sh
#  
#
#  Created by Iliana on 14/4/24.
#  CONFS=(512_4_128 512_4_256 512_8_64 512_8_128 512_8_256 1024_8_64 1024_8_128 1024_8_256 1024_16_64 1024_16_128 1024_16_256 2048_16_64 2048_16_128 2048_16_256)
Outputs="/home/iliana/Downloads/parsec-3.0/parsec_workspace/tlb_outputs"
results="/home/iliana/Downloads/parsec-3.0/parsec_workspace/tlb_mean_results"
# List of configurations
CONFS=(32_4_4096 32_8_4096 64_1_4096 64_2_4096 64_4_4096 64_8_4096 64_16_4096 64_32_4096 64_64_4096 128_4_4096 256_4_4096)

# Iterate over each configuration
for conf in "${CONFS[@]}"; do

    # We set the Internal Field Separator to '_'(we need this to store variables using read)
    IFS='_'

    # Read the parameters into variables
    read TLBe TLBa TLBp <<< "$conf"

    # Store the parameters into variables
    TLB_entries="$TLBe"
    TLB_associativity="$TLBa"
    TLB_page_size="$TLBp"

    # Print the stored variables
    echo "TLB size(entries): $TLB_entries"
    echo "TLB associativity: $TLB_associativity"
    echo "TLB page size: $TLB_page_size"
    
    # Initialization of the sums we will need to calculate the mean
    IPC_sum=0
    MPKI_sum=0
    files_count=0
    
    # Create the output file
    out_file="${results}/TLB_${TLB_entries}_${TLB_associativity}_${TLB_page_size}_mean_values.txt"
    
    echo "TLB-Data Cache" >> "$out_file"

    # Write the parameters into the output file
    echo "Size(entries): $TLB_entries" >> "$out_file"
    echo "Page Size(B): $TLB_page_size" >> "$out_file"
    echo "Associativity: $TLB_associativity" >> "$out_file"

    #pattern to match filenames
    pattern="TLB_$(printf "%04d" "$TLB_entries")_$(printf "%02d" "$TLB_associativity")_$(printf "%03d" "$TLB_page_size").out"
    echo "Pattern: $pattern"

    # Iterate over files in the directory
    for file in "${Outputs}"/*; do
        # Check if the filename matches the pattern
        if [[ "$file" =~ $pattern ]]; then
            # If it matches, take the information we need reading from the file
            total_instructions=$(grep "Total Instructions:" "$file" | awk '{print $3}')
            echo "Total Instructions found: $total_instructions"
            #total_cycles=$(grep "Total Cycles:" "$file" | awk '{print $3}')
            IPC=$(grep "IPC:" "$file" | awk '{print $2}')
            
            echo "IPC found: $IPC"
       	
            total_misses=$(grep "Tlb-Total-Misses:" "$file" | awk '{print $2}')
            
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
    #LC_NUMERIC="C" mean_IPC=$(awk "BEGIN {printf \"%.6f\", $IPC_sum / $files_count}")
    LC_NUMERIC="C" mean_MPKI=$(awk "BEGIN {printf \"%.6f\", $MPKI_sum / $files_count}")
    #mean_MPKI=$(bc <<< "scale=6; ${MPKI_sum} / ${files_count}")
    
    # Store the results in the output file created
    echo "For this triplet in TLB and for all ${files_count} files we found that: " >> "$out_file"
    echo "Mean IPC: ${mean_IPC}" >> "$out_file"
    echo "Mean MPKI: ${mean_MPKI}" >> "$out_file"
done

