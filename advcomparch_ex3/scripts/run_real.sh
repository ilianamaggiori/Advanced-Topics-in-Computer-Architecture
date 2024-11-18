#!/bin/bash

CODE=/home/manolis/Desktop/helpcode
OUTPUT_DIR_BASE="/home/manolis/Desktop/outputs/real"

LOCKTYPES="tas_cas tas_ts ttas_cas ttas_ts mutex"
iterations=120000000
for LOCKTYPE in $LOCKTYPES; do
	executable=${CODE}/locks_${LOCKTYPE}
	echo "Running: $(basename ${executable})"
	mkdir -p $OUTPUT_DIR_BASE
	for n_threads in 1 2 4 8; do
	for grain_size in 1 10 100; do
			outDir=$(printf "%s.NTHREADS_%02d-GRAIN_%03d.out" $LOCKTYPE $n_threads $grain_size)
			outDir="${OUTPUT_DIR_BASE}/${outDir}"
			mkdir -p $outDir
			outfile=$outDir/info.out
			touch $outfile 
			CMD="${executable} ${n_threads} ${iterations} ${grain_size}"
			echo -e "CMD: $CMD\n"
			/bin/bash -c "($CMD) &> $outfile"
			cat $outfile
	done
	done
done
