TABLES ?= job_events task_events task_usage
OUTPUT ?= output

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

${OUTPUT}/task_usage/distribute/.processed: $(patsubst ${OUTPUT}/task_usage/%.csv.gz,${OUTPUT}/task_usage/distribute/.processed_%,$(shell find ${OUTPUT}/task_usage -name '*.csv.gz' | sort))
	bin/convert.sh ${OUTPUT}/task_usage/distribute task_usage "" "1 2 3 4 5 6"
	touch $@

${OUTPUT}/task_usage/distribute/.processed_%: bin/distribute ${OUTPUT}/task_usage/.downloaded
	$< --input ${OUTPUT}/task_usage/$*.csv.gz --output ${OUTPUT}/task_usage/distribute --group 2 --select 0,1,2,3,4,5
	touch $@

bin/%:
	${MAKE} -C src $*

clean:
	${MAKE} -C src clean
	rm -rf ${OUTPUT}

.PHONY: all clean
