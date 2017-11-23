//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Jay Gabriel on 10/8/17.
//  Copyright © 2017 Jay Gabriel. All rights reserved.
//

import Foundation

// Updating main
func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

