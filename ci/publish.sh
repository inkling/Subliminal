#!/bin/sh -e

echo "Installing dependencies..."
if ! (yarn --no-progress --non-interactive --frozen-lockfile); then
  echo "Failed to install dependencies via yarn"
  exit 1
fi

echo "Publishing packages..."
if ! (yarn workspaces run publish); then
  echo "Failed to publish packages"
  exit 1
fi
