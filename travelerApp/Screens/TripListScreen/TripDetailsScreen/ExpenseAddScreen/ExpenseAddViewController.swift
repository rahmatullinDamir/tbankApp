import UIKit
import Combine

class ExpenseAddViewController: UIViewController {
    private var viewModel: any ExpenseAddViewModelling
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
    
    private lazy var descriptionTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Описание"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var amountTextField: ValidatedTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Сумма"
        textField.keyboardType = .decimalPad
        let validatedField = ValidatedTextField(textField: textField)
        validatedField.translatesAutoresizingMaskIntoConstraints = false
        return validatedField
    }()
    
    private lazy var categoryButton: CustomTextField = {
        let button = CustomTextField()
        button.placeholder = "Выберите категорию"
        button.isUserInteractionEnabled = true
        button.rightView = UIImageView(image: UIImage(systemName: "chevron.down"))
        button.rightViewMode = .always
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryButtonTapped))
        button.addGestureRecognizer(tapGesture)
        return button
    }()
    
    private lazy var participantsLabel: UILabel = {
        let label = UILabel()
        label.text = "За кого платите:"
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.regular.value)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var participantButton: CustomTextField = {
        let button = CustomTextField()
        button.placeholder = "Выберите за кого платите"
        button.isUserInteractionEnabled = true
        button.rightView = UIImageView(image: UIImage(systemName: "chevron.down"))
        button.rightViewMode = .always
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(participantButtonTapped))
        button.addGestureRecognizer(tapGesture)
        return button
    }()
    
    private lazy var addExpenseButton: CustomActionButton = {
        let button = CustomActionButton(title: "Добавить расход")
        let action = UIAction { [weak self] _ in
            self?.viewModel.trigger(.addExpense)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    init(viewModel: any ExpenseAddViewModelling) {
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
        viewModel.trigger(.onDidLoad)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(descriptionTextField)
        contentView.addSubview(amountTextField)
        contentView.addSubview(categoryButton)
        contentView.addSubview(participantsLabel)
        contentView.addSubview(participantButton)
        view.addSubview(addExpenseButton)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(addExpenseButton.snp.top).offset(-Padding.default.value)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        descriptionTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Padding.default.value)
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
            make.height.equalTo(CGFloat.defaultHeight)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextField.snp.bottom).offset(Padding.default.value)
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
        }
        
        categoryButton.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(Padding.default.value)
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
            make.height.equalTo(CGFloat.defaultHeight)
        }
        
        participantsLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryButton.snp.bottom).offset(Padding.default.value)
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
        }
        
        participantButton.snp.makeConstraints { make in
            make.top.equalTo(participantsLabel.snp.bottom).offset(Padding.tiny.value)
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
            make.height.equalTo(CGFloat.defaultHeight)
            make.bottom.equalToSuperview().offset(-Padding.default.value)
        }
        
        addExpenseButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Padding.default.value)
        }
    }
    
    private func setupBindings() {
        descriptionTextField.textPublisher
            .sink { [weak self] text in
                self?.viewModel.trigger(.updateDescription(text ?? ""))
            }
            .store(in: &cancellables)
        
        amountTextField.textPublisher
            .sink { [weak self] text in
                self?.viewModel.trigger(.updateAmount(text ?? ""))
            }
            .store(in: &cancellables)
            
        viewModel.isAddButtonEnabledPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.addExpenseButton.isEnabled = isEnabled
                self?.addExpenseButton.alpha = isEnabled ? 1.0 : 0.5
            }
            .store(in: &cancellables)
            
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.amountTextField.showError(error)
            }
            .store(in: &cancellables)
            
        viewModel.selectedCategoryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                self?.categoryButton.text = category
            }
            .store(in: &cancellables)
            
        viewModel.selectedParticipantsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] participants in
                self?.participantButton.text = participants.isEmpty ? "" : participants.joined(separator: ", ")
            }
            .store(in: &cancellables)
    }
    
    @objc private func categoryButtonTapped() {
        let alert = UIAlertController(title: "Выберите категорию", message: nil, preferredStyle: .actionSheet)
        
        viewModel.availableCategories.forEach { category in
            let action = UIAlertAction(title: category, style: .default) { [weak self] _ in
                self?.viewModel.trigger(.selectCategory(category))
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = categoryButton
            popoverController.sourceRect = categoryButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    @objc private func participantButtonTapped() {
        let alert = UIAlertController(title: "За кого платите", message: "Выберите участников, за которых платите", preferredStyle: .actionSheet)
        
        viewModel.availableParticipants.forEach { participant in
            let isSelected = viewModel.selectedParticipants.contains(participant)
            let action = UIAlertAction(
                title: (isSelected ? "✓ " : "") + participant,
                style: .default
            ) { [weak self] _ in
                self?.viewModel.trigger(.selectParticipant(participant))
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Готово", style: .cancel))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = participantButton
            popoverController.sourceRect = participantButton.bounds
        }
        
        present(alert, animated: true)
    }
}

extension ExpenseAddViewController: ExpenseAddViewModelDelegate {
    func expenseAddViewModelDidFinish() {
        navigationController?.popViewController(animated: true)
    }
} 

private extension CGFloat {
    static let defaultHeight: CGFloat = 56
}
