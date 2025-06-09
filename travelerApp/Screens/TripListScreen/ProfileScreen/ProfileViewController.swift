import UIKit
import Combine
import SnapKit

final class ProfileViewController: UIViewController {
    private let viewModel: any ProfileViewModeling
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        view.layer.cornerRadius = CGFloat.buttonCornerRadius
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var initialsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.header.value)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontFamilies.robotoBold.value, size: FontConstants.title.value)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var phoneLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var settingsTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Настройки приложения"
        label.font = UIFont(name: FontFamilies.robotoBold.value, size: FontConstants.title.value)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var notificationsSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.onTintColor = .systemBlue
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(notificationsSwitchChanged), for: .valueChanged)
        return toggle
    }()
    
    private lazy var notificationsLabel: UILabel = {
        let label = UILabel()
        label.text = "Уведомления"
        label.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var darkModeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .systemBlue
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(darkModeSwitchChanged), for: .valueChanged)
        return toggle
    }()
    
    private lazy var darkModeLabel: UILabel = {
        let label = UILabel()
        label.text = "Темная тема"
        label.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var logoutButton: CustomActionButton = {
        let button = CustomActionButton(title: "Выйти")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        button.isEnabled = true
        button.alpha = 1.0
        return button
    }()
    
    init(viewModel: any ProfileViewModeling) {
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
        view.backgroundColor = .systemBackground
        
        avatarView.addSubview(initialsLabel)
        
        let userInfoStackView = UIStackView(arrangedSubviews: [nameLabel, phoneLabel])
        userInfoStackView.axis = .vertical
        userInfoStackView.spacing = CGFloat.userInfoStackViewSpacing
        userInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let notificationsStackView = UIStackView(arrangedSubviews: [notificationsLabel, notificationsSwitch])
        notificationsStackView.axis = .horizontal
        notificationsStackView.distribution = .equalSpacing
        notificationsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let darkModeStackView = UIStackView(arrangedSubviews: [darkModeLabel, darkModeSwitch])
        darkModeStackView.axis = .horizontal
        darkModeStackView.distribution = .equalSpacing
        darkModeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let settingsStackView = UIStackView(arrangedSubviews: [notificationsStackView, darkModeStackView])
        settingsStackView.axis = .vertical
        settingsStackView.spacing = CGFloat.settingsStackSpacing
        settingsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [avatarView, userInfoStackView, settingsTitleLabel, settingsStackView, logoutButton].forEach { view.addSubview($0) }
        
        avatarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Padding.middle.value)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(CGFloat.avatarViewHeight)
        }
        
        initialsLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        userInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(Padding.default.value)
            make.centerX.equalToSuperview()
        }
        
        settingsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(userInfoStackView.snp.bottom).offset(Padding.big.value)
            make.leading.equalToSuperview().offset(Padding.default.value)
        }
        
        settingsStackView.snp.makeConstraints { make in
            make.top.equalTo(settingsTitleLabel.snp.bottom).offset(Padding.default.value)
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Padding.default.value)
            make.height.equalTo(LayoutConstants.defaultButtonHeight)
        }
    }
    
    private func setupBindings() {
        viewModel.stateDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.handleState()
            }
            .store(in: &cancellables)
        
        viewModel.isNotificationsEnabledPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.notificationsSwitch.isOn = isEnabled
            }
            .store(in: &cancellables)
        
        viewModel.isDarkModeEnabledPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.darkModeSwitch.isOn = isEnabled
            }
            .store(in: &cancellables)
    }
    
    private func handleState() {
        switch viewModel.state {
        case .loading:
            break
            
        case .content(let user):
            updateUserInfo(user)
            
        case .error(let message):
            print(message)
        }
    }
    
    private func updateUserInfo(_ user: UserDto) {
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        phoneLabel.text = user.phoneNumber
        initialsLabel.text = user.initials
    }
    
    @objc private func notificationsSwitchChanged(_ sender: UISwitch) {
        viewModel.trigger(.onToggleNotifications(enabled: sender.isOn))
    }
    
    @objc private func darkModeSwitchChanged(_ sender: UISwitch) {
        viewModel.trigger(.onToggleDarkMode(enabled: sender.isOn))
    }
    
    @objc private func logoutButtonTapped() {
        viewModel.trigger(.onLogout)
    }
}

private extension CGFloat {
    static let buttonCornerRadius: CGFloat = 50
    static let logoutButtonHeight: CGFloat = 56
    static let avatarViewHeight: CGFloat = 100
    static let settingsStackSpacing: CGFloat = 20
    static let userInfoStackViewSpacing: CGFloat = 8
}
