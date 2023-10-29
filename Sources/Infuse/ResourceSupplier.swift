/// A supplier of dependencies.
///
/// Here's an example implementation.
///
/// ```swift
/// class Supplier: ResourceSupplier {
///     lazy var networkService: NetworkService { RealNetworkService() }
///     lazy var tokenAuthService: TokenAuthService { RealTokenAuthService() }
///
///     func supply(cache: ResourceCache) {
///         cache.cache { self.networkService }
///         cache.cache { self.tokenAuthService }
///         cache.cache { self.tokenAuthService as TokenService }
///     }
/// }
/// ```
///
/// In this example, the `TokenAuthService` is a concrete class which conforms to the `TokenService`
/// protocol. When supplying the `resolver`, it is provided as the implementation and as a protocol
/// reference. This allows for any resources references to either the type or the protocol:
///
/// ```swift
/// @Resource var tokenService: TokenService
/// @Resource var authService: TokenAuthService
/// ```
///
/// Both resolve to the same instance.
public protocol ResourceSupplier {
    /// Supplies a collection of resources maintained by the supplier.
    ///
    /// - note: Invoked by the `ResourceCache`.
    func supply(cache: ResourceCache)
}
