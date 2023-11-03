//
//  FirestoreService.swift
//  PartySpot
//
//  Created by Mickaël Horn on 19/10/2023.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - PROTOCOL
protocol FirestoreServiceProtocol {
    func saveUserInDatabase(userID: String, user: User) -> AnyPublisher<Void, Error>
    func fetchUser(userID: String) -> AnyPublisher<User, Error>
}

// MARK: - CLASS
class FirestoreService: FirestoreServiceProtocol {
    func saveUserInDatabase(userID: String, user: User) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            let docRef = Firestore
                .firestore()
                .collection(Constant.FirestoreTables.User.tableName)
                .document(userID)
            
            do {
                try docRef.setData(from: user)
                promise(.success(()))
            } catch {
                promise(.failure(FirestoreError.defaultError))
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchUser(userID: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            let docRef = Firestore.firestore().collection(Constant.FirestoreTables.User.tableName).document(userID)
            docRef.getDocument { documentSnapshot, error in
                
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let documentSnapshot = documentSnapshot else {
                    promise(.failure(FirestoreError.documentNotFound))
                    return
                }
                
                do {
                    let user = try documentSnapshot.data(as: User.self)
                    promise(.success(user))
                } catch {
                    print(error)
                    promise(.failure(FirestoreError.invalidUserData))
                }
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - ERROR HANDLING
enum FirestoreError: Error {
    case documentNotFound
    case invalidUserData
    case defaultError
}

extension FirestoreError {
    var errorDescription: String {
        switch self {
        case .documentNotFound:
            return "Document not found."
        case .invalidUserData:
            return "The user data are invalid."
        case .defaultError:
            return "Something went wrong"
        }
    }
}
