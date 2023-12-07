//
//  CreatePartyViewController.swift
//  PartySpot
//
//  Created by Mickaël Horn on 18/10/2023.
//

import UIKit
import Combine
import FirebaseAuth

final class CreatePartyViewController: UIViewController {
    
    // MARK: - OUTLETS & PROPERTIES
    @IBOutlet weak var labelToDelete: UILabel!
    
    private var cancellables = Set<AnyCancellable>()
    private var viewModel = CreatePartyViewModel()
    private var dataSource: TabBarViewController { tabBarController as! TabBarViewController }
    
    let loginVC = "LoginViewController"
    private let input: PassthroughSubject<CreatePartyViewModel.Input, Never> = .init()
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToViewModel()
        loginState()
        bindUser()
    }
    
    // MARK: - ACTIONS
    @IBAction func unwindToRootVC(segue: UIStoryboardSegue) { }
    
    private func loginState() {
        if Auth.auth().currentUser == nil {
            presentLoginViewController()
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        input.send(.fetchUser(userID: userID))
    }
    
    // MARK: - FUNCTIONS
    private func bindToViewModel() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchUserDidSucceed(let user):
                    self?.dataSource.userViewModel.user = user
                    
                case .fetchUserDidFailed(let error):
                    if let error = error as? FirestoreService.FirestoreError {
                        self?.presentErrorAlert(with: error.errorDescription)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindUser() {
        dataSource.userViewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.labelToDelete.text = user?.lastname
            }
            .store(in: &cancellables)
    }
    
    private func presentLoginViewController() {
        presentViewController(storyboardName: "Main", viewControllerIdentifier: loginVC) { [weak self] (vc: LoginViewController) in
            vc.modalPresentationStyle = .fullScreen
            vc.userDelegate = self?.dataSource
        }
    }
}
