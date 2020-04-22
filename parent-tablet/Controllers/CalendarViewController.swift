//
//  CalendarViewController.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 21/04/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase

class CalendarViewController: UIViewController {
    
    fileprivate weak var calendar: FSCalendar!
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var dateSelected:String?
    var datesWithEvents:[String]=[]
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let calendar = FSCalendar(frame: CGRect(x: 0, y: UIScreen.main.bounds.width/2, width: UIScreen.main.bounds.width, height: 400))
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        self.calendar = calendar

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FetchAllEvents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.CalendarEventSegue {
            let destinationVC = segue.destination as! EventViewController
            destinationVC.dateString = dateSelected
        }
    }
    
    func FetchAllEvents() {
        db.collection(K.FStore.collectionName).addSnapshotListener { (querySnapshot, error) in
            
            self.datesWithEvents = []
            
            if let e = error {
                print(e.localizedDescription)
            }
            else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let eventDate = data[K.FStore.dateStringField] as? String {
                            self.datesWithEvents.append(eventDate)
                        }
                    }
                    DispatchQueue.main.async {
                        self.calendar.reloadData()
                    }
                }
            }
        }
        
    }
    
}

extension CalendarViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.dateFormatter.string(from: date)
        if self.datesWithEvents.contains(dateString) {
            return 1
        }
        else {
            return 0
        }
    }
}

extension CalendarViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.dateSelected = dateFormatter.string(from: date)
        self.performSegue(withIdentifier: K.CalendarEventSegue, sender: self)
    }
}
