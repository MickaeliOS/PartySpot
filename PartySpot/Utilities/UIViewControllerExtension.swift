//
//  UIViewControllerExtension.swift
//  PartySpot
//
//  Created by Mickaël Horn on 07/12/2023.
//

import UIKit
import Foundation

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
        
        // TODO: Si le VC est à nil, que fait-on ? Gère ce cas.
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
