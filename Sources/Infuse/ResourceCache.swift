import Mutex

/// Collection of service and configuration dependencies.
///
/// On the initialization of an application, resources should be provided to the cache. Commonly,
/// these references are maintained by one or more sources. Example implementations on iOS include:
/// ```swift
/// // SwiftUI Lifecycle
/// @main
/// struct MyApp: App {
///   init() {
///     ResourceCache.configure(with: Supplier())
///   }
/// }
///
/// // UIKit Lifecycle
/// @UIApplicationMain
/// class AppDelegate: UIResponder, UIApplicationDelegate {
///     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
///         ResourceCache.configure(with: Supplier())
///
///         return true
///     }
/// }
/// ```
///
/// See `ResourceSupplier` for additional details.
public final class ResourceCache: Sendable {

    public static let shared: ResourceCache = .init()
    
    /// Resources maintained by the cache
    ///
    /// - note: `ObjectIdentifier` provides a hashable reference to a specific type being cached.
    private let resources: Mutex<[ObjectIdentifier: () -> Any]> = Mutex([:])

    public init() {
    }
    
    /// Add a resource to the cache.
    public func cache<T>(resource: @escaping () -> T) {
        /*
         https://forums.swift.org/t/mutex-error/76653
         https://github.com/swiftlang/swift/issues/77199
         https://github.com/swiftlang/swift/issues/87540
         */
        let nonAdvisableClosure = { resource }
        resources.withLock {
            $0[ObjectIdentifier(T.self)] = nonAdvisableClosure()
        }
    }
    
    /// Resolve a resource stored in the cache.
    ///
    /// - throws: `ResourceError`
    /// - returns: The resolved resource for the request type.
    public func resolve<T>() throws -> T {
        let source = resources.withLock {
            $0[ObjectIdentifier(T.self)]
        }

        guard let source = source?() else {
            throw ResourceError.source(T.self)
        }
        
        guard let resource = source as? T else {
            throw ResourceError.type(T.self)
        }
        
        return resource
    }
    
    /// Configures the cache with a `ResourceSupplier`.
    ///
    /// - parameters:
    ///   - supplier: The _supplier_ with _resources_ that should be added to _cache_.
    public func configure(with supplier: any ResourceSupplier) {
        supplier.supply(cache: self)
    }
}

public extension ResourceCache {
    /// Add a resource to the `.shared` cache.
    ///
    /// - parameters:
    ///   - resource: Function returning a resource type to be cached.
    static func cache<T>(resource: @escaping () -> T) {
        ResourceCache.shared.cache(resource: resource)
    }
    
    /// Resolve a resource stored in the `.shared` cache.
    ///
    /// - throws: `ResourceError`
    /// - returns: The resolved resource for the request type.
    static func resolve<T>() throws -> T {
        try ResourceCache.shared.resolve()
    }
    
    /// Configures the `.shared` cache with a `ResourceSupplier`.
    ///
    /// - parameters:
    ///   - supplier: The _supplier_ with _resources_ that should be added to _cache_.
    static func configure(with supplier: any ResourceSupplier) {
        ResourceCache.shared.configure(with: supplier)
    }
}
