.PHONY: update quality

ansible-lint:
	ansible-lint -p *.y*ml

yamllint:
	git ls-files '*.y*ml' | grep -v vault | xargs yamllint -f parsable

quality: yamllint ansible-lint

update:
	pip install -U pip setuptools
	pip install -r requirements.txt -U
