# Reusing AppIntentSupport

Copy the whole package folder into a new project package area and run:

```bash
./Scripts/verify_package.sh
```

Then either:

1. link the package as a Swift Package for helper APIs; or
2. copy selected source files into a source-only package folder if the host project uses source-only integration.

Do not move product-specific App Intent implementations into this package unless they are generic across products.
