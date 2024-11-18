#!/bin/bash

OUTPUT_DIR_BASE="/root/outputs/"
SNIPER_DIR="/root/sniper"

echo "Outputs to be processed located in: $OUTPUT_DIR_BASE"

for benchdir in $OUTPUT_DIR_BASE/*; do
  bench=$(basename $benchdir)
  echo -e "\nProcessing directory: $bench"

  cmd="${SNIPER_DIR}/tools/advcomparch_mcpat.py -d $benchdir -t total -o $benchdir/power > $benchdir/power.total.out"
  echo CMD: $cmd
  /bin/bash -c "$cmd"
done
