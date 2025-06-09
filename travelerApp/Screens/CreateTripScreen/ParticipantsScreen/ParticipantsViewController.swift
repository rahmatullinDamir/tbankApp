import UIKit
import Combine

class ParticipantsViewController: UIViewController {
    private let viewModel: any ParticipantsViewModeling
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var phoneTextField: ValidatedTextField = {
        let textField = CustomTextField(placeholder: "Введите номер телефона")
        textField.keyboardType = .phonePad
        textField.delegate = self
        
        let field = ValidatedTextField(textField: textField)
        field.backgroundColor = UIColor(hex: CustomColors.grey.value, alpha: CGFloat.defaultAlpha)
        field.layer.cornerRadius = LayoutConstants.defaultCornerRadius
        return field
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔍", for: .normal)
        button.backgroundColor = UIColor(hex: CustomColors.grey.value, alpha: CGFloat.defaultAlpha)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = LayoutConstants.defaultCornerRadius
        
        let action = UIAction { [weak self] _ in
            guard let phoneNumber = self?.phoneTextField.textField.text, !phoneNumber.isEmpty else {
                self?.showError("Введите номер телефона")
                return
            }
            
            self?.viewModel.trigger(.addParticipant(phoneNumber: phoneNumber))
        }
        
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: CustomActionButton = {
        let button = CustomActionButton(title: "Далее")
        let action = UIAction { [weak self] _ in
            self?.viewModel.trigger(.nextStep)
        }
        button.addAction(action, for: .touchUpInside)
        
        button.isEnabled = false
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ParticipantCell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(viewModel: any ParticipantsViewModeling) {
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
        setupPhoneFormatting()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(phoneTextField)
        view.addSubview(addButton)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(nextButton)
        
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Padding.default.value)
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.trailing.equalTo(addButton.snp.leading).offset(-Padding.tiny.value)
            make.height.equalTo(LayoutConstants.defaultTextFieldHeight)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField)
            make.trailing.equalToSuperview().offset(-Padding.default.value)
            make.width.equalTo(CGFloat.buttonAddWidth)
            make.height.equalTo(LayoutConstants.defaultTextFieldHeight)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(Padding.default.value)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(-Padding.default.value)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.trailing.equalToSuperview().offset(-Padding.default.value)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Padding.default.value)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        viewModel.stateDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if let state = self?.viewModel.state {
                    self?.render(state)
                }
            }
            .store(in: &cancellables)
            
        viewModel.stateDidChange
            .map { [weak self] _ in
                return self?.viewModel.isNextButtonEnabled ?? false
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: nextButton)
            .store(in: &cancellables)
    }
    
    private func setupPhoneFormatting() {
        phoneTextField.textField.textPublisher
            .map { text -> String in
                let digitsOnly = PhoneNumberFormatter.digits(from: text)
                return PhoneNumberFormatter.applyMask(to: digitsOnly)
            }
            .sink { [weak self] formattedText in
                if self?.phoneTextField.textField.text != formattedText {
                    self?.phoneTextField.textField.text = formattedText
                }
            }
            .store(in: &cancellables)
    }
    
    private func render(_ state: ParticipantsViewState) {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            view.isUserInteractionEnabled = false
            
        case .participantsUpdated(_):
            loadingIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
            tableView.reloadData()
            nextButton.isEnabled = viewModel.isNextButtonEnabled
            
        case .error(let message):
            loadingIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
            showError(message)
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ParticipantsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for: indexPath)
        let participant = viewModel.participants[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = "\(participant.firstName) \(participant.lastName)"
        content.secondaryText = participant.phoneNumber
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.trigger(.removeParticipant(at: indexPath.row))
        }
    }
}

extension ParticipantsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}

private extension CGFloat {
    static let buttonAddWidth: CGFloat = 100
    static let defaultAlpha: CGFloat = 0.02
}
