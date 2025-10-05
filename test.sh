#!/bin/bash
set -e

# Test script for dunolint autoloading config feature
# Tests various invocation scenarios to verify config files are loaded correctly

DUNOLINT=dunolint
ROOT_DIR="$(pwd)"

echo "=== Test 1: Run dunolint from root directory ==="
echo "Expected: Root config should be loaded and applied"
echo
cd "$ROOT_DIR"
$DUNOLINT lint --dry-run

echo
echo "=== Test 2: Run dunolint with --below lib (from root) ==="
echo "Expected: Only check lib/, applying root config"
echo
cd "$ROOT_DIR"
$DUNOLINT lint --dry-run --below lib

echo
echo "=== Test 3: Run dunolint with --below repo/foo (from root) ==="
echo "Expected: Check repo/foo/, should load foo's config"
echo
cd "$ROOT_DIR"
$DUNOLINT lint --dry-run --below repo/foo

echo
echo "=== Test 4: Run dunolint with --below repo/bar (from root) ==="
echo "Expected: Check repo/bar/, should load bar's config"
echo
cd "$ROOT_DIR"
$DUNOLINT lint --dry-run --below repo/bar

echo
echo "=== Test 5: Run dunolint from repo/foo (foo as root) ==="
echo "Expected: Foo config as root, should apply foo-specific rules"
echo
cd "$ROOT_DIR/repo/foo"
$DUNOLINT lint --dry-run

echo
echo "=== Test 6: Run dunolint from repo/bar (bar as root) ==="
echo "Expected: Bar config as root, should apply bar-specific rules"
echo
cd "$ROOT_DIR/repo/bar"
$DUNOLINT lint --dry-run

echo
echo "=== All tests completed ==="
