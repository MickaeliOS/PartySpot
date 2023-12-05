//
//  ProfileViewController.swift
//  PartySpot
//
//  Created by Mickaël Horn on 18/10/2023.
//

import UIKit
import FirebaseAuth

// Put `final` as possible
final class ProfileViewController: UIViewController {
    // MARK: - PROPERTIES
    private var dataSource: TabBarViewController { tabBarController as! TabBarViewController }
    // Try to avoid implicit unwrap `!` to avoid app crashes

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
        presentViewController(storyboardName: "Main", viewControllerIdentifier: Constant.VCIdentifiers.loginVC) { [weak self] (vc: LoginViewController) in
            vc.modalPresentationStyle = .fullScreen
            vc.delegate = self?.dataSource
        }
    }
}
