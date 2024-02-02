FROM ubuntu:20.04

ENV TERRAFORM_VERSION 1.3.7
ENV TERRAGRUNT_VERSION 0.42.6
ENV AWSCLI_VERSION 2.3.9
ENV HELM_VERSION 3.10.3

RUN apt-get update -y && \
    apt-get install -qq --no-install-recommends -y \
    git \
    python3 \
    python3-pip \
    unzip \
    wget \
    tar \
    openssh-client && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN python3 -m pip install -r requirements.txt && \
    ansible-galaxy collection install community.general:3.8.0 && \
    rm requirements.txt

RUN wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform && \
    terraform --version && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN wget -O terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 && \
    mv terragrunt /usr/local/bin/ && \
    chmod +x /usr/local/bin/terragrunt && \
    terragrunt --version

RUN wget -O awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip

RUN wget -O https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar xvf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin && \
    rm helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    rm -rf linux-amd64

RUN apt-get remove -y \
    wget \
    unzip

COPY version_check.sh ./
CMD ./version_check.sh