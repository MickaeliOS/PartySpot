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
    func saveUser(userID: String, user: User) throws
    func fetchUser(userID: String) -> AnyPublisher<User, FirestoreUserService.Error>
}

// MARK: - CLASS
final class FirestoreUserService: FirestoreServiceProtocol {
    private static let tableName = "User"
    
    func saveUser(userID: String, user: User) throws {
        let docRef = Firestore
            .firestore()
            .collection(Self.tableName)
            .document(userID)
        
            try docRef.setData(from: user)
    }
    
    func fetchUser(userID: String) -> AnyPublisher<User, FirestoreUserService.Error> {
        return Future<User, Error> { promise in
            let docRef = Firestore.firestore().collection(Self.tableName).document(userID)

            docRef.getDocument { documentSnapshot, error in
                
                if error != nil {
                    promise(.failure(Error.defaultError))
                    return
                }
                
                guard let documentSnapshot = documentSnapshot else {
                    promise(.failure(Error.documentNotFound))
                    return
                }
                
                do {
                    let user = try documentSnapshot.data(as: User.self)
                    promise(.success(user))
                } catch {
                    promise(.failure(Error.invalidUserData))
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension FirestoreUserService {
    // MARK: - ERROR HANDLING
    enum Error: Swift.Error {
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
