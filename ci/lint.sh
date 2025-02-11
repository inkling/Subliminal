#!/bin/sh -e

echo "Installing dependencies..."
if ! (yarn --no-progress --non-interactive --frozen-lockfile); then
  echo "Failed to install dependencies via yarn"
  exit 1
fi

echo "Checking files with ESLint and Prettier..."
if ! (yarn lint:no-cache); then
  exit 1
fi
