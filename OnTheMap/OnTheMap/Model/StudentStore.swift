//
//  StudentStore.swift
//  OnTheMap
//
//  Created by Jay Gabriel on 10/8/17.
//  Copyright © 2017 Jay Gabriel. All rights reserved.
//

import Foundation

class StudentStore {
    
    var students: [Student]
    
    init() {
        self.students = [Student]()
    }
    
    func addStudent(student: Student) {
        if (student.latitude != nil && student.longitude != nil) {
            students.append(student)
        }
    }
    
    func removeAllStudents() {
        students.removeAll()
    }
    
    func sortStudents() {
        students.sort { $0.updatedAtDate! > $1.updatedAtDate! }
    }

}
