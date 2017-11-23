//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jay Gabriel on 10/8/17.
//  Copyright © 2017 Jay Gabriel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingViewIndicator: UIActivityIndicatorView!
    
    // MARK: - Actions
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        
        // Disable the UI, display loading screen and wait for the request to finish
        self.view.isUserInteractionEnabled = false
        toggleLoading(visible: true, view: loadingView, indicator: loadingViewIndicator)
        
        OnTheMapClient.OTMClient.loadStudentLocations() { (success, errorString) in
            
            // If the request is successful, populate the map view with pins
            if success {
                performUIUpdatesOnMain {
                    self.populateMapview()
                    self.view.isUserInteractionEnabled = true
                    toggleLoading(visible: false, view: self.loadingView, indicator: self.loadingViewIndicator)
                    printMessage(title: Constants.AlertMessages.Success, message: Constants.AlertMessages.LoadingSuccess)
                }
            // Otherwise, display an error message
            } else {
                performUIUpdatesOnMain {
                    self.view.isUserInteractionEnabled = true
                    toggleLoading(visible: false, view: self.loadingView, indicator: self.loadingViewIndicator)
                    printMessage(title: Constants.AlertMessages.Error, message: errorString!)
                }
            }
        }
    }
    
    @IBAction func addLocationButtonPressed(_ sender: UIBarButtonItem) {
        let addLocationViewController = self.storyboard!.instantiateViewController(withIdentifier: "addLocationViewController")
        present(addLocationViewController, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        OnTheMapClient.OTMClient.logout()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Configuration
    override func viewDidLoad() {
        
        // When the view loads, load the student locations
        self.view.isUserInteractionEnabled = false
        toggleLoading(visible: true, view: loadingView, indicator: loadingViewIndicator)
        
        super.viewDidLoad()
        mapView.delegate = self
        OnTheMapClient.OTMClient.loadStudentLocations() { (success, errorString) in
    
            if success {
                performUIUpdatesOnMain {
                    self.populateMapview()
                    
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
    
    func populateMapview() {
        // Remove any existing pins
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        // Iterate through the Student array to populate the map
        for student in 0..<OnTheMapClient.OTMClient.studentStore.students.count {
            let currentStudent = OnTheMapClient.OTMClient.studentStore.students[student]
            self.createPin(forStudent: currentStudent)
        }
    }
    
    private func createPin(forStudent student: Student) {
        // Create annotation
        let annotation = MKPointAnnotation()
        annotation.title = "\(student.firstName!) \(student.lastName!)"
        annotation.subtitle = student.mediaURL!
        annotation.coordinate = CLLocationCoordinate2D(latitude: student.latitude!, longitude: student.longitude!)
        
        // Create pin and set annotation
        let pin = MKPinAnnotationView()
        pin.annotation = annotation
        self.mapView.addAnnotation(annotation)
    }
    
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinIcon = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinIcon == nil {
            pinIcon = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinIcon!.canShowCallout = true
            pinIcon!.animatesDrop = false
            pinIcon?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinIcon!.annotation = annotation
        }
        
        return pinIcon
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let mediaURL = URL(string: (view.annotation?.subtitle as? String)!) else {
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
    }
}
