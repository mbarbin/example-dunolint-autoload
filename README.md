# Dunolint Autoload Config Test Repository

> **⚠️ Example Repository**
> This is a demonstration/example repository showing how dunolint's config autoloading feature works.
> **Not an official dunolint repository.** Created for educational and testing purposes.

This repository tests the dunolint autoloading config feature, which allows dunolint to automatically discover and apply configuration files from different levels of the project hierarchy.

## Repository Structure

```
.
├── dune-project                 # Root project (lang dune 3.18)
├── dunolint                     # Root config: base rules
├── lib/
│   ├── dune                     # Library with violations
│   └── root_lib.ml
├── repo/
│   ├── foo/
│   │   ├── dune-project         # Foo subproject
│   │   ├── dunolint             # Foo config: overrides + additions
│   │   └── lib/
│   │       ├── dune             # Library with violations
│   │       └── wrong_name.ml
│   └── bar/
│       ├── dune-project         # Bar subproject
│       ├── dunolint             # Bar config: different overrides
│       └── lib/
│           ├── dune             # Library with minimal violations
│           └── bar_lib.ml
├── test.sh                      # Test script with multiple scenarios
├── dune                         # Test runner with promotion
└── test.expected                # Expected output (promoted)
```

## Config Strategy

### Root `dunolint` Config
- **Combinable rules:**
  - Enforce `(instrumentation (backend bisect_ppx))` on all libraries

- **Base rules (can be overridden):**
  - `(implicit_transitive_deps (equals false))`
  - `(name (is_suffix _lib))`

### Foo `dunolint` Config
- **Overrides:**
  - Specific name requirement: `(name (equals foo_lib))` - overrides root's `is_suffix _lib` rule

### Bar `dunolint` Config
- **Overrides:**
  - Allow implicit transitive deps: `(implicit_transitive_deps (equals true))` - overrides root's requirement for `false`
  - Specific name: `(name (equals bar_lib))` - overrides root's `is_suffix _lib` rule

## Intentional Violations

### Root `dune-project`
- ❌ `implicit_transitive_deps true` (violates root rule requiring false)

### `lib/dune` (Root Library)
- ❌ Missing `instrumentation` field (violates root combinable rule)
- ✅ `name root_lib` (matches `is_suffix _lib`)

### `repo/foo/dune-project`
- ❌ `implicit_transitive_deps true` (violates inherited root rule requiring false)

### `repo/foo/lib/dune` (Foo Library)
- ❌ `name wrong_name` (violates foo override requiring `foo_lib`)
- ❌ Missing `instrumentation` field (violates inherited root rule)

### `repo/bar/dune-project`
- ❌ `implicit_transitive_deps false` (violates bar override requiring true)

### `repo/bar/lib/dune` (Bar Library)
- ❌ Missing `instrumentation` field (violates inherited root rule)
- ✅ `name bar_lib` (matches bar override)

## Test Scenarios

The `test.sh` script runs 6 different test scenarios:

1. **From root directory**: Should apply root config to entire tree
2. **`--below lib`**: Check only root lib with root config
3. **`--below repo/foo`**: Check foo with foo config loaded
4. **`--below repo/bar`**: Check bar with bar config loaded
5. **From `repo/foo` as root**: Foo config as root
6. **From `repo/bar` as root**: Bar config as root

## Running Tests

### Manual Test Run
```bash
./test.sh
```

### Dune Test with Promotion
```bash
# Run tests and see diff
dune runtest

# Promote new output as expected
dune runtest --auto-promote
```

### Initial Setup
To generate the initial expected output:
```bash
dune runtest --auto-promote
```

## Expected Behavior

The test verifies that:
- Root config rules are applied to all libraries by default
- Subproject configs can override specific rules
- Subproject configs can add new rules that combine with inherited ones
- The `--below` flag correctly limits the scope
- Running from different directories correctly identifies the root config

## Usage for Validating New Dunolint Versions

After updating dunolint:
1. Run `dune runtest` in this repository
2. Review the diff to ensure behavior is as expected
3. If behavior changed intentionally, promote with `dune runtest --auto-promote`
4. Commit the updated `test.expected` to track the new baseline
