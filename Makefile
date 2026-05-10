.PHONY: lint fmt breaking generate all

all: lint generate

lint:
	buf lint

fmt:
	buf format -w

breaking:
	buf breaking --against '.git#branch=main'

generate:
	buf generate

check: lint fmt breaking
