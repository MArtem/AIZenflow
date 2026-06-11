# AppAnalyticsNetworkingIntegration

Optional integration helper package.

This package intentionally depends on multiple root standalone packages and is not itself a root infrastructure package. Use it when the required packages are already present in the host project.

## Required packages

- `AppAnalytics`
- `AppNetworking`

## Test

```bash
swift test --package-path Packages/IntegrationHelpers/AppAnalyticsNetworkingIntegration
```
