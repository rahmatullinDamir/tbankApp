import UIKit
import SnapKit

final class ErrorMessageView: UIView {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.regular.value)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor.systemRed.withAlphaComponent(CGFloat.defaultAlpha)
        layer.cornerRadius = CGFloat.cornerRadius
        
        addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: Padding.tiny.value, left: Padding.default.value, bottom: Padding.tiny.value, right: Padding.default.value))
        }
        
        isHidden = true
    }
    
    func showError(_ message: String?) {
        messageLabel.text = message
        isHidden = message == nil
        
        if message != nil {
            alpha = 0
            UIView.animate(withDuration: CGFloat.animateDuration) {
                self.alpha = 1
            }
        }
    }
} 

private extension CGFloat {
    static let cornerRadius: CGFloat = 8
    static let defaultAlpha: CGFloat = 0.1
    static let animateDuration: CGFloat = 0.3
}
