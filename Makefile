DESTDIR := /usr/local

meet: meet.cr shard.yml .git/refs/heads/master
	crystal build --release --static --no-debug -o $@ $<

.PHONY: install
install: meet
	install meet $(DESTDIR)/bin/meet
