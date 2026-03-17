@testable import Infuse
import Testing

/// Verify the behaviors and expectations of the `ResourceCache`,
/// `ResourceSupplier`, and `Resource` property wrapper.
struct ResourceTests {

    private protocol ExampleService {
        func getData() -> String
    }

    private class ConcreteService: ExampleService {
        var data: String

        init(defaultData: String = "") {
            data = defaultData
        }

        func getData() -> String {
            data
        }
    }

    private class Supplier: ResourceSupplier {
        private let defaultData: String
        lazy var service = ConcreteService(defaultData: defaultData)

        init(defaultData: String = "Initial") {
            self.defaultData = defaultData
        }

        func supply(cache: ResourceCache) {
            cache.cache { self.service }
            cache.cache { self.service as any ExampleService }
        }
    }

    /// Verify that different types access the same underlying object.
    @Test func `typed resolver`() {
        let cache = ResourceCache()
        cache.configure(with: Supplier())

        @Resource(cache: cache) var exampleService: any ExampleService
        @Resource(cache: cache) var concreteService: ConcreteService

        #expect(exampleService.getData() == "Initial")
        concreteService.data = "Modified"
        #expect(concreteService.getData() == "Modified")
        #expect(exampleService.getData() == "Modified")
    }

    /// Verify that a resource can be dissolved and resolved upon next access.
    @Test func `dependency dissolve`() {
        let cache = ResourceCache()
        cache.configure(with: Supplier())

        @Resource(cache: cache) var example1: any ExampleService
        #expect(example1.getData() == "Initial")
        @Resource(cache: cache) var example2: any ExampleService
        #expect(example2.getData() == "Initial")

        _example1.dissolve()
        cache.configure(with: Supplier(defaultData: "Re-supply"))

        #expect(example1.getData() == "Re-supply")
        #expect(example2.getData() == "Initial")
    }
}
