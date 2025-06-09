import UIKit
import Combine
import SnapKit

class BudgetDistributionViewController: UIViewController {
    private var viewModel: any BudgetDistributionViewModelling
    private var cancellables = Set<AnyCancellable>()
    private var categoryViews: [BudgetCategoryView] = []
    private let categoriesPerRow = Int.categoriesPerRow
    
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
    
    private lazy var categoriesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = CGFloat.stackViewSpacing
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var createTripButton: CustomActionButton = {
        let button = CustomActionButton(title: "Создать поездку")
        let action = UIAction { [weak self] _ in
            self?.viewModel.trigger(.createTrip)
        }
        button.addAction(action, for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var pieChartView: BudgetPieChartView = {
        let view = BudgetPieChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var sliderContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var currentSliderView: BudgetSliderView?
    private var activeCategory: String?
    
    init(viewModel: any BudgetDistributionViewModelling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupCategories()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(pieChartView)
        contentView.addSubview(categoriesStackView)
        contentView.addSubview(sliderContainerView)
        view.addSubview(createTripButton)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(createTripButton.snp.top).offset(-Padding.default.value)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        pieChartView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Padding.default.value)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(CGFloat.pieChartViewHeight)
        }
        
        categoriesStackView.snp.makeConstraints { make in
            make.top.equalTo(pieChartView.snp.bottom).offset(Padding.middle.value)
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.trailing.equalToSuperview().offset(-Padding.default.value)
        }
        
        sliderContainerView.snp.makeConstraints { make in
            make.top.equalTo(categoriesStackView.snp.bottom).offset(Padding.middle.value)
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.trailing.equalToSuperview().offset(-Padding.default.value)
            make.height.equalTo(CGFloat.sliderContainerViewHeight)
            make.bottom.equalToSuperview().offset(-Padding.default.value)
        }
        
        createTripButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.trailing.equalToSuperview().offset(-Padding.default.value)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Padding.default.value)
        }
    }
    
    private func setupCategories() {
        categoryViews.forEach { $0.removeFromSuperview() }
        categoryViews.removeAll()
        categoriesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let categories = viewModel.defaultCategories
        
        for i in stride(from: 0, to: categories.count, by: categoriesPerRow) {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = CGFloat.stackViewSpacing
            categoriesStackView.addArrangedSubview(rowStackView)
            
            for cat in i..<min(i + categoriesPerRow, categories.count) {
                let category = categories[cat]
                let categoryView = BudgetCategoryView(title: category.title, icon: category.icon)
                categoryView.delegate = self
                categoryView.translatesAutoresizingMaskIntoConstraints = false
                categoryView.setCategoryColor(category.color)
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
    
    private func setupBindings() {
        viewModel.totalBudgetPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] budget in
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.groupingSeparator = " "
                formatter.maximumFractionDigits = 0
                
                let formattedBudget = formatter.string(from: NSNumber(value: budget)) ?? "0"
                self?.pieChartView.setAmounts(total: "\(formattedBudget) ₽", spent: "")
                self?.currentSliderView?.updateTotalBudget(Double(budget))
            }
            .store(in: &cancellables)
            
        viewModel.categoryPercentagesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updatePieChart()
            }
            .store(in: &cancellables)
            
        viewModel.isReadyToProceedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isReady in
                self?.createTripButton.isEnabled = isReady
                self?.createTripButton.alpha = isReady ? 1.0 : 0.5
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
    
    private func getCategoryColor(_ category: String) -> UIColor {
        return UIColor(hex: CategoryColors.color(from: category))
    }
    
    private func updatePieChart() {
        var segments = viewModel.selectedCategories.compactMap { category -> (color: UIColor, percentage: CGFloat)? in
            guard let percentage = viewModel.categoryPercentages[category] else { return nil }
            let color = getCategoryColor(category)
            
            if let categoryView = categoryViews.first(where: { $0.categoryTitle == category }) {
                categoryView.updatePercentage(percentage)
            }
            
            return (color, CGFloat(percentage))
        }
        
        let remainingPercentage = 100 - viewModel.totalPercentage
        if remainingPercentage > 0 {
            segments.append((UIColor(hex: "#F2F2F2"),
                             percentage: CGFloat(remainingPercentage)))
        }
        
        pieChartView.updateSegments(segments)
    }
    
    private func showSlider(for category: String, color: UIColor) {
        currentSliderView?.removeFromSuperview()
        
        let sliderView = BudgetSliderView(color: color, totalBudget: Double(viewModel.totalBudget))
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.delegate = self
        
        let maxAllowed = viewModel.getMaxAllowedPercentage(for: category)
        sliderView.setMaxAllowedValue(maxAllowed)
        
        if let percentage = viewModel.categoryPercentages[category] {
            sliderView.setValue(percentage)
        } else {
            sliderView.setValue(0)
        }
        
        sliderContainerView.addSubview(sliderView)
        
        sliderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(CGFloat.sliderContainerViewHeight)
        }
        
        currentSliderView = sliderView
        activeCategory = category
        
        sliderContainerView.layoutIfNeeded()
    }
    
    private func hideSlider() {
        currentSliderView?.removeFromSuperview()
        currentSliderView = nil
        activeCategory = nil
        sliderContainerView.layoutIfNeeded()
    }
}

extension BudgetDistributionViewController: BudgetCategoryViewDelegate {
    func budgetCategoryView(_ view: BudgetCategoryView, didTapRemove category: String) {
        viewModel.trigger(.toggleCategory(category))
        view.setActive(false)
        if category == activeCategory {
            hideSlider()
        }
        updatePieChart()
    }
    
    func budgetCategoryViewDidTapAdd(_ view: BudgetCategoryView) {
        let color = getCategoryColor(view.categoryTitle)
        viewModel.trigger(.toggleCategory(view.categoryTitle))
        view.setActive(true)
        showSlider(for: view.categoryTitle, color: color)
        updatePieChart()
    }
    
    func budgetCategoryViewDidTapEdit(_ view: BudgetCategoryView) {
        let color = getCategoryColor(view.categoryTitle)
        showSlider(for: view.categoryTitle, color: color)
    }
}

extension BudgetDistributionViewController: BudgetSliderViewDelegate {
    func budgetSliderView(_ view: BudgetSliderView, didUpdateValue value: Double) {
        guard let category = activeCategory else { return }
        
        let maxAllowed = viewModel.getMaxAllowedPercentage(for: category)
        let clampedValue = min(value, maxAllowed)

        viewModel.trigger(.updatePercentage(category: category, value: clampedValue))
        
        if let categoryView = categoryViews.first(where: { $0.categoryTitle == category }) {
            categoryView.updatePercentage(clampedValue)
        }
        updatePieChart()
    }
}

extension BudgetDistributionViewController: BudgetDistributionViewModelDelegate {
    func budgetDistributionViewModelDidFinish(_ trip: TripDto) {
        DispatchQueue.main.async { [weak self] in
            if let navigationController = self?.navigationController {
                navigationController.popToRootViewController(animated: true)
            }
        }
    }
} 


private extension CGFloat {
    static let stackViewSpacing: CGFloat = 16
    static let pieChartViewHeight: CGFloat = 300
    static let sliderContainerViewHeight: CGFloat = 80
}

private extension Int {
    static let categoriesPerRow: Int = 2
}
