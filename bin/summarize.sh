#!/bin/bash

set -e

data_path="${1}"
table_name="${2}"

function execute() {
  echo "${2}" | sqlite3 "${1}"
}

function job_events() {
  job_count_query="SELECT COUNT(DISTINCT \`job ID\`) FROM \`${table_name}\`;"
  user_count_query="SELECT COUNT(DISTINCT \`user\`) FROM \`${table_name}\`;"
  sample_count_query="SELECT COUNT(*) FROM \`${table_name}\`;"
  job_count=$(execute "${1}" "${job_count_query}")
  user_count=$(execute "${1}" "${user_count_query}")
  sample_count=$(execute "${1}" "${sample_count_query}")
  echo "${1}: jobs ${job_count}, users ${user_count}, samples ${sample_count}"
}

function task_usage() {
  job_count_query="SELECT COUNT(DISTINCT \`job ID\`) FROM \`${table_name}\`;"
  task_count_query="SELECT COUNT(*) FROM (SELECT COUNT(*) FROM \`${table_name}\` GROUP BY \`job ID\`, \`task index\`);"
  sample_count_query="SELECT COUNT(*) FROM \`${table_name}\`;"
  job_count=$(execute "${1}" "${job_count_query}")
  task_count=$(execute "${1}" "${task_count_query}")
  sample_count=$(execute "${1}" "${sample_count_query}")
  echo "${1}: jobs ${job_count}, tasks, ${task_count}, samples ${sample_count}"
}

for part_path in $(find ${data_path} -name '*.sqlite3' | sort); do
  ${table_name} "${part_path}"
done
