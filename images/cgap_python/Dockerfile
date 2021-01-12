FROM python:3.6

MAINTAINER William Ronchetti "william_ronchetti@hms.harvard.edu"

# Add emacs, vim
RUN apt-get update
RUN apt-get -y install emacs vim

# Environment Configuration
# Adapated from https://github.com/python-poetry/poetry/discussions/1879
# Don't buffer output from Python
ENV PYTHONUNBUFFERED=1 
# Don't write .pyc files (to disk)
ENV PYTHONDONTWRITEBYTECODE=1  

# Optimize pip
ENV PIP_NO_CACHE_DIR=off 
ENV PIP_DISABLE_PIP_VERSION_CHECK=on 
ENV PIP_DEFAULT_TIMEOUT=100 
    
# Configure poetry
# Reference: https://python-poetry.org/docs/configuration/#using-environment-variables
ENV POETRY_VERSION=1.0.10 
# make poetry install to this location
ENV POETRY_HOME="/home/cgap-admin/poetry" 
# make poetry create the virtual environment in the project's root
# it gets named `.venv`
ENV POETRY_VIRTUALENVS_IN_PROJECT=true 
ENV POETRY_NO_INTERACTION=1 
# This is where our requirements + virtual environment will live
ENV PYSETUP_PATH="/home/cgap-admin/cgap-portal" 
ENV VENV_PATH="/home/cgap-admin/.venv"

# Configure Path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"
RUN curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python

