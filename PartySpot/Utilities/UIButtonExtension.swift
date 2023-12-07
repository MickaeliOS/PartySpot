//
//  UIButtonExtension.swift
//  PartySpot
//
//  Created by Mickaël Horn on 07/12/2023.
//

import UIKit
import Foundation

extension UIButton {
    func togglePasswordVisibilityImage(isVisible: Bool) {
        let imageName = isVisible ? "eye.fill" : "eye.slash.fill"
        self.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
