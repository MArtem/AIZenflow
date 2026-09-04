import XCTest
@testable import AppLogging

final class LoggerTests: XCTestCase {
    func testMemoryLoggerStoresEventsAboveMinimumLevel() async {
        let logger = MemoryLogger(minimumLevel: .warning)

        await logger.log(LogEvent(level: .debug, message: "debug"))
        await logger.log(LogEvent(level: .error, message: "error"))

        let events = await logger.events()
        XCTAssertEqual(events.map(\.message), ["error"])
    }

    func testMemoryLoggerClear() async {
        let logger = MemoryLogger()
        await logger.log(LogEvent(level: .info, message: "message"))
        await logger.clear()
        let events = await logger.events()
        XCTAssertTrue(events.isEmpty)
    }

    func testConsoleLoggerFormatsAndRedactsOutput() async {
        final class OutputBox: Sendable {
            private let queue = DispatchQueue(label: "AppLoggingTests.OutputBox")
            private let key = DispatchSpecificKey<[String]>()

            init() {
                queue.setSpecific(key: key, value: [])
            }

            func append(_ value: String) {
                queue.sync {
                    var values = queue.getSpecific(key: key) ?? []
                    values.append(value)
                    queue.setSpecific(key: key, value: values)
                }
            }

            var values: [String] {
                queue.sync { queue.getSpecific(key: key) ?? [] }
            }
        }
        let box = OutputBox()
        let logger = ConsoleLogger(minimumLevel: .debug, output: { value in box.append(value) })
        let event = LogEvent(
            level: .info,
            subsystem: "auth",
            category: "login",
            message: "Login",
            metadata: LogMetadata(["access_token": .string("secret"), "url": .url("https://example.com/a?token=secret")])
        )

        await logger.log(event)

        XCTAssertEqual(box.values.count, 1)
        XCTAssertTrue(box.values[0].contains("[INFO] auth.login: Login"))
        XCTAssertTrue(box.values[0].contains("access_token=<redacted>"))
        XCTAssertTrue(box.values[0].contains("url=https://example.com/a"))
        XCTAssertFalse(box.values[0].contains("secret"))
    }

    func testRedactingLoggerSanitizesBeforePassingToBaseLogger() async {
        let memory = MemoryLogger()
        let logger = RedactingLogger(base: memory)
        let event = LogEvent(
            level: .info,
            message: "token secret in message",
            metadata: LogMetadata(["password": .string("123456")])
        )
        let redactor = LogRedactor(stringMasks: ["secret": "<masked>"])
        let customLogger = RedactingLogger(base: memory, redactor: redactor)

        await logger.log(event)
        await customLogger.log(event)

        let events = await memory.events()
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].metadata.values["password"], .string("<redacted>"))
        XCTAssertEqual(events[1].message, "token <masked> in message")
    }

    func testMultiplexLoggerForwardsToAllLoggers() async {
        let first = MemoryLogger()
        let second = MemoryLogger()
        let logger = MultiplexLogger(first, second)

        await logger.log(LogEvent(level: .critical, message: "boom"))

        let firstEvents = await first.events()
        let secondEvents = await second.events()
        XCTAssertEqual(firstEvents.count, 1)
        XCTAssertEqual(secondEvents.count, 1)
    }

    func testConvenienceMethodsLogExpectedLevels() async {
        let logger = MemoryLogger()
        await logger.info("info")
        await logger.error("error")

        let events = await logger.events()
        XCTAssertEqual(events.map(\.level), [.info, .error])
    }
}
