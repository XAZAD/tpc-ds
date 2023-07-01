#!/bin/bash
function usage {
    echo ""
    echo "usage: generate-data.sh --mode String --size Int"
    echo ""
    echo "  --mode string   mode of work. Supported values:"
    echo "                                ${!tpcGenerateModes[@]}"
    echo "  --size int      Required size of dataset in Gb."
    echo ""
}

function die {
    printf "Script failed: %s\n\n" "$1"
    exit 1
}

while [ $# -gt 0 ]; do
    if [[ $1 == "--help" ]]; then
        usage
        exit 0
    elif [[ $1 == "--"* ]]; then
        v="${1/--/}"
        declare "$v"="$2"
        shift
    fi
    shift
done

if [[ -z $mode ]]; then
    usage
    die "Missing parameter --mode"


elif [[ -z $size ]]; then
    usage
    die "Missing parameter --size"
fi


echo you can define parameters via env vars: OUTPUT_DIR, PARALLEL_STREAMS_COUNT

unset $TPC_WORKING_DIR
TPC_SCRIPT_PATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
export TPC_WORKING_DIR=$(realpath $TPC_SCRIPT_PATH/..)
echo Working dir: $TPC_WORKING_DIR

#Add new mode here
declare -A tpcGenerateModes=(
[GCP]="/GCP/generate_data.sh $size" 
[local]="/local/generate-data.sh $size" 
)

if [[ -v tpcGenerateModes[$mode] ]]
then
    exec $TPC_WORKING_DIR/bin/${tpcGenerateModes[$mode]}
else 
    usage
    die "Bad parameter value --mode"
fi