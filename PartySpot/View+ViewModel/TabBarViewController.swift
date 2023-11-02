//
//  TabBarViewController.swift
//  PartySpot
//
//  Created by Mickaël Horn on 19/10/2023.
//

import UIKit

class TabBarViewController: UITabBarController {
    var userViewModel = UserViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

protocol UserDelegate: AnyObject {
    func sendUser(user: User)
}

extension TabBarViewController: UserDelegate {
    func sendUser(user: User) {
        userViewModel.user = user
    }
}
