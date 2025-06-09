import UIKit
import Combine

final class CreateTripViewController: UIViewController {
    private let viewModel: any CreateTripViewModeling
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: any CreateTripViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var nameTextField: ValidatedTextField = {
        let textField = CustomTextField(placeholder: "Название поездки")
        textField.delegate = self
        textField.returnKeyType = .next
        textField.backgroundColor = .clear
        
        let field = ValidatedTextField(textField: textField)
        field.backgroundColor = UIColor(hex: CustomColors.grey.value, alpha: CGFloat.defaultAlpha)
        field.layer.cornerRadius = LayoutConstants.defaultCornerRadius
        return field
    }()
    
    private lazy var startDateField: ValidatedTextField = {
        let textField = CustomTextField(placeholder: "")
        textField.backgroundColor = .clear
        textField.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        textField.inputView = startDatePicker
        textField.inputAccessoryView = createDatePickerToolbar(for: .start)
        textField.delegate = self
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat.leftPaddingWidth, height: CGFloat.leftPaddingHeight))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.contentVerticalAlignment = .bottom
        textField.frame.size.height = CGFloat.textFieldHeight
        
        let field = ValidatedTextField(textField: textField)
        field.backgroundColor = UIColor(hex: CustomColors.grey.value, alpha: CGFloat.defaultAlpha)
        field.layer.cornerRadius = LayoutConstants.defaultCornerRadius
        
        let titleLabel = UILabel()
        titleLabel.text = "Дата начала"
        titleLabel.textColor = UIColor(hex: CustomColors.lightTextSecondary.value)
        titleLabel.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        field.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let formatLabel = UILabel()
        formatLabel.text = "дд.мм.гггг"
        formatLabel.textColor = UIColor(hex: CustomColors.lightTextSecondary.value)
        formatLabel.font =  UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.tiny.value)
        formatLabel.tag = CGFloat.formatLabelTag
        field.addSubview(formatLabel)
        formatLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let calendarContainer = UIView()
        calendarContainer.translatesAutoresizingMaskIntoConstraints = false
        field.addSubview(calendarContainer)
        
        let calendarImage = UIImage(systemName: "calendar")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: calendarImage)
        imageView.tintColor = UIColor(hex: CustomColors.grey.value)
        imageView.contentMode = .scaleAspectFit
        calendarContainer.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.top.equalToSuperview().offset(Padding.tiny.value)
        }
        
        formatLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.top.equalTo(titleLabel.snp.bottom).offset(Padding.small.value)
        }
        
        calendarContainer.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Padding.default.value)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(LayoutConstants.defaultTextFieldHeight)
        }
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(CGFloat.calendarImageHeight)
        }
        
        field.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(CGFloat.fieldHeight)
        }
        
        return field
    }()
    
    private lazy var endDateField: ValidatedTextField = {
        let textField = CustomTextField(placeholder: "")
        textField.backgroundColor = .clear
        textField.inputView = endDatePicker
        textField.inputAccessoryView = createDatePickerToolbar(for: .end)
        textField.delegate = self
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat.leftPaddingWidth, height: CGFloat.leftPaddingHeight))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.contentVerticalAlignment = .bottom
        textField.frame.size.height = CGFloat.textFieldHeight
        
        let field = ValidatedTextField(textField: textField)
        field.backgroundColor = UIColor(hex: CustomColors.grey.value, alpha: CGFloat.defaultAlpha)
        field.layer.cornerRadius = LayoutConstants.defaultCornerRadius
        
        let titleLabel = UILabel()
        titleLabel.text = "Дата окончания"
        titleLabel.textColor = UIColor(hex: CustomColors.lightTextSecondary.value)
        titleLabel.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        field.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let formatLabel = UILabel()
        formatLabel.text = "дд.мм.гггг"
        formatLabel.textColor = UIColor(hex: CustomColors.lightTextSecondary.value)
        formatLabel.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.tiny.value)
        formatLabel.tag = CGFloat.formatLabelTag
        field.addSubview(formatLabel)
        formatLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let calendarContainer = UIView()
        calendarContainer.translatesAutoresizingMaskIntoConstraints = false
        field.addSubview(calendarContainer)
        
        let calendarImage = UIImage(systemName: "calendar")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: calendarImage)
        imageView.tintColor = UIColor(hex: CustomColors.grey.value)
        imageView.contentMode = .scaleAspectFit
        calendarContainer.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.top.equalToSuperview().offset(Padding.tiny.value)
        }
        
        formatLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.top.equalTo(titleLabel.snp.bottom).offset(Padding.small.value)
        }
        
        calendarContainer.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Padding.default.value)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(LayoutConstants.defaultTextFieldHeight)
        }
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(CGFloat.calendarImageHeight)
        }
        
        field.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(CGFloat.fieldHeight)
        }
        
        return field
    }()
    
    private lazy var budgetField: ValidatedTextField = {
        let textField = CustomTextField(placeholder: "Бюджет", keyboardType: .numberPad)
        textField.delegate = self
        let field = ValidatedTextField(textField: textField)
        return field
    }()
    
    private lazy var nextButton: CustomActionButton = {
        let button = CustomActionButton(title: "Далее")
        let action = UIAction(handler: {[weak self] _ in
            self?.viewModel.trigger(.nextStep)
        })
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    private lazy var errorMessageView: ErrorMessageView = {
        let view = ErrorMessageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        
        let action = UIAction { _ in
            self.startDateSelected()
        }
        picker.addAction(action, for: .valueChanged)
        picker.addTarget(self, action: #selector(startDateSelected), for: .valueChanged)
        return picker
    }()
    
    private lazy var endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.addTarget(self, action: #selector(endDateSelected), for: .valueChanged)
        return picker
    }()
    
    private enum DateFieldType {
        case start
        case end
    }
    
    private func createDatePickerToolbar(for type: DateFieldType) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(datePickerDoneButtonTapped))
        let todayButton = UIBarButtonItem(title: "Сегодня", style: .plain, target: self, action: #selector(todayButtonTapped(_:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        todayButton.tag = type == .start ? 0 : 1
        
        toolbar.setItems([todayButton, flexSpace, doneButton], animated: false)
        return toolbar
    }
    
    @objc private func datePickerDoneButtonTapped() {
        view.endEditing(true)
    }
    
    @objc private func todayButtonTapped(_ sender: UIBarButtonItem) {
        let today = Date()
        if sender.tag == 0 {
            startDatePicker.date = today
            startDateSelected()
        } else {
            endDatePicker.date = today
            endDateSelected()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        setupBindings()
        viewModel.trigger(.onDidLoad)
    }
    
    private func configureUI() {
        let stackView = UIStackView(arrangedSubviews: [
            nameTextField,
            startDateField,
            endDateField,
            budgetField,
        ])
        stackView.axis = .vertical
        stackView.spacing = CGFloat.stackViewSpacing
        
        view.addSubview(stackView)
        view.addSubview(nextButton)
        view.addSubview(errorMessageView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Padding.default.value)
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.trailing.equalToSuperview().offset(-Padding.default.value)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Padding.default.value)
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.trailing.equalToSuperview().offset(-Padding.default.value)
            make.height.equalTo(LayoutConstants.defaultButtonHeight)
        }
        
        errorMessageView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(Padding.default.value)
            make.leading.trailing.equalTo(stackView)
        }
    }
    
    private func setupBindings() {
        viewModel.stateDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.render()
            }
            .store(in: &cancellables)
        
        nameTextField.textPublisher
            .sink { [weak self] text in
                self?.viewModel.trigger(.updateName(text ?? ""))
            }
            .store(in: &cancellables)
        
        budgetField.textPublisher
            .sink { [weak self] text in
                if let text = text?.replacingOccurrences(of: " ", with: ""),
                   !text.isEmpty {
                    if let amount = Int(text) {
                        self?.viewModel.trigger(.updateBudget(amount))
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .decimal
                        formatter.groupingSeparator = " "
                        if let formattedString = formatter.string(from: NSNumber(value: amount)) {
                            self?.budgetField.textField.text = formattedString
                        }
                    }
                } else {
                    self?.viewModel.trigger(.updateBudget(0))
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest4(
            viewModel.nameErrorPublisher,
            viewModel.startDateErrorPublisher,
            viewModel.endDateErrorPublisher,
            viewModel.budgetErrorPublisher
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] nameError, startDateError, endDateError, budgetError in
            self?.nameTextField.showError(nameError)
            self?.startDateField.showError(startDateError)
            self?.endDateField.showError(endDateError)
            self?.budgetField.showError(budgetError)
        }
        .store(in: &cancellables)
        
        viewModel.isFormValidPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: nextButton)
            .store(in: &cancellables)
    }
    
    private func render() {
        switch viewModel.state {
        case .loading:
            CustomLoadingManager.shared.show(on: view, with: "Загрузка данных...")
            errorMessageView.showError(nil)
            
        case .content(let data):
            CustomLoadingManager.shared.hide()
            errorMessageView.showError(nil)
            
            nameTextField.textField.text = data.name
            if let budget = data.totalBudget {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.groupingSeparator = " "
                budgetField.textField.text = formatter.string(from: NSNumber(value: budget))
            } else {
                budgetField.textField.text = ""
            }
            
            if let startDate = data.startDate {
                startDateField.textField.text = startDate.displayFormatted
                if let formatLabel = startDateField.viewWithTag(CGFloat.formatLabelTag) as? UILabel {
                    formatLabel.isHidden = true
                }
            }
            
            if let endDate = data.endDate {
                endDateField.textField.text = endDate.displayFormatted
                if let formatLabel = endDateField.viewWithTag(CGFloat.formatLabelTag) as? UILabel {
                    formatLabel.isHidden = true
                }
            }
            
        case .error(let message):
            CustomLoadingManager.shared.hide()
            errorMessageView.showError(message)
        }
    }
    
    @objc private func startDateSelected() {
        startDateField.textField.text = startDatePicker.date.displayFormatted
        if let formatLabel = startDateField.viewWithTag(CGFloat.formatLabelTag) as? UILabel {
            formatLabel.isHidden = true
        }
        viewModel.trigger(.updateStartDate(startDatePicker.date))
    }
    
    @objc private func endDateSelected() {
        endDateField.textField.text = endDatePicker.date.displayFormatted
        if let formatLabel = endDateField.viewWithTag(CGFloat.formatLabelTag) as? UILabel {
            formatLabel.isHidden = true
        }
        viewModel.trigger(.updateEndDate(endDatePicker.date))
    }
}

