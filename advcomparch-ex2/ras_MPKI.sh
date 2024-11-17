#!/bin/bash

Outputs="/home/iliana/Downloads/advcomparch-ex2-helpcode/outputs_4.4"
Results="/home/iliana/Downloads/advcomparch-ex2-helpcode/mean_res_4_4"

# List of benchmarks
benchmarks=("403.gcc" "436.cactusADM" "456.hmmer" "462.libquantum" "473.astar" "429.mcf" "445.gobmk" "458.sjeng" "470.lbm" "483.xalancbmk" "434.zeusmp" "450.soplex" "459.GemsFDTD" "471.omnetpp")



entries=("4" "8" "16" "32" "48" "64")
for entrie in "${entries[@]}"; do
    MPKI_sum=0
    files_count=0
    # Create the output file
    out_file="${Results}/${entrie}_mean_MPKI.txt"
    # Iterate through each benchmark file
    for benchmark in "${benchmarks[@]}"; do
        pattern="${benchmark}.cslab_4_2_branch_predictors.out"
        echo "Pattern: $pattern"
        # Iterate over files in the directory
        for file in "${Outputs}"/*; do
            # Check if the filename matches the pattern
            if [[ "$file" =~ $pattern ]]; then
                total_instructions=$(grep "Total Instructions:" "$file" | awk '{print $3}')
                # If it matches, take the information we need reading from the file
                incorrect_branches=$(grep "RAS ($entrie entries):" "$file" | awk '{print $5}')
                echo "we have incorrect = $incorrect_branches"
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
    echo "For RAS with ${entrie} entries and for all ${files_count} benchmarks we found that: " >> "$out_file"
    echo "Mean MPKI: ${mean_MPKI}" >> "$out_file"
done

