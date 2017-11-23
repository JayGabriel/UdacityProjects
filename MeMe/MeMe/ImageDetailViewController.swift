//
//  ImageDetailViewController.swift
//  MeMe
//
//  Created by jay on 9/15/17.
//  Copyright © 2017 JayGabriel. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    var imageToSet: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        imageView.image = imageToSet
        imageView.contentMode = .scaleAspectFit
    }
    
}
