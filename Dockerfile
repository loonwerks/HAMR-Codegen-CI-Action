# Container image that runs your code
#FROM ghcr.io/loonwerks/inspecta-ci-action-container:4.20250721.f13c8b0e
FROM ghcr.io/loonwerks/inspecta-ci-action-container:4.20250825.20d1bda
#FROM ghcr.io/loonwerks/inspecta-ci-action-container:4.20250924.c877daf
#FROM ghcr.io/loonwerks/inspecta-ci-action-container:master

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
