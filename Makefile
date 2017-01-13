TABLES ?= job_events task_events task_usage

all:
	@echo What?

result/all.sqlite3: $(patsubst %,result/%/.downloaded,${TABLES})
	for table in ${TABLES}; do \
		bin/convert.sh result/$${table} $${table} $@; \
	done

$(patsubst %,result/%.sqlite3,${TABLES}): result/%.sqlite3: result/%/.downloaded
	bin/convert.sh result/$* $* $@

$(patsubst %,result/%/.downloaded,${TABLES}): result/%/.downloaded: bin/gsutil
	mkdir -p result
	$< -m cp -R gs://clusterdata-2011-2/$* result
	touch $@

result/task_usage/distribute/.processed: $(patsubst result/task_usage/%.csv.gz,result/task_usage/distribute/.processed_%,$(shell find result/task_usage -name '*.csv.gz' | sort))
	bin/convert.sh result/task_usage/distribute task_usage "" "1 2 3 4 5 6"
	touch $@

result/task_usage/distribute/.processed_%: bin/distribute result/task_usage/.downloaded
	$< --input result/task_usage/$*.csv.gz --output result/task_usage/distribute --group 2 --select 0,1,2,3,4,5
	touch $@

bin/%:
	${MAKE} -C src $*

clean:
	${MAKE} -C src clean
	rm -rf result

.PHONY: all clean
