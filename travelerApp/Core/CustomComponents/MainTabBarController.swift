import UIKit

protocol MainTabBarControllerDelegate: AnyObject {
    func mainTabBarControllerDidTapPlusButton()
}

final class MainTabBarController: UITabBarController {
    weak var mainDelegate: MainTabBarControllerDelegate?

    private lazy var customPlusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(hex: CustomColors.lightBlue.value)
        button.layer.cornerRadius = LayoutConstants.buttonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false

        let plusImage = UIImage(systemName: "plus")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: CGFloat.pointSize, weight: .bold)
        )
        button.setImage(plusImage, for: .normal)
        button.tintColor = .black

        let action = UIAction(handler: { _ in
            self.mainDelegate?.mainTabBarControllerDidTapPlusButton()
        })
        button.addAction(action, for: .touchUpInside)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        delegate = self
        setupPlusButton()
    }

    private func setupPlusButton() {
        view.addSubview(customPlusButton)
        
        customPlusButton.snp.makeConstraints { make in
            make.centerX.equalTo(tabBar.snp.centerX)
            make.width.height.equalTo(LayoutConstants.defaultButtonHeight)
            make.top.equalTo(tabBar.snp.top).offset(-Padding.default.value)
        }
    }

    private func setupTabBar() {
        tabBar.backgroundColor = .white
        tabBar.tintColor = UIColor(hex: CustomColors.blue.value)
        tabBar.unselectedItemTintColor = .systemGray3
    }

    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        guard let tripListVC = viewControllers?.first as? UINavigationController,
              tripListVC.viewControllers.first is TripListViewController,
              let profileVC = viewControllers?.last as? UINavigationController,
              profileVC.viewControllers.first is ProfileViewController else {
            return
        }

        tripListVC.tabBarItem = UITabBarItem(
            title: "Главная",
            image: UIImage(systemName: "briefcase"),
            selectedImage: UIImage(systemName: "briefcase.fill")
        )

        profileVC.tabBarItem = UITabBarItem(
            title: "Профиль",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        let emptyItem = UITabBarItem(title: nil, image: nil, tag: 1)

        let emptyVC = UIViewController()
        emptyVC.tabBarItem = emptyItem

        super.setViewControllers([tripListVC, emptyVC, profileVC], animated: animated)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController), index == 1 {
            return false
        }
        return true
    }
}

private extension CGFloat {
    static let pointSize: CGFloat = 24
}
