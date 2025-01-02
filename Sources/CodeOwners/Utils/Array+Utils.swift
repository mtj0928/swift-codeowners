extension Array {
    func indexes(where predicate: (Element) -> Bool) -> [Int] {
        self.enumerated()
            .filter { predicate($0.element) }
            .map { $0.offset }
    }
}
