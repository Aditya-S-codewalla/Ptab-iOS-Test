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
    var userId:String?
    var familyId:String?
    private init(){
    }
}
