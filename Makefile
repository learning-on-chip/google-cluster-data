URL ?= gs://clusterdata-2011-2
OUTPUT ?= output

tables := job_events task_events task_usage
task_usage := ${OUTPUT}/task_usage
task_usage_group := 2
task_usage_select := 0 1 2 3 4 5
task_usage_parts := $(shell find "${task_usage}" -name '*.csv.gz' 2> /dev/null | sort)

all:
	@echo What?

$(patsubst %,${OUTPUT}/%.sqlite3,${tables}): ${OUTPUT}/%.sqlite3: ${OUTPUT}/%/.downloaded
	bin/convert "${OUTPUT}/$*" "$*" "$@"

$(patsubst %,${OUTPUT}/%/.downloaded,${tables}): ${OUTPUT}/%/.downloaded: bin/gsutil
	mkdir -p "${OUTPUT}"
	$< -m cp -R "${URL}/$*" "${OUTPUT}"
	touch "$@"

${task_usage}/distribution/.processed: $(patsubst ${task_usage}/%.csv.gz,${task_usage}/distribution/.processed_%,${task_usage_parts})
	bin/convert "${task_usage}/distribution" task_usage '' "${task_usage_select}"
	touch "$@"

${task_usage}/distribution/.processed_%: bin/distribute ${task_usage}/.downloaded
	$< --input "${task_usage}/$*.csv.gz" --output "${task_usage}/distribution" --group ${task_usage_group} --select "${task_usage_select}"
	touch "$@"

bin/%:
	${MAKE} -C src $*

clean:
	${MAKE} -C src clean
	rm -rf "${OUTPUT}"

.PHONY: all clean
