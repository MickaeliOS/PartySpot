//
//  Constant.swift
//  PartySpot
//
//  Created by Mickaël Horn on 19/10/2023.
//

import Foundation

enum Constant {
    
    // MARK: - FIRESTORE TABLES
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
    
    // MARK: - SEGUE IDENTIFIERS
    enum SegueIdentifiers {
        static let unwindToRootVC = "unwindToRootVC"
        static let segueToCreateAccountViewController = "segueToCreateAccountViewController"
    }
    
    // MARK: - VIEW CONROLLER IDENTIFIERS
    enum VCIdentifiers {
        static let loginVC = "LoginViewController"
    }
}
