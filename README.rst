########### 
cgap-docker
###########

Docker Components for CGAP. For now, this consists of a single Dockerfile that will provision the application back-end. This component can be invoked to run commands on the back-end resources of any CGAP environment without interacting with the main application (Beanstalk). This repo at this time only requires Docker to be installed on the machine.

****************
Images Directory
****************

The images directory contains 2 folders that contain separate containers. They
are called cgap_python and cgap_backend. The first is a re-usable component that
configures Python 3.6 and a working Poetry version for use by other images. The
second image extends the first with the remaining setup specific to the CGAP
back-end. The top level Dockerfile represents the combination of these two 
components in one Dockerfile.

