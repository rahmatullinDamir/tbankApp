import XCTest
@testable import travelerApp

final class CreateTripValidatorTests: XCTestCase {
    var sut: CreateTripValidator!
    
    override func setUp() {
        super.setUp()
        sut = CreateTripValidator()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testValidate_WithValidData_ShouldReturnNil() {
        // Given
        var data = CreateTripData()
        data.name = "Test Trip"
        data.startDate = Date()
        data.endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        data.totalBudget = 1000
        data.categories = ["Food", "Hotels"]
        
        // When
        let result = sut.validate(data)
        
        // Then
        XCTAssertNil(result)
    }
    
    func testValidate_WithEmptyName_ShouldReturnError() {
        // Given
        var data = CreateTripData()
        data.name = ""
        data.startDate = Date()
        data.endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        data.totalBudget = 1000
        data.categories = ["Food", "Hotels"]
        
        // When
        let result = sut.validate(data)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "Название поездки не может быть пустым")
    }
    
    func testValidate_WithMissingStartDate_ShouldReturnError() {
        // Given
        var data = CreateTripData()
        data.name = "Test Trip"
        data.startDate = nil
        data.endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        data.totalBudget = 1000
        data.categories = ["Food", "Hotels"]
        
        // When
        let result = sut.validate(data)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "Выберите дату начала поездки")
    }
    
    func testValidate_WithEndDateBeforeStartDate_ShouldReturnError() {
        // Given
        var data = CreateTripData()
        data.name = "Test Trip"
        data.startDate = Date()
        data.endDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        data.totalBudget = 1000
        data.categories = ["Food", "Hotels"]
        
        // When
        let result = sut.validate(data)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "Дата окончания не может быть раньше даты начала")
    }
    
    func testValidate_WithNegativeBudget_ShouldReturnError() {
        // Given
        var data = CreateTripData()
        data.name = "Test Trip"
        data.startDate = Date()
        data.endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        data.totalBudget = -1000
        data.categories = ["Food", "Hotels"]
        
        // When
        let result = sut.validate(data)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "Бюджет должен быть больше 0")
    }
    
    func testValidate_WithEmptyCategories_ShouldReturnError() {
        // Given
        var data = CreateTripData()
        data.name = "Test Trip"
        data.startDate = Date()
        data.endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        data.totalBudget = 1000
        data.categories = []
        
        // When
        let result = sut.validate(data)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "Выберите хотя бы одну категорию")
    }
} 