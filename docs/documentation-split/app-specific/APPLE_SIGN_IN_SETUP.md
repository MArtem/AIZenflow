# Apple Sign In Setup

## Purpose
This file records the practical setup required to make `Sign in with Apple` work reliably in `source-app`.
The current code-level integration is already in place, but real authorization depends on Apple platform configuration, signing, and runtime environment.

## Current Project State
- App target bundle id: `com.example.source-app`
- Secondary app target bundle id: `com.example.source-appOcean`
- App and widget entitlements are now prepared to resolve the shared app group from build setting `APP_GROUP_IDENTIFIER`
- Current entitlement file:
  `source-app/source-app.entitlements`
- Current code already includes:
  - Apple sign-in button in the login screen
  - Apple credential handling in `LoginViewModel`
  - stable local persistence through `appleUserID`
  - session restore through local `user.id`
  - local username sign-in kept as fallback

## Important Limitation
Do not treat simulator behavior as a trustworthy signal for final Apple sign-in readiness.

Current simulator/auth errors like:
- `AKAuthenticationError Code=-7022`
- `ASAuthorizationError Code=1000`

usually point to platform configuration or simulator limitations, not to the basic login-screen wiring.

For real validation, use a properly signed app on a real device.

In the current environment:
- only simulator is available
- no App Store distribution exists yet
- the project can be prepared locally, but not truly validated end-to-end

That means the practical goal right now is:
- keep code and UX ready
- remove hardcoded placeholder assumptions from project config
- make the remaining Apple-side blockers explicit

## Required Apple Developer Setup
For each app bundle identifier that should support Apple login:

### 1. Register the real App ID
Create or confirm the App ID in Apple Developer for:
- `com.example.source-app` replacement with the real production or development bundle id
- `com.example.source-appOcean` replacement too, if that target should also support Apple login

### 2. Enable Sign in with Apple capability
Inside Apple Developer:
- open the App ID
- enable `Sign in with Apple`
- save the capability update

### 3. Refresh provisioning profiles
After capability changes:
- regenerate the provisioning profile
- download or let Xcode refresh it automatically

If the profile does not include the Apple sign-in capability, runtime auth will fail even if the entitlement exists in source.

## Required Xcode Setup

### 1. Replace placeholder bundle identifiers
Do not keep `com.example.*` identifiers for real Apple sign-in validation.
Use actual bundle ids that exist in the Apple Developer account.

The project is prepared so these identifiers can be replaced through build settings instead of hunting hardcoded app-group values in entitlement files.

### 2. Verify Signing & Capabilities
In Xcode for each app target:
- open `Signing & Capabilities`
- confirm the correct Team is selected
- confirm the correct bundle identifier is used
- confirm `Sign in with Apple` appears as a capability

### 3. Keep entitlement aligned with capability
Current entitlement already includes:
- `com.apple.developer.applesignin = Default`

That is correct, but it must match:
- the real App ID capability
- the active signing profile

### 4. Check both app targets separately
The project has two app targets:
- `source-app`
- `source-appOcean`

If both are meant to support Apple login, both need:
- valid App IDs
- enabled Apple sign-in capability
- valid profiles

One shared entitlement file is acceptable only if both targets are configured consistently on the Apple side.

## Recommended Real Device Validation

### 1. Use a physical iPhone
Preferred validation environment:
- real device
- signed build
- real Apple ID logged into the device

### 2. Validate first authorization
On first successful Apple login, verify:
- credential returns stable `user`
- optional `fullName` may be present
- optional `email` may be present
- local user gets created with `appleUserID`
- session restore works after app relaunch

### 3. Validate repeat authorization
On later Apple logins, verify:
- `credential.user` stays stable
- `fullName` may be absent
- `email` may be absent
- existing local user is restored by `appleUserID`

This is already the intended persistence model in the current implementation.

## Current Architecture Expectation
The project now correctly assumes:
- Apple identity should be persisted by stable identifier, not by display name
- local session restore should use stable local user id, not username
- username remains a UI-facing display and fallback local sign-in path

Do not regress this by switching Apple auth back to username-based matching.

## Practical Debug Checklist
If Apple login still fails after real signing setup:

### Check 1. Bundle id
- confirm app build is not still running under `com.example.*`
- confirm the target build settings point to the intended real identifier, not just the Xcode General tab copy

### Check 2. Team and profile
- confirm Xcode uses the expected Team
- confirm the provisioning profile was refreshed after enabling the capability

### Check 3. Capability presence
- confirm `Sign in with Apple` is visible in target capabilities

### Check 4. Device environment
- confirm the device is signed into an Apple ID
- confirm network access is available

### Check 5. Reinstall app
- remove the app from device
- install again after signing/profile updates

### Check 6. Credential reuse behavior
- remember that name/email may not be returned on repeated logins
- only `credential.user` should be treated as stable

## Follow-Up Improvements
Once real Apple sign-in is verified, the next reasonable product-level follow-up is:
- expose account/provider info in profile or settings
- show whether the user signed in with Apple or local username
- decide whether local username editing is allowed for Apple-backed profiles
- decide whether both app targets should support the feature or only one

## Non-Goals For Now
- no test work in this phase
- no verification work in this phase unless explicitly requested later
- no extra auth abstraction layers unless the project grows into multiple external providers

## What Was Prepared Locally In This Phase
- Apple auth flow is already implemented in app code
- Apple-specific credential parsing was extracted into infrastructure package `source-appleAuthentication`
- profile and shell now reflect Apple-vs-local account state
- the simulator login screen now explicitly warns that simulator-only Apple validation is not a reliable final signal
- app-group entitlements were prepared for build-setting-based replacement instead of hardcoded `group.com.example...`
