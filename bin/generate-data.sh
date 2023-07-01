#!/bin/bash

echo you can define parameters via env vars: OUTPUT_DIR, PARALLEL_STREAMS_COUNT

TPC_SCRIPT_PATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TPC_WORKING_DIR=$(realpath $TPC_SCRIPT_PATH/..)
echo Working dir: $TPC_WORKING_DIR

if [ "$#" != 1 ]; then
    echo "Missing SCALE factor param (GB)."
    exit 1
fi



if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR=$TPC_WORKING_DIR/generated-data
    echo Using default OUTPUT_DIR=$OUTPUT_DIR
else
    OUTPUT_DIR=$(realpath $OUTPUT_DIR)
    echo Set OUTPUT_DIR=$OUTPUT_DIR
fi

find $OUTPUT_DIR  -maxdepth 0 -empty -delete

if [ -d $OUTPUT_DIR ]; then
    echo "It looks like data already generated. Remove/rename the '$OUTPUT_DIR' directory to generate it again."
    exit 1
else 
    mkdir $OUTPUT_DIR
fi

SCALE=$1
SUFFIX="_$(printf "%04d" $SCALE).dat"

if [ -z "$PARALLEL_STREAMS_COUNT" ]; then
    PARALLEL_STREAMS_COUNT=64
    echo Using default PARALLEL_STREAMS_COUNT=$PARALLEL_STREAMS_COUNT
else
    echo Set PARALLEL_STREAMS_COUNT=$PARALLEL_STREAMS_COUNT
fi

cd $TPC_WORKING_DIR/tools

for ((i = 1; i <= $PARALLEL_STREAMS_COUNT; i++)); do
    #echo Started thread_$i
    nohup ./dsdgen -scale $SCALE -dir $OUTPUT_DIR -parallel $PARALLEL_STREAMS_COUNT -child $i > /dev/null 2>&1 &
       
    #& pids[${i}]=$!
done

echo
echo Threads list:
echo
ps aux | grep dsdgen| awk '{for (i=3; i<=10; i++) $i=""; print $0}'

# for p in ${pids[*]}
#     echo $p
# done
# FOO_PID=$!

# echo $FOO_PID

# # wait for generating be completed
# for pid in ${pids[*]}; do
#     wait $pid
# done
