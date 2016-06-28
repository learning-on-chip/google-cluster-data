tables := job_events task_events task_usage

all: google.sqlite3

google.sqlite3: $(addsuffix /.done,$(tables))
	./dump.py $(tables)

%/.done: gsutil/gsutil
	$^ -m cp -R gs://clusterdata-2011-2/$* .
	touch $@

gsutil/gsutil: gsutil.tar.gz
	tar -xzf gsutil.tar.gz

gsutil.tar.gz:
	curl https://storage.googleapis.com/pub/gsutil.tar.gz -o $@

clean:
	rm -f *.sqlite3 *.tar.gz
	rm -rf $(tables)

.PHONY: all clean
