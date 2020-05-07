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
        aView?.backgroundColor = UIColor.gray
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = aView!.center
        activityIndicator.startAnimating()
        aView?.addSubview(activityIndicator)
        self.view.addSubview(aView!)
    }
    
    func removeLoader() {
        aView?.removeFromSuperview()
        aView = nil
    }
    
}
