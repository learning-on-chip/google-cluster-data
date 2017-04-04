ifndef TABLE
$(error TABLE should be defined)
endif

task_usage_group := 2

job_events_select := 0 2 3 4 7
task_usage_select := 0 1 2 3 4 5

OUTPUT ?= output
GROUP ?= ${${TABLE}_group}
SELECT ?= ${${TABLE}_select}

parts := $(shell find "${OUTPUT}/${TABLE}" -name '*.csv.gz' 2> /dev/null | sort)
processed_parts := $(patsubst ${OUTPUT}/${TABLE}/%.csv.gz,${OUTPUT}/${TABLE}/distribution/.processed_%,${parts})

convert: ${OUTPUT}/${TABLE}.sqlite3

download: ${OUTPUT}/${TABLE}/.downloaded

distribute: ${OUTPUT}/${TABLE}/distribution/.processed

${OUTPUT}/${TABLE}.sqlite3: bin/convert ${OUTPUT}/${TABLE}/.downloaded
	$< "${OUTPUT}/${TABLE}" "${TABLE}" "$@" "${SELECT}"

${OUTPUT}/${TABLE}/distribution/.processed: bin/convert ${processed_parts}
	$< "${OUTPUT}/${TABLE}/distribution" "${TABLE}" '' "${SELECT}"
	touch "$@"

${OUTPUT}/${TABLE}/distribution/.processed_%: bin/distribute ${OUTPUT}/${TABLE}/.downloaded
	$< \
		--input "${OUTPUT}/${TABLE}/$*.csv.gz" \
		--output "${OUTPUT}/${TABLE}/distribution" \
		--group "${GROUP}" \
		--select "${SELECT}"
	touch "$@"

${OUTPUT}/${TABLE}/.downloaded: bin/gsutil
	mkdir -p "${OUTPUT}"
	$< -m cp -R "gs://clusterdata-2011-2/${TABLE}" "${OUTPUT}"
	touch "$@"

bin/%:
	${MAKE} -C src $*

clean:
	${MAKE} -C src clean
	rm -rf "${OUTPUT}"

.PHONY: all clean
