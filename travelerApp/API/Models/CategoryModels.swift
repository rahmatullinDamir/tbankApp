import Foundation

struct CategoryDto: Codable {
    let id: Int64?
    let name: String
    let description: String?
    let iconUrl: String?
}

struct CreateCategoryRequestDto: Codable {
    let name: String
    let description: String?
    let iconUrl: String?
}

struct UpdateCategoryRequestDto: Codable {
    let id: Int64
    let name: String
    let description: String?
    let iconUrl: String?
}

struct CategoryListDto: Codable {
    let categories: [CategoryDto]
    let totalCount: Int
} 