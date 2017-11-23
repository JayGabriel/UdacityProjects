//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Jay Gabriel on 10/8/17.
//  Copyright © 2017 Jay Gabriel. All rights reserved.
//

import Foundation
import UIKit

class ListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var studentTableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingViewIndicator: UIActivityIndicatorView!
    
    // MARK: - Configuration
    override func viewDidLoad() {
        super.viewDidLoad()
        studentTableView.rowHeight = UITableViewAutomaticDimension
        
        // Disable the UI, display loading screen and wait for the request to finish
        self.view.isUserInteractionEnabled = false
        toggleLoading(visible: true, view: self.loadingView, indicator: self.loadingViewIndicator)
        
        OnTheMapClient.OTMClient.loadStudentLocations() { (success, errorString) in
            
            // If the request is successful, populate the table view
            if success {
                performUIUpdatesOnMain {
                    self.studentTableView.reloadData()
                    self.view.isUserInteractionEnabled = true
                    toggleLoading(visible: false, view: self.loadingView, indicator: self.loadingViewIndicator)
                    
                    printMessage(title: Constants.AlertMessages.Success, message: Constants.AlertMessages.LoadingSuccess)
                }
            // Otherwise, display an error message
            } else {
                performUIUpdatesOnMain {
                    self.view.isUserInteractionEnabled = true
                    printMessage(title: Constants.AlertMessages.Error, message: errorString!)
                }
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        
        self.view.isUserInteractionEnabled = false
        toggleLoading(visible: true, view: self.loadingView, indicator: self.loadingViewIndicator)
        
        OnTheMapClient.OTMClient.loadStudentLocations(){ (success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    self.studentTableView.reloadData()
                    
                    self.view.isUserInteractionEnabled = true
                    toggleLoading(visible: false, view: self.loadingView, indicator: self.loadingViewIndicator)
                    
                    printMessage(title: Constants.AlertMessages.Success, message: Constants.AlertMessages.LoadingSuccess)
                }
            } else {
                performUIUpdatesOnMain {
                    self.view.isUserInteractionEnabled = true
                    toggleLoading(visible: false, view: self.loadingView, indicator: self.loadingViewIndicator)
                    
                    printMessage(title: Constants.AlertMessages.Error, message: errorString!)
                }
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let addLocationViewController = self.storyboard!.instantiateViewController(withIdentifier: "addLocationViewController")
        present(addLocationViewController, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        OnTheMapClient.OTMClient.logout()
        self.dismiss(animated: true, completion: nil)
    }

}

//MARK: - TableView
extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OnTheMapClient.OTMClient.studentStore.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = OnTheMapClient.OTMClient.studentStore.students[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath) as! StudentCell
        cell.name?.text = "\(student.firstName!) \(student.lastName!)"
        cell.mediaURL?.text = student.mediaURL
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = OnTheMapClient.OTMClient.studentStore.students[indexPath.row]
        
        guard let mediaURL = URL(string: student.mediaURL!) else {
            printMessage(title: Constants.AlertMessages.Error, message: Constants.AlertMessages.urlError)
            return
        }
        
        if UIApplication.shared.canOpenURL(mediaURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(mediaURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(mediaURL)
            }
        } else {
            printMessage(title: Constants.AlertMessages.Error, message: Constants.AlertMessages.urlError)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
