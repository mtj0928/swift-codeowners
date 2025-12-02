public enum Token: Hashable, Sendable {
    case slash // "/"
    case asterisk // "*"
    case questionMark // "?"
    case consecutiveAsterisk // "**"
    case comment(String) // "#"
    case identifier(String)
    case space // " "

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
