//
//  DynamicLinkViewController.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 19/05/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import UIKit

class DynamicLinkViewController: UIViewController {

    @IBOutlet weak var uinLabel: UILabel!
    @IBOutlet weak var linkSenderName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        uinLabel.text = "UIN value from link:\(User.shared.uin ?? "No Value/link broken")"
        linkSenderName.text = "Invite sent by:\(User.shared.tempLinkSenderName?.replacingOccurrences(of: "+", with: " ") ?? "No Value/link broken")"
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func navigateToLogin(_ sender: UIButton) {
        self.performSegue(withIdentifier: "LinkToLogin", sender: nil)
    }
    

}
