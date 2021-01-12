# Extend the cgap-python image in this repo
FROM cgap-python:latest 

MAINTAINER William Ronchetti "william_ronchetti@hms.harvard.edu"


# Configure CGAP User
RUN useradd -ms /bin/bash cgap-admin 
RUN mkdir -p /home/cgap-admin/cgap-portal
RUN chown cgap-admin $PYSETUP_PATH
USER cgap-admin

# Clone to /home/cgap-admin/cgap-portal
WORKDIR /home/cgap-admin
RUN git clone https://github.com/dbmi-bgm/cgap-portal.git

# Build the back-end
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

