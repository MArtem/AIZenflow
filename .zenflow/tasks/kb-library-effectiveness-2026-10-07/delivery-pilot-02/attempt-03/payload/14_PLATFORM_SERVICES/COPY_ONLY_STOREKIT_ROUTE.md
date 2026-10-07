# Purchases and entitlements — copy-only reference route

Use for StoreKit, subscriptions, purchase UI, restore or access-control changes. Start from the
project's existing product and server/account contract. Check current official platform and
store guidance for time-sensitive API or policy assertions. This route does not authorize a
purchase, StoreKit test session, account change, network call or release action.

Identify the single entitlement source of truth and map purchase, pending, verified,
unverified, revoked/refunded, expired, restored and account-switch states as applicable. Trace
transaction updates through persistence/server sync and every access consumer. An optimistic
UI state must not silently become permanent access. Ask how duplicate updates, offline periods,
relaunch and device changes converge, and how users recover from an interrupted purchase.
Check product/configuration identity and the transaction-update listener's lifetime, including
startup/relaunch reconciliation and subscription transitions. A displayed product or completed
UI animation is not evidence that verification and every entitlement consumer agreed.

For an authorized code change, inspect UI, entitlement owner, verification boundary and
negative paths; protect identifiers and purchase information in logs. Recommend relevant
sandbox/test evidence without claiming it ran. `AUTO` applies the static state/consumer check;
`ADVISORY` gives prioritized verification and product-risk advice. This extracts useful
`ioslib-storekit` criteria without activating its old installation/runtime references.
