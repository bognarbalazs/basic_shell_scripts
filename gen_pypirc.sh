#!/bin/sh
set -euo pipefail

# Ellenőrizd, hogy a GITLAB_PACKAGE_REGISTRY_TYPE változó meg van-e adva
if [[ -z "${GITLAB_PACKAGE_REGISTRY_TYPE}" ]]; then
  echo "Error: GITLAB_PACKAGE_REGISTRY_TYPE is not set. Please set it to 'group' or 'project'."
  exit 1
fi

# Ellenőrizd, hogy a GITLAB_PACKAGE_REGISTRY_ID változó meg van-e adva
if [[ "${GITLAB_PACKAGE_REGISTRY_TYPE}" == "group" && -z "${GITLAB_PACKAGE_REGISTRY_ID}" ]]; then
  echo "Error: GITLAB_PACKAGE_REGISTRY_ID is not set. Please set it for group registry."
  exit 1
elif [[ "${GITLAB_PACKAGE_REGISTRY_TYPE}" == "project" && -z "${GITLAB_PACKAGE_REGISTRY_ID}" ]]; then
  echo "Error: GITLAB_PACKAGE_REGISTRY_ID is not set. Please set it for project registry."
  exit 1
fi

# Ellenőrizd, hogy a GITLAB_TOKEN változó meg van-e adva
if [[ -z "${GITLAB_TOKEN}" ]]; then
  echo "Error: GITLAB_TOKEN is not set. Please set it to authenticate."
  exit 1
fi

# PyPI beállítások generálása
if [[ "${GITLAB_PACKAGE_REGISTRY_TYPE}" == "group" ]]; then
  cat > ~/.pypirc <<EOL
[global]
trusted-host = ${CI_SERVER_URL#https://}
[distutils]
index-servers =
    gitlab-${GITLAB_PACKAGE_REGISTRY_ID}

[gitlab-${GITLAB_PACKAGE_REGISTRY_ID}]
repository: ${CI_API_V4_URL}/groups/${GITLAB_PACKAGE_REGISTRY_ID}/-/packages/pypi/simple
username: __token__
password: ${GITLAB_TOKEN}
EOL
  echo ".pypirc file generated for GitLab group registry."

mkdir -p $HOME/.config/pip
  cat > $HOME/.config/pip/pip.conf <<EOL
[global]
trusted-host = ${CI_SERVER_URL#https://}
extra-index-url = https://__token__:${GITLAB_TOKEN}@${CI_API_V4_URL#https://}/groups/${GITLAB_PACKAGE_REGISTRY_ID}/-/packages/pypi/simple
EOL
  echo "$HOME/.config/pip/pip.conf file generated for GitLab project registry." 

elif [[ "${GITLAB_PACKAGE_REGISTRY_TYPE}" == "project" ]]; then
  cat > ~/.pypirc <<EOL
[global]
trusted-host = ${CI_SERVER_URL#https://}

[distutils]
index-servers =
    gitlab-${GITLAB_PACKAGE_REGISTRY_ID}

[gitlab-${GITLAB_PACKAGE_REGISTRY_ID}]
repository: ${CI_API_V4_URL}/projects/${GITLAB_PACKAGE_REGISTRY_ID}/packages/pypi/simple
username: __token__
password: ${GITLAB_TOKEN}
EOL
  echo ".pypirc file generated for GitLab project registry."

mkdir -p $HOME/.config/pip
  cat > $HOME/.config/pip/pip.conf <<EOL
[global]
trusted-host = ${CI_SERVER_URL#https://}
extra-index-url = https://__token__:${GITLAB_TOKEN}@${CI_API_V4_URL#https://}/projects/${GITLAB_PACKAGE_REGISTRY_ID}/packages/pypi/simple
EOL
  echo "pip.conf file generated for GitLab project registry."      


else
  echo "Error: Invalid GITLAB_PACKAGE_REGISTRY_TYPE. Please set it to 'group' or 'project'."
  exit 1
fi
