#!/usr/bin/env bash

set -eo pipefail

for dir in charts/steadybit-extension-*; do
  echo "Unit Testing $dir"
  helm unittest $dir $1
done