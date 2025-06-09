import CoreData
import UIKit
import Foundation

extension CoreDataManager {
    func saveExpense(_ expenseDto: ExpenseDto, for tripId: Int64) {
        let expense = Expense(context: getContext())
        expense.id = expenseDto.id ?? 0
        expense.amount = expenseDto.amount
        expense.expenseDescription = expenseDto.description
        expense.status = expenseDto.status.rawValue
        expense.payerId = expenseDto.payerId ?? 0
        expense.phoneNumbersOfDebtors = expenseDto.phoneNumbersOfDebtors
        expense.date = expenseDto.date
        
        let tripFetch: NSFetchRequest<Trip> = Trip.fetchRequest()
        tripFetch.predicate = NSPredicate(format: "id == %lld", tripId)
        
        if let trip = try? getContext().fetch(tripFetch).first {
            expense.trip = trip
        }
        
        let categoryFetch: NSFetchRequest<Category> = Category.fetchRequest()
        categoryFetch.predicate = NSPredicate(format: "id == %lld", expenseDto.categoryId)
        
        if let category = try? getContext().fetch(categoryFetch).first {
            expense.category = category
        }
        
        saveContext()
    }
    
    func fetchExpenses(for tripId: Int64, status: ExpenseStatus? = nil) -> [ExpenseDto] {
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        var predicates: [NSPredicate] = [NSPredicate(format: "trip.id == %lld", tripId)]
        
        if let status = status {
            predicates.append(NSPredicate(format: "status == %@", status.rawValue))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
            let expenses = try getContext().fetch(fetchRequest)
            return expenses.compactMap { expense in
                guard let status = expense.status,
                      let date = expense.date else {
                    return ExpenseDto(
                        id: expense.id,
                        categoryId: expense.category?.id ?? 0,
                        amount: expense.amount,
                        description: expense.expenseDescription,
                        status: .PLANNED,
                        payerId: expense.payerId,
                        phoneNumbersOfDebtors: expense.phoneNumbersOfDebtors ?? [],
                        date: Date()
                    )
                }
                
                return ExpenseDto(
                    id: expense.id,
                    categoryId: expense.category?.id ?? 0,
                    amount: expense.amount,
                    description: expense.expenseDescription,
                    status: ExpenseStatus(rawValue: status) ?? .PLANNED,
                    payerId: expense.payerId,
                    phoneNumbersOfDebtors: expense.phoneNumbersOfDebtors ?? [],
                    date: date
                )
            }
        } catch {
            print("Error fetching expenses: \(error)")
            return []
        }
    }
} 
