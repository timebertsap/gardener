#!/bin/bash
#
# Copyright (c) 2019 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

echo "> Installing requirements"

GO111MODULE=off go get golang.org/x/tools/cmd/goimports

export GO111MODULE=on

GOLANGCI_VERSION=v1.27.0
if which golangci-lint && golangci-lint --version | grep ${GOLANGCI_VERSION#v} ; then
  echo "golangci-lint $GOLANGCI_VERSION is already installed, skipping the installation..."
else
  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin $GOLANGCI_VERSION
fi

HELM_VERSION=v2.17.0
if which helm && helm version --client | grep ${HELM_VERSION} ; then
  echo "helm $HELM_VERSION is already installed, skipping the installation..."
else
  curl -s "https://raw.githubusercontent.com/helm/helm/$HELM_VERSION/scripts/get" | bash -s -- --version $HELM_VERSION
fi

platform=$(uname -s)
if [[ ${platform} == "Linux" ]]; then
  if ! which jq &>/dev/null; then
    echo "Installing jq ..."
    curl -L -o /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
    chmod +x /usr/local/bin/jq
  fi
fi

if [[ ${platform} == *"Darwin"* ]]; then
  cat <<EOM
You are running in a MAC OS environment!

Please make sure you have installed the following requirements:

- GNU Core Utils
- GNU Tar
- GNU Sed
- GNU Parallel

Brew command:
$ brew install coreutils gnu-tar gnu-sed jq parallel

Please allow them to be used without their "g" prefix:
$ export PATH=/usr/local/opt/coreutils/libexec/gnubin:\$PATH
$ export PATH=/usr/local/opt/gnu-tar/libexec/gnubin:\$PATH
$ export PATH=/usr/local/opt/gnu-sed/libexec/gnubin:\$PATH
EOM
fi
