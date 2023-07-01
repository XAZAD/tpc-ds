#!/bin/bash

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

find $OUTPUT_DIR -maxdepth 0 -empty -delete 2>/dev/null

SCALE=$1

if [ -z "$PARALLEL_STREAMS_COUNT" ]; then
    cpuNum=$(grep -c ^processor /proc/cpuinfo)
    PARALLEL_STREAMS_COUNT=$((cpuNum*2))
    echo Using default PARALLEL_STREAMS_COUNT=$PARALLEL_STREAMS_COUNT
else
    echo Set PARALLEL_STREAMS_COUNT=$PARALLEL_STREAMS_COUNT
fi

function checkRunAndKill {
    if [[ $($TPC_WORKING_DIR/bin/list-thread.sh) ]]; then
        read -p "It looks like data generation in process. Stop it? [Y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            (exec $TPC_WORKING_DIR/bin/stop-generate-data.sh)
            sleep 1
            checkRunAndKill
        else
            echo GoodBye
            exit 1
        fi
    else
        echo "No active data generation processes, passing"
    fi

}
function checkDataAndDelete {
    if [ -d $OUTPUT_DIR ]; then
        read -p "It looks like data already generated. Delete $OUTPUT_DIR? [Y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf $OUTPUT_DIR
            sleep 1
            checkDataAndDelete
        else
            echo GoodBye
            exit 1
        fi
    else
        echo "$OUTPUT_DIR doesn't exist, creating"
        mkdir $OUTPUT_DIR
    fi
}

function generate {
    echo "Starting to generate data in $OUTPUT_DIR" >&2

    for ((i = 1; i <= $PARALLEL_STREAMS_COUNT; i++)); do
        nohup ./dsdgen -scale $SCALE -dir $OUTPUT_DIR -parallel $PARALLEL_STREAMS_COUNT -child $i >/dev/null 2>&1 &
    done

}

function lookup {
    function infLookup {
        while [[ $($TPC_WORKING_DIR/bin/list-thread.sh) ]]
        do
            clear
            currentSize=$(du -h $OUTPUT_DIR | awk '{print $1}')
            (exec $TPC_WORKING_DIR/bin/list-thread.sh)
            echo CurrentSize: $currentSize
            sleep 5
        done
        echo Finished
    }

    echo
    echo Threads List:
    (exec $TPC_WORKING_DIR/bin/list-thread.sh)
    read -p "Do you want to interactively refresh status? [Y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        infLookup
    else
        echo GoodBye, you can use list-threads.sh to check it anytime.
    fi

}
cd $TPC_WORKING_DIR/tools

checkRunAndKill && checkDataAndDelete && generate && lookup
