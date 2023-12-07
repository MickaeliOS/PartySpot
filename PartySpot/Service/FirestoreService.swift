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
    let tableName = "User"

    func saveUserInDatabase(userID: String, user: User) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            let docRef = Firestore
                .firestore()
                .collection(self.tableName)
                .document(userID)
            
            do {
                try docRef.setData(from: user)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchUser(userID: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            let docRef = Firestore.firestore().collection(self.tableName).document(userID)
            docRef.getDocument { documentSnapshot, error in
                
                /*if let error = error {
                    promise(.failure(error))
                    return
                }*/
                
                if error != nil {
                    promise(.failure(FirestoreError.defaultError))
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

extension FirestoreService {
    // MARK: - ERROR HANDLING
    enum FirestoreError: Error {
        case documentNotFound
        case invalidUserData
        case defaultError
        
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
}

