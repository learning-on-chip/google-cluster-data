TABLES ?= job_events task_events task_usage

all: result/database.sqlite3

result/database.sqlite3: $(patsubst %,result/%/.done,${TABLES})
	mkdir -p result
	for table in ${TABLES}; do \
		./bin/convert.sh result/$${table} $${table} $@; \
	done

result/%/.done: bin/gsutil
	$< -m cp -R gs://clusterdata-2011-2/$* result
	touch $@

bin/%:
	${MAKE} -C src $*

clean:
	${MAKE} -C src clean
	rm -rf result

.PHONY: all clean
