//
//  Constants.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 21/04/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import Foundation

struct K {
    static let appName = "Parent-Tablet"
    static let registerSegue = "RegisterToMain"
    static let loginSegue = "LoginToMain"
    static let CalendarEventSegue = "CalendarToEvent"
    static let ContactsSegue = "Contacts"
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "EventCell"
    
    struct FStore {
        static let collectionName = "Events"
        static let creatorField = "creator"
        static let titleField = "title"
        static let dateStringField = "dateString"
        static let dateField = "dateAdded"
        static let eventId = "id"
        
        static let userCollectionsName = "Users"
        static let userIdField = "userId"
        static let familyIdField = "familyId"
    }
    
}
