//
//  NotificationModels.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 9.06.25.
//

import Foundation
import UIKit

struct NotificationDto: Codable {
    let id: Int64
    let message: String
    let tripId: Int64
    let tripName: String
    let type: String?
    let timestamp: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case message
        case tripId
        case tripName
        case type
        case timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        message = try container.decode(String.self, forKey: .message)
        tripId = try container.decode(Int64.self, forKey: .tripId)
        tripName = try container.decode(String.self, forKey: .tripName)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        
        let timestampString = try container.decode(String.self, forKey: .timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = formatter.date(from: timestampString) {
            timestamp = date
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .timestamp,
                in: container,
                debugDescription: "Failed to parse date: \(timestampString)"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(message, forKey: .message)
        try container.encode(tripId, forKey: .tripId)
        try container.encode(tripName, forKey: .tripName)
        try container.encodeIfPresent(type, forKey: .type)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        try container.encode(formatter.string(from: timestamp), forKey: .timestamp)
    }
}

struct MarkNotificationsReadRequest: Codable {
    let notificationIds: [Int64]
}

enum NotificationType {
    case payment
    case info
    case system
    case invitation
    
    var icon: String {
        switch self {
        case .payment:
            return NotificationIcons.forkKnife
        case .info:
            return NotificationIcons.infoCircle
        case .system:
            return NotificationIcons.star
        case .invitation:
            return NotificationIcons.person
        }
    }
    
    var color: UIColor {
        switch self {
        case .payment:
            return NotificationColors.green
        case .info:
            return NotificationColors.yellow
        case .system:
            return NotificationColors.gray
        case .invitation:
            return NotificationColors.yellow
        }
    }
}

struct NotificationItem {
    let id: Int64
    let type: NotificationType
    let description: String
    let participants: String
    let amount: Double?
    let date: Date
    let tripId: Int64
    
    var formattedAmount: String? {
        guard let amount = amount else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)).map { "\($0) ₽" }
    }
    
    var isInvitation: Bool {
        type == .invitation
    }
} 
