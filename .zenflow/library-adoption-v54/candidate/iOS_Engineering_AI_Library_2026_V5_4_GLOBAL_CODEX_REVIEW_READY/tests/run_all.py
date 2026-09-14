#!/usr/bin/env python3
from __future__ import annotations

import argparse
import concurrent.futures
import io
import os
import pathlib
import sys
import unittest

sys.dont_write_bytecode = True
os.environ["PYTHONDONTWRITEBYTECODE"] = "1"
ROOT = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))


def flatten(suite):
    for item in suite:
        if isinstance(item, unittest.TestSuite):
            yield from flatten(item)
        else:
            yield item


def worker(group_id):
    # Each class executes in a separate process. This prevents one test class's
    # monkeypatches from affecting another while keeping all fixtures synthetic.
    sys.dont_write_bytecode = True
    if str(ROOT) not in sys.path:
        sys.path.insert(0, str(ROOT))
    suite = unittest.defaultTestLoader.loadTestsFromName(group_id)
    buf = io.StringIO()
    result = unittest.TextTestRunner(stream=buf, verbosity=2).run(suite)
    return {
        'group': group_id,
        'tests': result.testsRun,
        'failures': len(result.failures),
        'errors': len(result.errors),
        'skipped': len(result.skipped),
        'ok': result.wasSuccessful(),
        'output': buf.getvalue(),
    }


def main():
    ap = argparse.ArgumentParser(description='Run the shipped review-ready synthetic regression suite.')
    ap.add_argument('--jobs', type=int, default=min(8, max(1, os.cpu_count() or 1)), help='parallel TestCase processes (default: up to 8; use --serial for one-at-a-time diagnostics)')
    ap.add_argument('--serial', action='store_true', help='run one TestCase process at a time')
    args = ap.parse_args()
    jobs = 1 if args.serial else max(1, min(args.jobs, 8))

    discovered = unittest.defaultTestLoader.discover(str(ROOT), pattern='test_*.py')
    ids = sorted({test.id().rsplit('.', 1)[0] for test in flatten(discovered)})
    if not ids:
        print('REVIEW_READY_TEST_SUMMARY total=0 pass=0 fail=1 skip=0')
        return 1

    results = []
    if jobs == 1:
        for group in ids:
            results.append(worker(group))
    else:
        with concurrent.futures.ProcessPoolExecutor(max_workers=min(jobs, len(ids))) as pool:
            future_map = {pool.submit(worker, group): group for group in ids}
            for fut in concurrent.futures.as_completed(future_map):
                group = future_map[fut]
                try:
                    results.append(fut.result())
                except BaseException as exc:
                    results.append({'group': group, 'tests': 0, 'failures': 0, 'errors': 1, 'skipped': 0, 'ok': False, 'output': f'{group}: worker failure: {type(exc).__name__}: {exc}\n'})

    results.sort(key=lambda r: r['group'])
    for r in results:
        sys.stdout.write(r['output'])

    total = sum(r['tests'] for r in results)
    failures = sum(r['failures'] for r in results)
    errors = sum(r['errors'] for r in results)
    skipped = sum(r['skipped'] for r in results)
    failed = failures + errors
    passed = total - failed - skipped
    print(f'\nREVIEW_READY_TEST_SUMMARY total={total} pass={passed} fail={failed} skip={skipped}')
    return 0 if failed == 0 and all(r['ok'] for r in results) else 1


if __name__ == '__main__':
    raise SystemExit(main())
