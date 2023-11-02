//
//  LoginViewController.swift
//  PartySpot
//
//  Created by Mickaël Horn on 16/10/2023.
//

import UIKit
import Combine

class LoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        outletsBind()
        bind()
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    
    weak var delegate: UserDelegate?
    var viewModel = LoginViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let input: PassthroughSubject<LoginViewModel.Input, Never> = .init()

    @IBAction func signinButtonTapped(_ sender: Any) {
        input.send(.signInButtonDidTap)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: Constant.SegueIdentifiers.segueToCreateAccountViewController, sender: nil)
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
                    if let error = error as? FirestoreError {
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
}

extension LoginViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.SegueIdentifiers.segueToCreateAccountViewController {
            let createAccountVC = segue.destination as? CreateAccountViewController
            createAccountVC?.delegate = delegate
        }
    }
}
