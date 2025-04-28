//
//  LoadingManager.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 28.04.25.
//

import UIKit

class LoadingManager {
    static let shared = LoadingManager()
    
    private var loadingView: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    
    private init() {}
    
    func show(on view: UIView, with text: String = "Загрузка...") {
        guard loadingView == nil else { return }
        
        let loadingView = UIView()
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingView.frame = view.bounds
        loadingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.center = CGPoint(x: loadingView.bounds.midX, y: loadingView.bounds.midY - 20)
        activityIndicator.startAnimating()
        
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.sizeToFit()
        label.frame = CGRect(x: 0, y: activityIndicator.frame.maxY + 8, width: loadingView.bounds.width, height: 20)
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
