//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Jay Gabriel on 10/20/17.
//  Copyright © 2017 Jay Gabriel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

// MARK: - UIViewController
class PhotoAlbumViewController: UIViewController {
    
    // MARK: - Properties
    var albumPin: Pin!
    var collectionViewCanBeEdited: Bool!
    var countForRequest: Int!
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var deleteLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        // Enables the collection view to be edited.
        
        if collectionViewCanBeEdited {
            collectionViewCanBeEdited = false
            editButton.title = "Edit"
            refreshButton.isEnabled = true
            UIView.animate(withDuration: 0.3, animations: {
                self.deleteLabel.alpha = 0
            })
            
        } else {
            collectionViewCanBeEdited = true
            editButton.title = "Done"
            refreshButton.isEnabled = false
            UIView.animate(withDuration: 0.3, animations: {
                self.deleteLabel.alpha = 1
            })
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        // Starts a new album request.
        newAlbumRequest()
    }
    
    // MARK: - View configuration
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set flow layout and editing mode.
        setFlowLayout()
        collectionViewCanBeEdited = false
    
        // Load an existing album or request a new one.
        checkEmptyAlbum()
        
        // Set flag
        countForRequest = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Shows the location on the map view
        displayMapAnnotation()
    }
    
    func checkEmptyAlbum() {
        // Checks if the Pin's .photos property is empty, and starts a new album request if necessary.
       
        if let photoSet = albumPin.photos {
            
            if photoSet.count == 0 {
                newAlbumRequest()
            } else {
                photoCollectionView.reloadData()
            }
            
        } else {
            newAlbumRequest()
        }
    }
    
    func newAlbumRequest() {
        // Calls a Flickr API search method and updates the UI upon completion of the request.
        
        // Disable UI
        editButton.isEnabled = false
        editButton.title = "Edit"
        refreshButton.isEnabled = false
        UIView.animate(withDuration: 0.3, animations: {
            self.deleteLabel.alpha = 0
        })
        
        // Set parameters for network request
        let methodParameters: [String: AnyObject] = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod as AnyObject,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey as AnyObject,
            Constants.FlickrParameterKeys.BoundingBox: FlickrAPI.sharedInstance.convertCoordinates(latitude: albumPin.latitude, longitude: albumPin.longitude) as AnyObject,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch as AnyObject,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL as AnyObject as AnyObject,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat as AnyObject,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback as AnyObject
        ]
        
        // Set flag
        countForRequest = 0
        
        // Start request
        FlickrAPI.sharedInstance.loadPhotos(latitude: albumPin.latitude, longitude: albumPin.longitude, methodParameters) { (success, errorString, resultArray)  in
            
            // If the request is successful, the photo album is updated.
            if success {
                
                // Begin loading placeholder cells
                self.countForRequest = resultArray!.count
                performUIUpdatesOnMain {
                    self.photoCollectionView.reloadData()
                }
                
                // Clear the Pin's .photos
                self.removeAllPhotos()
                
                if let urlStringArray = resultArray {
                    
                    // Convert strings to URLS
                    var urlArray = [URL]()
                    for urlString in urlStringArray {
                        if let url = URL(string: urlString) {
                            urlArray.append(url)
                        }
                    }
                    
                    // Convert URLs to Data
                    var dataArray = [Data]()
                    for url in urlArray {
                        if let data = try? Data(contentsOf: url) {
                            dataArray.append(data)
                        }
                    }
                    
                    // Save data to database
                    self.savePhotos(dataArray: dataArray)
                    
                    // Reset flag
                    self.countForRequest = 0

                    // Update UI
                    performUIUpdatesOnMain {
                        self.photoCollectionView.reloadData()
                        self.editButton.isEnabled = true
                        self.refreshButton.isEnabled = true
                    }
                }
                
            // Else if the request fails, a message is displayed.
            } else {
                performUIUpdatesOnMain {
                    showAlert(title: Constants.AlertMessages.Error, message: errorString!)
                }
            }
        }
    }
    
}

// MARK: - MKMapViewDelegate
extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func displayMapAnnotation() {
        // Displays the specified location with a pin on the map view.
        
        let latitudeSpan: CLLocationDegrees = 1.0
        let longitudeSpan: CLLocationDegrees = 1.0
        
        let span = MKCoordinateSpanMake(latitudeSpan, longitudeSpan)
        let point = CLLocationCoordinate2DMake(albumPin.latitude, albumPin.longitude)
        
        let region = MKCoordinateRegionMake(point, span)
        mapView.setRegion(region, animated: true)
        let pinLocation = CLLocationCoordinate2DMake(albumPin.latitude, albumPin.longitude)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        
        self.mapView.addAnnotation(objectAnnotation)
        
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if countForRequest > 0 {
            return countForRequest
        } else {
            if let photoSet = albumPin.photos {
                return photoSet.count
            }
            return 0
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Configures the collection view cell.
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell

        // Display placeholders while cell is loading
        if countForRequest > 0 {
            cell.imageView.image = nil
            cell.tintView.isHidden = false
            cell.activityIndicatorView.startAnimating()
    
        // Display an image if loading is complete
        } else {
            
            if let photoSet = albumPin.photos {
                let photoArray = Array(photoSet) as! [Photo]
                
                let photoForCell = photoArray[indexPath.row]
                cell.imageView.image = UIImage(data: photoForCell.data! as Data)
                cell.data = photoForCell.data! as Data
                cell.tintView.isHidden = true
                cell.activityIndicatorView.stopAnimating()
            }
        }
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // If the colleciton view is editable, deletes a cell from the collection view and updates the database.
        
        if collectionViewCanBeEdited {
            let selectedCell = collectionView.cellForItem(at: indexPath) as! PhotoCell
            let dataToRemove = selectedCell.data
            
            removePhoto(data: dataToRemove!)
            collectionView.deleteItems(at: [indexPath])
            checkEmptyAlbum()
        }
        
    }
    
    func setFlowLayout() {
        // Configures the layout of the collection view.
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: screenWidth / 3, height: screenWidth / 3)
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        photoCollectionView!.collectionViewLayout = layout
        
    }
    
}

// MARK: - Core Data
extension PhotoAlbumViewController {
    
    func savePhotos(dataArray: [Data]) {
        // Saves the current photo album to the database.
        
        let context = CoreDataController.getContext()
        
        for i in 0..<dataArray.count {
    
            let data = dataArray[i]
            let newPhoto = NSEntityDescription.insertNewObject(forEntityName: Constants.ApplicationPreferences.PhotoClassName, into: context) as! Photo
            
            newPhoto.data = data as NSData
            albumPin.addToPhotos(newPhoto)
        }
        CoreDataController.saveContext()
        
    }
    
    func removeAllPhotos() {
        // Removes all Photo objects from the associated Pin.
        
        if let set = albumPin.photos {
            let photoSet = Array(set) as! [Photo]
            
            for photo in photoSet {
                albumPin.removeFromPhotos(photo)
                CoreDataController.getContext().delete(photo)
            }
            CoreDataController.saveContext()
        }
        
    }
    
    func removePhoto(data: Data) {
        // Removes a Photo object from the associated Pin with the given index value.
        
        if let set = albumPin.photos {
            let photoSet = Array(set) as! [Photo]
            
            for photo in photoSet {
                if photo.data == data as NSData {
                    albumPin.removeFromPhotos(photo)
                    CoreDataController.getContext().delete(photo)
                }
            }
            CoreDataController.saveContext()
        }
        
    }
}


