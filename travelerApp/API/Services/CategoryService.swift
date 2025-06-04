import Foundation

protocol CategoryServicing {
    func getAllCategories() async throws -> CategoryListDto
    func getCategoryById(id: Int64) async throws -> CategoryDto
    func createCategory(_ category: CreateCategoryRequestDto) async throws -> CategoryDto
    func updateCategory(_ category: UpdateCategoryRequestDto) async throws -> CategoryDto
    func deleteCategory(id: Int64) async throws
}

final class CategoryService: CategoryServicing {
    private let networkService: NetworkServicing
    
    init(networkService: NetworkServicing = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func getAllCategories() async throws -> CategoryListDto {
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
} 