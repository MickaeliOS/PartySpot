//
//  CreateAccountViewController.swift
//  PartySpot
//
//  Created by Mickaël Horn on 16/10/2023.
//

import UIKit
import Combine

final class CreateAccountViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var firstnameTextField: UITextField!
    @IBOutlet private weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var createAccountButton: UIButton!
    
    // MARK: - PROPERTIES
    weak var userDelegate: UserDelegate?
    // ViewModel toujours en private let, sinon pb de conception
    private let viewModel = CreateAccountViewModel()

    // Preference perso : je nomme mes cancellables `subscriptions` car on nomme nos variable pas pour ce qu'elles font (etre cancel)
    // mais pour ce qu'elles sont: des subscriptions. Ca devient encore plus clair qu'on ecrit: `subscription.cancel()`
    // C'est a toi de choisir ce que tu preferes ;)
    private var cancellables = Set<AnyCancellable>()
    
    let unwindToRootVC = "unwindToRootVC"
    private let input: PassthroughSubject<CreateAccountViewModel.Input, Never> = .init()
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        bindToViewModel()
        bindOutlets()
    }
    
    // MARK: - ACTIONS
    @IBAction private func createAccountButtonTapped(_ sender: Any) {
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
    
    @IBAction private func closeButtonDidTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - FUNCTIONS
    private func bindToViewModel() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .idle: break
                case .createAccountDidSucceed:
                    break // Cf ma proposition d'enum pour eviter de handle ces cas pour rien

                case .createAccountDidFail(let error):
                    if let error = error as? FirebaseAuthServiceError {
                        self?.presentErrorAlert(with: error.errorDescription)
                    }
                    
                case .saveUserInDatabaseDidSucceed(let user):
                    self?.userDelegate?.saveUserLocally(user: user)
                    self?.performSegue(withIdentifier: self?.unwindToRootVC ?? "unwindToRootVC", sender: user)
                    
                case .saveUserInDatabaseDidFail(let error):
                    if let error = error as? FirestoreService.FirestoreError {
                        self?.presentErrorAlert(with: error.errorDescription)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindOutlets() {
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
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        guard let textFieldContainer = sender.superview,
              let textField = textFieldContainer.superview as? UITextField else { return }
        
        textField.isPasswordVisible.toggle()
        sender.togglePasswordVisibilityImage(isVisible: textField.isPasswordVisible)
    }
}
