#!/bin/bash

Outputs="/home/iliana/Downloads/advcomparch-ex2-helpcode/outputs_4.2b"
Results="/home/iliana/Downloads/advcomparch-ex2-helpcode/mean_res_4_2b"

# List of benchmarks
benchmarks=("403.gcc" "436.cactusADM" "456.hmmer" "462.libquantum" "473.astar" "429.mcf" "445.gobmk" "458.sjeng" "470.lbm" "483.xalancbmk" "434.zeusmp" "450.soplex" "459.GemsFDTD" "471.omnetpp")



predictors=("Nbit-32K-1" "2bit-16K-2" "Nbit-16K-2" "Nbit-8K-4" )
for predictor in "${predictors[@]}"; do
    MPKI_sum=0
    files_count=0
    # Create the output file
    out_file="${Results}/${predictor}_mean_MPKI.txt"
    # Iterate through each benchmark file
    for benchmark in "${benchmarks[@]}"; do
        pattern="${benchmark}.cslab_4_2b_branch_predictors.out"
        echo "Pattern: $pattern"
        # Iterate over files in the directory
        for file in "${Outputs}"/*; do
            # Check if the filename matches the pattern
            if [[ "$file" =~ $pattern ]]; then
                total_instructions=$(grep "Total Instructions:" "$file" | awk '{print $3}')
                # If it matches, take the information we need reading from the file
                incorrect_branches=$(grep "$predictor" "$file" | awk '{print $3}')
                # Calculate MPKI
                MPKI=$(echo "scale=6; (${incorrect_branches} * 1000) / ${total_instructions}" | bc)
                MPKI_sum=$(echo "scale=6; ${MPKI_sum} + ${MPKI}" | bc)
                # Increasing of files_count. At the end it should be 14 as we have 14 different benchmarks
                ((files_count++))
            fi
        done
    done
    mean_MPKI=$(echo "scale=6; ${MPKI_sum} / ${files_count}" | bc)
    # Store the results in the output file created
    echo "For predictor ${predictor} and for all ${files_count} benchmarks we found that: " >> "$out_file"
    echo "Mean MPKI: ${mean_MPKI}" >> "$out_file"
done

