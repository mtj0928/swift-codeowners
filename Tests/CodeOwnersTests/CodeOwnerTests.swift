import Testing
import CodeOwners

struct CodeOwnerTests {

    @Test
    func codeOwner_match_pattern_1() async throws {
        let codeOwnersFile = """
        * @global-owner1 @global-owner2
        """
        let codeOwners = CodeOwners.parse(file: codeOwnersFile)
        #expect(codeOwners.codeOwner(pattern: "foo")?.owners == [.user(.userName("global-owner1")), .user(.userName("global-owner2"))])
        #expect(codeOwners.codeOwner(pattern: "foo/bar")?.owners == [.user(.userName("global-owner1")), .user(.userName("global-owner2"))])
    }

    @Test
    func codeOwner_match_pattern_2() async throws {
        let codeOwnersFile = """
        *.js @js-owner #This is an inline comment.
        *.go docs@example.com
        *.txt @octo-org/octocats
        """
        let codeOwners = CodeOwners.parse(file: codeOwnersFile)
        #expect(codeOwners.codeOwner(pattern: "foo.js")?.owners == [.user(.userName("js-owner"))])
        #expect(codeOwners.codeOwner(pattern: "foo/bar.js")?.owners == [.user(.userName("js-owner"))])
        #expect(codeOwners.codeOwner(pattern: "foo/bar.go")?.owners == [.user(.email("docs@example.com"))])
        #expect(codeOwners.codeOwner(pattern: "foo.txt")?.owners == [.group(GroupIdentifier(org: "octo-org", name: "octocats"))])
    }

    @Test
    func codeOwner_match_pattern_3() async throws {
        let codeOwnersFile = """
        /build/logs/ @doctocat
        """
        let codeOwners = CodeOwners.parse(file: codeOwnersFile)
        #expect(codeOwners.codeOwner(pattern: "foo")?.owners == nil)
        #expect(codeOwners.codeOwner(pattern: "build/foo")?.owners == nil)
        #expect(codeOwners.codeOwner(pattern: "build/logs/foo")?.owners == [.user(.userName("doctocat"))])
        #expect(codeOwners.codeOwner(pattern: "build/logs/foo/bar")?.owners == [.user(.userName("doctocat"))])
    }

    @Test
    func codeOwner_match_pattern_4() async throws {
        let codeOwnersFile = """
        docs/* docs@example.com
        """
        let codeOwners = CodeOwners.parse(file: codeOwnersFile)
        #expect(codeOwners.codeOwner(pattern: "docs/foo")?.owners == [.user(.email("docs@example.com"))])
        #expect(codeOwners.codeOwner(pattern: "docs/foo/bar")?.owners == nil)
    }

    @Test
    func codeOwner_match_pattern_5() async throws {
        let codeOwnersFile = """
        apps/ @octocat
        /docs/ @doctocat
        /scripts/ @doctocat @octocat
        """
        let codeOwners = CodeOwners.parse(file: codeOwnersFile)
        #expect(codeOwners.codeOwner(pattern: "/apps/foo")?.owners == [.user(.userName("octocat"))])
        #expect(codeOwners.codeOwner(pattern: "/bar/apps/foo")?.owners == [.user(.userName("octocat"))])
        #expect(codeOwners.codeOwner(pattern: "/docs/foo")?.owners == [.user(.userName("doctocat"))])
        #expect(codeOwners.codeOwner(pattern: "/bar/docs/foo")?.owners == nil)
        #expect(codeOwners.codeOwner(pattern: "/scripts/foo")?.owners == [
            .user(.userName("doctocat")), .user(.userName("octocat"))
        ])
    }

    @Test
    func codeOwner_match_pattern_6() async throws {
        let codeOwnersFile = """
        **/logs @octocat
        /apps/ @octocat
        /apps/github
        """
        let codeOwners = CodeOwners.parse(file: codeOwnersFile)
        #expect(codeOwners.codeOwner(pattern: "/aaa/bbb/logs/foo")?.owners == [.user(.userName("octocat"))])
    }


    @Test func codeOwner_match_pattern_x() async throws {
        let codeOwnersFile = """
        /apps/ @octocat
        /apps/github @doctocat
        """
        let codeOwners = CodeOwners.parse(file: codeOwnersFile)
        #expect(codeOwners.codeOwner(pattern: "apps/foo")?.owners == [.user(.userName("octocat"))])
        #expect(codeOwners.codeOwner(pattern: "apps/github/foo")?.owners == [.user(.userName("doctocat"))])
        #expect(codeOwners.codeOwner(pattern: "foo")?.owners == nil)
    }
}
