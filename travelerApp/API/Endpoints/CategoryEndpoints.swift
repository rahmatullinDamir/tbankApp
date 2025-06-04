import Foundation
import Alamofire

enum CategoryEndpoints {
    case getAllCategories
    case getCategoryById(id: Int64)
    case createCategory(CreateCategoryRequestDto)
    case updateCategory(UpdateCategoryRequestDto)
    case deleteCategory(id: Int64)
}

extension CategoryEndpoints: APIEndpoint {
    var path: String {
        switch self {
        case .getAllCategories:
            return "/categories"
        case .getCategoryById(let id):
            return "/categories/\(id)"
        case .createCategory:
            return "/categories"
        case .updateCategory:
            return "/categories"
        case .deleteCategory(let id):
            return "/categories/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAllCategories, .getCategoryById:
            return .get
        case .createCategory:
            return .post
        case .updateCategory:
            return .put
        case .deleteCategory:
            return .delete
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getAllCategories, .getCategoryById, .deleteCategory:
            return nil
        case .createCategory(let request):
            return try? request.asDictionary()
        case .updateCategory(let request):
            return try? request.asDictionary()
        }
    }
} 