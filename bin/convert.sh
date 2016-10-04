#!/bin/bash

set -e

bin_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
database_path="${1}"
table_name="${2}"
column_indices="${3}"

function join() {
    local IFS="${1}";
    shift;
    echo "$*";
}

function execute() {
    echo "${2}" | sqlite3 "${1}"
}

mapfile -t all_column_definitions < <("${bin_path}/describe.py" ${table_name})

if [ -z "${column_indices}" ]; then
    column_count=${#all_column_definitions[@]}
    column_indices=($(seq ${column_count}))
else
    column_indices=(${column_indices})
    column_count=${#column_indices[@]}
fi

for i in $(seq ${column_count}); do
    column_definitions[${i} - 1]=${all_column_definitions[${column_indices[${i} - 1]} - 1]}
done

temporary_path="${table_name}.tmp"

setup_query="""
DROP TABLE IF EXISTS \`${table_name}\`;
CREATE TABLE \`${table_name}\` ($(join ', ' "${column_definitions[@]}"));
"""

write_query="""
.mode csv
.import ${temporary_path} ${table_name}
"""

if [ ! -z "${database_path}" ]; then
    execute "${database_path}" "${setup_query}"
fi

for part_path in $(find ${table_name} -name '*.csv.gz' | sort); do
    echo "Processing ${part_path}..."
    gunzip -c "${part_path}" | cut -d',' -f$(join ',' ${column_indices[@]}) > "${temporary_path}"
    if [ ! -z "${database_path}" ]; then
        execute "${database_path}" "${write_query}"
    else
        execute "${part_path%.csv.gz}.sqlite3" "${setup_query}${write_query}"
    fi
    rm "${temporary_path}"
done
