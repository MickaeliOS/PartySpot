//
//  User.swift
//  PartySpot
//
//  Created by Mickaël Horn on 16/10/2023.
//

import Foundation

struct User: Codable {
    enum UserTable {
        static let lastname = "lastname"
        static let firstname = "firstname"
        static let age = "age"
        static let gender = "gender"
        static let email = "email"
    }
    
    enum Gender: String, Codable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }
    
    let lastname: String
    let firstname: String
    let email: String
    let birthdate: Date?
    let gender: Gender
    var profilePicture: String?
}
