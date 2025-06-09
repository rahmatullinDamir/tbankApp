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
            return NetworkConstants.apiPath + "/category"
        case .getCategoryById(let id):
            return NetworkConstants.apiPath + "/category/\(id)"
        case .createCategory:
            return NetworkConstants.apiPath + "/category"
        case .updateCategory:
            return NetworkConstants.apiPath + "/category"
        case .deleteCategory(let id):
            return NetworkConstants.apiPath + "/category/\(id)"
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
            return [
                "name": request.name
            ]
        case .updateCategory(let request):
            return [
                "id": request.id,
                "name": request.name
            ]
        }
    }
} 