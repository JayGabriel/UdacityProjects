//
//  ConfirmLocationViewController.swift
//  OnTheMap
//
//  Created by Jay Gabriel on 10/8/17.
//  Copyright © 2017 Jay Gabriel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ConfirmLocationViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingViewIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var appDelegate: AppDelegate!
    var location: CLLocation!
    
    // MARK: - Actions
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        
        // Display the specified location and confirm with the user
        // to initiate a POST request
        view.isUserInteractionEnabled = false
        toggleLoading(visible: true, view: loadingView, indicator: loadingViewIndicator)

        OnTheMapClient.OTMClient.latitude = location.coordinate.latitude
        OnTheMapClient.OTMClient.longitude = location.coordinate.longitude
        
        OnTheMapClient.OTMClient.addLocation() { (success, errorString) in
            performUIUpdatesOnMain {
                self.view.isUserInteractionEnabled = true
                toggleLoading(visible: false, view: self.loadingView, indicator: self.loadingViewIndicator)
            }
            if success {
                performUIUpdatesOnMain {
                    let postSuccessAlert = UIAlertController(title: Constants.AlertMessages.Success, message: Constants.AlertMessages.PostSuccess, preferredStyle: .alert)
                    postSuccessAlert.addAction(UIAlertAction(title: Constants.AlertMessages.Dismiss,
                                                             style: .default,
                                                             handler: { (alert: UIAlertAction!) in
                                                                self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(postSuccessAlert, animated: true, completion: nil)
                }
            } else {
                printMessage(title: Constants.AlertMessages.Error, message: errorString!)
            }
        }
    }
    
    // MARK: - Configuration
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        mapView.delegate = self
        
        showChosenLocation()
    }
    
    func showChosenLocation() {
        // Display the specified location with a pin on the map view
        let latitudeSpan: CLLocationDegrees = 0.5
        let longitudeSpan: CLLocationDegrees = 0.5
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latitudeSpan, longitudeSpan)
        let point:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(point, span)
        mapView.setRegion(region, animated: true)
        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        
        self.mapView.addAnnotation(objectAnnotation)
    }
    
}
