# Privacy and Telemetry Policy

## Default rule

No package should emit raw user data, tokens, request bodies, headers, notification content, or arbitrary error descriptions by default.

## Forbidden by default

```text
Authorization headers
Cookies
Refresh tokens
Access tokens
HTTP body text
HTTP response body text
Raw notification title/body
Emails
Phone numbers
Full URLs with query/fragment
String(describing: error) for unknown errors
File paths containing user names
```

## Preferred telemetry values

Use sanitized values:

```text
status_code
error_category
error_code
is_retryable
has_body
body_size
url_host
url_path_without_query
source
state
attempt_count
```

## Redaction

If a package handles diagnostics, logging, analytics, or observability, it must define a redaction boundary.

Example:

```swift
public protocol ValueRedacting: Sendable {
    func redact(_ value: String, context: RedactionContext) -> String
}
```

## Tests

Every package that emits telemetry must have tests proving that sensitive data does not leak.
