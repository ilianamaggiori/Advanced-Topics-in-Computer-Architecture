#!/bin/bash

## Modify the following paths appropriately
PARSEC_PATH=/home/iliana/Downloads/parsec-3.0
PIN_EXE=/home/iliana/Downloads/pin-3.30-98830-g1d7b601b3-gcc-linux/pin
PIN_TOOL=/home/iliana/Downloads/advcomparch-ex1-helpcode/pintool/obj-intel64/simulator.so
CMDS_FILE=./cmds_simlarge.txt
outDir="./pref_outputs/"

export LD_LIBRARY_PATH=$PARSEC_PATH/pkgs/libs/hooks/inst/amd64-linux.gcc-serial/lib/

## Triples of <prefetched lines>
N="1 2 4 8 16 32 64"

L1size=128
L1assoc=8
L1bsize=128
L2size=2048
L2assoc=16
L2bsize=256
TLBe=64
TLBp=4096
TLBa=4
#L2prf=0

#in order not to write everytime all benchmarks as arguments
benchmarks=("blackscholes" "canneal" "fluidanimate" "rtview")

for BENCH in "${benchmarks[@]}"; do
	cmd=$(cat ${CMDS_FILE} | grep "$BENCH")
for n in $N; do
	## Get parameters
    L2prf=$n
    #L1size=$(echo $conf | cut -d'_' -f1)
    #L1assoc=$(echo $conf | cut -d'_' -f2)
    #L1bsize=$(echo $conf | cut -d'_' -f3)

	outFile=$(printf "%s.dcache_cslab.L2prf_%02d.out" $BENCH ${L2prf})
	outFile="$outDir/$outFile"

	pin_cmd="$PIN_EXE -t $PIN_TOOL -o $outFile -L1c ${L1size} -L1a ${L1assoc} -L1b ${L1bsize} -L2c ${L2size} -L2a ${L2assoc} -L2b ${L2bsize} -TLBe ${TLBe} -TLBp ${TLBp} -TLBa ${TLBa} -L2prf ${L2prf} -- $cmd"
	time $pin_cmd
done
done





