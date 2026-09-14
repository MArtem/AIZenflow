# Patch Discipline

- inspect before editing;
- preserve existing local architecture unless a violated invariant requires change;
- prefer the smallest coherent behavioral patch;
- do not combine cleanup with functional changes unless necessary for correctness;
- do not introduce abstractions with one speculative consumer;
- update tests at the observable contract boundary;
- keep generated files and package locks intentional;
- preserve public API/source compatibility unless migration is explicit;
- review `git diff` after formatting/codegen;
- identify every changed file that has a distinct risk profile.
