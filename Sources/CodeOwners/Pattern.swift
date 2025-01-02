public struct Pattern: Sendable, Equatable  {
    public var tokens: [Token]
    public var isDirectory: Bool {
        tokens.last == .slash
    }

    public init(tokens: [Token]) {
        self.tokens = tokens
    }

    public func match(_ text: String) -> Bool {
        let pathPatterns = tokens.split(separator: .slash).compactMap { PathPattern(tokens: Array($0)) }
        let stringPathComponents = text.split(separator: "/").map { String($0) }

        if pathPatterns.count == 1 {
            if tokens.count == 2,
               tokens.first == .slash,
               case .identifier(let identifier) = tokens[1] {
                return stringPathComponents[0] == identifier
            } else if tokens.first != .slash {
                // According to the spec, if the pattern doesn't have "/", all paths which have the pattern in the path should be matched.
                return stringPathComponents.first(where: { pathPatterns[0].match($0) }) != nil
            }
        }

        return recursiveMatch(stringPathComponents, pathPatterns: pathPatterns)
    }

    private func recursiveMatch(_ stringPathComponents: [String], pathPatterns: [PathPattern]) -> Bool {
        if stringPathComponents.count == 0 {
            if pathPatterns.count == 1,
               pathPatterns[0] == .consecutiveAsterisk {
                return true
            }
            return pathPatterns.isEmpty
        }
        else if pathPatterns.count == 0 {
            return tokens.last != .asterisk
        }

        if pathPatterns.count >= 2,
           pathPatterns[0] == .consecutiveAsterisk,
           case .normal(let tokens) = pathPatterns[1],
           case .identifier(let identifier) = tokens.first,
           tokens.count == 1 {
            let indexes = stringPathComponents.indexes(where: { $0 == identifier })
            for index in indexes {
                if index == 0 {
                    return recursiveMatch(
                        stringPathComponents.dropFirst().map { $0 },
                        pathPatterns: pathPatterns.dropFirst(2).map { $0 }
                    )
                } else
                if recursiveMatch(
                    stringPathComponents[(index + 1)...].map { $0 },
                    pathPatterns: Array(pathPatterns.dropFirst(index))
                ) {
                    return true
                }
            }
        }

        if pathPatterns[0].match(stringPathComponents[0]) {
            if pathPatterns[0] == .consecutiveAsterisk {
                if recursiveMatch(Array(stringPathComponents.dropFirst()), pathPatterns: pathPatterns) {
                    return true
                } else {
                    return recursiveMatch(Array(stringPathComponents.dropFirst()), pathPatterns: Array(pathPatterns.dropFirst()))
                }
            }
            return recursiveMatch(Array(stringPathComponents.dropFirst()), pathPatterns: Array(pathPatterns.dropFirst()))
        }
        return false
    }

    enum PathPattern: Equatable {
        case consecutiveAsterisk
        case normal([Token])

        init?(tokens: [Token]) {
            if tokens.count == 1,
               tokens[0] == .consecutiveAsterisk {
                self = .consecutiveAsterisk
            } else if tokens.allSatisfy({ $0 != .consecutiveAsterisk }){
                self = .normal(tokens)
            } else {
                return nil
            }
        }

        func match(_ stringPathComponents: String) -> Bool {
            switch self {
            case .consecutiveAsterisk:
                return true
            case .normal(let tokens):
                return match(stringPathComponents, tokens: tokens)
            }
        }

        private func match(_ targetString: String, tokens: [Token]) -> Bool {
            if tokens.isEmpty && targetString.isEmpty {
                return true
            } else if tokens.isEmpty {
                return false
            }

            // From here, tokens should have at least one element
            let token = tokens[0]

            switch token {
            case .slash, .space, .comment:
                assertionFailure("Logic error")
                return false
            case .identifier(let string):
                if targetString.hasPrefix(string) {
                    // ex:
                    // targetString = "aaabb"
                    // pattern = "aa*b"
                    // string = "aa"
                    let nextString = String(targetString.dropFirst(string.count))
                    // Check "*b" is matched with "abb". ("aa" is removed)
                    return match(nextString, tokens: Array(tokens.dropFirst()))
                } else {
                    return false
                }
            case .asterisk:
                if tokens.count == 1 {
                    // The pattern is "*", and it matches all string.
                    return true
                } else if case .identifier(let nextString) = tokens[1] {
                    // ex:
                    // targetString = "abab"
                    // pattern = "*b"
                    //
                    // In this pattern, check the next identifier in tokens[1], and check all patterns matching the next identifiers.
                    let indexes = targetString.indexes(of: nextString)
                    for index in indexes {
                        let nextIndex = targetString.index(index, offsetBy: nextString.count)
                        // "ab" or "".
                        let nextTarget = String(targetString[nextIndex...])
                        // "*" and the next identifier are checked, so we should drop the second elements.
                        if  match(nextTarget, tokens: Array(tokens.dropFirst(2))) {
                            return true
                        }
                    }
                    return false
                }
            case .questionMark:
                if tokens.count == 1 {
                    return targetString.count > 0
                } else if case .identifier(let nextString) = tokens[1] {
                    let indexes = targetString.indexes(of: nextString)
                    for index in indexes.filter({ $0 != targetString.startIndex }) {
                        let nextIndex = targetString.index(index, offsetBy: nextString.count)
                        let nextTarget = String(targetString[nextIndex...])
                        if match(nextTarget, tokens: Array(tokens.dropFirst(2))) {
                            return true
                        }
                    }
                    return false
                }
            case .consecutiveAsterisk:
                assertionFailure("Logic error")
                return true
            }
            return false
        }
    }
}
