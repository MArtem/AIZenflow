# Testing Instructions

## Purpose
Active verification policy for `<AppName>`.

## Default Rule
- Do not write or modify tests unless the user explicitly opens a test-writing phase or asks to fix a specific failing test.
- Do not run builds/tests/simulator UI/Instruments by default unless explicitly requested or already approved for the current implementation block.
- Use the cheapest verification path that proves the requested behavior.

## Verification Levels
### Absent
- no build
- no tests
- no simulator/manual verification

### Low
- compile/build only

### Medium
- targeted tests/builds relevant to the change

### Full
- full test suite/build matrix/manual or profiler validation when required

## Project Commands
Fill after the project is created:

```zsh
# build
<build command>

# targeted tests
<targeted test command>

# full tests
<full test command>
```
