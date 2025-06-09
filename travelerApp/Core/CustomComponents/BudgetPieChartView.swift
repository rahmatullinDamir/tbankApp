import UIKit
import SnapKit

class BudgetPieChartView: UIView {
    private var segments: [(color: UIColor, percentage: CGFloat)] = []
    private let totalAmountLabel = UILabel()
    private let spentAmountLabel = UILabel()
    private let centerCircle = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = CGFloat.stackViewSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        totalAmountLabel.textAlignment = .center
        totalAmountLabel.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.title.value)
        totalAmountLabel.textColor = .black
        
        spentAmountLabel.textAlignment = .center
        spentAmountLabel.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        spentAmountLabel.textColor = .gray
        
        stackView.addArrangedSubview(totalAmountLabel)
        stackView.addArrangedSubview(spentAmountLabel)
        
        centerCircle.backgroundColor = .white
        centerCircle.translatesAutoresizingMaskIntoConstraints = false
        centerCircle.layer.cornerRadius = bounds.width * 0.3
        
        addSubview(centerCircle)
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        centerCircle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(centerCircle.snp.width)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerCircle.layer.cornerRadius = centerCircle.bounds.width / 2
    }
    
    func setAmounts(total: String, spent: String) {
        totalAmountLabel.text = total
        spentAmountLabel.text = spent
    }
    
    func updateSegments(_ newSegments: [(color: UIColor, percentage: CGFloat)]) {
        segments = newSegments
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.45
        var startAngle: CGFloat = -.pi / 2
        
        for segment in segments {
            let endAngle = startAngle + (segment.percentage / 100 * .pi * 2)
            
            context.setFillColor(segment.color.cgColor)
            context.move(to: center)
            context.addArc(center: center,
                          radius: radius,
                          startAngle: startAngle,
                          endAngle: endAngle,
                          clockwise: false)
            context.closePath()
            context.fillPath()
            
            startAngle = endAngle
        }
    }
} 

private extension CGFloat {
    static let stackViewSpacing: CGFloat = 8
}
