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
        case createAccountButtonDidTap
    }
    
    enum Output {
        case idle // status en attente, obligatoire de set une valeur avec le @Published, mais le status reste pertinent
        case createAccountDidSucceed(userID: String)
        case createAccountDidFail(error: Error)
        case saveUserInDatabaseDidFail(error: Error)
        case saveUserInDatabaseDidSucceed(user: User)
    }
    // Proposition d'enum Output (cf voir mes commentaires plus bas dans la methode `handleSaveUserInDatabase`)
//    enum Output {
//        case idle
//        case accountCreationDidSucceed
//        case accountCreationDidFailed(Error)
//    }

    // MARK: - PROPERTIES
    // All these properties should be private
    var lastname: String = ""
    var firstname: String = ""
    var gender: User.Gender = .male
    var birthdate: Date = Date.now
    @Published var email: String = ""
    @Published var password: String = ""
    var confirmPassword: String = ""

    private let authService: FirebaseAuthServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    @Published private(set) var output: Output = .idle
    private var cancellables = Set<AnyCancellable>()
    
    private var hasEmptyField: Bool {
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
        // Here is some options :)

        //
        // 1st option
        //
        Publishers.CombineLatest(
            $email.filter { !$0.isEmpty }, // filter any wrong email by calling any validating method to check email
            $password.filter { !$0.isEmpty } // same here for password
        )
        .zip(input.filter { $0 == .createAccountButtonDidTap }) // listen only create account button tapped view event
        .flatMap { [authService] combinedData in
            let email = combinedData.0.0
            let password = combinedData.0.1
            return authService
                .createAccount(email: email, password: password)
                .handleEvents(receiveOutput: { [weak self] userId in
                    self?.handleSaveUserInDatabase(userID: userId)
                })
                .map { userId in Output.createAccountDidSucceed(userID: userId) }
                .catch { error in Just(Output.createAccountDidFail(error: error)).eraseToAnyPublisher() }
        }
        .assign(to: &$output)

        //
        // 2nde option
        //
//        input
//            .filter { $0 == .createAccountButtonDidTap }
//            .flatMap { [authService, weak self] _ in
//                guard let self else {
//                    return Empty<Output, Never>().eraseToAnyPublisher()
//                }
//                return authService
//                    .createAccount(email: self.email, password: self.password)
//                    .handleEvents(receiveOutput: { [weak self] userId in
//                        self?.handleSaveUserInDatabase(userID: userId)
//                    })
//                    .map { userId in Output.createAccountDidSucceed(userID: userId) }
//                    .catch { error in Just(Output.createAccountDidFail(error: error)) }
//                    .eraseToAnyPublisher()
//            }
//            .assign(to: &$output)

        //
        // 3th option: with cancellable
        //
//        input
//            .filter { $0 == .createAccountButtonDidTap }
//            .flatMap { [authService, weak self] _ in
//                guard let self else {
//                    return Empty<Output, Never>().eraseToAnyPublisher()
//                }
//                return authService
//                    .createAccount(email: self.email, password: self.password)
//                    .handleEvents(receiveOutput: { [weak self] userId in
//                        self?.handleSaveUserInDatabase(userID: userId)
//                    })
//                    .map { userId in Output.createAccountDidSucceed(userID: userId) }
//                    .catch { error in Just(Output.createAccountDidFail(error: error)) }
//                    .eraseToAnyPublisher()
//            }
//            .sink { completion in
//
//            } receiveValue: { [weak self] result in
//                self?.output = result
//            }
//            .store(in: &cancellables)

        return $output.eraseToAnyPublisher()
    }

    private func handleSaveUserInDatabase(userID: String) {
        let user = User(
            lastname: lastname,
            firstname: firstname,
            email: email,
            birthdate: birthdate,
            gender: gender
        )

        do {
            try firestoreService.saveUserInDatabase(userID: userID, user: user)

            // Une erreur a ne pas commettre ici c'est de passer le user que tu as cree toi.
            // Car peut etre que la base de donnee/ ou l'API peut importe ne l'a pas sauvegarde exactement avec ces valeurs
            // Il faut toujours utiliser ce qui provient de la BDD/API, meme si tu n'as pas recu d'erreur.
            // Donc ici il faudrait que `firestoreService.saveUserInDatabase` te retourne le user sauvegardé pour ensuite le passé :
            output = .saveUserInDatabaseDidSucceed(user: user)
        } catch {
            // Le soucis ici c'est que dans ton scenario, on creer un compte et on save. Et dans chacun des cas tu peux avoir une erreur. 
            // Ca signifie aussi que potentiellement tu peux avoir 2 erreurs de suite. On evite mais c'est peut etre possible.
            // Je te propose donc de ne pas differencier les 2 erreur et d'avoir 1 seul erreur dans l'output pour ce scenario.
            // Car le user il s'en fiche que ca soit une erreur de BDD ou de firebase. Ce qui compte pour lui c'est de savoir si ca a marche ou non c'est tout.
            // Donc j'aurai juste mis :
            // `case accountCreationError` dans ton enum a la place des deux.
            // Cote VM oui on peut avoir besoin de savoir d'ou vient l'erreur (BDD ou firebase) par contre cote View/ViewController on s'en fiche :)
            output = .saveUserInDatabaseDidFail(error: error)
        }
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
