.PHONY: piptools upgrade fix_transifex_resource_names transifex_resources_requirements validate_translation_files \
sync_translations sync_translations_github_workflow


# Default languages for the sync_translations.py file
export TX_LANGUAGES := ar,de,fr_CA


piptools:
	pip install -q -r requirements/pip_tools.txt

upgrade: export CUSTOM_COMPILE_COMMAND=make upgrade
upgrade: piptools  ## update the requirements/*.txt files with the latest packages satisfying requirements/*.in
	pip-compile --allow-unsafe --rebuild --upgrade -o requirements/pip.txt requirements/pip.in
	pip-compile --rebuild --upgrade -o requirements/pip_tools.txt requirements/pip_tools.in
	pip install -qr requirements/pip.txt
	pip install -qr requirements/pip_tools.txt
	pip-compile --rebuild --upgrade -o requirements/translations.txt requirements/translations.in
	pip-compile --rebuild --upgrade -o requirements/transifex.txt requirements/transifex.in
	pip-compile --rebuild --upgrade -o requirements/test.txt requirements/test.in
	pip-compile --rebuild --upgrade -o requirements/sync.txt requirements/sync.in


transifex_resources_requirements:  ## Installs the requirements file
	pip install -q -r requirements/transifex.txt

fix_transifex_resource_names:  ## Runs the script
	python scripts/fix_transifex_resource_names.py

fix_transifex_resource_names_dry_run:  ## Runs the script in --dry-run mode
	python scripts/fix_transifex_resource_names.py --dry-run


test_requirements:  ## Installs test.txt requirements
	pip install -q -r requirements/test.txt

test:  ## Run scripts tests
	 pytest -v -s --cov=. --cov-report=term-missing --cov-report=html scripts/tests

validate_translation_files:  ## Run basic validation to ensure files are compilable
	find translations/ -name '*.po' \
	    | grep -v '/en/LC_MESSAGES/' \
	    | xargs -I{} msgfmt -v --strict --check {}
	@echo '-----------------------------------------'
	@echo 'Congratulations! Translation files are valid.'
	@echo '-----------------------------------------'

sync_requirements:  ## install sync.txt requirements
	pip install -q -r requirements/sync.txt

sync_translations:  ## Syncs from the old projects to the new openedx-translations project
	python scripts/sync_translations.py $(SYNC_ARGS)

sync_translations_github_workflow:  ## Run with parameters from .github/workflows/sync-translations.yml
	make SYNC_ARGS="--simulate-github-workflow $(SYNC_ARGS)" sync_translations

