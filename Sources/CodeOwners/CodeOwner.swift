/// A single entry in a CODEOWNERS file.
public struct CodeOwner: Sendable, Equatable {
    /// The pattern that must match a file path for this entry.
    public var pattern: Pattern
    /// The owners associated with the ``pattern``.
    public var owners: [Owner]
    /// An optional inline comment appearing after the owners.
    public var inlineComment: String?

    /// Creates a new ``CodeOwner`` entry.
    /// - Parameters:
    ///   - pattern: The path ``Pattern`` that should be matched.
    ///   - owners: The owners responsible for the matched files.
    ///   - inlineComment: An optional comment following the owners in the
    ///     ``CODEOWNERS`` file line.
    public init(pattern: Pattern, owners: [Owner], inlineComment: String? = nil) {
        self.pattern = pattern
        self.owners = owners
        self.inlineComment = inlineComment
    }
}

/// Represents an owner declared in a ``CODEOWNERS`` entry.
public enum Owner: Sendable, Equatable {
    /// A single user specified by their username or e-mail address.
    case user(UserIdentifier)
    /// A team within an organization.
    case team(TeamIdentifier)

    /// Parses owner tokens from a ``Token`` sequence.
    ///
    /// - Parameter tokens: Tokens extracted from a single owner declaration.
    /// - Returns: The parsed ``Owner`` or `nil` if the tokens do not represent a
    ///   valid owner.
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

/// Identifies a single user.
public enum UserIdentifier: Sendable, Equatable {
    /// A user's e-mail address.
    case email(String)
    /// A GitHub username.
    case userName(String)
}

/// Identifies a team within a GitHub organization.
public struct TeamIdentifier: Sendable, Equatable {
    /// The organization the team belongs to.
    public var organization: String
    /// The team name.
    public var name: String

    /// Creates a new team identifier.
    /// - Parameters:
    ///   - organization: The organization slug.
    ///   - name: The team name.
    public init(organization: String, name: String) {
        self.organization = organization
        self.name = name
    }
}
