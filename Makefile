tables := job_events task_events task_usage

all: google.sqlite3

google.sqlite3: $(addsuffix /.done,$(tables))
	for table in $(tables); do \
		./bin/convert.sh $@ $$table; \
	done

%/.done: gsutil/gsutil
	$< -m cp -R gs://clusterdata-2011-2/$* .
	touch $@

gsutil/gsutil: gsutil.tar.gz
	tar -xzf $<

gsutil.tar.gz:
	curl https://storage.googleapis.com/pub/gsutil.tar.gz -o $@

clean:
	rm -rf gsutil gsutil.tar.gz *.sqlite3
	rm -rf $(tables)

.PHONY: all clean
