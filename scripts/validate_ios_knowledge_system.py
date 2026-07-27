#!/usr/bin/env python3
"""Validate the routed reusable iOS knowledge coverage contract."""

from __future__ import annotations

import json
import sys
from datetime import date
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REGISTRY_PATH = ROOT / "docs" / "IOS_KNOWLEDGE_COVERAGE_REGISTRY.json"
ROUTES_PATH = ROOT / "docs" / "TASK_DOCUMENT_ROUTES.json"
ALLOWED_MATURITY = {"missing", "outline", "operational", "complete", "deferred"}
REQUIRED_DOMAIN_KEYS = {
    "id",
    "tier",
    "maturity",
    "route",
    "operating_documents",
    "deep_references",
    "skills",
    "review_triggers",
}


def local_path(value: str) -> Path:
    if not value.startswith("./"):
        raise ValueError(f"path must start with ./: {value}")
    return ROOT / value[2:]


def main() -> int:
    failures: list[str] = []
    try:
        registry = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
        routes = json.loads(ROUTES_PATH.read_text(encoding="utf-8"))["routes"]
    except (OSError, KeyError, json.JSONDecodeError) as error:
        return report([f"cannot load registry or routes: {error}"])

    if registry.get("schema_version") != 1:
        failures.append("schema_version must be 1")
    maturity_values = registry.get("maturity_values")
    if not isinstance(maturity_values, list) or set(maturity_values) != ALLOWED_MATURITY or len(maturity_values) != len(ALLOWED_MATURITY):
        failures.append("maturity_values must contain each supported value exactly once")

    scope_policy = registry.get("scope_policy")
    if not isinstance(scope_policy, str) or not local_path(scope_policy).is_file():
        failures.append("scope_policy must reference an existing local file")

    verification = registry.get("verification", {})
    try:
        date.fromisoformat(verification["last_primary_source_review"])
    except (KeyError, TypeError, ValueError):
        failures.append("verification.last_primary_source_review must be an ISO date")
    if not verification.get("toolchain_reference"):
        failures.append("verification.toolchain_reference is required")

    domains = registry.get("domains")
    if not isinstance(domains, list) or not domains:
        return report([*failures, "domains must be a non-empty list"])

    seen: set[str] = set()
    for index, domain in enumerate(domains):
        label = domain.get("id", f"index {index}") if isinstance(domain, dict) else f"index {index}"
        if not isinstance(domain, dict):
            failures.append(f"{label}: domain must be an object")
            continue
        missing_keys = REQUIRED_DOMAIN_KEYS - set(domain)
        if missing_keys:
            failures.append(f"{label}: missing keys {sorted(missing_keys)}")
            continue
        if label in seen:
            failures.append(f"duplicate domain id: {label}")
        seen.add(label)
        maturity = domain["maturity"]
        if maturity not in ALLOWED_MATURITY:
            failures.append(f"{label}: unsupported maturity {maturity}")
        is_deferred = maturity == "deferred"
        if is_deferred != (domain["tier"] == "deferred-platform"):
            failures.append(f"{label}: deferred maturity and tier must be used together")
        route = domain["route"]
        if is_deferred:
            if route is not None:
                failures.append(f"{label}: deferred domain must not have an active route")
        elif not isinstance(route, str) or route not in routes:
            failures.append(f"{label}: active domain route is missing from TASK_DOCUMENT_ROUTES.json")
        for collection in ("operating_documents", "deep_references", "skills"):
            values = domain[collection]
            if not isinstance(values, list):
                failures.append(f"{label}: {collection} must be a list")
                continue
            for value in values:
                try:
                    candidate = local_path(value)
                except (TypeError, ValueError) as error:
                    failures.append(f"{label}: {error}")
                    continue
                if not candidate.is_file():
                    failures.append(f"{label}: missing {collection} path {value}")
        if not isinstance(domain["review_triggers"], list) or not domain["review_triggers"]:
            failures.append(f"{label}: at least one review trigger is required")
        if not is_deferred and maturity in {"operational", "complete"}:
            if not domain["operating_documents"]:
                failures.append(f"{label}: {maturity} domain needs an operating document")

    if failures:
        return report(failures)
    active = sum(domain["maturity"] != "deferred" for domain in domains)
    complete = sum(domain["maturity"] == "complete" for domain in domains)
    print(f"iOS knowledge system OK: {active} active domains, {complete} complete, {len(domains) - active} deferred")
    return 0


def report(failures: list[str]) -> int:
    print("iOS knowledge system FAILED:")
    for failure in failures:
        print(f"- {failure}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
