# Containerfile
FROM docker.io/jenkins/jenkins:lts

USER root

# Install Node.js, npm, and other useful tools
RUN apt-get update && apt-get install -y curl git \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn \
    && apt-get clean

# (Optional) Install Podman if you deploy using containers
RUN apt-get install -y podman

# Install Ansible and Python3
RUN apt-get update && \
    apt-get install -y python3 python3-pip ansible sshpass && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Return to Jenkins user
USER jenkins
