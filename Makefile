DESTDIR := /usr/local
VERSION := $(shell grep version shard.yml | cut -d' ' -f2)
LDFLAGS := -rdynamic -static -lreadline -ltermcap

meet: meet.cr shard.yml .git/refs/heads/master shard.lock | lib
	crystal build --release --static --no-debug --link-flags "$(LDFLAGS)" -o $@ $<

lib: shard.lock
	shards

.PHONY: install
install: meet
	install meet $(DESTDIR)/bin/meet

.PHONY: pack
pack: meet-$(VERSION).tgz

meet-$(VERSION).tgz: meet COPYING
	tar czf $@ $^
