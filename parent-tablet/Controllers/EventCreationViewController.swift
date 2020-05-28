//
//  EventCreationViewController.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 28/05/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import UIKit

protocol onEventCreationSuccess {
    func createEventObject(_ time:String, _ desc:String) -> Void
}

class EventCreationViewController: UIViewController {
    
    
    @IBOutlet weak var eventDescription: UITextField!
    @IBOutlet weak var eventTimePicker: UIDatePicker!
    
    var delegate: onEventCreationSuccess?
    
    var formattedTime: String {
        let formatter = DateFormatter()
        //formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: eventTimePicker.date)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func eventCreatePressed(_ sender: UIButton) {
        if let eventDesc = eventDescription.text {
            delegate?.createEventObject(formattedTime, eventDesc)
            self.dismiss(animated: true)
        }
        
    }
    
}
