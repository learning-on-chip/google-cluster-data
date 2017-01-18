TABLES ?= job_events task_events task_usage
OUTPUT ?= output

task_usage := ${OUTPUT}/task_usage
task_usage_parts := $(shell find ${task_usage} -name '*.csv.gz' 2> /dev/null | sort)

all:
	@echo What?

${OUTPUT}/all.sqlite3: $(patsubst %,${OUTPUT}/%/.downloaded,${TABLES})
	for table in ${TABLES}; do \
		bin/convert.sh ${OUTPUT}/$${table} $${table} $@; \
	done

$(patsubst %,${OUTPUT}/%.sqlite3,${TABLES}): ${OUTPUT}/%.sqlite3: ${OUTPUT}/%/.downloaded
	bin/convert.sh ${OUTPUT}/$* $* $@

$(patsubst %,${OUTPUT}/%/.downloaded,${TABLES}): ${OUTPUT}/%/.downloaded: bin/gsutil
	mkdir -p ${OUTPUT}
	$< -m cp -R gs://clusterdata-2011-2/$* ${OUTPUT}
	touch $@

${task_usage}/distribute/.processed: $(patsubst ${task_usage}/%.csv.gz,${task_usage}/distribute/.processed_%,${task_usage_parts})
	bin/convert.sh ${task_usage}/distribute task_usage "" "1 2 3 4 5 6"
	touch $@

${task_usage}/distribute/.processed_%: bin/distribute ${task_usage}/.downloaded
	$< --input ${task_usage}/$*.csv.gz --output ${task_usage}/distribute --group 2 --select 0,1,2,3,4,5
	touch $@

bin/%:
	${MAKE} -C src $*

clean:
	${MAKE} -C src clean
	rm -rf ${OUTPUT}

.PHONY: all clean
