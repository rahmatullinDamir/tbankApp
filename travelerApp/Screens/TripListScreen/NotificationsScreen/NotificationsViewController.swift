import UIKit
import Combine

class NotificationsViewController: UIViewController {
    private let viewModel: any NotificationsViewModelling
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(NotificationCell.self, forCellReuseIdentifier: "NotificationCell")
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .white
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshNotifications), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Нет новых уведомлений"
        label.textAlignment = .center
        label.textColor = .gray
        label.isHidden = true
        return label
    }()
    
    init(viewModel: any NotificationsViewModelling) {
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
        setupNavigationBar()
        viewModel.loadNotifications()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Прочитано",
            style: .plain,
            target: self,
            action: #selector(markAllAsRead)
        )
    }
    
    private func setupBindings() {
        viewModel.notificationsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notifications in
                self?.refreshControl.endRefreshing()
                self?.tableView.reloadData()
                self?.emptyStateLabel.isHidden = !notifications.isEmpty
                
                let hasNonInvitationNotifications = notifications.contains { !$0.isInvitation }
                self?.navigationItem.rightBarButtonItem?.isEnabled = hasNonInvitationNotifications
            }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.refreshControl.endRefreshing()
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        viewModel.delegate?.notificationsViewModelDidFinish()
    }
    
    @objc private func refreshNotifications() {
        viewModel.loadNotifications()
    }
    
    @objc private func markAllAsRead() {
        let nonInvitationIds = viewModel.notifications
            .filter { !$0.isInvitation }
            .map { $0.id }
        if !nonInvitationIds.isEmpty {
            viewModel.markAsRead(nonInvitationIds)
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let notification = viewModel.notifications[indexPath.row]
        cell.configure(with: notification, viewModel: viewModel as! NotificationsViewModel)
        return cell
    }
}

extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let notification = viewModel.notifications[indexPath.row]
        
        if notification.isInvitation {
            return nil
        }
        
        let markAsReadAction = UIContextualAction(style: .normal, title: "Прочитано") { [weak self] (_, _, completion) in
            self?.viewModel.markAsRead([notification.id])
            completion(true)
        }
        markAsReadAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [markAsReadAction])
    }
}

class NotificationCell: UITableViewCell {
    private let iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = LayoutConstants.defaultCornerRadius
        view.backgroundColor = NotificationColors.yellow
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.regular.value)
        label.numberOfLines = 0
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.tiny.value)
        label.textColor = .gray
        return label
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = CGFloat.stackViewSpacing
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true
        return stackView
    }()
    
    private lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Принять", for: .normal)
        button.backgroundColor = NotificationColors.green
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius =  CGFloat.buttonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var rejectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отклонить", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = CGFloat.buttonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var viewModel: NotificationsViewModel?
    private var notification: NotificationItem?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .white
        
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(timestampLabel)
        
        buttonsStackView.addArrangedSubview(acceptButton)
        buttonsStackView.addArrangedSubview(rejectButton)
        contentView.addSubview(buttonsStackView)
        
        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.top.equalToSuperview().offset(Padding.medium.value)
            make.width.height.equalTo(CGFloat.iconContainerHeight)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(CGFloat.iconImageViewHeight)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(Padding.medium.value)
            make.top.equalToSuperview().offset(Padding.medium.value)
            make.trailing.equalToSuperview().offset(-Padding.default.value)
        }
        
        timestampLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(Padding.medium.value)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(Padding.small.value)
            make.trailing.equalToSuperview().offset(-Padding.default.value)
        }
        
        buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(timestampLabel.snp.bottom).offset(Padding.tiny.value)
            make.leading.equalTo(iconContainer.snp.trailing).offset(Padding.medium.value)
            make.trailing.equalToSuperview().offset(-Padding.default.value)
            make.bottom.equalToSuperview().offset(-Padding.medium.value)
            make.height.equalTo(CGFloat.buttonHeight)
        }
        
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(rejectButtonTapped), for: .touchUpInside)
    }
    
    func configure(with notification: NotificationItem, viewModel: NotificationsViewModel) {
        self.notification = notification
        self.viewModel = viewModel
        
        descriptionLabel.text = notification.description
        iconImageView.image = UIImage(systemName: notification.type.icon)
        iconContainer.backgroundColor = notification.type.color
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        timestampLabel.text = formatter.string(from: notification.date)
        
        buttonsStackView.isHidden = !notification.isInvitation
        
        if notification.isInvitation {
            timestampLabel.snp.remakeConstraints { make in
                make.leading.equalTo(iconContainer.snp.trailing).offset(Padding.medium.value)
                make.top.equalTo(descriptionLabel.snp.bottom).offset(Padding.small.value)
                make.trailing.equalToSuperview().offset(-Padding.default.value)
            }
            buttonsStackView.snp.remakeConstraints { make in
                make.top.equalTo(timestampLabel.snp.bottom).offset(Padding.tiny.value)
                make.leading.equalTo(iconContainer.snp.trailing).offset(Padding.medium.value)
                make.trailing.equalToSuperview().offset(-Padding.default.value)
                make.bottom.equalToSuperview().offset(-Padding.medium.value)
                make.height.equalTo(CGFloat.buttonHeight)
            }
        } else {
            timestampLabel.snp.remakeConstraints { make in
                make.leading.equalTo(iconContainer.snp.trailing).offset(Padding.medium.value)
                make.top.equalTo(descriptionLabel.snp.bottom).offset(Padding.small.value)
                make.trailing.equalToSuperview().offset(-Padding.default.value)
                make.bottom.equalToSuperview().offset(-Padding.medium.value)
            }
        }
        layoutIfNeeded()
    }
    
    @objc private func acceptButtonTapped() {
        guard let notification = notification, let viewModel = viewModel else { return }
        viewModel.handleInvitation(tripId: notification.tripId, accept: true, notificationId: notification.id)
    }
    
    @objc private func rejectButtonTapped() {
        guard let notification = notification, let viewModel = viewModel else { return }
        viewModel.handleInvitation(tripId: notification.tripId, accept: false, notificationId: notification.id)
    }
} 

private extension CGFloat {
    static let buttonHeight: CGFloat = 36
    static let iconImageViewHeight: CGFloat = 24
    static let iconContainerHeight: CGFloat = 40
    static let buttonCornerRadius: CGFloat = 8
    static let stackViewSpacing: CGFloat = 8
}
