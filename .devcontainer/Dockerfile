FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install additional OS packages
# python3-boto3 and python3-botocore are required for Ansible AWS modules on Ubuntu 24.04+ (PEP 668)
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    python3-boto3 \
    python3-botocore \
    software-properties-common

# Install Ansible via PPA to ensure a recent version
RUN add-apt-repository --yes --update ppa:ansible/ansible \
    && apt-get install -y ansible
