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
    enum Input {
        case createAccountButtonDidTap
        // Bad naming: saveUser is better because the VC shouldn't know where the user is stored. Database, of file, or somewhere else, VC doesn't care about
        case saveUserInDatabase(userID: String)
        // Why not having all textfields input here? If you put them here, you will make all your properties private (see below)
    }
    
    enum Output {
        case createAccountDidSucceed(userID: String)
        case createAccountDidFail(error: Error)
        case saveUserInDatabaseDidFail(error: Error)
        case saveUserInDatabaseDidSucceed(user: User)
    }
    
    // MARK: - PROPERTIES
    // They should be private
    var lastname: String = "" // Is empty a good value for you? Why? IMO, if no lastname is been entered, it should be nil, not empty. The textfield's text property is an Optional of String: https://developer.apple.com/documentation/uikit/uitextfield/1619635-text, same for UILabel. Same for the others
    var firstname: String = ""
    var gender: User.Gender = .male
    var birthdate: Date = Date.now
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""

    private let authService: FirebaseAuthServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    var hasEmptyField: Bool {
        if email.isReallyEmpty || password.isReallyEmpty || confirmPassword.isReallyEmpty || lastname.isReallyEmpty || firstname.isReallyEmpty {
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
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                switch event {
                case .createAccountButtonDidTap:
                    self?.handleCreateAccount()
                    
                case .saveUserInDatabase(let userID):
                    self?.handleSaveUserInDatabase(userID: userID)
                }
            }
            .store(in: &cancellables)
            return output.eraseToAnyPublisher()
    }
    
    private func handleCreateAccount() {
        authService.createAccount(email: email, password: password)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.output.send(.createAccountDidFail(error: error))
                }
            } receiveValue: { [weak self] userID in
                self?.output.send(.createAccountDidSucceed(userID: userID))
            }
            .store(in: &cancellables)
    }
    
    private func handleSaveUserInDatabase(userID: String) {
        let user = User(lastname: lastname,
                        firstname: firstname,
                        email: email,
                        birthdate: birthdate,
                        gender: gender)
        
        firestoreService.saveUserInDatabase(userID: userID, user: user)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.output.send(.saveUserInDatabaseDidFail(error: error))
                }
            } receiveValue: { [weak self] in
                self?.output.send(.saveUserInDatabaseDidSucceed(user: user))
            }
            .store(in: &cancellables)
    }
    
    func formCheck() throws {
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
