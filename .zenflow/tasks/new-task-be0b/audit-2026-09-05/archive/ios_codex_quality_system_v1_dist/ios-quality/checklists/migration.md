# Persistence Migration Checklist

- [ ] Source and destination schema versions identified.
- [ ] All supported upgrade origins have a path.
- [ ] Existing user data assumptions validated.
- [ ] Optional/backfill/constraint sequencing safe.
- [ ] Duplicate/collision policy defined.
- [ ] Migration failure does not auto-delete store.
- [ ] Old-store fixture/real old version tested.
- [ ] Empty-store path tested.
- [ ] Large/edge dataset considered.
- [ ] Save/transaction failure handled.
- [ ] Rollback/recovery documented.
