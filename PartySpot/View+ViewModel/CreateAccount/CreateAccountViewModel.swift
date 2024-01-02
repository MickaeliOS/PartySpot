//
//  CreateAccountViewModel.swift
//  PartySpot
//
//  Created by Mickaël Horn on 16/10/2023.
//

import Foundation
import Combine

final class CreateAccountViewModel: ObservableObject {
    
    // MARK: - INPUT & OUTPUT
    enum Input: Equatable {
        case createAccountButtonTapped
    }
    
    enum Output {
        case accountCreationDidSucceed(user: User)
        case accountCreationDidFailed(Error)
    }
    
    // MARK: - PROPERTIES
    var lastname: String = ""
    var firstname: String = ""
    var gender: User.Gender = .male
    var birthdate: Date = Date.now
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""

    private let authService: FirebaseAuthServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    var hasEmptyField: Bool {
        return email.isReallyEmpty
        || password.isReallyEmpty
        || confirmPassword.isReallyEmpty
        || lastname.isReallyEmpty
        || firstname.isReallyEmpty
    }

    // MARK: - INIT
    init(authService: FirebaseAuthServiceProtocol = FirebaseAuthService(),
         firestoreService: FirestoreServiceProtocol = FirestoreService()) {
        
        self.authService = authService
        self.firestoreService = firestoreService
    }
    
    // MARK: - FUNCTIONS
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .filter { $0 == .createAccountButtonTapped }
            .flatMap { [weak self] _ in
                guard let self = self else {
                    return Just(Output.accountCreationDidFailed(FirebaseAuthService.AuthError.defaultError))
                        .eraseToAnyPublisher()
                }

                return authService.createAccount(email: email, password: password)
                    .tryMap { [weak self] userID in
                        guard let self = self else {
                            throw FirestoreService.FirestoreServiceError.defaultError
                        }

                        let user = try saveUserInDatabase(userID: userID)
                        return .accountCreationDidSucceed(user: user)
                    }
                    .catch {
                        Just(Output.accountCreationDidFailed($0))
                    }
                    .eraseToAnyPublisher()
            }
            .sink(receiveValue: { [output] value in
                output.send(value)
            })
            .store(in: &subscriptions)

        return output.eraseToAnyPublisher()
    }

    private func saveUserInDatabase(userID: String) throws -> User {
        // TODO: Idéalement, ne renvoie pas l'user que tu as déjà mais plutôt celui qui est sur Firestore car imagine s'il y a une différence entre l'user qui vient d'être créé et celui de ton app.
        let user = User(
            lastname: lastname,
            firstname: firstname,
            email: email,
            birthdate: birthdate,
            gender: gender
        )
                
        try firestoreService.saveUser(userID: userID, user: user)
        return user
    }
    
    func validateForm() throws {
        guard !hasEmptyField else {
            throw CreationFormError.emptyFields
        }
        
        guard email.isValidEmail() else {
            throw CreationFormError.badlyFormattedEmail
        }
        
        guard isValidPassword(password) else {
            throw CreationFormError.weakPassword
        }
        
        guard passwordEqualityCheck(password: password, confirmPassword: confirmPassword) else {
            throw CreationFormError.passwordsNotEquals
        }
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // Same logic as the email verification.
        let regex = #"(?=^.{7,}$)(?=^.*[A-Z].*$)(?=^.*\d.*$).*"#
        
        return password.range(
            of: regex,
            options: .regularExpression
        ) != nil
    }
    
    private func passwordEqualityCheck(password: String, confirmPassword: String) -> Bool {
        return password == confirmPassword
    }
}

// MARK: - CREATION ERROR
enum CreationFormError: Error {
    case badlyFormattedEmail
    case weakPassword
    case passwordsNotEquals
    case emptyFields

    var errorDescription: String {
        switch self {
        case .badlyFormattedEmail:
            return "Badly formatted email, please provide a correct one."
        case .weakPassword:
            return "Your password is too weak. It must be : \n - At least 7 characters long \n - At least one uppercase letter \n - At least one number"
        case .passwordsNotEquals:
            return "Passwords must be equals."
        case .emptyFields:
            return "All fields must be filled."
        }
    }
}
