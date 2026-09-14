# Security & Privacy Protocol

For every sensitive boundary identify:
- assets/secrets/PII;
- trust boundary;
- attacker capability;
- authorization vs authentication;
- storage lifetime;
- logging/analytics exposure;
- transport requirements;
- third-party SDK data flow;
- deletion/retention requirements.

## Hard rules
- no credentials in source/UserDefaults/plain fixtures;
- no sensitive data in logs/breadcrumbs;
- do not disable ATS or trust evaluation to fix networking;
- validate deep links/universal links before privileged actions;
- permission denial/revocation is a normal state;
- privacy manifest must match actual collected data and required-reason API use;
- dependency upgrade review includes privacy manifest/signature requirements.
