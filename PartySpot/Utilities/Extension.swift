//
//  Extension.swift
//  PartySpot
//
//  Created by Mickaël Horn on 18/10/2023.
//

import UIKit
import Combine
import Foundation

// MARK: - LOGIC EXTENTIONS
extension String {
    var isReallyEmpty: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func isValidEmail() -> Bool {
        // Firebase already warns us about badly formatted email addresses, but this involves a network call.
        // To help with Green Code, I prefer to handle the email format validation myself.
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}

// MARK: - UIKIT EXTENTIONS
extension UIViewController {
    func presentVCFullScreen(with identifier: String, error: String? = nil) {
        // Presenting a VC in Modal Full Screen, with an error if needed.
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: identifier)
        vc.modalPresentationStyle = .fullScreen
        
        guard let error = error else {
            present(vc, animated: true)
            return
        }
        
        present(vc, animated: true) {
            vc.presentErrorAlert(with: error)
        }
    }
    
    func presentViewController<T: UIViewController>(storyboardName: String, viewControllerIdentifier: String, configure: ((T) -> Void)? = nil) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        if let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? T {
            configure?(viewController)
            present(viewController, animated: true)
        }
    }
    
    func presentErrorAlert(with error: String) {
        let alert: UIAlertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension UITextField {
    var isPasswordVisible: Bool {
        get {
            return !isSecureTextEntry
        }
        set {
            isSecureTextEntry = !newValue
        }
    }
    
    func addLeftSystemImage(image: UIImage) {
        leftViewMode = .always
        
        let imageView = UIImageView(frame: CGRect(x: 15, y: 0, width: 25, height: 25))
        imageView.contentMode = .scaleAspectFit // If the image isn't squared, we keep the aspect ratio.
        imageView.tintColor = UIColor.placeholderText
        imageView.image = image
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 25))
        view.addSubview(imageView)
        
        leftView = view
    }
    
    func addPasswordToggleButton(target: Any?, action: Selector) {
        // This method adds an eye icon to the given UITextField for toggling password visibility.
        // The button's action needs to be handled in the UIViewController.
        let button = UIButton(type: .custom)
        
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        button.contentMode = .scaleAspectFit
        button.tintColor = UIColor.placeholderText
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 25))
        view.addSubview(button)
        
        self.rightView = view
        self.rightViewMode = .always
    }
}

extension UIButton {
    func togglePasswordVisibilityImage(isVisible: Bool) {
        let imageName = isVisible ? "eye.fill" : "eye.slash.fill"
        self.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
