# Integration Helpers Rules

Integration helpers connect two or more otherwise independent root packages.

## Why helpers exist

Root packages must remain standalone. But real apps often need composition:

```text
Networking events → Analytics events
Networking errors → App-facing errors
Product localization bundle → Generic localization manager
Push notification events → Analytics events
Navigation events → Analytics events
```

Those mappings should not live inside root packages.

## Allowed helper forms

### 1. Copy file helper

A single `.swift` file the app can copy into its integration target.

Good for:

```text
small adapters;
one-way mapping;
no additional resources;
no complex tests needed in consuming app.
```

### 2. Testable helper package

A full Swift package under `IntegrationHelpers/`.

Required when:

```text
mapping is complex;
privacy policy is non-trivial;
helper has tests;
helper may be reused in multiple apps.
```

## Helper package structure

```text
HelperName/
├── Package.swift
├── README.md
├── PackageContract.md
├── Sources/
├── Tests/
├── Sources/<Module>/Documentation.docc/
└── Scripts/verify_package.sh
```

## Privacy rule

Helpers must never forward raw sensitive data by default:

Forbidden telemetry values:

```text
raw URL with query/fragment;
HTTP headers;
HTTP body;
tokens;
emails;
phone numbers;
user-entered text;
notification title/body;
String(describing: error) for arbitrary errors.
```

Use sanitized codes/categories instead:

```text
error_category
error_code
status_code
is_retryable
has_title
url_host
url_path_without_query
```

## Naming

Helpers should be explicit:

```text
AppAnalyticsNetworkingIntegration
AppErrorsNetworkingIntegration
ProductLocalizationAppLocalizationIntegration
```
