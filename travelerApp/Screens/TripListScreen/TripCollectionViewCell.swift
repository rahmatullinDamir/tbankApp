import UIKit
import SnapKit
import SkeletonView

class TripCollectionViewCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = LayoutConstants.defaultCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = LayoutConstants.defaultCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let expensesContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = LayoutConstants.defaultCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let addExpenseContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = LayoutConstants.defaultCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.title.value)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateAndParticipantsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.regular.value)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let budgetLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.title.value)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expensesLabel: UILabel = {
        let label = UILabel()
        label.text = "Траты"
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.regular.value)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expensesAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.regular.value)
        label.textColor = .systemGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .bar)
        view.trackTintColor = .systemGray6
        view.progressTintColor = UIColor(hex: CustomColors.yellow.value)
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let addExpenseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавьте расходы", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.regular.value)
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupSkeletonViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(headerContainerView)
        headerContainerView.addSubview(nameLabel)
        headerContainerView.addSubview(dateAndParticipantsLabel)
        headerContainerView.addSubview(budgetLabel)
        
        containerView.addSubview(expensesContainerView)
        expensesContainerView.addSubview(expensesLabel)
        expensesContainerView.addSubview(expensesAmountLabel)
        expensesContainerView.addSubview(progressView)
        
        containerView.addSubview(addExpenseContainerView)
        addExpenseContainerView.addSubview(addExpenseButton)
        addExpenseContainerView.addSubview(chevronImageView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        headerContainerView.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(Padding.tiny.value)
            make.leading.equalTo(containerView).offset(Padding.tiny.value)
            make.trailing.equalTo(containerView).offset(-Padding.tiny.value)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(headerContainerView).offset(Padding.middle.value)
            make.leading.equalTo(headerContainerView).offset(Padding.middle.value)
            make.trailing.equalTo(headerContainerView).offset(-Padding.middle.value)
        }
        
        dateAndParticipantsLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Padding.medium.value)
            make.leading.equalTo(headerContainerView).offset(Padding.middle.value)
        }
        
        budgetLabel.snp.makeConstraints { make in
            make.top.equalTo(dateAndParticipantsLabel.snp.bottom).offset(Padding.default.value)
            make.leading.equalTo(headerContainerView).offset(Padding.middle.value)
            make.bottom.equalTo(headerContainerView).offset(-Padding.middle.value)
        }
        
        expensesContainerView.snp.makeConstraints { make in
            make.top.equalTo(headerContainerView.snp.bottom).offset(Padding.tiny.value)
            make.leading.equalTo(containerView).offset(Padding.tiny.value)
            make.trailing.equalTo(containerView).offset(-Padding.tiny.value)
        }
        
        expensesLabel.snp.makeConstraints { make in
            make.top.equalTo(expensesContainerView).offset(Padding.middle.value)
            make.leading.equalTo(expensesContainerView).offset(Padding.middle.value)
        }
        
        expensesAmountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(expensesLabel)
            make.trailing.equalTo(expensesContainerView).offset(-Padding.middle.value)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(expensesLabel.snp.bottom).offset(Padding.default.value)
            make.leading.equalTo(expensesContainerView).offset(Padding.middle.value)
            make.trailing.equalTo(expensesContainerView).offset(-Padding.middle.value)
            make.bottom.equalTo(expensesContainerView).offset(-Padding.middle.value)
            make.height.equalTo(Padding.tiny.value)
        }
        
        addExpenseContainerView.snp.makeConstraints { make in
            make.top.equalTo(expensesContainerView.snp.bottom).offset(Padding.tiny.value)
            make.leading.equalTo(containerView).offset(Padding.tiny.value)
            make.trailing.equalTo(containerView).offset(-Padding.tiny.value)
            make.bottom.equalTo(containerView).offset(-Padding.tiny.value)
        }
        
        addExpenseButton.snp.makeConstraints { make in
            make.top.equalTo(addExpenseContainerView).offset(Padding.middle.value)
            make.leading.equalTo(addExpenseContainerView).offset(Padding.middle.value)
            make.bottom.equalTo(addExpenseContainerView).offset(-Padding.middle.value)
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.centerY.equalTo(addExpenseButton)
            make.trailing.equalTo(addExpenseContainerView).offset(-Padding.middle.value)
            make.size.equalTo(Padding.default.value)
        }
    }
    
    private func setupSkeletonViews() {
        nameLabel.isSkeletonable = true
        dateAndParticipantsLabel.isSkeletonable = true
        budgetLabel.isSkeletonable = true
        expensesLabel.isSkeletonable = true
        expensesAmountLabel.isSkeletonable = true
        
        containerView.isSkeletonable = true
        headerContainerView.isSkeletonable = true
        expensesContainerView.isSkeletonable = true
        addExpenseContainerView.isSkeletonable = true
        
        progressView.isSkeletonable = true
        
        nameLabel.linesCornerRadius = CGFloat.cornerRadius
        dateAndParticipantsLabel.linesCornerRadius = CGFloat.cornerRadius
        budgetLabel.linesCornerRadius = CGFloat.cornerRadius
        
        isSkeletonable = true
    }
        
    // TODO: ADD EXPENSE AND PARipientS
    func configure(with trip: TripDto) {
        nameLabel.text = trip.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let startDate = dateFormatter.string(from: trip.startDate)
        let endDate = trip.endDate.map { dateFormatter.string(from: $0) } ?? "..."
        dateAndParticipantsLabel.text = "\(startDate)-\(endDate) · \(trip.formattedParticipantsCount)"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        
        budgetLabel.text = (formatter.string(from: NSNumber(value: trip.totalBudget)) ?? "0") + " ₽"
        
        if let spentAmount = trip.spentAmount {
            expensesAmountLabel.text = (formatter.string(from: NSNumber(value: spentAmount)) ?? "0") + " ₽"
            progressView.progress = trip.progressPercentage
        } else {
            expensesAmountLabel.text = "0 ₽"
            progressView.progress = 0
        }
    }
}

private extension CGFloat {
    static let cornerRadius = 8
}
