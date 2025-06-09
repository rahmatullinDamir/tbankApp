//
//  LoadingManager.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 28.04.25.
//

import UIKit

class CustomLoadingManager {
    static let shared = CustomLoadingManager()
    
    private var loadingView: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    
    private init() {}
    
    func show(on view: UIView, with text: String = "Загрузка...") {
        guard loadingView == nil else { return }
        
        let loadingView = UIView()
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(CGFloat.backgoundAlpha)
        loadingView.frame = view.bounds
        loadingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.center = CGPoint(x: loadingView.bounds.midX, y: loadingView.bounds.midY - CGFloat.activityIndicatorTopOffset)
        activityIndicator.startAnimating()
        
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.regular.value)
        label.sizeToFit()
        label.frame = CGRect(x: 0, y: activityIndicator.frame.maxY + Padding.tiny.value, width: loadingView.bounds.width, height: CGFloat.labelHeight)
        label.textAlignment = .center
        
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(label)
        view.addSubview(loadingView)
        
        self.loadingView = loadingView
        self.activityIndicator = activityIndicator
    }
    
    func hide() {
        guard let loadingView = loadingView else { return }
        loadingView.removeFromSuperview()
        self.loadingView = nil
        self.activityIndicator = nil
    }
}

private extension CGFloat {
    static let labelHeight: CGFloat = 20
    static let activityIndicatorTopOffset: CGFloat = 20
    static let backgoundAlpha: CGFloat = 0.5
}
