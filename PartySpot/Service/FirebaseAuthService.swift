//
//  FirebaseAuthService.swift
//  PartySpot
//
//  Created by Mickaël Horn on 16/10/2023.
//

import FirebaseAuth
import Combine

// MARK: - PROTOCOL
protocol FirebaseAuthServiceProtocol {
    typealias UserID = String
    
    func createAccount(email: String, password: String) -> AnyPublisher<UserID, FirebaseAuthService.AuthError>
    func signIn(email: String, password: String) -> AnyPublisher<UserID, FirebaseAuthService.AuthError>
}

// MARK: - CLASS
final class FirebaseAuthService: FirebaseAuthServiceProtocol {
    func createAccount(email: String, password: String) -> AnyPublisher<UserID, FirebaseAuthService.AuthError> {
        return Future<UserID, FirebaseAuthService.AuthError> { promise in
            Task {
                do {
                    let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
                    let userID = authDataResult.user.uid
                    promise(.success((userID)))
                } catch {
                    promise(.failure(self.handleFirebaseError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<UserID, FirebaseAuthService.AuthError> {
        return Future<UserID, FirebaseAuthService.AuthError> { promise in
            Task {
                do {
                    let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
                    promise(.success(authDataResult.user.uid))
                } catch {
                    promise(.failure(self.handleFirebaseError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func handleFirebaseError(_ error: Error) -> FirebaseAuthService.AuthError {
        let nsError = error as NSError
        
        if nsError.userInfo["NSUnderlyingError"].debugDescription.contains("INVALID_LOGIN_CREDENTIALS") {
            return .invalidCredentials
        } else if nsError.userInfo.debugDescription.contains("ERROR_NETWORK_REQUEST_FAILED") {
            return .networkError
        } else {
            return .defaultError
        }
    }
}

extension FirebaseAuthService {
    // MARK: - ERROR HANDLING
    enum AuthError: Error {
        case invalidCredentials
        case networkError
        case defaultError
        
        var errorDescription: String {
            switch self {
            case .invalidCredentials:
                return "Incorrect email or password."
            case .networkError:
                return "Please verify your network."
            case .defaultError:
                return "An error occured."
            }
        }
    }
}
