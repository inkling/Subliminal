#!/bin/sh -e

echo "Installing dependencies..."
if ! (yarn --no-progress --non-interactive --frozen-lockfile); then
  echo "Failed to install dependencies via yarn"
  exit 1
fi

echo "Running build..."
if ! (yarn build); then
  exit 1
fi
