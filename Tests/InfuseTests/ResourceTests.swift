import XCTest
@testable import Infuse

/// Verify the behaviors and expectations of the `ResourceCache`, 
/// `ResourceSupplier`, and `Resource` property wrapper.
final class ResourceTests: XCTestCase {
    
    private let cache = ResourceCache()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        cache.configure(with: Supplier())
    }
    
    /// Verify that different types access the same underlying object.
    func testTypedResolver() {
        @Resource(cache: cache) var exampleService: ExampleService
        @Resource(cache: cache) var concreteService: ConcreteService
        
        XCTAssertEqual(exampleService.getData(), "Initial")
        concreteService.data = "Modified"
        XCTAssertEqual(concreteService.getData(), "Modified")
        XCTAssertEqual(exampleService.getData(), "Modified")
    }
    
    /// Verify that a resource can be dissolved and resolved upon next access.
    func testDependencyDissolve() {
        @Resource(cache: cache) var example1: ExampleService
        XCTAssertEqual(example1.getData(), "Initial")
        @Resource(cache: cache) var example2: ExampleService
        XCTAssertEqual(example2.getData(), "Initial")
        
        _example1.dissolve()
        cache.configure(with: Supplier(defaultData: "Re-supply"))
        
        XCTAssertEqual(example1.getData(), "Re-supply")
        XCTAssertEqual(example2.getData(), "Initial")
    }
}

private protocol ExampleService {
    func getData() -> String
}

private class ConcreteService: ExampleService {
    var data: String
    
    init(defaultData: String = "") {
        data = defaultData
    }
    
    func getData() -> String { data }
}

private class Supplier: ResourceSupplier {
    private let defaultData: String
    lazy var service = ConcreteService(defaultData: defaultData)
    
    init(defaultData: String = "Initial") {
        self.defaultData = defaultData
    }
    
    func supply(cache: ResourceCache) {
        cache.cache { self.service }
        cache.cache { self.service as ExampleService }
    }
}
