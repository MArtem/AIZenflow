from pathlib import Path
import hashlib, json, os, plistlib, subprocess, sys

w = Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
r = w / '.zenflow/tasks/new-task-be0b/library-utility-tc-mp01/regression'
stage = sys.argv[1]
assert stage in ['baseline', 'after']
out = r / ('component-' + stage)
out.mkdir(exist_ok=False)
source = (w / 'TchopApp/Views/News/NewsFeedView.swift').read_text()
tests = (w / 'TchopAppTests/FeedMediaPreviewRendererTests.swift').read_text()
kind = source[source.index('enum FeedMediaPreviewKind:'):source.index('@MainActor\nprivate final class FeedMediaPreviewMemoryCache')]
renderer = source[source.index('enum FeedMediaPreviewRenderer {'):source.index('private enum ComposerMediaPathResolver {')]
fixtures = tests[tests.index('    private func makeFixtureDirectory()'):tests.rfind('\n}')]
fixtures = fixtures.replace('#require(', 'require(').replace(
    'FileManager.default.temporaryDirectory',
    'URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)')
support = '''
private enum ComposerMediaPathResolver {
    static func resolve(fileURLString: String?) -> URL? {
        guard let fileURLString, let url = URL(string: fileURLString), url.isFileURL,
              FileManager.default.fileExists(atPath: url.path) else { return nil }
        return url
    }
}
private enum FixtureFailure: Error { case condition, missingValue }
private func require(_ condition: Bool) throws {
    guard condition else { throw FixtureFailure.condition }
}
private func require<T>(_ value: T?) throws -> T {
    guard let value else { throw FixtureFailure.missingValue }
    return value
}
@main
@MainActor
private struct MediaPreviewProbe {
    static func main() async {
        let probe = MediaPreviewProbe()
        var failures = 0
        var assertions = 0
        do {
            let directory = try probe.makeFixtureDirectory()
            defer { try? FileManager.default.removeItem(at: directory) }
            for rotated in [false, true] {
                let url = directory.appendingPathComponent(rotated ? "rotated.mov" : "normal.mov")
                try await probe.writeVideo(to: url, rotated: rotated)
                let data = try require(await FeedMediaPreviewRenderer.previewData(fileURLString: url.absoluteString, kind: .video))
                let imageSource = try require(CGImageSourceCreateWithData(data as CFData, nil))
                let image = try require(CGImageSourceCreateImageAtIndex(imageSource, 0, nil))
                let aspect = Double(image.width) / Double(image.height)
                let checks = [image.width > 0 && image.height > 0,
                              max(image.width, image.height) <= 1200,
                              abs(aspect - (rotated ? 0.75 : 4.0 / 3.0)) < 0.005,
                              rotated ? image.height > image.width : image.width > image.height]
                failures += checks.filter { !$0 }.count
                assertions += checks.count
                print(String(data: try JSONSerialization.data(withJSONObject: ["case": rotated ? "rotated" : "normal", "width": image.width, "height": image.height, "checks": checks]), encoding: .utf8)!)
            }
            let malformed = directory.appendingPathComponent("malformed")
            try Data("Not a media file".utf8).write(to: malformed)
            for kind in [FeedMediaPreviewKind.image, .video, .pdf] {
                for (label, url) in [("missing", directory.appendingPathComponent("missing")), ("malformed", malformed)] {
                    let data = await FeedMediaPreviewRenderer.previewData(fileURLString: url.absoluteString, kind: kind)
                    assertions += 1
                    if data != nil { failures += 1 }
                    print("CASE " + kind.rawValue + " " + label + " " + (data == nil ? "PASS" : "FAIL"))
                }
            }
            print("RESULT assertions=" + String(assertions) + " failures=" + String(failures))
            exit(failures == 0 ? 0 : 1)
        } catch {
            print("FIXTURE_OR_DECODE_FAILURE " + String(describing: error))
            exit(2)
        }
    }
'''
imports = 'import Foundation\nimport AVFoundation\nimport CoreGraphics\nimport CoreVideo\nimport ImageIO\nimport PDFKit\nimport UniformTypeIdentifiers\n'
generated = imports + kind + renderer + support + fixtures + '\n}\n'
(out / 'MediaPreviewProbe.swift').write_text(generated)
app = out / 'MediaPreviewProbe.app'
app.mkdir()
(app / 'Info.plist').write_bytes(plistlib.dumps({'CFBundleExecutable': 'MediaPreviewProbe',
    'CFBundleIdentifier': 'com.zenflow.TCMP01.ComponentProbe', 'CFBundlePackageType': 'APPL'}))
env = os.environ.copy()
iso = {k: str(r / p) for k, p in [('TMPDIR', 'tmp'), ('CFFIXED_USER_HOME', 'cocoa-home'), ('XDG_CACHE_HOME', 'cache')]}
env.update(iso)
sdk = '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator27.0.sdk'
args = ['/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc',
        '-parse-as-library', '-swift-version', '6', '-strict-concurrency=complete', '-warnings-as-errors',
        '-target', 'arm64-apple-ios17.0-simulator', '-sdk', sdk,
        '-module-cache-path', str(r / 'cache/component-modules'), '-o', str(app / 'MediaPreviewProbe'),
        str(out / 'MediaPreviewProbe.swift')]
(out / 'invocation.json').write_text(json.dumps({'args': args, 'environment': iso,
    'source_sha256': hashlib.sha256(source.encode()).hexdigest(),
    'renderer_exact_slice_sha256': hashlib.sha256(renderer.encode()).hexdigest(),
    'fixture_test_source_sha256': hashlib.sha256(tests.encode()).hexdigest(),
    'limits': 'Exact real production renderer/kind compiled; fixture-only direct-file resolver replaces app path fallback. No loader/cache/view/app-host or fallback-domain integration claim. Fixture builder derived from actual unit source, no target logic reimplementation.'}, indent=2) + '\n')
with (out / 'compile.log').open('w') as log:
    p = subprocess.run(args, cwd=w, env=env, stdout=log, stderr=subprocess.STDOUT, timeout=120)
(out / 'compile-result.json').write_text(json.dumps({'exit_code': p.returncode}) + '\n')
print('COMPONENT COMPILE', stage, p.returncode)
if p.returncode:
    print((out / 'compile.log').read_text()[:4000])
raise SystemExit(p.returncode)
