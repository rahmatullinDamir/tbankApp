import UIKit
import Combine

class TripDetailsViewController: UIViewController {
    private var viewModel: any TripDetailsViewModelling
    private var cancellables = Set<AnyCancellable>()
    private var categoryViews: [BudgetCategoryView] = []
    private let categoriesPerRow = 2
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dateRangeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.regular.value)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var participantsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.regular.value)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var pieChartView: BudgetPieChartView = {
        let view = BudgetPieChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var categoriesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = CGFloat.stackViewSpacing
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var expensesLabel: UILabel = {
        let label = UILabel()
        label.text = "Расходы"
        label.font = UIFont(name: FontFamilies.robotoBold.value, size: FontConstants.title.value)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var expensesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = CGFloat.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var addExpenseButton: CustomActionButton = {
        let button = CustomActionButton(title: "")
        button.layer.cornerRadius = CGFloat.butonCornerRadius
        button.clipsToBounds = true
        
        let plusImage = UIImage(systemName: "plus")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: CGFloat.pointSize, weight: .bold)
        )
        button.setImage(plusImage, for: .normal)
        button.tintColor = .black
        
        let action = UIAction { [weak self] _ in
            self?.viewModel.trigger(.addExpense)
        }
        button.addAction(action, for: .touchUpInside)
        button.isEnabled = true
        button.alpha = 1.0
        return button
    }()
    
    init(viewModel: any TripDetailsViewModelling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        refreshData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(dateRangeLabel)
        contentView.addSubview(participantsLabel)
        contentView.addSubview(pieChartView)
        contentView.addSubview(categoriesStackView)
        contentView.addSubview(expensesLabel)
        contentView.addSubview(expensesStackView)
        view.addSubview(addExpenseButton)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
    
        dateRangeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Padding.default.value)
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
        }
        
        participantsLabel.snp.makeConstraints { make in
            make.top.equalTo(dateRangeLabel.snp.bottom).offset(Padding.tiny.value)
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
        }
        
        pieChartView.snp.makeConstraints { make in
            make.top.equalTo(participantsLabel.snp.bottom).offset(Padding.middle.value)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(CGFloat.pieChartViewHeight)
        }
        
        categoriesStackView.snp.makeConstraints { make in
            make.top.equalTo(pieChartView.snp.bottom).offset(Padding.middle.value)
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
        }
        
        expensesLabel.snp.makeConstraints { make in
            make.top.equalTo(categoriesStackView.snp.bottom).offset(Padding.big.value)
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
        }
        
        expensesStackView.snp.makeConstraints { make in
            make.top.equalTo(expensesLabel.snp.bottom).offset(Padding.default.value)
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
            make.bottom.equalToSuperview().offset(-CGFloat.expensesStackViewBottomOffset)
        }
        
        addExpenseButton.snp.makeConstraints { make in
            make.width.height.equalTo(CGFloat.addExpenseButtonWidth)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Padding.default.value)
        }
    }
    
    private func setupBindings() {
        viewModel.tripDetailsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] details in
                self?.updateUI(with: details)
            }
            .store(in: &cancellables)
            
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                let alert = UIAlertController(
                    title: "Ошибка",
                    message: error,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with details: TripDetailsViewData) {
        dateRangeLabel.text = details.dateRange
        participantsLabel.text = "👤 \(details.participantsCount)"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        
        let totalAmount = formatter.string(from: NSNumber(value: details.totalBudget)) ?? "0"
        let spentAmount = formatter.string(from: NSNumber(value: details.spentAmount)) ?? "0"
        
        pieChartView.setAmounts(
            total: "\(totalAmount) ₽",
            spent: "Потрачено: \(spentAmount) ₽"
        )
        
        updateCategories(with: details.categories)
        updatePieChart(with: details.categories)
        updateExpenses(with: details.expenses)
    }
    
    private func updateCategories(with categories: [TripCategoryDetails]) {
        categoryViews.forEach { $0.removeFromSuperview() }
        categoryViews.removeAll()
        categoriesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for i in stride(from: 0, to: categories.count, by: categoriesPerRow) {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = CGFloat.stackViewSpacing
            categoriesStackView.addArrangedSubview(rowStackView)
            
            for cat in i..<min(i + categoriesPerRow, categories.count) {
                let category = categories[cat]
                let categoryView = BudgetCategoryView(title: category.name, icon: category.icon, withoutPlus: true)
                categoryView.translatesAutoresizingMaskIntoConstraints = false
                categoryView.setCategoryColor(UIColor(hex: category.color))
                categoryView.updatePercentage(category.percentage)
                categoryViews.append(categoryView)
                rowStackView.addArrangedSubview(categoryView)
            }
            
            let remainingInRow = categoriesPerRow - (categories.count - i)
            if remainingInRow > 0 && remainingInRow < categoriesPerRow {
                let placeholderView = UIView()
                placeholderView.translatesAutoresizingMaskIntoConstraints = false
                rowStackView.addArrangedSubview(placeholderView)
            }
        }
    }
    
    private func updatePieChart(with categories: [TripCategoryDetails]) {
        let totalTripBudget = categories.reduce(0) { $0 + $1.plannedAmount }
        
        let segments = categories.map { category -> (color: UIColor, percentage: CGFloat) in
            let color = UIColor(hex: category.color)
            let amount = category.amount
            let budgetPercentage = totalTripBudget > 0 ? (amount / totalTripBudget) * 100 : 0
            return (color, CGFloat(budgetPercentage))
        }
        
        let totalPercentage = segments.reduce(0) { $0 + $1.percentage }
        
        var updatedSegments = segments
        
        if totalPercentage < 100 {
            updatedSegments.append((
                UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1),
                100 - totalPercentage
            ))
        }
        
        pieChartView.updateSegments(updatedSegments)
    }
    
    private func updateExpenses(with expenses: [ExpenseDto]) {
        expensesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        expenses.filter { $0.status == .ACTUAL }.forEach { expense in
            let expenseView = createExpenseView(for: expense)
            expensesStackView.addArrangedSubview(expenseView)
        }
    }
    
    private func createExpenseView(for expense: ExpenseDto) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .black
        iconView.contentMode = .scaleAspectFit
        
        if let categoryIcon = getCategoryIcon(for: expense.categoryId) {
            iconView.image = UIImage(systemName: categoryIcon)
        }
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = expense.description
        descriptionLabel.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.regular.value)
        
        let payerLabel = UILabel()
        payerLabel.translatesAutoresizingMaskIntoConstraints = false
        payerLabel.text = getPayerName(for: expense.payerId)
        payerLabel.font =  UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.tiny.value)

        payerLabel.textColor = .gray
        
        let amountLabel = UILabel()
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        let formattedAmount = formatter.string(from: NSNumber(value: expense.amount)) ?? "0"
        amountLabel.text = "-\(formattedAmount) ₽"
        amountLabel.font =  UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.regular.value)
        amountLabel.textAlignment = .right
        
        containerView.addSubview(iconView)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(payerLabel)
        containerView.addSubview(amountLabel)
        
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(CGFloat.iconViewWidthHeight)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(Padding.default.value)
            make.top.equalToSuperview().offset(Padding.small.value)
        }
        
        payerLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(Padding.default.value)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(Padding.small.value)
            make.bottom.equalToSuperview().offset(-Padding.small.value)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(descriptionLabel.snp.trailing).offset(Padding.default.value)
        }
        
        return containerView
    }
    
    private func getCategoryIcon(for categoryId: Int64) -> String? {
        return CategoryIcon.from(categoryId: categoryId).rawValue
    }
    
    private func getPayerName(for payerId: Int64?) -> String {
        return viewModel.getPayerName(for: payerId) ?? "Unknown"
    }
    
    private func refreshData() {
        viewModel.trigger(.onDidLoad)
    }
}

extension TripDetailsViewController: TripDetailsViewModelDelegate {
    func tripDetailsViewModelDidFinish() {
        navigationController?.popViewController(animated: true)
    }
    
    func tripDetailsViewModelDidRequestAddExpense(_ tripId: Int64) {
        let moduleFactory = ModuleFactory()
        let viewController = moduleFactory.makeExpenseAddModule(coordinator: self, tripId: tripId, title: "Добавить расход")
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension TripDetailsViewController: ExpenseAddViewModelDelegate {
    func expenseAddViewModelDidFinish() {
        navigationController?.popViewController(animated: true)
        refreshData()
    }
} 
 
private extension CGFloat {
    static let stackViewSpacing: CGFloat = 16
    static let butonCornerRadius: CGFloat = 30
    static let pointSize: CGFloat = 24
    static let pieChartViewHeight: CGFloat = 300
    static let expensesStackViewBottomOffset: CGFloat = 100
    static let addExpenseButtonWidth: CGFloat = 60
    static let iconViewWidthHeight: CGFloat = 24
}
