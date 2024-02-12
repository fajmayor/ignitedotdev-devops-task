# Ignitedotdev Devops Task Solution

## Set up a Kubernetes Cluster using KIND

1. Run `kind-cluster.sh` from your terminal to deploy KIND cluster.

- The script checks if Docker is installed and running on the system. If Docker is not installed or not running, it mandates you to install Docker before it can run successfully.
- The script installs `kubectl` if not available.
- The script examines the architecture of your Linux system to determine the KIND cluster to install.
- It prompts you to enter the name of the cluster.
- It also saves the kubeconfig file in `~/.kube`.
