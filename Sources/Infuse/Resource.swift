/// Convenience property wrapper that resolves a type from the `ResourceCache`.
@propertyWrapper public struct Resource<T> {
    
    private let cache: ResourceCache
    private(set) var value: T?
    
    public init(cache: ResourceCache = .shared) {
        self.cache = cache
    }
    
    public var wrappedValue: T {
        mutating get {
            guard let value = self.value else {
                do {
                    let resolved: T = try cache.resolve()
                    self.value = resolved
                    return resolved
                } catch {
                    preconditionFailure("Failed to resolve resource of type '\(String(describing: T.self))'.")
                }
            }
            
            return value
        } set {
            value = newValue
        }
    }
    
    /// Resets the underlying resource reference, forcing resolution on the next access.
    public mutating func dissolve() {
        value = nil
    }
}
