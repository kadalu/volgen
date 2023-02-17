fmt-check:
	crystal tool format --check src spec

lint:
	shards install
	./bin/ameba src spec

fmt:
	crystal tool format src spec

spec:
	shards install
	crystal spec

.PHONY: fmt-check lint fmt spec
