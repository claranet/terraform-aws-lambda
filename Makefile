# http://clarkgrubb.com/makefile-style-guide

MAKEFLAGS += --warn-undefined-variables --no-print-directory
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:


.PHONY: help
help:
	@echo "Available make targets:"
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'


.PHONY: README.md
README.md: ## Updates README.md using terraform-docs
	@echo "Removing everything from the Inputs section onwards"
	printf '%s\n' "`awk '/## Inputs/{exit}1' README.md`" > README.tmp
	@echo "Adding terraform-docs generated Inputs and Outputs to the end of README.md"
	printf '\n%s\n' "`terraform-docs md .`" >> README.tmp
	mv README.tmp README.md
