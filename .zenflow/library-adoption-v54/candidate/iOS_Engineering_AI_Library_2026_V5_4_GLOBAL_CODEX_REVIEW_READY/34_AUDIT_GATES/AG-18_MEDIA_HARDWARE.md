# AG-18 — Media/hardware gate

- [ ] Permission/capability/unsupported-device paths handled.
- [ ] Session/engine lifecycle and teardown explicit.
- [ ] Interruptions/route/device changes restore coherent state.
- [ ] Realtime callbacks do not block or allocate excessively.
- [ ] Buffers/assets bounded; memory/thermal measured.
- [ ] Orientation/color/HDR/audio format semantics verified.
- [ ] Real-device test performed where simulator is insufficient.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
