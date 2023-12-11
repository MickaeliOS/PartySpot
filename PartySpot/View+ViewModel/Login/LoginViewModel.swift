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
        case fetchUser(userID: String)
    }
    
    enum Output {
        case signInDidSucceed(userID: String)
        case signInDidFail(error: Error)
        case fetchUserDidSucceed(user: User)
        case fetchUserDidFail(error: Error)
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
         firestoreService: FirestoreServiceProtocol = FirestoreUserService()) {
        self.authService = authService
        self.firestoreService = firestoreService
    }
    
    // MARK: - FUNCTIONS
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                switch event {
                case .signInButtonDidTap:
                    self?.authenticate()
                    
                case .fetchUser(let userID):
                    self?.handleFetchUser(userID: userID)
                }
            }
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
    
    private func authenticate() {
        authService.signIn(email: email, password: password)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.output.send(.signInDidFail(error: error))
                }
            } receiveValue: { [weak self] userID in
                self?.output.send(.signInDidSucceed(userID: userID))
            }
            .store(in: &subscriptions)
    }
    
    private func handleFetchUser(userID: String) {
        firestoreService.fetchUser(userID: userID)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.output.send(.fetchUserDidFail(error: error))
                }
            } receiveValue: { [weak self] user in
                self?.output.send(.fetchUserDidSucceed(user: user))
            }
            .store(in: &subscriptions)
    }
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
