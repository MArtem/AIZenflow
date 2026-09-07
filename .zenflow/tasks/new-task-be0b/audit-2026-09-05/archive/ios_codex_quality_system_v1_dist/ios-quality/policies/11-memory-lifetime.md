# 11 — Memory and Lifetime

## Principle

Memory correctness is mostly ownership correctness. For every long-lived object, callback, subscription, timer, task, observer, delegate, or cache, identify who retains whom and when the relationship ends.

## Retain-cycle review triggers

Review any new or changed:

- escaping closure capturing `self`;
- `Task` stored by the same object it captures;
- Combine subscription stored in `self` while closure captures `self`;
- timer/display link retaining target/closure;
- NotificationCenter observer token/selector lifecycle;
- delegate/data-source relationship;
- parent/child coordinator graph;
- async stream continuation ownership.

## Weak/unowned

- Use `weak` when the referenced object may legitimately disappear first.
- Use `unowned` only when lifetime ordering is a proven invariant. A wrong `unowned` assumption crashes.
- Do not mechanically add `[weak self]` to every closure; strong capture may be correct for short-lived operations.

## Tasks

A strong capture by a finite task is not automatically a cycle. It becomes a cycle when the owner stores the task and the task closure retains the owner, or when another retained graph closes the loop.

Long `await` calls can extend object lifetime even after a weak capture if the code upgrades to a strong `self` before suspension.

## Caches

Caches MUST define:

- ownership and eviction;
- memory warning/pressure behavior when applicable;
- key/value identity;
- thread/actor safety;
- whether values contain sensitive data.

## Images/data

Avoid decoding/storing unnecessarily huge images/data on main thread or indefinitely in memory. Downsample or stream when product scale requires it.

## Verification

For suspected leaks or R3 memory changes, use appropriate tools (Memory Graph, Allocations, Leaks) and report whether the behavior was actually profiled.
