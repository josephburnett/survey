default:
	@echo Usage: make deploy

deploy: build update

build:
	bin/kamal build push

update:
	hack/update.sh
