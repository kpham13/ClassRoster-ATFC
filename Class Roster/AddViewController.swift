//
//  AddViewController.swift
//  Class Roster Final
//
//  Created by Kevin Pham on 8/26/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UITextFieldDelegate {

    var addPerson : Person?
    var defaultProfileImage = UIImage(named: "default")
    
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstNameTxtField.delegate = self
        self.lastNameTxtField.delegate = self
        
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 6 // 2=Circle, 3,4,5=RoundedCorners, 10=
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderWidth = 3.0
        self.imageView.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override func viewWillAppear(animated: Bool) {
        // super.viewWillAppear(true)
        self.imageView.image = defaultProfileImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "doneSegue" {
            var rootViewController = segue.destinationViewController as ViewController
            
            var firstName = self.firstNameTxtField.text
            var lastName = self.lastNameTxtField.text
            var newPerson = Person(firstName: firstName as String, lastName: lastName as String)
            addPerson = newPerson
            
            rootViewController.classRoster[1].append(addPerson!)
        }
        
    }

}