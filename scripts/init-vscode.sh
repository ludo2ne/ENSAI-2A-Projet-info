#!/bin/sh

# Install packages and VSCode extensions
# Expected parameters : None

pip install inquirerPy psycopg2-binary pytest python-dotenv tabulate

code-server --install-extension charliermarsh.ruff
code-server --uninstall-extension ms-python.flake8