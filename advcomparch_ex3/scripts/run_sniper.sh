#!/bin/bash

SNIPER_CONFIG=/root/advcomparch-ex3-helpcode/ask3.cfg
OUTPUT_DIR_BASE="/root/outputs/sniper/"
architectures="1_1_1 2_2_2 4_4_4 8_4_8 16_1_8"

LOCKTYPES=("mutex" "ttas_cas" "ttas_ts" "tas_cas" "tas_ts")
iterations=1000

for LOCKTYPE in "${LOCKTYPES[@]}"; do
    for architecture in $architectures; do
        n_threads=$(echo $architecture | cut -d'_' -f1)
        l2=$(echo $architecture | cut -d'_' -f2)
        l3=$(echo $architecture | cut -d'_' -f3)

        executable="/root/advcomparch-ex3-helpcode/locks_$LOCKTYPE"

        for grain_size in 1 10 100; do
            outDir=$(printf "%s.NTHREADS_%02d-GRAIN_%03d.out" $LOCKTYPE $n_threads $grain_size)
            outDir="${OUTPUT_DIR_BASE}/${outDir}"

            sniper_cmd="./run-sniper \\
                -c ${SNIPER_CONFIG} \\
                -n ${n_threads} \\
                -d ${outDir} \\
                --roi -c --perf_model/l2_cache/shared_cores=$l2 \\
                -c --perf_model/l3_cache/shared_cores=$l3 \\
                -- ${executable} ${n_threads} ${iterations} ${grain_size}"
            echo -e "CMD: $sniper_cmd\n"
            /bin/bash -c "time $sniper_cmd"
        done
    done
done