extension CreateTripViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameTextField.textField {
            budgetField.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === startDateField.textField || textField === endDateField.textField {
            return false
        }
        
        if textField === budgetField.textField {
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            let cleanText = newText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            
            if let number = Int(cleanText), number > 999999999 {
                return false
            }
            
            if cleanText.isEmpty {
                textField.text = ""
                self.viewModel.trigger(.updateBudget(0))
                return false
            }
            
            if let number = Int(cleanText) {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.groupingSeparator = " "
                if let formattedString = formatter.string(from: NSNumber(value: number)) {
                    textField.text = formattedString
                    self.viewModel.trigger(.updateBudget(number))
                }
            }
            
            return false
        }

        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === startDateField.textField {
            if let formatLabel = startDateField.viewWithTag(CGFloat.formatLabelTag) as? UILabel {
                formatLabel.isHidden = !(textField.text?.isEmpty ?? true)
            }
        } else if textField === endDateField.textField {
            if let formatLabel = endDateField.viewWithTag(CGFloat.formatLabelTag) as? UILabel {
                formatLabel.isHidden = !(textField.text?.isEmpty ?? true)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === startDateField.textField {
            if let formatLabel = startDateField.viewWithTag(CGFloat.formatLabelTag) as? UILabel {
                formatLabel.isHidden = !(textField.text?.isEmpty ?? true)
            }
        } else if textField === endDateField.textField {
            if let formatLabel = endDateField.viewWithTag(CGFloat.formatLabelTag) as? UILabel {
                formatLabel.isHidden = !(textField.text?.isEmpty ?? true)
            }
        }
    }
}

extension CreateTripViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
} 

private extension CGFloat {
    static let leftPaddingWidth: CGFloat = 16
    static let leftPaddingHeight: CGFloat = 40
    static let textFieldHeight: CGFloat = 60
    static let formatLabelTag = 100
    static let fieldHeight: CGFloat = 70
    static let calendarImageHeight: CGFloat = 20
    static let stackViewSpacing: CGFloat = 16
    static let defaultAlpha: CGFloat = 0.02
}
