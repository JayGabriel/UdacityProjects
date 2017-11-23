//
//  Student.swift
//  OnTheMap
//
//  Created by Jay Gabriel on 10/8/17.
//  Copyright © 2017 Jay Gabriel. All rights reserved.
//

import Foundation

class Student {
    
    // MARK: Properties
    var firstName: String?
    var lastName: String?
    var latitude: Double?
    var longitude: Double?
    var mediaURL: String?
    var updatedAt: String?
    var updatedAtDate: Date?
    
    // MARK: Initializer
    init(studentInfo: [String:AnyObject]) {
        self.firstName = studentInfo[Constants.ParseResponseKeys.FirstName] as? String
        self.lastName = studentInfo[Constants.ParseResponseKeys.LastName] as? String
        self.latitude = studentInfo[Constants.ParseResponseKeys.Latitude] as? Double
        self.longitude = studentInfo[Constants.ParseResponseKeys.Longitude] as? Double
        self.mediaURL = studentInfo[Constants.ParseResponseKeys.MediaURL] as? String
        self.updatedAt = studentInfo[Constants.ParseResponseKeys.UpdatedAt] as? String
        
        getUpdateInfo()
        validateFields()
    }
    
    // MARK: - Class methods
    func getUpdateInfo() {
        
        // This method formats and sets the student's updatedAtDate property
        let calendar = NSCalendar.current
        
        let yearStart = updatedAt!.index(updatedAt!.startIndex, offsetBy: 0)
        let yearEnd = updatedAt!.index(updatedAt!.startIndex, offsetBy: 4)
        let year = String(updatedAt![yearStart..<yearEnd])
        
        let monthStart = updatedAt!.index(updatedAt!.startIndex, offsetBy: 5)
        let monthEnd = updatedAt!.index(updatedAt!.startIndex, offsetBy: 7)
        let month = String(updatedAt![monthStart..<monthEnd])

        let dayStart = updatedAt!.index(updatedAt!.startIndex, offsetBy: 8)
        let dayEnd = updatedAt!.index(updatedAt!.startIndex, offsetBy: 10)
        let day = String(updatedAt![dayStart..<dayEnd])

        let hourStart = updatedAt!.index(updatedAt!.startIndex, offsetBy: 11)
        let hourEnd = updatedAt!.index(updatedAt!.startIndex, offsetBy: 13)
        let hour = String(updatedAt![hourStart..<hourEnd])

        let minuteStart = updatedAt!.index(updatedAt!.startIndex, offsetBy: 14)
        let minuteEnd = updatedAt!.index(updatedAt!.startIndex, offsetBy: 16)
        let minute = String(updatedAt![minuteStart..<minuteEnd])

        let secondStart = updatedAt!.index(updatedAt!.startIndex, offsetBy: 17)
        let secondEnd = updatedAt!.index(updatedAt!.startIndex, offsetBy: 19)
        let second = String(updatedAt![secondStart..<secondEnd])
        
        var dateAndTimeComponents = DateComponents()
        dateAndTimeComponents.year = Int(year)!
        dateAndTimeComponents.month = Int(month)!
        dateAndTimeComponents.day = Int(day)!
        dateAndTimeComponents.hour = Int(hour)!
        dateAndTimeComponents.minute = Int(minute)!
        dateAndTimeComponents.second = Int(second)!
        
        let dateAndTime = calendar.date(from: dateAndTimeComponents)
        self.updatedAtDate = dateAndTime
    }
    
    func validateFields() {
        // This methods validates required fields
        
        if firstName == nil || firstName == "" {
            firstName = "(no first name)"
        }
        if lastName == nil || lastName == "" {
            lastName = "(no last name)"
        }
        if mediaURL == nil || mediaURL == "" {
            mediaURL = "(no media url)"
        }
    }
    
}
