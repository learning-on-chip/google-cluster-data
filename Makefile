TABLES ?= job_events task_events task_usage
task_usage_distribute := result/task_usage/distribute

all: result/database.sqlite3

result/database.sqlite3: $(patsubst %,result/%/.done,${TABLES})
	for table in ${TABLES}; do \
		bin/convert.sh result/$${table} $${table} $@; \
	done

result/%/.done: bin/gsutil
	mkdir -p result
	$< -m cp -R gs://clusterdata-2011-2/$* result
	touch $@

${task_usage_distribute}/.done: $(patsubst result/task_usage/%.csv.gz,${task_usage_distribute}/.done_%,$(shell find result/task_usage -name '*.csv.gz' | sort))
	bin/convert.sh ${task_usage_distribute} task_usage "" "1 2 3 4 5 6"
	touch $@

${task_usage_distribute}/.done_%: bin/distribute result/task_usage/.done
	$< --input result/task_usage/$*.csv.gz --output ${task_usage_distribute} --group 2 --select 0,1,2,3,4,5
	touch $@

bin/%:
	${MAKE} -C src $*

clean:
	${MAKE} -C src clean
	rm -rf result

.PHONY: all clean
