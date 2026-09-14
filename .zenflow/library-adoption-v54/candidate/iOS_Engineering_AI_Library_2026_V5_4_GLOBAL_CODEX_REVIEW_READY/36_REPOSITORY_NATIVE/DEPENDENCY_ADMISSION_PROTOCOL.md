# Dependency Admission Protocol

Before adding an SPM/binary/CocoaPods dependency, record:
- problem impossible or costly to solve with platform/local code;
- maintenance/release cadence and ownership;
- license and distribution implications;
- supported deployment/toolchain matrix;
- binary size/startup/runtime impact;
- privacy manifest / required-reason API / network behavior;
- concurrency/sendability model;
- transitive graph and supply-chain risk;
- testability and removal/exit plan.

A dependency is an architectural decision, not a shortcut to avoid writing 50 lines of code.
