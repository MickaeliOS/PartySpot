//
//  CreatePartyViewController.swift
//  PartySpot
//
//  Created by Mickaël Horn on 18/10/2023.
//

import UIKit
import Combine
import FirebaseAuth

class CreatePartyViewController: UIViewController {
    
    @IBOutlet weak var labelToDelete: UILabel!
    
    private let input: PassthroughSubject<CreatePartyViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private var viewModel = CreatePartyViewModel()
    private var dataSource: TabBarViewController { tabBarController as! TabBarViewController }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        loginState()
        bindUser()
    }
    
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
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchUserDidSucceed(let user):
                    self?.dataSource.userViewModel.user = user
                case .fetchUserDidFailed(let error):
                    if let error = error as? FirestoreError {
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
    
    func presentLoginViewController() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        if let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            loginVC.delegate = dataSource
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        }
    }
}
