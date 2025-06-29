.PHONY: run
run:
	@uvx fastmcp run src/main.py

.PHONY: dev
dev:
	@uvx fastmcp dev src/main.py

.PHONY: fmt
fmt:
	@uvx ruff format
	@uvx ruff check --fix --extend-select I

.PHONY: test
test:
	@uvx pytest
