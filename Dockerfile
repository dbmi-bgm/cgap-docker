FROM python:3.6

# XXX: We should consider a multi-base image setup where python, poetry, app etc are done
# separately and can be extended.
MAINTAINER William Ronchetti "william_ronchetti@hms.harvard.edu"

# Add emacs, vim
RUN apt-get update
RUN apt-get -y install emacs vim

# Open postgres, ES ports
# XXX: This doesn't seem to work for postgres
EXPOSE 5441
EXPOSE 9200

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


# Configure CGAP User
RUN useradd -ms /bin/bash cgap-admin 
RUN mkdir -p /home/cgap-admin/cgap-portal
RUN chown cgap-admin $PYSETUP_PATH
USER cgap-admin

# Clone to /home/cgap-admin/cgap-portal
WORKDIR /home/cgap-admin
RUN git clone https://github.com/dbmi-bgm/cgap-portal.git && cd cgap-portal && git checkout c4_503 && cd ..

# Build, configure the back-end
WORKDIR /home/cgap-admin/cgap-portal
RUN curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python
RUN poetry install && poetry run python setup_eb.py develop 
RUN make aws-ip-ranges
RUN cat /dev/urandom | head -c 256 | base64 > session-secret.b64

# Execute commands with docker run -it cgap-ingestion-docker:<version> poetry run <cmd> <arguments>

# Get environment information from beanstalk
# https://stackoverflow.com/questions/36354423/which-is-the-best-way-to-pass-aws-credentials-to-docker-container
# Get VCF File
# BOTO3 S3 call?
# Validate + Post (command)

