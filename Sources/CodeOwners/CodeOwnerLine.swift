import Foundation
public enum CodeOwnerLine: Sendable, Equatable {
    case codeOwner(CodeOwner)
    case comment(String)
    case invalid(line: String, reason: CodeOwnerLineInvalidReason)
}

public enum CodeOwnerLineInvalidReason: Error, Sendable, Equatable {
    case emptyLine
    case invalidOwner
    case intermediateComment
}

extension CodeOwnerLine {
    public static func parse(line: String) -> CodeOwnerLine? {
        let line = line.trimmingCharacters(in: .whitespacesAndNewlines)

        if line.isEmpty {
            return nil // Empty line
        }

        let tokens = Token.tokenize(line: line)

        let codeOwnerLineComponents = tokens.split(separator: .space)
            .compactMap { $0.isEmpty ? nil : CodeOwnerLineComponent(tokens: Array($0)) }

        if codeOwnerLineComponents.isEmpty {
            return .invalid(line: line, reason: .emptyLine)
        }

        do {
            let pattern = codeOwnerLineComponents[0]
            let others = codeOwnerLineComponents[1...]
            let (owners, comment) = try extractOwnersAndComments(from: others.map { $0 })
            return .codeOwner(CodeOwner(
                pattern: Pattern(tokens: pattern.tokens),
                owners: owners,
                inlineComment: comment
            ))
        } catch {
            return .invalid(line: line, reason: error)
        }
    }

    private static func extractOwnersAndComments(
        from codeOwnerLineComponents: [CodeOwnerLineComponent]
    ) throws(CodeOwnerLineInvalidReason) -> (owners: [Owner], comment: String?) {
        var owners: [Owner] = []
        var comment: String?
        for (index, codeOwnerLineComponent) in codeOwnerLineComponents.enumerated() {
            let token = codeOwnerLineComponent.tokens[0]
            switch token {
            case .slash, .asterisk, .questionMark, .consecutiveAsterisk, .space, .identifier:
                guard let owner = Owner.parse(codeOwnerLineComponent.tokens) else {
                    throw .invalidOwner
                }
                owners.append(owner)
            case .comment(let commentText):
                // Comment should be in the end.
                guard index == codeOwnerLineComponents.count - 1 else {
                    throw .intermediateComment
                }
                comment = commentText
            }
        }
        return (owners, comment)
    }

    private struct CodeOwnerLineComponent {
        var tokens: [Token]
    }
}
