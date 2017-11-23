//
//  ApplicationMethods.swift
//  OnTheMap
//
//  Created by Jay Gabriel on 10/13/17.
//  Copyright © 2017 Jay Gabriel. All rights reserved.
//

import UIKit

// Methods used by most classes in the app

func printMessage(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
    
    if var currentViewController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = currentViewController.presentedViewController {
            currentViewController = presentedViewController
        }
        currentViewController.present(alert, animated: true, completion: nil)
    }
}

func toggleLoading(visible: Bool, view: UIView?, indicator: UIActivityIndicatorView) {
    
    if visible {
        indicator.isHidden = false
        indicator.startAnimating()
        if let v = view {
            v.isHidden = false
        }
    } else {
        indicator.isHidden = true
        indicator.stopAnimating()
        if let v = view {
            v.isHidden = true
        }
    }
}
