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
        
        //adding swipe gestures to change the scope of the calendar
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        upSwipe.direction = .up
        downSwipe.direction = .down
        //view.addGestureRecognizer(upSwipe)
        //view.addGestureRecognizer(downSwipe)
        calendar.addGestureRecognizer(upSwipe)
        calendar.addGestureRecognizer(downSwipe)

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
        
        //Retreiving all events by querying with respect to userid. Later we can simply change it to family id.
        if let eventId = User.shared.userId {
            db.collection(K.FStore.collectionName).whereField(K.FStore.eventId, isEqualTo: eventId).addSnapshotListener { (querySnapshot, error) in
                
                self.datesWithEvents = []
                
                if let e = error {
                    print("\(e.localizedDescription) inside Calendar controller")
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
        else {
            print("Error retreiving user id")
        }
        
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if sender.direction == .up {
            calendar.scope = .week
        }
        if sender.direction == .down {
            calendar.scope = .month
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
