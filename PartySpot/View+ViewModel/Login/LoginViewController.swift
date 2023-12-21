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
    
    weak var userDelegate: UserDelegate?
    private var viewModel = LoginViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    let unwindToRootVCSegueID = "unwindToRootVCSegueID"
    let segueToCreateAccountViewController = "segueToCreateAccountViewController"
    private let input: PassthroughSubject<LoginViewModel.Input, Never> = .init()

    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        outletsBind()
        bindToViewModel()
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
        performSegue(withIdentifier: segueToCreateAccountViewController, sender: nil)
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
    
    private func bindToViewModel() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchUserDidSucceed(let user):
                    self?.userDelegate?.saveUserLocally(user: user)
                    self?.performSegue(withIdentifier: self?.unwindToRootVCSegueID ?? "unwindToRootVC", sender: nil)
                    
                case .fetchUserDidFail(let error):
                    if let error = error as? FirebaseAuthService.AuthError {
                        self?.presentErrorAlert(with: error.errorDescription)
                    }
                }
            }
            .store(in: &subscriptions)
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
            .store(in: &subscriptions)
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
        if segue.identifier == segueToCreateAccountViewController {
            let createAccountVC = segue.destination as? CreateAccountViewController
            createAccountVC?.userDelegate = userDelegate
        }
    }
}
