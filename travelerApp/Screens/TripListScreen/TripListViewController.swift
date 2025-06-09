import UIKit
import Combine
import SnapKit
import SkeletonView

class TripListViewController: UIViewController {
    private let viewModel: any TripListViewModeling
    private let notificationsViewModel: any NotificationsViewModelling
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var userInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = LayoutConstants.defaultCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.title.value)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var userPhoneLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var notificationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var notificationBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 5
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = CGFloat.defaultLayoutConstant
        layout.minimumInteritemSpacing = CGFloat.defaultLayoutConstant
        layout.sectionInset = UIEdgeInsets(
            top: CGFloat.defaultLayoutConstant,
            left: CGFloat.defaultLayoutConstant,
            bottom: CGFloat.defaultLayoutConstant,
            right: CGFloat.defaultLayoutConstant
        )
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TripCollectionViewCell.self, forCellWithReuseIdentifier: "TripCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.isSkeletonable = true
        return collectionView
    }()
    
    init(viewModel: any TripListViewModeling) {
        self.viewModel = viewModel
        self.notificationsViewModel = NotificationsViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupUI()
        setupBindings()
        setupSkeletonView()
        viewModel.trigger(.onDidLoad)
        notificationsViewModel.loadNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh data when screen appears
        viewModel.trigger(.onReload)
        notificationsViewModel.loadNotifications()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGray6
        
        view.addSubview(userInfoView)
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        
        setupUserInfoView()
        setupCollectionView()
        setupEmptyStateView()
    }
    
    private func setupUserInfoView() {
        userInfoView.addSubview(userNameLabel)
        userInfoView.addSubview(userPhoneLabel)
        userInfoView.addSubview(notificationButton)
        notificationButton.addSubview(notificationBadge)
        
        userInfoView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.trailing.equalToSuperview().offset(-Padding.default.value)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Padding.default.value)
            make.leading.equalToSuperview().offset(Padding.default.value)
        }
        
        userPhoneLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(Padding.small.value)
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.bottom.equalToSuperview().offset(-Padding.default.value)
        }
        
        notificationButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-Padding.default.value)
            make.size.equalTo(Padding.middle.value)
        }
        
        notificationBadge.snp.makeConstraints { make in
            make.width.height.equalTo(10)
            make.top.equalTo(notificationButton).offset(2)
            make.trailing.equalTo(notificationButton).offset(-2)
        }
    }
    
    private func setupCollectionView() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(userInfoView.snp.bottom).offset(Padding.default.value)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupEmptyStateView() {
        let imageView = UIImageView(image: UIImage(systemName: "briefcase"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "У вас еще нет поездок"
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.default.value)
        label.textColor = .systemGray
        label.textAlignment = .center
        
        emptyStateView.addSubview(imageView)
        emptyStateView.addSubview(label)
        
        emptyStateView.snp.makeConstraints { make in
            make.top.equalTo(userInfoView.snp.bottom).offset(Padding.default.value)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(Padding.big.value)
            make.size.equalTo(CGFloat.imageViewSize)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(Padding.default.value)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.trailing.equalToSuperview().offset(-Padding.default.value)
        }
    }
    
    private func setupSkeletonView() {
        collectionView.prepareSkeleton { [weak self] _ in
            self?.showLoadingSkeleton()
        }
    }
    
    private func showLoadingSkeleton() {
        collectionView.showAnimatedGradientSkeleton()
    }
    
    private func hideLoadingSkeleton() {
        collectionView.hideSkeleton()
    }
    
    private func setupBindings() {
        viewModel.stateDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.render()
            }
            .store(in: &cancellables)
        
        let action = UIAction { _ in
            self.viewModel.trigger(.onNotificationsTapped)
        }
        notificationButton.addAction(action, for: .touchUpInside)
        
        notificationsViewModel.notificationsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notifications in
                self?.notificationBadge.isHidden = notifications.isEmpty
            }
            .store(in: &cancellables)
    }
    
    private func render() {
        switch viewModel.state {
        case .loading:
            if let user = viewModel.user {
                userNameLabel.text = "\(user.firstName) \(user.lastName)"
                userPhoneLabel.text = user.phoneNumber
            }
            emptyStateView.isHidden = true
            collectionView.isHidden = false
            showLoadingSkeleton()
            
        case .content(let tripList):
            hideLoadingSkeleton()
            
            emptyStateView.isHidden = !tripList.isEmpty
            collectionView.isHidden = tripList.isEmpty
            collectionView.reloadData()
            
        case .error(let message):
            hideLoadingSkeleton()
            // TODO: Show error state
            print(message)
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        
        return (formatter.string(from: NSNumber(value: amount)) ?? "0") + " ₽"
    }
}

// MARK: - SkeletonCollectionViewDataSource

extension TripListViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return "TripCell"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if case .content(let tripList) = viewModel.state {
            return tripList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard case .content(let tripList) = viewModel.state,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TripCell", for: indexPath) as? TripCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let trip = tripList[indexPath.item]
        cell.configure(with: trip)
        return cell
    }
}

extension TripListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - Padding.big.value
        return CGSize(width: width, height: CGFloat.defaultCollectionLayoutHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.trigger(.tripSelected(indexPath))
    }
}

private extension CGFloat {
    static let defaultLayoutConstant: CGFloat = 16
    static let imageViewOffset: CGFloat = -40
    static let imageViewSize: CGFloat = 80
    static let defaultCollectionLayoutHeight: CGFloat = 320
}

extension TripListViewController: NotificationsViewModelDelegate {
    func notificationsViewModelDidFinish() {
        navigationController?.popViewController(animated: true)
    }
}
