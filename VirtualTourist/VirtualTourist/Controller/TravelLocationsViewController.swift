//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Jay Gabriel on 10/16/17.
//  Copyright © 2017 Jay Gabriel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

// MARK: - UIViewController
class TravelLocationsViewController: UIViewController {
    
    // MARK: - Properties
    var selectedLocation: CLLocationCoordinate2D?
    var mapViewCanBeEdited: Bool!
    // MARK: - Core Data Class Properties
    var PinArray = [Pin]()
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteLabel: UILabel!
    
    // MARK: - Actions
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Called when a user taps on a pin on the map. Pushes a PhotoAlbumViewController onto the navigation stack. If in editing mode, selecting a pin removes it from the map.
        
        mapView.deselectAnnotation(view.annotation, animated: true)
        let selectedAnnotation = view.annotation!
        
        // If the map is in edit mode, a Pin will be deleted from the database when tapped.
        if mapViewCanBeEdited {
            mapView.removeAnnotation(view.annotation!)
            
            var correspondingPin: Pin!
            for i in 0..<PinArray.count {
                
            if (selectedAnnotation.coordinate.latitude == PinArray[i].latitude && selectedAnnotation.coordinate.longitude == PinArray[i].longitude) {
                    correspondingPin = PinArray[i]
                }
            }
            deletePinFromDatabase(pinToDelete: correspondingPin)
            
        // If the map is not in editable, the photo album for the corresponding Pin is shown.
        } else {
            selectedLocation = view.annotation?.coordinate
            performSegue(withIdentifier: "toPhotoAlbum", sender: self)
        }
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
        if mapViewCanBeEdited {
            mapViewCanBeEdited = false
            editButton.title = "Edit"
            UIView.animate(withDuration: 0.3, animations: {
                self.deleteLabel.alpha = 0
            })
        } else {
            mapViewCanBeEdited = true
            editButton.title = "Done"
            UIView.animate(withDuration: 0.3, animations: {
                self.deleteLabel.alpha = 1
            })
        }
        
    }
    
    // MARK: - View configuration
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable Pin dropping and annotate the map view if Pin objects exist in the database.
        enablePinDropping()
        annotateMap()
        
        // Set editing mode
        mapViewCanBeEdited = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.isUserInteractionEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view.isUserInteractionEnabled = false
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Configures the incoming PhotoAlbumViewController to be pushed onto the navigation stack.
        
        if segue.identifier == "toPhotoAlbum" {
            let PhotoAlbumVC = segue.destination as? PhotoAlbumViewController

            // Find corresponding pin
            var correspondingPin: Pin!
            for i in 0..<PinArray.count {
                
                if (selectedLocation?.latitude == PinArray[i].latitude && selectedLocation?.longitude == PinArray[i].longitude) {
                    correspondingPin = PinArray[i]
                }
            }
            
            PhotoAlbumVC?.albumPin = correspondingPin
        }
    }
    
    // MARK: - Map interaction
    func enablePinDropping() {
        // Toggles functionality for adding a pin by enabling a pin drop for a long press on the map view.
        let pressDuration = 0.5
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(longPress:)))
        longPressGestureRecognizer.minimumPressDuration = pressDuration
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        
    }
    
    func annotateMap() {
        // Annotates the map view with Pin objects saved in the database.
        loadPinsFromDatabase()
        
        for i in 0..<PinArray.count {
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = PinArray[i].latitude
            annotation.coordinate.longitude = PinArray[i].longitude
            mapView.addAnnotation(annotation)
        }
    }
    
}

// MARK: - MKMapViewDelegate
extension TravelLocationsViewController: MKMapViewDelegate {
    
    @objc func addAnnotation(longPress:UIGestureRecognizer){
        // Called when a long press on the map view is detected. It adds a pin to the selected location. Map must be in edit mode.
        
        if !mapViewCanBeEdited {
            if longPress.state == UIGestureRecognizerState.began {
                let selectedLocation = longPress.location(in: mapView)
                let newLocation = mapView.convert(selectedLocation, toCoordinateFrom: mapView)
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = newLocation
                
                CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newLocation.latitude, longitude: newLocation.longitude), completionHandler: {(placemarks, error) -> Void in
                    
                    if let _ = error {
                        showAlert(title: Constants.AlertMessages.Error, message: Constants.AlertMessages.OfflineError)
                        return
                    }
                    
                    guard let placemarks_array = placemarks else { return }
                    
                    if placemarks_array.count > 0 {
                        _ = placemarks![0]
                        
                        self.mapView.addAnnotation(annotation)
                        self.savePinToDatabase(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                    }
                })
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Configures an annotation to be displayed as a pin.
        
        let reuseID = "pin"
        var pinIcon = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinIcon == nil {
            pinIcon = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinIcon!.canShowCallout = false
            pinIcon!.animatesDrop = true
        } else {
            pinIcon!.annotation = annotation
        }
        
        return pinIcon
    }
}

// MARK: - Core Data
extension TravelLocationsViewController {
    
    func loadPinsFromDatabase() {
        // Sends a fetch request to retrieve the user's saved pins.
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            let searchResults = try CoreDataController.getContext().fetch(fetchRequest)
            PinArray = searchResults
        } catch {
            showAlert(title: Constants.AlertMessages.Error, message: Constants.AlertMessages.LoadError)
        }
    }
    
    func savePinToDatabase(latitude: Double, longitude: Double) {
        // Saves a Pin to the database with the given coordinate values.
        
        let newPin = NSEntityDescription.insertNewObject(forEntityName: Constants.ApplicationPreferences.PinClassName, into: CoreDataController.getContext()) as! Pin
        
        newPin.latitude = latitude
        newPin.longitude = longitude
        
        CoreDataController.saveContext()
        loadPinsFromDatabase()
    }
    
    func deletePinFromDatabase(pinToDelete: Pin) {
        // Deletes a Pin and all associate Photo objects from the database.
        
        let context = CoreDataController.getContext()
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let pinPredicate = NSPredicate(format: "pin = %@", pinToDelete)
        fetchRequest.predicate = pinPredicate
        
        do {
            let results = try context.fetch(fetchRequest)
            for photoToDelete in results {
                CoreDataController.getContext().delete(photoToDelete)
            }
        } catch {
            return
        }
        CoreDataController.getContext().delete(pinToDelete)
        CoreDataController.saveContext()
    }

}





