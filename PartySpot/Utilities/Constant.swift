//
//  Constant.swift
//  PartySpot
//
//  Created by Mickaël Horn on 19/10/2023.
//

import Foundation

enum Constant {
    
    enum FirestoreTables {
        
        enum User {
            static let tableName = "User"
            
            static let lastname = "lastname"
            static let firstname = "firstname"
            static let age = "age"
            static let gender = "gender"
            static let email = "email"
        }
    }
    
    enum SegueIdentifiers {
        static let unwindToRootVC = "unwindToRootVC"
        static let segueToCreateAccountViewController = "segueToCreateAccountViewController"
    }
}
