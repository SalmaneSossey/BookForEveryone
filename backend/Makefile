PYTHON := .venv/bin/python
UVICORN := .venv/bin/uvicorn

.PHONY: venv install test run check clean

venv:
	python3 -m venv .venv

install: venv
	$(PYTHON) -m pip install -r requirements.txt

test:
	$(PYTHON) -m pytest tests

run:
	$(UVICORN) main:app --reload --host 127.0.0.1 --port 8000

check:
	$(PYTHON) -m compileall main.py api core models services tests
	$(PYTHON) -m pytest tests

clean:
	find . -type d -name __pycache__ -prune -exec rm -rf {} +
	find . -type d -name .pytest_cache -prune -exec rm -rf {} +
