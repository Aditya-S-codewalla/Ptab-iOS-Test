//
//  User.swift
//  parent-tablet
//
//  Created by Aditya Sinha on 04/05/20.
//  Copyright © 2020 codewalla. All rights reserved.
//

import Foundation

class User {
    static let shared = User()
    
    private init(){}
    
    var userId:String?
    var familyId:String?
    var userName:String?
    
    var userDict:[String:Any]{
        return [K.FStore.userIdField:userId ?? "",
                K.FStore.familyIdField:familyId ?? "",
                K.FStore.userNameField:userName ?? ""]
    }
}
