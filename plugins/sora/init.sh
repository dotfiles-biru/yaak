#!/usr/bin/env bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$ROOT_DIR/src"

INDEX_FILE="$SRC_DIR/index.ts"
TEST_FILE="$SRC_DIR/index.test.ts"

echo "==> Initializing Sora Yaak plugin..."

# --------------------------------------------------
# Check Node.js / npm
# --------------------------------------------------

if ! command -v node >/dev/null 2>&1; then
  echo "Error: node is not installed."
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "Error: npm is not installed."
  exit 1
fi

echo "Node: $(node --version)"
echo "npm:  $(npm --version)"

# --------------------------------------------------
# Install dependencies
# --------------------------------------------------

echo "==> Checking dependencies..."

if [[ ! -d "$ROOT_DIR/node_modules" ]]; then
  echo "==> node_modules not found, running npm install..."
  npm install
else
  echo "==> node_modules already exists"
fi

# --------------------------------------------------
# Check / install Vitest
# --------------------------------------------------

if ! npm list vitest --depth=0 >/dev/null 2>&1; then
  echo "==> Vitest not found, installing..."
  npm install -D vitest
else
  echo "==> Vitest already installed"
fi

# --------------------------------------------------
# Ensure test script exists
# --------------------------------------------------

if node -e '
const fs = require("fs");

const file = "package.json";
const pkg = JSON.parse(fs.readFileSync(file, "utf8"));

process.exit(pkg.scripts?.test === "vitest run" ? 0 : 1);
'; then
  echo "==> npm test script already configured"
else
  echo "==> Adding npm test script..."
  npm pkg set scripts.test="vitest run"
fi

# --------------------------------------------------
# Run tests
# --------------------------------------------------

echo
echo "========================================"
echo " Running Sora theme tests"
echo "========================================"
echo

if ! npx vitest run; then
  echo
  echo "ERROR: Tests failed."
  echo "Build will NOT run."
  exit 1
fi

# --------------------------------------------------
# Build
# --------------------------------------------------

echo
echo "========================================"
echo " Tests passed!"
echo " Starting plugin build"
echo "========================================"
echo

npm run build

echo
echo "==> Sora Yaak plugin initialized successfully!"
