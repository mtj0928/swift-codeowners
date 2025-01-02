import CodeOwners
import Testing

@Test func tokenize_pattern_1() {
    let line = "a/bb\\/\\*/**/c?c/*/\\ ddd/ eee # This is a comment"
    let token = Token.tokenize(line: line)
    #expect(token == [
        .identifier("a"),
        .slash,
        .identifier("bb/*"),
        .slash,
        .consecutiveAsterisk,
        .slash,
        .identifier("c"),
        .questionMark,
        .identifier("c"),
        .slash,
        .asterisk,
        .slash,
        .identifier(" ddd"),
        .slash,
        .space,
        .identifier("eee"),
        .space,
        .comment("# This is a comment")
    ])
}

@Test func tokenize_pattern_2() {
    let line = "a/b/*/"
    let token = Token.tokenize(line: line)
    #expect(token == [
        .identifier("a"),
        .slash,
        .identifier("b"),
        .slash,
        .asterisk,
        .slash
    ])
}

@Test func tokenize_pattern_3() {
    let line = "a/bb/*/c/ @user"
    let token = Token.tokenize(line: line)
    #expect(token == [
        .identifier("a"),
        .slash,
        .identifier("bb"),
        .slash,
        .asterisk,
        .slash,
        .identifier("c"),
        .slash,
        .space,
        .identifier("@user")
    ])
}

@Test
func tokenize_pattern_4() async throws {
    let line = "/aa/bbb @owner org/team #comment"
    let token = Token.tokenize(line: line)
    #expect(token == [
        .slash,
        .identifier("aa"),
        .slash,
        .identifier("bbb"),
        .space,
        .identifier("@owner"),
        .space,
        .identifier("org"),
        .slash,
        .identifier("team"),
        .space,
        .comment("#comment")
    ])
}
