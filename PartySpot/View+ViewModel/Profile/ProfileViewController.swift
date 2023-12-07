//
//  ProfileViewController.swift
//  PartySpot
//
//  Created by Mickaël Horn on 18/10/2023.
//

import UIKit
import FirebaseAuth

final class ProfileViewController: UIViewController {
    // MARK: - PROPERTIES
    private var dataSource: TabBarViewController { tabBarController as! TabBarViewController }
    let loginVC = "LoginViewController"

    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - ACTIONS
    @IBAction func logout(_ sender: Any) {
        try? Auth.auth().signOut()
        presentLoginViewController()
    }
    
    // MARK: - FUNCTIONS
    func presentLoginViewController() {
        presentViewController(storyboardName: "Main", viewControllerIdentifier: loginVC) { [weak self] (vc: LoginViewController) in
            vc.modalPresentationStyle = .fullScreen
            vc.userDelegate = self?.dataSource
        }
    }
}
