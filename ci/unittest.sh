#!/bin/sh -e

echo "Installing dependencies..."
if ! (yarn --no-progress --non-interactive --frozen-lockfile); then
  echo "Failed to install dependencies via yarn"
  exit 1
fi

echo "Running Jest..."
if ! (yarn jest --ci --silent --verbose); then
  exit 1
fi
