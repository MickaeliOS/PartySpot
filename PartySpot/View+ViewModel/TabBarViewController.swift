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
    func sendUser(user: User)
}

// MARK: - EXTENSIONS
extension TabBarViewController: UserDelegate {
    // func sendUser(_ user: User) {
    // to avoid:
    // let user = User()
    // sendUser(user: user)
    // `user` 3 times...
    // Also the func naming do not tell anything, send send to what? for what?
    // Shouldn't be an TabBarController func as well, more in a service or viewModel
    func sendUser(user: User) {
        userViewModel.user = user
    }
}
