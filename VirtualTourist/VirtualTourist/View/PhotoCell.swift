//
//  PhotoCell.swift
//  VirtualTourist
//
//  Created by Jay Gabriel on 10/21/17.
//  Copyright © 2017 Jay Gabriel. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tintView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: Properties
    var data: Data!
}
