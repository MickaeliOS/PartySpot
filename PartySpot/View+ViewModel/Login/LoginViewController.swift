//
//  LoginViewController.swift
//  PartySpot
//
//  Created by Mickaël Horn on 16/10/2023.
//

import UIKit
import Combine

final class LoginViewController: UIViewController {

    // MARK: - OUTLETS & PROPERTIES
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    
    // Must be private
    var viewModel = LoginViewModel()
    weak var delegate: UserDelegate?
    private var cancellables = Set<AnyCancellable>()
    private let input: PassthroughSubject<LoginViewModel.Input, Never> = .init()

    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        outletsBind()
        bind()
    }
    
    // MARK: - ACTIONS
    @IBAction func signinButtonTapped(_ sender: Any) {
        do {
            try viewModel.formCheck()
            input.send(.signInButtonDidTap)
        } catch {
            if let error = error as? LoginFormError {
                presentErrorAlert(with: error.errorDescription)
            }
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: Constant.SegueIdentifiers.segueToCreateAccountViewController, sender: nil)
    }
    
    // MARK: - FUNCTIONS
    private func setupTextFields() {
        passwordTextField.addPasswordToggleButton(target: self,
                                                  action: #selector(togglePasswordVisibility))
        
        guard let personImage = UIImage(systemName: "person.fill"),
              let passwordLockImage = UIImage(systemName: "lock.fill") else { return }
        
        emailTextField.addLeftSystemImage(image: personImage)
        passwordTextField.addLeftSystemImage(image: passwordLockImage)
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .signInDidSucceed(let userID):
                    self?.input.send(.fetchUser(userID: userID))
                    
                case .signInDidFail(let error):
                    if let error = error as? FirebaseAuthServiceError {
                        self?.presentErrorAlert(with: error.errorDescription)
                    }
                    
                case .fetchUserDidSucceed(let user):
                    self?.delegate?.sendUser(user: user)
                    self?.performSegue(withIdentifier: Constant.SegueIdentifiers.unwindToRootVC, sender: nil)
                    
                case .fetchUserDidFail(let error):
                    if let error = error as? FirestoreService.Error {
                        self?.presentErrorAlert(with: error.errorDescription)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func outletsBind() {
        bindTextField(emailTextField, to: \.email)
        bindTextField(passwordTextField, to: \.password)
    }
    
    private func bindTextField(_ textField: UITextField, to keyPath: ReferenceWritableKeyPath<LoginViewModel, String>) {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: textField)
            .compactMap { ($0.object as? UITextField)?.text }
            .assign(to: keyPath, on: viewModel)
            .store(in: &cancellables)
    }
    
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        guard let textFieldContainer = sender.superview,
              let textField = textFieldContainer.superview as? UITextField else { return }
        
        textField.isPasswordVisible.toggle()
        sender.togglePasswordVisibilityImage(isVisible: textField.isPasswordVisible)
    }
}

// MARK: - EXTENSIONS
extension LoginViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.SegueIdentifiers.segueToCreateAccountViewController {
            let createAccountVC = segue.destination as? CreateAccountViewController
            createAccountVC?.delegate = delegate
        }
    }
}
