//
//  Event.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 22/04/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import Foundation
struct Event {
    let title:String
    let dateString:String
    let timeString:String
    let month:String
    let creator:String
    let dateAdded:Double
    let id:String
    
    var eventDict:[String:Any] {
        var dict = [String:Any]()
        dict[K.FStore.titleField]=self.title
        dict[K.FStore.creatorField]=self.creator
        dict[K.FStore.dateStringField]=self.dateString
        dict[K.FStore.dateField]=self.dateAdded
        dict[K.FStore.eventId]=self.id
        dict[K.FStore.timeStringField] = self.timeString
        dict[K.FStore.monthField] = self.month
        return dict
    }
    
}
