#!/usr/bin/env bash

set -eo pipefail

for dir in charts/steadybit-extension-*; do
  echo "Updating dependencies for $dir"
  helm dependency update "$dir"
  echo
done