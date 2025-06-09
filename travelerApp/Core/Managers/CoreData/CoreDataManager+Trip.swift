import CoreData
import UIKit
import Foundation

extension CoreDataManager {
    func saveTrip(_ tripDto: TripDto) {
        let context = getContext()
        
        context.performAndWait {
            let trip = Trip(context: context)
            trip.id = tripDto.id
            trip.name = tripDto.name
            trip.createdDate = tripDto.createdDate
            trip.startDate = tripDto.startDate
            trip.endDate = tripDto.endDate
            trip.totalBudget = tripDto.totalBudget
            trip.status = tripDto.status.rawValue
            trip.participantsCount = Int16(tripDto.participantsCount ?? 0)
            trip.spentAmount = tripDto.spentAmount ?? 0.0
            
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %lld", tripDto.creator.id)
            
            let creator: User
            if let existingUser = try? context.fetch(fetchRequest).first {
                creator = existingUser
            } else {
                creator = User(context: context)
                creator.id = tripDto.creator.id
                creator.firstName = tripDto.creator.firstName
                creator.lastName = tripDto.creator.lastName
                creator.phoneNumber = tripDto.creator.phoneNumber
            }
            
            trip.creator = creator
            
            do {
                try context.save()
            } catch {
                print("Error saving trip: \(error)")
            }
        }
    }
    
    func fetchTrips(with status: TripStatus? = nil) -> [TripDto] {
        let context = getContext()
        var trips: [TripDto] = []
        
        context.performAndWait {
            let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
            
            if let status = status {
                fetchRequest.predicate = NSPredicate(format: "status == %@", status.rawValue)
            }
            
            do {
                let fetchedTrips = try context.fetch(fetchRequest)
                trips = fetchedTrips.compactMap { trip in
                    guard let name = trip.name,
                          let status = trip.status,
                          let creator = trip.creator,
                          let createdDate = trip.createdDate,
                          let startDate = trip.startDate,
                          let userDto = convertToUserDto(creator) else {
                        return nil
                    }
                    
                    let jsonString = """
                    {
                        "id": \(trip.id),
                        "name": "\(name)",
                        "creator": {
                            "id": \(userDto.id),
                            "firstName": "\(userDto.firstName)",
                            "lastName": "\(userDto.lastName)",
                            "phoneNumber": "\(userDto.phoneNumber)"
                        },
                        "createdDate": "\(createdDate.apiFormatted)",
                        "startDate": "\(startDate.apiFormatted)",
                        "endDate": \(trip.endDate != nil ? "\"\(trip.endDate!.apiFormatted)\"" : "null"),
                        "totalBudget": \(trip.totalBudget),
                        "status": "\(status)"
                    }
                    """
                    
                    guard let jsonData = jsonString.data(using: .utf8) else { return nil }
                    
                    do {
                        var tripDto = try JSONDecoder().decode(TripDto.self, from: jsonData)
                        tripDto.participantsCount = Int(trip.participantsCount)
                        tripDto.spentAmount = trip.spentAmount
                        return tripDto
                    } catch {
                        print("Error decoding trip: \(error)")
                        return nil
                    }
                }
            } catch {
                print("Error fetching trips: \(error)")
            }
        }
        
        return trips
    }
} 
