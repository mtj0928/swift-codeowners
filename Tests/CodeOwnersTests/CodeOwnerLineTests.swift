import Testing
import CodeOwners

struct CodeOwnerLineTests {
    @Test
    func parseCodeOwnerLine() async throws {
        let line = "/aa/bbb @owner @org/team #comment"
        let codeOwnerLine = CodeOwnerLine.parse(line: line)
        #expect(codeOwnerLine == .codeOwner(CodeOwner(
            pattern: Pattern(tokens: [
                .slash,
                .identifier("aa"),
                .slash,
                .identifier("bbb")
            ]),
            owners: [
                .user(.userName("owner")),
                .group(GroupIdentifier(org: "org", name: "team")),
            ],
            inlineComment: "#comment"
        )))
    }
}
