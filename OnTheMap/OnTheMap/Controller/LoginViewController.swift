//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jay Gabriel on 10/8/17.
//  Copyright © 2017 Jay Gabriel. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var launchLogo: UIImageView!
    @IBOutlet weak var emailTextField: LeftPaddedTextField!
    @IBOutlet weak var passwordTextField: LeftPaddedTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginLoadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Configuration
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailTextField.text = ""
        passwordTextField.text = ""
        loginLoadingIndicator.isHidden = true
        view.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        loginLoadingIndicator.isHidden = true
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    private func login() {
        // Disable the UI, display loading screen and wait for the request to finish
        self.view.isUserInteractionEnabled = false
        toggleLoading(visible: true, view: nil, indicator: loginLoadingIndicator)
        
        OnTheMapClient.OTMClient.getSessionID(email: emailTextField.text!, password: passwordTextField.text!) { (success, errorString) in
            
            // If the request is successful, proceed to the map view
            if success {
                let mainNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "mainNavigation")
                self.present(mainNavigationController!, animated: true, completion: nil)
            // Otherwise, display an error message
            } else {
                performUIUpdatesOnMain {
                    self.view.isUserInteractionEnabled = true
                    toggleLoading(visible: false, view: nil, indicator: self.loginLoadingIndicator)
                }
                printMessage(title: Constants.AlertMessages.Error, message: errorString!)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        hideKeyboards()
        login()
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        let signUpURL = URL(string: Constants.UdacityParameterKeys.SignUpURL)
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(signUpURL!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(signUpURL!)
        }
    }
    
    @IBAction func tappedOutsideKeyboard(_ sender: UITapGestureRecognizer) {
        if emailTextField.isFirstResponder || passwordTextField.isFirstResponder {
            hideKeyboards()
        }
    }

}

// MARK: - TextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
        if textField.tag == 1 {
            textField.text = ""
            textField.isSecureTextEntry  = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        login()
        return true
    }
    
    
    @objc func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y = 0 - getKeyboardHeight(notification) / 1.5
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func hideKeyboards() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    
}
