#  swift-codeowners

Analyze `CODEOWNERS` of GitHub in Swift.

## How to Use

```swift
import CodeOwners

// Load CODEOWNERS file as String
let codeOwnersString: String = """
Sources/Foo @foo
Sources/Bar @bar @org/bar-team
"""
let codeOwners = CodeOwners.parse(file: codeOwnersFile)

guard let matchedCodeOwner = codeOwners.codeOwner(pattern: "Sources/Foo/Foo.swift") else {
    // No matched owner
    return
}

let pattern: Pattern = matchedCodeOwner.pattern
let owners: [Owner] = matchedCodeOwner.owners
let comment: String? = matchedCodeOwner.inlineComment
```

## Requirements
Swift 6.0.0 or later

## Installation

You can install the library via Swift Package Manager.

```swift
dependencies: [
  .package(url: "https://github.com/mtj0928/swift-codeowners", from: "0.1.0")
]
```
