#!/usr/bin/bash

#set -e

## Hard-core installation:
#export PYTHON_VERSION=$1
#sudo apt install build-essential -y
#wget "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"
#tar -xf "Python-${PYTHON_VERSION}.tgz"
#cd "Python-${PYTHON_VERSION}" || exit 1
#./configure --enable-optimizations
#sudo make install

## Light installation:

TERRAFORM_VERSION=1.8.5

# Python3
sudo apt update
sudo apt install zip unzip python3 python3-pip python3.10-venv -y
python3 --version

# AWS-cli
DEPLOY_ARCH_TYPE=$(dpkg --print-architecture)
if [[ "$(dpkg --print-architecture)" == "arm64" ]]; then
  DEPLOY_ARCH_TYPE="aarch64"
fi

curl "https://awscli.amazonaws.com/awscli-exe-linux-${DEPLOY_ARCH_TYPE}.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_$(dpkg --print-architecture).zip"
unzip "terraform_${TERRAFORM_VERSION}_linux_$(dpkg --print-architecture).zip"
sudo mv terraform /usr/local/bin/
sudo chmod +x /usr/local/bin/terraform

exit 0