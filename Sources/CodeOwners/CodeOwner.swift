public struct CodeOwner: Sendable, Equatable {
    public var pattern: Pattern
    public var owners: [Owner]
    public var inlineComment: String?

    public init(pattern: Pattern, owners: [Owner], inlineComment: String? = nil) {
        self.pattern = pattern
        self.owners = owners
        self.inlineComment = inlineComment
    }
}

public enum Owner: Sendable, Equatable {
    case user(UserIdentifier)
    case team(TeamIdentifier)

    public static func parse(_ tokens: [Token]) -> Owner? {
        if tokens.count == 1 {
            guard case .identifier(let identifier) = tokens.first else { return nil }
            if identifier.hasPrefix("@") {
                return .user(.userName(identifier.replacingOccurrences(of: "@", with: "")))
            } else if identifier.contains("@") {
                return .user(.email(identifier))
            } else {
                return nil
            }
        } else if tokens.count == 3 {
            if case .identifier(let organization) = tokens[0],
               tokens[1] == .slash,
               case .identifier(let groupName) = tokens[2],
               organization.hasPrefix("@")
            {
                return .team(TeamIdentifier(organization: organization.replacingOccurrences(of: "@", with: ""), name: groupName))
            }
        }
        return nil
    }
}

public enum UserIdentifier: Sendable, Equatable {
    case email(String)
    case userName(String)
}

public struct TeamIdentifier: Sendable, Equatable {
    public var organization: String
    public var name: String

    public init(organization: String, name: String) {
        self.organization = organization
        self.name = name
    }
}
