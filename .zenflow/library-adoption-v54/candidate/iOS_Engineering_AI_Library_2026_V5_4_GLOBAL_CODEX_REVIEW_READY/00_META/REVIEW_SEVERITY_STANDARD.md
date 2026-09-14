# Review Severity Standard

## Blocker
Likely crash, data loss/corruption, auth/security bypass, privacy violation, broken migration, payment/release blocker, deterministic race or broken public contract.

## High
Substantial correctness failure, stale state, retry duplication, leak with meaningful growth, severe accessibility regression, likely production hang/performance collapse.

## Medium
Real bug or maintenance risk with bounded blast radius; missing error/cancellation path; fragile identity/state ownership; insufficient tests for a changed contract.

## Low
Actionable local improvement with measurable benefit. Do not report mere stylistic preference if formatter/linter owns it.

## Finding format
Each finding must contain:
1. severity;
2. exact location;
3. violated invariant;
4. concrete failure scenario;
5. minimal fix;
6. test that would catch it.

Do not inflate severity. Do not produce generic praise or style lists when user asked for defects.
