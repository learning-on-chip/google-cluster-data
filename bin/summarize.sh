#!/bin/bash

set -e

data_path="${1}"
table_name="${2}"

function execute() {
  echo "${2}" | sqlite3 "${1}"
}

function job_events() {
  sample_count_query="SELECT COUNT(*) FROM \`${table_name}\`;"
  job_count_query="SELECT COUNT(DISTINCT \`job ID\`) FROM \`${table_name}\`;"
  user_count_query="SELECT COUNT(DISTINCT \`user\`) FROM \`${table_name}\`;"
  sample_count=$(execute "${1}" "${sample_count_query}")
  job_count=$(execute "${1}" "${job_count_query}")
  user_count=$(execute "${1}" "${user_count_query}")
  echo "${1}: ${sample_count} ${job_count} ${user_count}"
}

function task_usage() {
  sample_count_query="SELECT COUNT(*) FROM \`${table_name}\`;"
  job_count_query="SELECT COUNT(DISTINCT \`job ID\`) FROM \`${table_name}\`;"
  task_count_query="SELECT COUNT(*) FROM (SELECT COUNT(*) FROM \`${table_name}\` GROUP BY \`job ID\`, \`task index\`);"
  sample_count=$(execute "${1}" "${sample_count_query}")
  job_count=$(execute "${1}" "${job_count_query}")
  task_count=$(execute "${1}" "${task_count_query}")
  echo "${1}: ${sample_count} ${job_count} ${task_count}"
}

case "${table_name}" in
  'job_events')
    ;;
  'task_usage')
    ;;
  *)
    echo 'Error: no table is given, or it is unknown.' && exit 1
    ;;
esac

for part_path in $(find ${data_path} -name '*.sqlite3' | sort); do
  ${table_name} "${part_path}"
done
