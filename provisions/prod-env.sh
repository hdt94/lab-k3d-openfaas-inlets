#!/bin/bash

set -e

# kubectl
# https://kubernetes.io//docs/tasks/tools/install-kubectl/
curl -sLO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# k3d + k3s
# https://github.com/rancher/k3d
# curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh | TAG=v3.0.0-rc.3 bash
curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh | TAG=v1.7.0 bash

# arkade
# https://docs.openfaas.com/deployment/kubernetes/
curl -SLsf https://dl.get-arkade.dev/ | sudo sh

# inlets + inletsctl
# https://github.com/inlets/inlets#install-the-cli
# https://github.com/inlets/inletsctl#install-inletsctl
curl -sLS https://get.inlets.dev | sudo sh
curl -sLSf https://inletsctl.inlets.dev | sudo sh