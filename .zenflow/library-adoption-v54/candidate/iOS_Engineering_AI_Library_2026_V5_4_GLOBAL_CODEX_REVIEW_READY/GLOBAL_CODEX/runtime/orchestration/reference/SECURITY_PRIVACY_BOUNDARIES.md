# Security & Privacy Boundaries

- Give each agent the least context needed.
- Do not propagate secrets, tokens, production data or PII into task packets unless essential and authorized; redact by default.
- Security-sensitive agents should receive interfaces and evidence, not unrelated user data.
- Tool/action permissions remain least privilege.
- Child agents cannot bypass confirmation or repository rules inherited from the parent task.
- Treat logs, crash payloads, analytics schemas and AI prompts as possible data-exfiltration surfaces.
