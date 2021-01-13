###########
CGAP-Docker
###########

Docker Components for CGAP. For now, this consists of a single Dockerfile that will provision the application back-end. This component can be invoked to run commands on the back-end resources of any CGAP environment without interacting with the main application (Beanstalk). This repo at this time only requires Docker to be installed on the machine.

##############
Pre-requisites
##############

For local development, only Docker is required. For running in production, see the end of the below section. Note that it is possible to run this component with
the local deployment, though that is not the intended use case.

See ``make info`` for details on how to use this repo.

############
How it works
############

CGAP-Docker containerizes the back-end of the CGAP Portal. It does this by provisioning a Python3.6 base image and
installing the application the standard way (via Poetry). The application now includes a special command called
``simulate_environment`` that utilizes an API in ``dcicutils.beanstalk_utils`` to grab configuration options necessary to run the application.
For reference on the dcicutils API, see ``dcicutils.beanstalk_utils.get_beanstalk_environment_variables``.

The aforementioned function just issues an API call to Elastic Beanstalk, requesting the environment configuration of
the environment we'd like to simulate. The boto3 function is called ``describe_configuration_settings``, additional info
on this function specifically can be found `here <https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/elasticbeanstalk.html#ElasticBeanstalk.Client.describe_configuration_settings>`_.
We should further consider IAM policies surrounding this capability.

The information contained in these configuration settings is sufficient to simulate the application server by connecting
directly to back-end resources such as RDS, ES and SQS. Once the information is present, we are able to call
the script ``generate_production_ini`` to build ``production.ini``, which is an input file specifying the application back-end.
We pass this file to the application when invoking commands. For example, a power user on EC2 with sufficient permissions
can run:

``make build && make enter``

Which will build/spin up the container and start a bash session inside. The user can then invoke the ``simulate_environment`` command
to build ``production.ini`` - note that it is the running EC2's permissions that are validated. Therefore it follows users who can access
the EC2 via SSH should have a permission set greater than that provided by the EC2 (ie: there is no privilege escalation through SSH).
It is likely when this component runs in Tibanna that we can disable SSH altogether.

The following invocation will trigger variant ingestion on fourfront-cgapwolf given all of the following conditions are true:

- The Docker container is invoked from an AWS Service that assumes an IAM role with sufficient permissions.
- The invocation location is within the VPC/subnet of the underlying back-end resources. That is, in our current setup, if the caller is not within the VPC, they will not be able to access the RDS, therefore simulation will fail.
- The VCF file has been mounted to an accessible location. In this example it has been copied into the repo directory.

``docker run -it cgap-ingestion-docker:0.0.0b0 bash -c "poetry run simulate-environment fourfront-cgapwolf && poetry run ingestion src/encoded/annotations/variant_table_v0.5.0.csv src/encoded/schemas/annotation_field.json src/encoded/schemas/variant.json src/encoded/schemas/variant_sample.json GAPFI4LHHWB6.vcf cgap-core hms-dbmi src/encoded/annotations/gene_table_v0.4.6.csv src/encoded/schemas/gene_annotation_field.json src/encoded/schemas/gene.json src/encoded/schemas/gene_annotation_field.json cgap-core hms-dbmi production.ini --app-name app --post-variants"``

For more information on the specifics of the ``ingestion`` command, see cgap-portal. Note that this command just ingests variants, it does not configure sample processing or other associated metadata.


****************
Images Directory
****************

This directory contains a draft structure that could be used to build hierachical images, in case we want to use
common Docker base images for many use cases. The images directory contains 2 folders that contain separate containers.
They are called cgap_python and cgap_backend. The first is a re-usable component that
configures Python 3.6 and a working Poetry version for use by other images. The
second image extends the first with the remaining setup specific to the CGAP
back-end. The top level Dockerfile represents the combination of these two
components in one Dockerfile.

