//
//  Person.swift
//  Class Roster Final
//
//  Created by Kevin Pham on 8/26/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class Person: NSObject, NSCoding {
    
    var firstName : String
    var lastName : String
    
    var gitHubUserName : String?
    
    var profileImage : UIImage?
    var hasImage = false
    
    init (firstName : String, lastName : String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    func fullName() -> String {
        return firstName + " " + lastName
    }
    
    required init(coder aDecoder: NSCoder!) {
        self.firstName      = aDecoder.decodeObjectForKey("firstName") as String
        self.lastName       = aDecoder.decodeObjectForKey("lastName") as String
        self.gitHubUserName = aDecoder.decodeObjectForKey("gitHubUserName") as? String
        self.hasImage       = aDecoder.decodeObjectForKey("hasImage") as Bool
    }
    
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(firstName, forKey: "firstName")
        aCoder.encodeObject(lastName, forKey: "lastName")
        aCoder.encodeObject(gitHubUserName, forKey: "gitHubUserName")
        aCoder.encodeObject(hasImage, forKey: "hasImage")
    }
    
}