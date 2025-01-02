import Testing
import CodeOwners

struct PatternMatchTests {
    @Test
    func patternMatchTest_1() async throws {
        let tokens = Token.tokenize(line: "aa/bbb/ccc")
        let pattern = Pattern(tokens: tokens)
        #expect(pattern.match("aa/bbb/ccc"))

        #expect(!pattern.match("aa/bbb/cc"))
        #expect(!pattern.match("/xxx/aa/bbb/ccc"))
    }

    @Test
    func patternMatchTest_2() async throws {
        let tokens = Token.tokenize(line: "aa")
        let pattern = Pattern(tokens: tokens)
        #expect(pattern.match("bb/aa"))
        #expect(pattern.match("cc/bb/aa"))
        #expect(pattern.match("cc/aa/bbb"))

        #expect(!pattern.match("cc/bb/aaaa"))
    }

    @Test
    func patternMatchTest_3() async throws {
        let tokens = Token.tokenize(line: "aa/**/bb")
        let pattern = Pattern(tokens: tokens)
        #expect(pattern.match("aa/bb"))
        #expect(pattern.match("aa/bb/cc"))
        #expect(pattern.match("aa/11/bb"))
        #expect(pattern.match("aa/11/22/bb"))
        #expect(pattern.match("aa/11/22/bb/33/44"))
        #expect(pattern.match("aa/11/22/bb/33/44/bb"))

        #expect(!pattern.match("aa/11/22/33/44"))
        #expect(!pattern.match("cc/11/22/33/44/bb"))
    }

    @Test
    func patternMatchTest_4() async throws {
        let tokens = Token.tokenize(line: "aa/**/bb/**/cc")
        let pattern = Pattern(tokens: tokens)
        #expect(pattern.match("aa/bb/cc"))
        #expect(pattern.match("aa/bb/cc/dd"))
        #expect(pattern.match("aa/11/bb/22/cc"))
        #expect(pattern.match("aa/11/22/bb/33/44/cc"))
        #expect(pattern.match("aa/11/bb/22/cc/dd"))

        #expect(!pattern.match("aa/11/bb/22/33/dd/dd"))
    }

    @Test
    func patternMatchTest_5() async throws {
        let tokens = Token.tokenize(line: "aa")
        let pattern = Pattern(tokens: tokens)
        #expect(pattern.match("aa/bb/cc"))
        #expect(pattern.match("bb/aa"))
        #expect(pattern.match("bb/aa/cc"))

        #expect(!pattern.match("bb/aaa/cc"))
    }

    @Test
    func patternMatchTest_6() async throws {
        let tokens = Token.tokenize(line: "/aa")
        let pattern = Pattern(tokens: tokens)
        #expect(pattern.match("aa/bb/cc"))
        #expect(!pattern.match("bb/aa"))
        #expect(!pattern.match("bb/aa/cc"))
        #expect(!pattern.match("bb/aaa/cc"))
    }

    @Test
    func patternMatchTest_7() async throws {
        let tokens = Token.tokenize(line: "/apps/github")
        let pattern = Pattern(tokens: tokens)
        #expect(pattern.match("/apps/github/foo"))

    }
}
