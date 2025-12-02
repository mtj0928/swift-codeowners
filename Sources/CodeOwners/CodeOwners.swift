public struct CodeOwners: Sendable, Hashable {
    public var lines: [CodeOwnerLine]

    public init(lines: [CodeOwnerLine]) {
        self.lines = lines
    }

    public func codeOwner(pattern: String) -> CodeOwner? {
        let revertedLines = lines.reversed()
        for line in revertedLines {
            switch line {
            case .codeOwner(let codeOwner):
                if codeOwner.pattern.match(pattern) {
                    return codeOwner
                }
            default: break
            }
        }
        return nil
    }
}

extension CodeOwners {
    public static func parse(file: String) -> CodeOwners {
        let lines = file.split(whereSeparator: \.isNewline)
        let codeOwnerLines = lines.compactMap { line in
            CodeOwnerLine.parse(line: String(line))
        }
        return CodeOwners(lines: codeOwnerLines)
    }
}
