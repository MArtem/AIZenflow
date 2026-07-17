---
name: ios-build-system
description: Use for Xcode build graphs, targets, schemes, xcconfig, build settings, modules, linker or dyld failures, SwiftPM, plugins, macros, XCFrameworks, binary distribution, build performance, dependency supply chain, licenses, or SBOM work.
---

# iOS Build System

## Required Context
Read:

- `./docs/DEPENDENCY_POLICY.md`
- `./docs/CI_CD_QUALITY_GATES.md`
- `./docs/knowledge/global/ios/XCODE_BUILD_BINARY_AND_SUPPLY_CHAIN.md`
- exact project/workspace target and effective build settings

## Workflow
1. Record Xcode/toolchain, target, configuration, destination, architecture, package resolution, and signing context.
2. Trace the failing or changing build-graph edge: source, resource, generated output, script, module, library, embed, sign, or package product.
3. Compare minimal correction, structural correction, and dependency/toolchain changes with compatibility and CI tradeoffs.
4. Inspect effective settings and artifact contents rather than relying only on Xcode UI state.
5. Review executable dependency surfaces, licenses, privacy manifests, advisories, and transitive changes.
6. Verify clean/incremental build, archive, consumer, or artifact properties only when authorized and required.

## Guardrails
- Keep DerivedData, caches, logs, and temporary artifacts inside the approved sandbox.
- Do not expose secrets through settings dumps or logs.
- Do not resolve build failures by broad target membership, duplicate embedding, or disabling safety checks without cause.
- Do not add a dependency before ownership and removal cost are justified.

## Output
Report build-graph cause, effective-setting evidence, selected fix, alternatives, compatibility/supply-chain impact, and exact verification scope.
