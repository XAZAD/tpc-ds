#!/bin/bash

TPC_SCRIPT_PATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1
	pwd -P
)"

TPC_WORKING_DIR=$(realpath $TPC_SCRIPT_PATH/..)
echo Working dir: $TPC_WORKING_DIR

if [ "$#" != 1 ]; then
	echo "Missing SCALE factor param (GB)."
	exit 1
fi

SCALE=$1

cd $TPC_WORKING_DIR/tools

TPC_TEMPLATE_DIR=$TPC_WORKING_DIR/query_templates
OUTPUT_DIR=$TPC_WORKING_DIR/queries
DIALECT_FILE=ansi
QUERIES_LIST=$TPC_TEMPLATE_DIR/templates.lst

echo  Output dir: $OUTPUT_DIR
function generate_query() {
	./dsqgen \
		-QUIET Y \
		-DIRECTORY $TPC_TEMPLATE_DIR \
		-SCALE $SCALE \
		-OUTPUT_DIR $OUTPUT_DIR \
		-DIALECT $DIALECT_FILE \
		-TEMPLATE $1 \
		-VERBOSE Y
	mv "$OUTPUT_DIR/query_0.sql" $OUTPUT_DIR/${1%.*}.sql
}

rm -rf $OUTPUT_DIR
mkdir $OUTPUT_DIR

while read p; do
	echo Generating $p
	QUERY_ID=$i
	generate_query $p
done < $QUERIES_LIST

# for i in {1..99}; do
#     QUERY_ID="$i"
#     generate_query
# done

# rm -rf ../../$OUTPUT_DIR
# mv -f $OUTPUT_DIR ../../..
# cd -
