import UIKit
import Combine
import SnapKit

class TripCategoriesViewController: UIViewController {
    private var viewModel: any TripDetailsViewModelling
    private var cancellables = Set<AnyCancellable>()
    
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
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(categoriesStackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        categoriesStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Padding.default.value)
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
            make.bottom.equalToSuperview().offset(-Padding.default.value)
        }
    }
    
    private func setupBindings() {
        viewModel.tripDetailsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] details in
                self?.updateCategories(with: details.categories)
            }
            .store(in: &cancellables)
    }
    
    private func updateCategories(with categories: [TripCategoryDetails]) {
        categoriesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        
        for category in categories {
            let categoryView = createCategoryView(for: category, formatter: formatter)
            categoriesStackView.addArrangedSubview(categoryView)
        }
    }
    
    private func createCategoryView(for category: TripCategoryDetails, formatter: NumberFormatter) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleStackView = UIStackView()
        titleStackView.axis = .horizontal
        titleStackView.spacing = CGFloat.titleStackViewSpacing
        titleStackView.alignment = .center
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor(hex: category.color)
        iconImageView.image = UIImage(systemName: category.icon)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = category.name
        titleLabel.font = UIFont(name: FontFamilies.robotoBold.value, size: FontConstants.title.value)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleStackView.addArrangedSubview(iconImageView)
        titleStackView.addArrangedSubview(titleLabel)
        
        let amountStackView = UIStackView()
        amountStackView.axis = .vertical
        amountStackView.spacing = CGFloat.amountStackViewSpacing
        amountStackView.alignment = .trailing
        amountStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let actualAmountLabel = UILabel()
        let formattedActualAmount = formatter.string(from: NSNumber(value: category.amount)) ?? "0"
        actualAmountLabel.text = "Потрачено: \(formattedActualAmount) ₽"
        actualAmountLabel.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.default.value)
        actualAmountLabel.textAlignment = .right
        
        let plannedAmountLabel = UILabel()
        let formattedPlannedAmount = formatter.string(from: NSNumber(value: category.plannedAmount)) ?? "0"
        plannedAmountLabel.text = "План: \(formattedPlannedAmount) ₽"
        plannedAmountLabel.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        plannedAmountLabel.textAlignment = .right
        plannedAmountLabel.textColor = .gray
        
        amountStackView.addArrangedSubview(plannedAmountLabel)
        amountStackView.addArrangedSubview(actualAmountLabel)
        
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = Float(category.percentage / 100)
        progressView.progressTintColor = UIColor(hex: category.color)
        progressView.trackTintColor = UIColor(hex: category.color).withAlphaComponent(CGFloat.defaultAlpha)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleStackView)
        containerView.addSubview(amountStackView)
        containerView.addSubview(progressView)
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(CGFloat.defaultImageWidthAndHeight)
        }
        
        titleStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(Padding.default.value)
        }
        
        amountStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(titleStackView)
            make.leading.greaterThanOrEqualTo(titleStackView.snp.trailing).offset(Padding.default.value)
        }
        
        progressView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleStackView.snp.bottom).offset(Padding.default.value)
            make.bottom.equalToSuperview().offset(-Padding.default.value)
            make.height.equalTo(Padding.tiny.value)
        }
        
        return containerView
    }
} 

private extension CGFloat {
    static let stackViewSpacing: CGFloat = 24
    static let titleStackViewSpacing: CGFloat = 12
    static let amountStackViewSpacing: CGFloat = 8
    static let defaultAlpha: CGFloat = 0.02
    static let defaultImageWidthAndHeight: CGFloat = 32
}
