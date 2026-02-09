#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if ! command -v bundle >/dev/null 2>&1; then
  echo "bundle command not found. Install Ruby bundler first."
  exit 1
fi

if ! ruby -e 'exit(RUBY_VERSION.to_f >= 4.0 ? 0 : 1)'; then
  echo "Ruby 4.0.0+ is required."
  exit 1
fi

bundle exec rails server -p "${SERVER_PORT:-8082}"
