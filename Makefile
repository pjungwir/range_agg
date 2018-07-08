MODULES = range_agg
EXTENSION = range_agg
EXTENSION_VERSION = 1.0.0

DATA = $(EXTENSION)--$(EXTENSION_VERSION).sql

REGRESS = init \
					range_agg_1_test \
					range_agg_2_test \
					inetrange_test \
					with_unnest

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

README.html: README.md
	jq --slurp --raw-input '{"text": "\(.)", "mode": "markdown"}' < README.md | curl --data @- https://api.github.com/markdown > README.html

release:
	git archive --format zip --prefix=$(EXTENSION)-$(EXTENSION_VERSION)/ --output $(EXTENSION)-$(EXTENSION_VERSION).zip master

.PHONY: release
