/// Lexical tokens used to parse ``CODEOWNERS`` lines.
public enum Token: Equatable, Sendable {
    /// A `/` character.
    case slash
    /// A single `*` wildcard.
    case asterisk
    /// A single `?` wildcard.
    case questionMark
    /// A double `**` wildcard.
    case consecutiveAsterisk
    /// A comment starting with `#`.
    case comment(String)
    /// Any other identifier fragment.
    case identifier(String)
    /// A space character used to delimit owners.
    case space

    /// Tokenizes a line from a ``CODEOWNERS`` file.
    /// - Parameter line: The raw line text.
    /// - Returns: An array of ``Token`` values representing the line.
    public static func tokenize(line: String) -> [Token] {
        var index = line.startIndex

        var identifier = ""
        var result: [Token] = [] {
            didSet {
                identifier = ""
            }
        }

        while index < line.endIndex {
            var character = line[index]
            switch character {
            case "/":
                if !identifier.isEmpty {
                    result.append(.identifier(identifier))
                }
                result.append(.slash)
            case "*":
                if !identifier.isEmpty {
                    result.append(.identifier(identifier))
                }
                let nextIndex = line.index(after: index)
                let nextCharacter = line[nextIndex]
                if nextCharacter == "*" {
                    let token: Token = .consecutiveAsterisk
                    result.append(token)
                    index = nextIndex
                } else {
                    result.append(.asterisk)
                }
            case "?":
                if !identifier.isEmpty {
                    result.append(.identifier(identifier))
                }
                result.append(.questionMark)
            case "\\":
                index = line.index(after: index)
                character = line[index]
                identifier += String(character)
            default:
                if character.isWhitespace {
                    if !identifier.isEmpty {
                        let token: Token = .identifier(identifier)
                        result.append(token)
                    }
                    result.append(.space)
                } else if identifier.isEmpty,
                          result.last == .space,
                          character == "#" {
                    let comment = String(line[index...])
                    result.append(.comment(comment))
                    index = line.index(before: line.endIndex)
                } else {
                    identifier += String(character)
                }
            }
            index = line.index(after: index)
        }

        if !identifier.isEmpty {
            result.append(.identifier(identifier))
        }
        return result
    }
}
