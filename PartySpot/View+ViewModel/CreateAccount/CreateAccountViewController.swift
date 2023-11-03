//
//  CreateAccountViewController.swift
//  PartySpot
//
//  Created by Mickaël Horn on 16/10/2023.
//

import UIKit
import Combine

class CreateAccountViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    
    // MARK: - PROPERTIES
    var viewModel = CreateAccountViewModel()
    weak var delegate: UserDelegate?
    private var cancellables = Set<AnyCancellable>()
    private var isPasswordVisible = false
    private let input: PassthroughSubject<CreateAccountViewModel.Input, Never> = .init()
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        bind()
        outletsBind()
    }
    
    // MARK: - ACTIONS
    @IBAction func createAccountButtonTapped(_ sender: Any) {
        do {
            try viewModel.formCheck()
            input.send(.createAccountButtonDidTap)
        } catch let error as CreationFormError {
            presentErrorAlert(with: error.errorDescription)
        } catch {
            presentErrorAlert(with: "Something went wrong, please verify your form.")
        }
    }
    
    @IBAction func genderSegmentedControlTapped(_ sender: UISegmentedControl) {
        // I didn't find a solution to bind a UISegmentedControl to my ViewModel
        // so I "bind" manually.
        let title = sender.titleForSegment(at: sender.selectedSegmentIndex)
        
        if let title = title {
            let gender = User.Gender(rawValue: title) ?? .male
            viewModel.gender = gender
        }
    }
    
    // MARK: - FUNCTIONS
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .createAccountDidSucceed(let userID):
                    self?.input.send(.saveUserInDatabase(userID: userID))
                    
                case .createAccountDidFail(let error):
                    if let error = error as? FirebaseAuthServiceError {
                        self?.presentErrorAlert(with: error.errorDescription)
                    }
                    
                case .saveUserInDatabaseDidSucceed(let user):
                    self?.delegate?.sendUser(user: user)
                    self?.performSegue(withIdentifier: Constant.SegueIdentifiers.unwindToRootVC, sender: user)
                    
                case .saveUserInDatabaseDidFail(let error):
                    if let error = error as? FirestoreError {
                        self?.presentErrorAlert(with: error.errorDescription)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func outletsBind() {
        bindTextField(nameTextField, to: \.lastname)
        bindTextField(firstnameTextField, to: \.firstname)
        bindTextField(emailTextField, to: \.email)
        bindTextField(passwordTextField, to: \.password)
        bindTextField(confirmPasswordTextField, to: \.confirmPassword)
    }
    
    private func bindTextField(_ textField: UITextField, to keyPath: ReferenceWritableKeyPath<CreateAccountViewModel, String>) {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: textField)
            .compactMap { ($0.object as? UITextField)?.text }
            .assign(to: keyPath, on: viewModel)
            .store(in: &cancellables)
    }
    
    private func setupTextFields() {
        passwordTextField.addPasswordToggleButton(target: self,
                                                  action: #selector(togglePasswordVisibility))
        
        confirmPasswordTextField.addPasswordToggleButton(target: self,
                                                         action: #selector(togglePasswordVisibility))
        
        guard let envelopeImage = UIImage(systemName: "envelope.fill"),
              let passwordLockImage = UIImage(systemName: "lock.fill"),
              let personImage = UIImage(systemName: "person.fill") else { return }
        
        nameTextField.addLeftSystemImage(image: personImage)
        firstnameTextField.addLeftSystemImage(image: personImage)
        emailTextField.addLeftSystemImage(image: envelopeImage)
        passwordTextField.addLeftSystemImage(image: passwordLockImage)
        confirmPasswordTextField.addLeftSystemImage(image: passwordLockImage)
    }
    
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        guard let textFieldContainer = sender.superview,
              let textField = textFieldContainer.superview as? UITextField else { return }
        
        textField.isPasswordVisible.toggle()
        sender.togglePasswordVisibilityImage(isVisible: textField.isPasswordVisible)
    }
}
