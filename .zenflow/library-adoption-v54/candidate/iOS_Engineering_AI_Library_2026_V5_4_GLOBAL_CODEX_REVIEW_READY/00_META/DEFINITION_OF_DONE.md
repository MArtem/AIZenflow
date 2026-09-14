# Definition of Done — iOS feature / fix

- [ ] Acceptance criteria выполнены.
- [ ] Код компилируется в заявленном toolchain/configuration.
- [ ] Нет новых warnings/errors/lint violations без явного обоснования.
- [ ] Swift 6 concurrency safety проверена; actor isolation и Sendable корректны.
- [ ] Cancellation/lifetime для async work определены.
- [ ] Retain cycles / memory ownership проверены.
- [ ] Error/loading/empty/offline states определены.
- [ ] Unit/integration/UI tests добавлены или обновлены пропорционально риску.
- [ ] Accessibility и localization проверены для UI change.
- [ ] Privacy/security impact оценён; privacy manifest/permissions обновлены при необходимости.
- [ ] Performance-sensitive path измерен или обосновано, почему измерение не нужно.
- [ ] Logging/metrics позволяют диагностировать критические сбои без утечки PII/secrets.
- [ ] New dependency прошла audit.
- [ ] Minimum deployment target и availability соблюдены.
- [ ] Migration/backward compatibility учтены.
- [ ] Diff минимален и не содержит unrelated refactor.
- [ ] PR description описывает решение, риски и verification.
