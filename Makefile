ifndef TABLE
$(error TABLE should be defined)
endif

task_usage_group := 2,3

job_events_select := 0,2,3,4,7
task_usage_select := 0,1,5

OUTPUT ?= output
FORMAT ?= sqlite3
GROUP ?= ${${TABLE}_group}
SELECT ?= ${${TABLE}_select}

parts := $(shell find "${OUTPUT}/${TABLE}" -name '*.csv.gz' 2> /dev/null | sort)
processed_parts := $(patsubst ${OUTPUT}/${TABLE}/%.csv.gz,${OUTPUT}/${TABLE}/distribution/.processed_%,${parts})

convert: ${OUTPUT}/${TABLE}.${FORMAT}

download: ${OUTPUT}/${TABLE}/.downloaded

distribute: ${OUTPUT}/${TABLE}/distribution/.processed

${OUTPUT}/${TABLE}.${FORMAT}: bin/convert ${OUTPUT}/${TABLE}/.downloaded
	$< \
		--input "${OUTPUT}/${TABLE}" \
		--table "${TABLE}" \
		--select "${SELECT}" \
		--output "$@" \
		--format "${FORMAT}"

${OUTPUT}/${TABLE}/distribution/.processed: bin/convert ${processed_parts}
	$< \
		--input "${OUTPUT}/${TABLE}/distribution" \
		--table "${TABLE}" \
		--select "${SELECT}" \
		--format "${FORMAT}"
	touch "$@"

${OUTPUT}/${TABLE}/distribution/.processed_%: bin/distribute ${OUTPUT}/${TABLE}/.downloaded
	$< \
		--input "${OUTPUT}/${TABLE}/$*.csv.gz" \
		--group "${GROUP}" \
		--select "${SELECT}" \
		--output "${OUTPUT}/${TABLE}/distribution"
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
