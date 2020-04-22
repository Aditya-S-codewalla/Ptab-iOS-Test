//
//  EventCell.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 22/04/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import UIKit
import Firebase

class EventCell: UITableViewCell {

    @IBOutlet weak var eventLabel: UILabel!
    
    var eventId:String?
    let db = Firestore.firestore()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func DeleteButtonPressed(_ sender: UIButton) {
        
        if let eId = eventId {
            db.collection(K.FStore.collectionName).document(eId).delete { (error) in
                if let e = error {
                    print(e.localizedDescription)
                }
                else {
                    print("Document deletion successful")
                }
            }
        }
        
    }
    
}
