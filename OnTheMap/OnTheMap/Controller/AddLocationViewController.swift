//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Jay Gabriel on 10/8/17.
//  Copyright © 2017 Jay Gabriel. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var mediaURLField: UITextField!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingViewIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var userLocation: CLLocation!
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        userLocation = nil
        
        locationField.delegate = self
        mediaURLField.delegate = self
    }
    
    // MARK: - Configuration
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLocationConfirmation" {
            let confirmLocationViewController = segue.destination as! ConfirmLocationViewController
            confirmLocationViewController.location = self.userLocation
        }
    }
    
    // MARK: - Actions
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        hideKeyboards()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        geocodeLocation()
    }
    
    @IBAction func tappedOutsideKeyboard(_ sender: UITapGestureRecognizer) {
        if locationField.isFirstResponder || mediaURLField.isFirstResponder {
            hideKeyboards()
        }
    }
    
    // MARK: - Geocoding
    func geocodeLocation() {
        hideKeyboards()
        view.isUserInteractionEnabled = false
        toggleLoading(visible: true, view: loadingView, indicator: loadingViewIndicator)
        
        // If text fields are not empty, proceed to reverse geocode
        if (locationField.text != "" && mediaURLField.text != "") {
            
            
            
            // If the city can be located, display a confirmation screen
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(locationField.text!) { (placemarks, error) in
                
                performUIUpdatesOnMain {
                    self.view.isUserInteractionEnabled = true
                    toggleLoading(visible: false, view: self.loadingView, indicator: self.loadingViewIndicator)
                }
                
                // Error
                if let e = error {
                    printMessage(title: Constants.AlertMessages.Error, message: e.localizedDescription)
                    return
                } else {
                    
                    // Set location
                    self.userLocation = placemarks?[0].location
                    var locationName = "City"
                    guard let loc = placemarks?[0].locality else {
                        printMessage(title: Constants.AlertMessages.Error, message: Constants.AlertMessages.cityError)
                        return
                    }
                    locationName = loc

                    // Set media url
                    guard let mediaURL = URL(string: self.mediaURLField.text!) else {
                        printMessage(title: Constants.AlertMessages.Error, message: Constants.AlertMessages.urlError)
                        return
                    }

                    // Verify media url and display confirmation screen
                    if UIApplication.shared.canOpenURL(mediaURL) {
                        OnTheMapClient.OTMClient.mediaURL = self.mediaURLField.text!
                        OnTheMapClient.OTMClient.mapString = locationName
                        self.performSegue(withIdentifier: "showLocationConfirmation", sender: nil)
                    } else {
                        printMessage(title: Constants.AlertMessages.Error, message: Constants.AlertMessages.urlError)
                    }
                }
            }
        } else {
            performUIUpdatesOnMain {
                self.view.isUserInteractionEnabled = true
                toggleLoading(visible: false, view: self.loadingView, indicator: self.loadingViewIndicator)
            }
            
            printMessage(title: Constants.AlertMessages.Error, message: Constants.AlertMessages.textFieldError)
        }
    }
}

// MARK:  - TextFieldDelegate
extension AddLocationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        self.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        geocodeLocation()
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
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func hideKeyboards() {
        locationField.resignFirstResponder()
        mediaURLField.resignFirstResponder()
    }
}

