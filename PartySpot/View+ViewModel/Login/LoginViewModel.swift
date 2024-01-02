//
//  LoginViewModel.swift
//  PartySpot
//
//  Created by Mickaël Horn on 16/10/2023.
//

import Combine

class LoginViewModel: ObservableObject {
    
    // MARK: - INPUT & OUTPUT
    enum Input {
        case signInButtonDidTap
    }
    
    enum Output {
        case fetchUserDidSucceed(user: User)
        case fetchUserDidFail(Error)
    }
    
    // MARK: - PROPERTIES
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    
    var email = ""
    var password = ""
    private var authService: FirebaseAuthServiceProtocol
    private var subscriptions = Set<AnyCancellable>()
    private let firestoreService: FirestoreServiceProtocol
    private let output: PassthroughSubject<Output, Never> = .init()
    
    var hasEmptyField: Bool {
        if email.isReallyEmpty || password.isReallyEmpty {
            return true
        }
        
        return false
    }

    // MARK: - INIT
    init(authService: FirebaseAuthServiceProtocol = FirebaseAuthService(),
         firestoreService: FirestoreServiceProtocol = FirestoreService()) {
        self.authService = authService
        self.firestoreService = firestoreService
    }
    
    // MARK: - FUNCTIONS
//    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
//        input
//            .filter { $0 == .signInButtonDidTap }
//            .flatMap { [weak self] _ -> AnyPublisher<FirebaseAuthService.UserID, FirebaseAuthService.AuthError> in
//                guard let self = self else {
//                    return Fail(error: FirebaseAuthService.AuthError.defaultError).eraseToAnyPublisher()
//                }
//                
//                return authService.signIn(email: email, password: password)
//            }
//            .catch { [weak self] authError -> AnyPublisher<FirebaseAuthService.UserID, Never> in
//                self?.output.send(.fetchUserDidFail(error: authError))
//                return Empty().eraseToAnyPublisher()
//            }
//            .flatMap { [weak self] userID -> AnyPublisher<User, FirestoreService.FirestoreServiceError> in
//                guard let self = self else {
//                    return Fail(error: FirestoreService.FirestoreServiceError.defaultError).eraseToAnyPublisher()
//                }
//                
//                return firestoreService.fetchUser(userID: userID)
//            }
//            .sink(receiveCompletion: { completion in
//                if case .failure(let error) = completion {
//                    self.output.send(.fetchUserDidFail(error: error))
//                }
//            }, receiveValue: { user in
//                self.output.send(.fetchUserDidSucceed(user: user))
//            })
//            .store(in: &subscriptions)
//        
//        return output.eraseToAnyPublisher()
//    }

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .filter { $0 == .signInButtonDidTap }
            .flatMap { [weak self] _ in
                guard let self = self else {
                    return Just(Output.fetchUserDidFail(FirebaseAuthService.AuthError.defaultError))
                        .eraseToAnyPublisher()
                }

                return authService.signIn(email: email, password: password)
                    .flatMap { [weak self] userID in
                        guard let self = self else {
                            return Just(Output.fetchUserDidFail(FirebaseAuthService.AuthError.defaultError))
                                .eraseToAnyPublisher()
                        }

                        return firestoreService.fetchUser(userID: userID)
                            .flatMap { [weak self] user in
                                guard let self else {
                                    return Just(Output.fetchUserDidFail(FirebaseAuthService.AuthError.defaultError))
                                        .eraseToAnyPublisher()
                                }

                                return Just(Output.fetchUserDidSucceed(user: user)).eraseToAnyPublisher()
                            }
                            .catch {
                                Just(Output.fetchUserDidFail($0))
                            }
                            .eraseToAnyPublisher()
                    }
                    .catch {
                        Just(Output.fetchUserDidFail($0))
                    }
                    .eraseToAnyPublisher()
            }
            .sink(receiveValue: { [output] value in
                output.send(value)
            })
            .store(in: &subscriptions)

        return output.eraseToAnyPublisher()

    }

    func formCheck() throws {
        guard hasEmptyField == false else {
            throw LoginFormError.emptyFields
        }
        
        guard email.isValidEmail() else {
            throw LoginFormError.badlyFormattedEmail
        }
    }
    
    /*private func authenticate() {
        authService.signIn(email: email, password: password)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.output.send(.signInDidFail(error: error))
                }
            } receiveValue: { [weak self] userID in
                self?.output.send(.signInDidSucceed(userID: userID))
            }
            .store(in: &subscriptions)
    }*/
    
    /*private func handleFetchUser(userID: String) {
        firestoreService.fetchUser(userID: userID)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.output.send(.fetchUserDidFail(error: error))
                }
            } receiveValue: { [weak self] user in
                self?.output.send(.fetchUserDidSucceed(user: user))
            }
            .store(in: &subscriptions)
    }*/
}

// MARK: - LOGIN ERROR
enum LoginFormError: Error {
    case badlyFormattedEmail
    case emptyFields

    var errorDescription: String {
        switch self {
        case .badlyFormattedEmail:
            return "Badly formatted email, please provide a correct one."
        case .emptyFields:
            return "All fields must be filled."
        }
    }
}
