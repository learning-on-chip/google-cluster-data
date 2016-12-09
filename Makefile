TABLES ?= job_events task_events task_usage

all: result/database.sqlite3

result/database.sqlite3: $(patsubst %,result/%/.done,${TABLES})
	for table in ${TABLES}; do \
		./bin/convert.sh result/$${table} $${table} $@; \
	done

result/%/.done: bin/gsutil
	mkdir -p result
	$< -m cp -R gs://clusterdata-2011-2/$* result
	touch $@

result/task_usage/distribute/.done: $(patsubst result/task_usage/%.csv.gz,result/task_usage/distribute/.done_%,$(shell find result/task_usage -name '*.csv.gz'))
	touch $@

result/task_usage/distribute/.done_%: bin/distribute result/task_usage/.done
	$< --input result/task_usage/$*.csv.gz --output result/task_usage/distribute --group 2 --selection 0,1,2,3,4,5;
	touch $@

bin/%:
	${MAKE} -C src $*

clean:
	${MAKE} -C src clean
	rm -rf result

.PHONY: all clean
