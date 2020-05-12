//
//  Util.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 07/05/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import Foundation
import UIKit

fileprivate var aView : UIView?

extension UIViewController {
    
    func showLoader() {
        aView = UIView(frame: self.view.bounds)
        aView?.backgroundColor = UIColor.cyan
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = aView!.center
        activityIndicator.startAnimating()
        aView?.addSubview(activityIndicator)
        self.navigationController?.navigationBar.toggle()
        self.view.addSubview(aView!)
    }
    
    func removeLoader() {
        aView?.removeFromSuperview()
        self.navigationController?.navigationBar.toggle()
        aView = nil
    }
    
}

extension UINavigationBar {
    func toggle() {
        if self.layer.zPosition == -1 {
            self.layer.zPosition = 0
            self.isUserInteractionEnabled = true
        } else {
            self.layer.zPosition = -1
            self.isUserInteractionEnabled = false
        }
    }
}
