#!/bin/bash

# Check if Docker is installed and running
if ! command -v docker &> /dev/null || ! docker info &> /dev/null; then
    echo "Error: Docker is either not installed or not running."
    echo "Please install Docker and ensure it is running before running this script."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed, installing..."
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo cp ./kubectl /usr/local/bin/kubectl
    echo "kubectl has been installed successfully."
fi

# For AMD64 / x86_64
if [ "$(uname -m)" = "x86_64" ]; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.21.0/kind-linux-amd64
# For ARM64
elif [ "$(uname -m)" = "aarch64" ]; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.21.0/kind-linux-arm64
else
    echo "Unsupported architecture: $(uname -m)"
    exit 1
fi

chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
rm -rf kind

# Prompt user for the cluster name
read -rp "Enter the name for the cluster to be created: " cluster_name


# Create a Kubernetes cluster named "$cluster_name" using kind
kind create cluster --name "$cluster_name"


# Retrieve the kubeconfig for the cluster and store it
mkdir -p ~/.kube
kind get kubeconfig --name "$cluster_name" > ~/.kube/"$cluster_name"-kubeconfig
