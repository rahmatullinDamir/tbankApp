import Foundation

struct CategoryDto: Codable {
    let id: Int64?
    let name: String
    let description: String?
    let iconUrl: String?
    
    var color: String {
        return CategoryColors.color(from: name)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description, iconUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int64.self, forKey: .id)
        
        let rawName = try container.decode(String.self, forKey: .name)
        if let data = rawName.data(using: .utf8),
           let nameDict = try? JSONSerialization.jsonObject(with: data) as? [String: String],
           let extractedName = nameDict["name"] {
            name = extractedName
        } else {
            name = rawName
        }
        
        description = try container.decodeIfPresent(String.self, forKey: .description)
        iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
    }
    
    init(id: Int64? = nil, name: String, description: String? = nil, iconUrl: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.iconUrl = iconUrl
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        
        let nameDict = ["name": name]
        if let jsonData = try? JSONSerialization.data(withJSONObject: nameDict),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            try container.encode(jsonString, forKey: .name)
        } else {
            try container.encode(name, forKey: .name)
        }
        
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(iconUrl, forKey: .iconUrl)
    }
    
    static func formatCategoryName(_ name: String) -> String {
        let nameDict = ["name": name]
        if let jsonData = try? JSONSerialization.data(withJSONObject: nameDict),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return name
    }
}

struct CreateCategoryRequestDto: Codable {
    let name: String
    let description: String?
    let iconUrl: String?
    
    private enum CodingKeys: String, CodingKey {
        case name, description, iconUrl
    }
    
    init(name: String, description: String? = nil, iconUrl: String? = nil) {
        self.name = name
        self.description = description
        self.iconUrl = iconUrl
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let nameDict = ["name": name]
        if let jsonData = try? JSONSerialization.data(withJSONObject: nameDict),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            try container.encode(jsonString, forKey: .name)
        } else {
            try container.encode(name, forKey: .name)
        }
        
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(iconUrl, forKey: .iconUrl)
    }
}

struct UpdateCategoryRequestDto: Codable {
    let id: Int64
    let name: String
    let description: String?
    let iconUrl: String?
    private enum CodingKeys: String, CodingKey {
        case id, name, description, iconUrl
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        
        let nameDict = ["name": name]
        if let jsonData = try? JSONSerialization.data(withJSONObject: nameDict),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            try container.encode(jsonString, forKey: .name)
        } else {
            try container.encode(name, forKey: .name)
        }
        
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(iconUrl, forKey: .iconUrl)
    }
}

struct CategoryListDto: Codable {
    let categories: [CategoryDto]
    let totalCount: Int
} 
