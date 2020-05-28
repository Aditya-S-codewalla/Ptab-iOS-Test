//
//  CalendarAndEventsViewController.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 27/05/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase

class CalendarAndEventsViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var eventTable: UITableView!
    
    var dateString:String?
    var timeString:String?
    
    let db = Firestore.firestore()
    var events:[Event] = []
    
    var formattedDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy 'at' HH:mm"
        return formatter
    }()
    
    var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: Date())
    }
    
    var monthExtractor: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }
    
    var toggleFullEventDetails: Bool = true
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        calendar.dataSource = self
        calendar.delegate = self
        
        eventTable.dataSource = self
        
        dateString = formattedDate.string(from: Date())
        
        fetchEventsForMonth(currentMonth)
        
        //adding swipe gestures to change the scope of the calendar
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        upSwipe.direction = .up
        downSwipe.direction = .down
    
        calendar.addGestureRecognizer(upSwipe)
        calendar.addGestureRecognizer(downSwipe)
        
    }
    
    func fetchEventsForMonth(_ month:String) {
        if User.shared.userId != nil {
            db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).whereField(K.FStore.monthField, isEqualTo: month).getDocuments { (querySnapshot, error) in
                
                self.events = []
                
                if let e = error {
                    print(e.localizedDescription)
                }
                else {
                    
                    if let snapshotDocuments = querySnapshot?.documents {
                        
                        for doc in snapshotDocuments {
                            
                            let data = doc.data()
                            
                            if let eventCreator = data[K.FStore.creatorField] as? String, let eventTitle = data[K.FStore.titleField] as? String, let timeString = data[K.FStore.timeStringField] as? String, let eventMonth = data[K.FStore.monthField] as? String {
                                
                                let newEvent = Event(title: eventTitle, dateString: data[K.FStore.dateStringField] as! String, timeString: timeString, month: eventMonth, creator: eventCreator, dateAdded: data[K.FStore.dateField] as! Double, id: doc.documentID)
                                
                                self.events.append(newEvent)
                                
                            }
                        }
                        DispatchQueue.main.async {
                            self.eventTable.reloadData()
                        }
                    }
                
                }
            }
        }
    }
    
    func loadEventsForSelectedDate() {
        
        if let dateStr = dateString, let eventId = User.shared.userId {
            print("About to enter fetch collection query")
            db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).whereField(K.FStore.dateStringField, isEqualTo: dateStr).whereField(K.FStore.eventId, isEqualTo: eventId).addSnapshotListener { (querySnapshot, error) in
                
                self.events = []
                
                if let e = error {
                    print(e.localizedDescription)
                }
                else {
                    
                    if let snapshotDocuments = querySnapshot?.documents {
                        
                        for doc in snapshotDocuments {
                            
                            let data = doc.data()
                            
                            if let eventCreator = data[K.FStore.creatorField] as? String, let eventTitle = data[K.FStore.titleField] as? String, let timeString = data[K.FStore.timeStringField] as? String, let eventMonth = data[K.FStore.monthField] as? String {
                                
                                let newEvent = Event(title: eventTitle, dateString: data[K.FStore.dateStringField] as! String, timeString: timeString, month: eventMonth, creator: eventCreator, dateAdded: data[K.FStore.dateField] as! Double, id: doc.documentID)
                                
                                self.events.append(newEvent)
                                
                            }
                            
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.eventTable.reloadData()
                        }
                    }
                    
                    print("Fetch collection finished")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventCreationSegue" {
            let destinationVC = segue.destination as! EventCreationViewController
            destinationVC.delegate = self
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

extension CalendarAndEventsViewController: FSCalendarDataSource {
    
}

extension CalendarAndEventsViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateString = formattedDate.string(from: date)
        toggleFullEventDetails = false
        loadEventsForSelectedDate()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let calendarCurrentPageDate = calendar.currentPage
        let changedMonth = monthExtractor.string(from: calendarCurrentPageDate)
        toggleFullEventDetails = true
        
        fetchEventsForMonth(changedMonth)
    }
}

extension CalendarAndEventsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        let event = events[indexPath.row]
        
        if toggleFullEventDetails == true {
            cell.textLabel?.text = event.title+" on "+event.dateString+" at "+event.timeString
        } else {
            cell.textLabel?.text = event.title+" at "+event.timeString
        }
        
        return cell
    }
    
}

extension CalendarAndEventsViewController: onEventCreationSuccess {
    
    func createEventObject(_ time: String, _ desc: String) {
        if let dateStr = dateString {
            
            let combinedDateString = dateStr+" at "+time
            let combinedDate = self.dateFormatter.date(from: combinedDateString)
            
            if let eventCreator = Auth.auth().currentUser?.email, let finalDate = combinedDate {
                
                let eventId = Auth.auth().currentUser?.uid
                let eventMonth = monthExtractor.string(from: finalDate)
                
                let event = Event(title: desc, dateString: dateStr, timeString: time, month: eventMonth, creator: eventCreator, dateAdded: finalDate.timeIntervalSince1970, id: eventId!)
                
                db.collection(K.FStore.collectionName).addDocument(data: event.eventDict) { (error) in
                    if let e = error {
                        print(e.localizedDescription)
                    }
                    else {
                        print("Write To DB success new")
                    }
                }
                
            }
            
        }
    }
    
    
}


