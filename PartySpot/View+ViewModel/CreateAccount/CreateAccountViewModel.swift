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
        case createAccountProcessButtonTapped
    }
    
    enum Output {
        case idle
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
    //@Published var email: String = ""
    //@Published var password: String = ""
    var confirmPassword: String = ""

    private let authService: FirebaseAuthServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private let output: PassthroughSubject<Output, Never> = .init()
    //@Published private(set) var output: Output = .idle
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
         firestoreService: FirestoreServiceProtocol = FirestoreUserService()) {
        
        self.authService = authService
        self.firestoreService = firestoreService
    }
    
    // MARK: - FUNCTIONS
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .flatMap { [weak self] _ -> AnyPublisher<String, Error> in
                guard let self = self else {
                    return Fail(error: FirestoreUserService.Error.defaultError).eraseToAnyPublisher()
                }
                
                return self.authService.createAccount(email: self.email, password: self.password)
            }
            .tryMap { [weak self] userID -> Output in
                guard let self = self else {
                    throw FirestoreUserService.Error.defaultError
                }
                
                let user = try self.saveUserInDatabase(userID: userID)
                
                return .accountCreationDidSucceed(user: user)
            }
            .catch { Just(Output.accountCreationDidFailed($0)) }
            .sink { output in
                self.output.send(output)
            }
            .store(in: &subscriptions)
        
        return output.eraseToAnyPublisher()
    }
    
    private func saveUserInDatabase(userID: String) throws -> User {
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
