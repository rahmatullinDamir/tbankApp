import UIKit
import SnapKit

protocol BudgetCategoryViewDelegate: AnyObject {
    func budgetCategoryView(_ view: BudgetCategoryView, didTapRemove category: String)
    func budgetCategoryViewDidTapAdd(_ view: BudgetCategoryView)
    func budgetCategoryViewDidTapEdit(_ view: BudgetCategoryView)
}

class BudgetCategoryView: UIView {
    private var withoutPlus = false
    private let defaultHeaderBackgroundColor = UIColor(hex: "#F2F2F2")
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = CGFloat.stackViewSpacing
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = defaultHeaderBackgroundColor
        view.layer.cornerRadius = LayoutConstants.defaultCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = CGFloat.stackViewSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = LayoutConstants.defaultCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.tiny.value)
        label.textColor = .black
        return label
    }()
    
    private lazy var percentageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.tiny.value)
        label.textColor = .black
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    
    private(set) var categoryTitle: String = ""
    private(set) var isActive: Bool = false
    private var categoryColor: UIColor = .systemGray4
    
    weak var delegate: BudgetCategoryViewDelegate?
    
    init(title: String, icon: String, withoutPlus: Bool = false) {
        super.init(frame: .zero)
        self.categoryTitle = title
        self.withoutPlus = withoutPlus
        setupUI(title: title, icon: icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String, icon: String) {
        addSubview(containerStack)
        
        headerView.addSubview(headerStack)
        
        headerStack.addArrangedSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        iconImageView.image = UIImage(systemName: icon)
        
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(percentageLabel)
        headerStack.addArrangedSubview(actionButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerViewTapped))
        headerView.addGestureRecognizer(tapGesture)
        headerView.isUserInteractionEnabled = true
        
        containerStack.addArrangedSubview(headerView)
        
        containerStack.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        
        headerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: Padding.tiny.value, bottom: 0, right: Padding.tiny.value))
        }
        
        headerView.snp.makeConstraints { make in
            make.height.equalTo(CGFloat.headerViewHeight)
        }
        
        iconContainer.snp.makeConstraints { make in
            make.width.height.equalTo(CGFloat.iconContainerWidth)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(CGFloat.iconImageWidth)
        }
        
        titleLabel.text = title
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        setActive(withoutPlus)
    }
    
    func setActive(_ active: Bool) {
        isActive = active
        
        if active {
            headerView.backgroundColor = categoryColor.withAlphaComponent(CGFloat.defaultAlphaComponent)
            iconImageView.tintColor = categoryColor
            if (!withoutPlus) {
                actionButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            }
        } else {
            if (!withoutPlus) {
                headerView.backgroundColor = defaultHeaderBackgroundColor
                iconImageView.tintColor = .systemGray3
                actionButton.setImage(UIImage(systemName: "plus"), for: .normal)
                percentageLabel.text = ""
            }
        }
    }
    
    func setCategoryColor(_ color: UIColor) {
        categoryColor = color
        if isActive {
            headerView.backgroundColor = color.withAlphaComponent(CGFloat.defaultAlphaComponent)
            iconImageView.tintColor = color
        }
    }
    
    func updatePercentage(_ percentage: Double) {
        if percentage > 0 {
            percentageLabel.text = "\(Int(percentage))%"
        } else {
            percentageLabel.text = ""
        }
    }
    
    @objc private func actionButtonTapped() {
        if isActive {
            delegate?.budgetCategoryView(self, didTapRemove: categoryTitle)
        } else {
            delegate?.budgetCategoryViewDidTapAdd(self)
        }
    }
    
    @objc private func headerViewTapped() {
        if isActive {
            delegate?.budgetCategoryViewDidTapEdit(self)
        }
    }
} 

private extension CGFloat {
    static let iconImageWidth: CGFloat = 16
    static let iconContainerWidth: CGFloat = 32
    static let headerViewHeight: CGFloat = 40
    static let stackViewSpacing: CGFloat = 8
    static let defaultAlphaComponent: CGFloat = 0.2
}
