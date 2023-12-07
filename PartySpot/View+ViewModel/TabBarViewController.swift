//
//  TabBarViewController.swift
//  PartySpot
//
//  Created by Mickaël Horn on 19/10/2023.
//

import UIKit

class TabBarViewController: UITabBarController {
    // MARK: - PROPERTIES
    var userViewModel = UserViewModel()

    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

// MARK: - PROTOCOLS
protocol UserDelegate: AnyObject {
    func saveUserLocally(user: User)
}

// MARK: - EXTENSIONS
extension TabBarViewController: UserDelegate {
    func saveUserLocally(user: User) {
        userViewModel.user = user
    }
}
