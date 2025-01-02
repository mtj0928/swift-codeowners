#  swift-codeowners

A library which can analyze `CODEOWNERS` of GitHub in Swift.

## How to Use

```swift
import CodeOwners

let codeOwnersString: String = ... // Load CODEOWNERS file as String
let codeOwners = CodeOwners.parse(file: codeOwnersFile)

guard let matchedCodeOwner = codeOwners.codeOwner(pattern: "foo/bar/baz.swift") else {
    // No matched owner
    return
}

let pattern: Pattern = matchedCodeOwner.pattern
let owners: [Owner] = matchedCodeOwner.owners
let comment: String? = matchedCodeOwner.inlineComment
```

## Requirements
Swift 6.0 or laater

## Installation

You can install the library via Swift Package Manager.

```swift
dependencies: [
  .package(url: "https://github.com/mtj0928/swift-codeowners", from: "0.1.0")
]
```