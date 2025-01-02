import Testing
@testable import CodeOwners

struct PathPatternTests {
    @Test func pathPattern_1() async throws {
        let tokens = Token.tokenize(line: "a*bc")
        let component = try #require(Pattern.PathPattern(tokens: tokens))
        #expect(component.match("abc"))
        #expect(component.match("aabc"))
        #expect(!component.match("abcd"))
        #expect(component.match("aabcebc"))
        #expect(!component.match("aabcebc1"))
    }

    @Test func pathPattern_2() async throws {
        let tokens = Token.tokenize(line: "a?bc")
        let component = try #require(Pattern.PathPattern(tokens: tokens))
        #expect(!component.match("abc"))
        #expect(component.match("aabc"))
        #expect(!component.match("abcd"))
        #expect(component.match("aabcebc"))
        #expect(!component.match("aabcebc1"))
    }
}
