public struct BuiltInInputFormatter: InputFormatter, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public enum Kind: Sendable, Hashable, Codable {
        case trimEdges
        case collapseWhitespace
        case allowDecimalDigits
        case allowCharacters(String)
        case uppercaseASCII
        case lowercaseASCII
        case maxLength(Int)
        case grouped(groupSize: Int, separator: String)
        case pattern(InputFormatPattern)
    }

    public let id: InputFormatterID
    public let kind: Kind

    public init(id: InputFormatterID, kind: Kind) throws {
        try Self.validate(kind)
        self.id = id
        self.kind = kind
    }

    public func format(_ snapshot: InputSnapshot) async throws -> InputFormattingResult {
        let transformed = try Self.apply(kind, to: snapshot.text)
        let mappedSelection = try transformed.map.map(snapshot.selection)
        let revision = try Self.nextRevision(after: snapshot.revision)
        return try InputFormattingResult(
            fieldID: snapshot.fieldID,
            text: transformed.text,
            selection: mappedSelection,
            appliedFormatterCount: 1,
            revision: revision
        )
    }

    public var description: String {
        "BuiltInInputFormatter(id:\(id),kind:\(redactedKindName))"
    }

    public var debugDescription: String { description }

    private var redactedKindName: String {
        switch kind {
        case .trimEdges: "trimEdges"
        case .collapseWhitespace: "collapseWhitespace"
        case .allowDecimalDigits: "allowDecimalDigits"
        case .allowCharacters: "allowCharacters"
        case .uppercaseASCII: "uppercaseASCII"
        case .lowercaseASCII: "lowercaseASCII"
        case .maxLength: "maxLength"
        case .grouped: "grouped"
        case .pattern: "pattern"
        }
    }

    private static func validate(_ kind: Kind) throws {
        switch kind {
        case .allowCharacters(let allowed):
            guard (1...2_048).contains(allowed.count) else {
                throw InputFormattingFailure.invalidLimit
            }
        case .maxLength(let length):
            guard (0...10_000).contains(length) else {
                throw InputFormattingFailure.invalidLimit
            }
        case .grouped(let groupSize, let separator):
            guard (1...16).contains(groupSize), (1...16).contains(separator.count) else {
                throw InputFormattingFailure.invalidLimit
            }
        default:
            break
        }
    }

    private static func nextRevision(after revision: UInt64) throws -> UInt64 {
        let result = revision.addingReportingOverflow(1)
        guard !result.overflow else {
            throw InputFormattingFailure.revisionOverflow
        }
        return result.partialValue
    }

    private static func apply(_ kind: Kind, to text: String) throws -> TransformationOutput {
        switch kind {
        case .trimEdges:
            return try trimEdges(text)
        case .collapseWhitespace:
            return try collapseWhitespace(text)
        case .allowDecimalDigits:
            return try filter(text) { $0.isNumber }
        case .allowCharacters(let allowed):
            let allowedValues = Set(allowed)
            return try filter(text) { allowedValues.contains($0) }
        case .uppercaseASCII:
            return try replaceCharacters(text) { character in
                guard let scalar = character.unicodeScalars.first, character.unicodeScalars.count == 1 else {
                    return String(character)
                }
                let value = scalar.value
                if (97...122).contains(value), let upper = UnicodeScalar(value - 32) {
                    return String(Character(upper))
                }
                return String(character)
            }
        case .lowercaseASCII:
            return try replaceCharacters(text) { character in
                guard let scalar = character.unicodeScalars.first, character.unicodeScalars.count == 1 else {
                    return String(character)
                }
                let value = scalar.value
                if (65...90).contains(value), let lower = UnicodeScalar(value + 32) {
                    return String(Character(lower))
                }
                return String(character)
            }
        case .maxLength(let maximum):
            return try maxLength(text, maximum: maximum)
        case .grouped(let groupSize, let separator):
            return try grouped(text, groupSize: groupSize, separator: separator)
        case .pattern(let pattern):
            return try applyPattern(pattern, to: text)
        }
    }

    private struct TransformationOutput {
        let text: String
        let map: InputCursorMap
    }

    private static func filter(_ text: String, keep: (Character) -> Bool) throws -> TransformationOutput {
        var output = ""
        var offsets = [0]
        offsets.reserveCapacity(text.count + 1)
        for character in text {
            if keep(character) {
                output.append(character)
            }
            offsets.append(output.count)
        }
        return try TransformationOutput(
            text: output,
            map: InputCursorMap(originalLength: text.count, formattedLength: output.count, formattedOffsets: offsets)
        )
    }

    private static func replaceCharacters(_ text: String, transform: (Character) -> String) throws -> TransformationOutput {
        var output = ""
        var offsets = [0]
        offsets.reserveCapacity(text.count + 1)
        for character in text {
            output.append(contentsOf: transform(character))
            offsets.append(output.count)
        }
        return try TransformationOutput(
            text: output,
            map: InputCursorMap(originalLength: text.count, formattedLength: output.count, formattedOffsets: offsets)
        )
    }

    private static func maxLength(_ text: String, maximum: Int) throws -> TransformationOutput {
        var output = ""
        var offsets = [0]
        offsets.reserveCapacity(text.count + 1)
        var kept = 0
        for character in text {
            if kept < maximum {
                output.append(character)
                kept += 1
            }
            offsets.append(output.count)
        }
        return try TransformationOutput(
            text: output,
            map: InputCursorMap(originalLength: text.count, formattedLength: output.count, formattedOffsets: offsets)
        )
    }

    private static func trimEdges(_ text: String) throws -> TransformationOutput {
        var startDrop = 0
        for character in text {
            if character.isWhitespace {
                startDrop += 1
            } else {
                break
            }
        }

        var endDrop = 0
        for character in text.reversed() {
            if character.isWhitespace {
                endDrop += 1
            } else {
                break
            }
        }

        let characters = Array(text)
        let keptRangeStart = startDrop
        let keptRangeEnd = max(keptRangeStart, characters.count - endDrop)
        let output = String(characters[keptRangeStart..<keptRangeEnd])
        var offsets: [Int] = []
        offsets.reserveCapacity(characters.count + 1)
        for offset in 0...characters.count {
            if offset <= keptRangeStart {
                offsets.append(0)
            } else if offset >= keptRangeEnd {
                offsets.append(output.count)
            } else {
                offsets.append(offset - keptRangeStart)
            }
        }
        return try TransformationOutput(
            text: output,
            map: InputCursorMap(originalLength: text.count, formattedLength: output.count, formattedOffsets: offsets)
        )
    }

    private static func collapseWhitespace(_ text: String) throws -> TransformationOutput {
        var output = ""
        var previousWasSpace = false
        var offsets = [0]
        offsets.reserveCapacity(text.count + 1)
        for character in text {
            if character.isWhitespace {
                if !previousWasSpace {
                    output.append(" ")
                    previousWasSpace = true
                }
            } else {
                output.append(character)
                previousWasSpace = false
            }
            offsets.append(output.count)
        }
        return try TransformationOutput(
            text: output,
            map: InputCursorMap(originalLength: text.count, formattedLength: output.count, formattedOffsets: offsets)
        )
    }

    private static func grouped(_ text: String, groupSize: Int, separator: String) throws -> TransformationOutput {
        var output = ""
        var offsets = [0]
        offsets.reserveCapacity(text.count + 1)
        var index = 0
        for character in text {
            if index > 0, index.isMultiple(of: groupSize) {
                output.append(separator)
            }
            output.append(character)
            index += 1
            offsets.append(output.count)
        }
        return try TransformationOutput(
            text: output,
            map: InputCursorMap(originalLength: text.count, formattedLength: output.count, formattedOffsets: offsets)
        )
    }

    private static func applyPattern(_ pattern: InputFormatPattern, to text: String) throws -> TransformationOutput {
        guard !text.isEmpty else {
            return try TransformationOutput(
                text: "",
                map: InputCursorMap(originalLength: 0, formattedLength: 0, formattedOffsets: [0])
            )
        }

        var output = ""
        var offsets = [0]
        offsets.reserveCapacity(text.count + 1)
        var patternIndex = pattern.value.startIndex
        for character in text {
            while patternIndex < pattern.value.endIndex, String(pattern.value[patternIndex]) != pattern.marker {
                output.append(pattern.value[patternIndex])
                patternIndex = pattern.value.index(after: patternIndex)
            }
            if patternIndex < pattern.value.endIndex {
                output.append(character)
                patternIndex = pattern.value.index(after: patternIndex)
            }
            offsets.append(output.count)
        }
        return try TransformationOutput(
            text: output,
            map: InputCursorMap(originalLength: text.count, formattedLength: output.count, formattedOffsets: offsets)
        )
    }
}
