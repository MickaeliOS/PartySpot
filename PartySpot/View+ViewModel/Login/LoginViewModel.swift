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
    
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    
    var email = ""
    var password = ""
    private var authService: FirebaseAuthServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: FirebaseAuthServiceProtocol = FirebaseAuthService(),
         firestoreService: FirestoreServiceProtocol = FirestoreService()) {
        self.authService = authService
        self.firestoreService = firestoreService
    }
    
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
            .store(in: &cancellables)
            return output.eraseToAnyPublisher()
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
            .store(in: &cancellables)
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
            .store(in: &cancellables)

    }
}

