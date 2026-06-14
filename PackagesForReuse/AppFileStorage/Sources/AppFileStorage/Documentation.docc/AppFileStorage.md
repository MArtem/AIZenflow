# AppFileStorage

A standalone, app-independent file storage package for iOS infrastructure projects.

## Purpose

`AppFileStorage` provides a privacy-aware mechanism for storing files under app-owned directories using safe relative paths, atomic writes, cleanup policies, size calculation, diagnostics, and test-friendly directory providers.

## Non-goals

This package does not define product-specific file names, feature-specific repositories, media picker UI, downloads, uploads, image pipeline behavior, or diagnostics export formats.

## Standalone contract

The package has no sibling package dependencies and can be copied as a single folder into another project.


## Safety Notes

`LocalFileStorage` validates component-based relative paths and verifies resolved URLs stay inside the configured storage directory after symlink resolution. This prevents a file placed inside the storage tree from redirecting reads or writes to another location.

Atomic writes use replacement semantics so an existing destination is not removed before the new file is ready.
