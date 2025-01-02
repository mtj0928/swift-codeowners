extension String {
    func indexes(of substring: String) -> [Index] {
        var indexes: [String.Index] = []
        var searchRange: Range<String.Index>? = startIndex..<endIndex

        while let foundRange = range(of: substring, options: [], range: searchRange) {
            indexes.append(foundRange.lowerBound)
            searchRange = foundRange.upperBound..<endIndex
        }

        return indexes
    }
}
