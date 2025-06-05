/// Represents the contents of a ``CODEOWNERS`` file.
public struct CodeOwners {
    /// Parsed lines from the ``CODEOWNERS`` file.
    public var lines: [CodeOwnerLine]

    /// Creates a new ``CodeOwners`` instance with the given lines.
    /// - Parameter lines: Parsed ``CodeOwnerLine`` values.
    public init(lines: [CodeOwnerLine]) {
        self.lines = lines
    }

    /// Returns the ``CodeOwner`` that matches the given path.
    ///
    /// The last matching entry wins, emulating GitHub's behavior.
    /// - Parameter pattern: The path to match against the owners list.
    /// - Returns: The matched ``CodeOwner`` or `nil` if no entry applies.
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
    /// Parses a ``CODEOWNERS`` file into a ``CodeOwners`` structure.
    /// - Parameter file: The raw ``CODEOWNERS`` file contents.
    /// - Returns: A ``CodeOwners`` instance containing all parsed lines.
    public static func parse(file: String) -> CodeOwners {
        let lines = file.split(whereSeparator: \.isNewline)
        let codeOwnerLines = lines.compactMap { line in
            CodeOwnerLine.parse(line: String(line))
        }
        return CodeOwners(lines: codeOwnerLines)
    }
}

