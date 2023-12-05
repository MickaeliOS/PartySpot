//
//  Constant.swift
//  PartySpot
//
//  Created by Mickaël Horn on 19/10/2023.
//

import Foundation

// Avoid making a Constants file with all your static strings.
// It will become a mess
// Move each one in their class
// For example here FirestoreTables constants would be better in your firestore classes (services) and put them private.
// Or for lastname constants, put them in your firestore DTO (User model here) instead
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
