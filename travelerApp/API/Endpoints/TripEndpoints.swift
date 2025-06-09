import Foundation
import Alamofire

enum TripEndpoints {
    case getAllTrips(status: TripStatus?)
    case getTrip(id: Int64)
    case createTrip(trip: TripCreateDto)
    case updateTripStatus(id: Int64, status: TripStatus)
    case deleteTrip(id: Int64)
    case getParticipants(tripId: Int64)
    case addParticipant(tripId: Int64, participant: ParticipantAddDeleteDto)
    case deleteParticipant(tripId: Int64, participant: ParticipantAddDeleteDto)
}

extension TripEndpoints: APIEndpoint {
    var path: String {
        switch self {
        case .getAllTrips:
            return NetworkConstants.apiPath + "/trip"
        case .getTrip(let id), .updateTripStatus(let id, _), .deleteTrip(let id):
            return NetworkConstants.apiPath + "/trip/\(id)"
        case .createTrip:
            return NetworkConstants.apiPath + "/trip"
        case .getParticipants(let tripId), .addParticipant(let tripId, _), .deleteParticipant(let tripId, _):
            return NetworkConstants.apiPath + "/trip/\(tripId)/participants"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAllTrips, .getTrip, .getParticipants:
            return .get
        case .createTrip, .addParticipant:
            return .post
        case .updateTripStatus:
            return .patch
        case .deleteTrip, .deleteParticipant:
            return .delete
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getAllTrips(let status):
            var params: [String: Any] = [:]
            if let status = status {
                params["status"] = status.rawValue
            }
            return params
            
        case .createTrip(let trip):
            var params: [String: Any] = [
                "name": trip.name,
                "startDate": trip.startDate.apiFormatted,
                "endDate": trip.endDate?.apiFormatted ?? trip.startDate.apiFormatted,
                "participants": trip.participants ?? [],
                "totalBudget": trip.totalBudget ?? 0.0
            ]
            
            if let createdDate = trip.createdDate {
                params["createdDate"] = createdDate.apiFormatted
            }
            
            print("Trip creation parameters: \(params)")
            return params
            
        case .updateTripStatus(_, let status):
            return ["status": status.rawValue]
            
        case .addParticipant(_, let participant), .deleteParticipant(_, let participant):
            return try? participant.asDictionary()
            
        case .getTrip, .deleteTrip, .getParticipants:
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .createTrip, .addParticipant:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
} 
 
