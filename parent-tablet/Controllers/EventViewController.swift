//
//  EventViewController.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 21/04/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import UIKit
import Firebase

class EventViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var eventTitleTextField: UITextField!
    var dateString:String?
    let db = Firestore.firestore()
    var events:[Event] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        LoadEvents()
    }
    
    @IBAction func AddEventButtonPressed(_ sender: UIButton) {
        
        if let eventBody = eventTitleTextField.text, let eventCreator = Auth.auth().currentUser?.email, let dateStr = dateString {
            
            //let writeId = db.collection(K.FStore.collectionName).document().documentID
            let eventId = Auth.auth().currentUser?.uid
            
            let event = Event(title: eventBody, dateString: dateStr, timeString: "random time", month: "random month", creator: eventCreator, dateAdded: Date().timeIntervalSince1970, id: eventId!)
            
            db.collection(K.FStore.collectionName).addDocument(data: event.eventDict) { (error) in
                if let e = error {
                    print(e.localizedDescription)
                }
                else {
                    print("Write To DB success")
                    DispatchQueue.main.async {
                        self.eventTitleTextField.text = ""
                    }
                }
            }
            
        }
    }
    
    func LoadEvents() {
        if let dateStr = dateString, let eventId = User.shared.userId {
            
            db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).whereField(K.FStore.dateStringField, isEqualTo: dateStr).whereField(K.FStore.eventId, isEqualTo: eventId).addSnapshotListener { (querySnapshot, error) in
                
                self.events = []
                
                if let e = error {
                    print(e.localizedDescription)
                }
                else {
                    
                    if let snapshotDocuments = querySnapshot?.documents {
                        
                        for doc in snapshotDocuments {
                            
                            let data = doc.data()
                            
                            if let eventCreator = data[K.FStore.creatorField] as? String, let eventTitle = data[K.FStore.titleField] as? String {
                                
                                let newEvent = Event(title: eventTitle, dateString: data[K.FStore.dateStringField] as! String, timeString: data[K.FStore.timeStringField] as! String, month: "random month", creator: eventCreator, dateAdded: data[K.FStore.dateField] as! Double, id: doc.documentID)
                                
                                self.events.append(newEvent)
                                
                            }
                        }
                        if snapshotDocuments.count == 0 {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.events.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    

}

extension EventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = events[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! EventCell
        cell.eventLabel.text = event.title
        cell.eventId = event.id
        return cell
    }
    
    
}
