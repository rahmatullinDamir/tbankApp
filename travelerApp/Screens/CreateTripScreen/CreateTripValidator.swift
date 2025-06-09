import Foundation

protocol CreateTripValidating {
    func validate(name: String?) -> String?
    func validate(startDate: Date?) -> String?
    func validate(endDate: Date?, startDate: Date?) -> String?
    func validate(budget: Double) -> String?
    func validate(categories: [TripBudgetCategory]) -> String?
    func validate(_ data: CreateTripData) -> String?
}

struct CreateTripValidator: CreateTripValidating {
    func validate(name: String?) -> String? {
        guard let name = name, !name.isEmpty else {
            return "Название поездки не может быть пустым"
        }
        
        if name.count < 3 || name.count > 50 {
            return "Название должно быть от 3 до 50 символов"
        }
        
        return nil
    }
    
    func validate(startDate: Date?) -> String? {
        guard let startDate = startDate else {
            return "Выберите дату начала поездки"
        }
        
        if startDate < Date().startOfDay() {
            return "Дата начала не может быть в прошлом"
        }
        
        return nil
    }
    
    func validate(endDate: Date?, startDate: Date?) -> String? {
        guard let endDate = endDate else {
            return "Выберите дату окончания поездки"
        }
        
        guard let startDate = startDate else {
            return "Сначала выберите дату начала поездки"
        }
        
        if endDate < startDate {
            return "Дата окончания не может быть раньше даты начала"
        }
        
        return nil
    }
    
    func validate(budget: Double) -> String? {
        if budget <= 0 {
            return "Бюджет должен быть больше 0"
        }
        
        if budget > 999999999 {
            return "Слишком большая сумма"
        }
        
        return nil
    }
    
    func validate(categories: [TripBudgetCategory]) -> String? {
        if categories.isEmpty {
            return "Добавьте хотя бы одну категорию"
        }
        
        let totalPercentage = categories.reduce(0.0) { $0 + $1.percentage }
        if totalPercentage > 100 {
            return "Общий процент категорий не может превышать 100%"
        }
        
        return nil
    }
    
    func validate(_ data: CreateTripData) -> String? {
        if let nameError = validate(name: data.name) {
            return nameError
        }
        
        if let startDateError = validate(startDate: data.startDate) {
            return startDateError
        }
        
        if let endDateError = validate(endDate: data.endDate, startDate: data.startDate) {
            return endDateError
        }
        
        if let budget = data.totalBudget, let budgetError = validate(budget: Double(budget)) {
            return budgetError
        }
        
        if data.categories.isEmpty {
            return "Выберите хотя бы одну категорию"
        }
        
        return nil
    }
}

private extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
}
