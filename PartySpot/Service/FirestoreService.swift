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
    func fetchUser(userID: String) -> AnyPublisher<User, FirestoreService.FirestoreServiceError>
}

// MARK: - CLASS
final class FirestoreService: FirestoreServiceProtocol {
    private static let userTableName = "User"
    
    func saveUser(userID: String, user: User) throws {
        let docRef = Firestore
            .firestore()
            .collection(Self.userTableName)
            .document(userID)
        
            try docRef.setData(from: user)
    }
    
    func fetchUser(userID: String) -> AnyPublisher<User, FirestoreService.FirestoreServiceError> {
        return Future<User, FirestoreService.FirestoreServiceError> { promise in
            let docRef = Firestore.firestore().collection(Self.userTableName).document(userID)

            docRef.getDocument { documentSnapshot, error in
                
                if error != nil {
                    promise(.failure(FirestoreServiceError.defaultError))
                    return
                }
                
                guard let documentSnapshot = documentSnapshot else {
                    promise(.failure(FirestoreServiceError.documentNotFound))
                    return
                }
                
                do {
                    let user = try documentSnapshot.data(as: User.self)
                    promise(.success(user))
                } catch {
                    promise(.failure(FirestoreServiceError.invalidUserData))
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension FirestoreService {
    // MARK: - ERROR HANDLING
    enum FirestoreServiceError: Error {
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
