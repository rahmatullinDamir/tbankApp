import Foundation

protocol CategoryServicing {
    func getAllCategories() async throws -> [CategoryDto]
    func getCategoryById(id: Int64) async throws -> CategoryDto
    func createCategory(_ category: CreateCategoryRequestDto) async throws -> CategoryDto
    func updateCategory(_ category: UpdateCategoryRequestDto) async throws -> CategoryDto
    func deleteCategory(id: Int64) async throws
    func findCategoryByName(_ name: String) async throws -> CategoryDto?
}

final class CategoryService: CategoryServicing {
    private let networkService: NetworkServicing
    
    init(networkService: NetworkServicing = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func getAllCategories() async throws -> [CategoryDto] {
        let endpoint = CategoryEndpoints.getAllCategories
        return try await networkService.request(endpoint)
    }
    
    func getCategoryById(id: Int64) async throws -> CategoryDto {
        let endpoint = CategoryEndpoints.getCategoryById(id: id)
        return try await networkService.request(endpoint)
    }
    
    func createCategory(_ category: CreateCategoryRequestDto) async throws -> CategoryDto {
        let endpoint = CategoryEndpoints.createCategory(category)
        return try await networkService.request(endpoint)
    }
    
    func updateCategory(_ category: UpdateCategoryRequestDto) async throws -> CategoryDto {
        let endpoint = CategoryEndpoints.updateCategory(category)
        return try await networkService.request(endpoint)
    }
    
    func deleteCategory(id: Int64) async throws {
        let endpoint = CategoryEndpoints.deleteCategory(id: id)
        try await networkService.request(endpoint)
    }
    
    func findCategoryByName(_ name: String) async throws -> CategoryDto? {
        let categories = try await getAllCategories()
        return categories.first { $0.name.lowercased() == name.lowercased() }
    }
} 