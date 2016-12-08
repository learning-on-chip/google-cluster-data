current := $(shell pwd)
root := $(shell dirname "${current}")

distribute: $(shell find distribute -name *.rs)
	cargo install --force --root "${root}" --path distribute

gsutil: gsutil/gsutil
	ln -s "${current}/$<" "${root}/bin/gsutil"

gsutil/gsutil: gsutil.tar.gz
	tar -xzf $<

gsutil.tar.gz:
	curl https://storage.googleapis.com/pub/gsutil.tar.gz -o $@

clean:
	rm -rf gsutil gsutil.tar.gz "${root}/bin/gsutil" "${root}/bin/distribute"

.PHONY: all clean distribute gsutil
