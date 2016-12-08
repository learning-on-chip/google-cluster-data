tables := job_events task_events task_usage

all: google.sqlite3

google.sqlite3: $(addsuffix /.done,${tables})
	for table in ${tables}; do \
		./bin/convert.sh $@ $${table}; \
	done

%/.done: bin/gsutil
	$< -m cp -R gs://clusterdata-2011-2/$* .
	touch $@

bin/%:
	${MAKE} -C src $*

clean:
	${MAKE} -C src clean
	rm -rf ${tables}

.PHONY: all clean
