import UIKit
import SnapKit

protocol BudgetSliderViewDelegate: AnyObject {
    func budgetSliderView(_ view: BudgetSliderView, didUpdateValue value: Double)
}

class BudgetSliderView: UIView {
    weak var delegate: BudgetSliderViewDelegate?
    
    private let slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        return slider
    }()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.regular.value)
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.regular.value)
        return label
    }()
    
    private var totalBudget: Double
    private var maxAllowedValue: Double = 100.0
    
    init(color: UIColor, totalBudget: Double) {
        self.totalBudget = totalBudget
        super.init(frame: .zero)
        setupUI()
        slider.tintColor = color
        slider.thumbTintColor = color
        updateLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(slider)
        addSubview(percentageLabel)
        addSubview(amountLabel)
        
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        slider.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Padding.tiny.value)
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.trailing.equalToSuperview().offset(-Padding.default.value)
        }
        
        percentageLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(Padding.tiny.value)
            make.trailing.equalToSuperview().offset(-Padding.default.value)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(Padding.tiny.value)
            make.leading.equalToSuperview().offset(Padding.default.value)
        }
    }
    
    func setValue(_ value: Double) {
        let clampedValue = min(value, maxAllowedValue)
        slider.value = Float(clampedValue)
        updateLabels()
    }
    
    func setMaxAllowedValue(_ value: Double) {
        maxAllowedValue = value
        slider.maximumValue = Float(value)
        updateLabels()
    }
    
    func updateTotalBudget(_ budget: Double) {
        totalBudget = budget
        updateLabels()
    }
    
    @objc private func sliderValueChanged() {
        let value = Double(slider.value)
        updateLabels()
        delegate?.budgetSliderView(self, didUpdateValue: value)
    }
    
    private func updateLabels() {
        let percentage = Double(slider.value)
        let amount = totalBudget * (percentage / 100.0)
        
        percentageLabel.text = String(format: "%.1f%%", percentage)
        amountLabel.text = String(format: "%.0f ₽", amount)
    }
} 
