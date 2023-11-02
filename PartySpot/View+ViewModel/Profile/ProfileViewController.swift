//
//  ProfileViewController.swift
//  PartySpot
//
//  Created by Mickaël Horn on 18/10/2023.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    private var dataSource: TabBarViewController { tabBarController as! TabBarViewController }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logout(_ sender: Any) {
        try? Auth.auth().signOut()
        presentLoginViewController()
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
