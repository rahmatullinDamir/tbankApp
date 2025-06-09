import Foundation
 
enum ProfileViewState {
    case loading
    case content(UserDto)
    case error(String)
} 