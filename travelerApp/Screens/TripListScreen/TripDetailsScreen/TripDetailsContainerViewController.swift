import UIKit
import Combine

class TripDetailsContainerViewController: UIViewController {
    private var viewModel: any TripDetailsViewModelling
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Расходы", "Категории"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var expensesViewController: TripDetailsViewController = {
        let vc = TripDetailsViewController(viewModel: viewModel)
        return vc
    }()
    
    private lazy var categoriesViewController: TripCategoriesViewController = {
        let vc = TripCategoriesViewController(viewModel: viewModel)
        return vc
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
        showExpensesTab()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(segmentedControl)
        view.addSubview(containerView)
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Padding.tiny.value)
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
            make.height.equalTo(CGFloat.segmentedControlHeight)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(Padding.tiny.value)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            showExpensesTab()
        case 1:
            showCategoriesTab()
        default:
            break
        }
    }
    
    private func showExpensesTab() {
        removeCurrentChildViewController()
        addChild(expensesViewController)
        containerView.addSubview(expensesViewController.view)
        expensesViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        expensesViewController.didMove(toParent: self)
    }
    
    private func showCategoriesTab() {
        removeCurrentChildViewController()
        addChild(categoriesViewController)
        containerView.addSubview(categoriesViewController.view)
        categoriesViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        categoriesViewController.didMove(toParent: self)
    }
    
    private func removeCurrentChildViewController() {
        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
} 

private extension CGFloat {
    static let segmentedControlHeight: CGFloat = 32
}
