//
//  DetailViewController.swift
//  Class Roster - ATFC
//
//  Created by Kevin Pham on 8/28/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
    var selectedPerson : Person?
    var defaultProfileImage = UIImage(named: "default")
    
    var textField = UITextField()
    var imageDownloadQueue = NSOperationQueue()
    
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var headlineLbl: UILabel!
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var gitHubTxtField: UITextField!
    @IBOutlet weak var headlineTxtField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageActivity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstNameTxtField.delegate = self
        self.lastNameTxtField.delegate = self
        
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 6 // 2=Circle, 3,4,5=RoundedCorners, 10=
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderWidth = 3.0
        self.imageView.layer.borderColor = UIColor.whiteColor().CGColor
        
        // UIGestureRecognizer
        
        let imageSelect = UITapGestureRecognizer(target: self, action: NSSelectorFromString("imageTap"))
        self.imageView.addGestureRecognizer(imageSelect)
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewWillAppear(animated: Bool) {
        // super.viewWillAppear(true)
        self.fullNameLbl.text = selectedPerson!.fullName()
        self.firstNameTxtField.text = selectedPerson!.firstName
        self.lastNameTxtField.text = selectedPerson!.lastName
        
        if self.selectedPerson!.gitHubUserName != nil {
            self.gitHubTxtField.text = selectedPerson!.gitHubUserName
        }
        
        if self.selectedPerson!.headline != nil {
            self.headlineLbl.text = selectedPerson!.headline
            self.headlineTxtField.text = selectedPerson!.headline
        } else {
            self.headlineLbl.text = ""
        }
        
        if self.selectedPerson!.profileImage != nil {
            self.imageView.image = self.selectedPerson!.profileImage
        } else {
            self.imageView.image = self.defaultProfileImage
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.selectedPerson!.firstName = self.firstNameTxtField.text
        self.selectedPerson!.lastName = self.lastNameTxtField.text
        self.selectedPerson!.gitHubUserName = self.gitHubTxtField.text
        self.selectedPerson!.headline = self.headlineTxtField.text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Image Picker Controller
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        var editedImage = info[UIImagePickerControllerEditedImage] as UIImage
        self.imageView.image = editedImage
        self.selectedPerson!.profileImage = editedImage
        self.selectedPerson!.hasImage = true
        self.saveImageToPhone(editedImage)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageTap() {
        var profileImageAction = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        profileImageAction.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: nil))
        profileImageAction.addAction(UIAlertAction(title: "Choose Existing", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
            var imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            // imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }))
        profileImageAction.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(profileImageAction, animated: true, completion: nil)
    }
    
    // MARK: - Data & Image Persistance
    
    func saveImageToPhone(image: UIImage) {
        var pngData = UIImagePNGRepresentation(image)
        let filePath = self.pathForDocumentDirectory() + "/\(self.selectedPerson!.fullName()).png"
        pngData.writeToFile(filePath, atomically: true)
    }
    
    func pathForDocumentDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as [String]
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // MARK: - GitHub, JSON, & Concurrent Programming
    
    @IBAction func gitHubAddButton(sender: UIButton) {
        var gitHubAlert = UIAlertController(title: "GitHub", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        gitHubAlert.addTextFieldWithConfigurationHandler(configurationTextField)
        gitHubAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        gitHubAlert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
            self.selectedPerson!.gitHubUserName = self.textField.text
            self.gitHubProfileImage()
        }))
        self.presentViewController(gitHubAlert, animated: true, completion: nil)
    }
    
    func configurationTextField (textField: UITextField!) {
        if let tField = textField {
            self.textField = textField!
            textField.placeholder = "Enter GitHub Username"
            // self.textField.text = "Hello world!"
        }
    }
    
    func gitHubProfileImage() {
        var gitHubURLString = "https://api.github.com/users/\(self.selectedPerson!.gitHubUserName!)"
        var gitHubURL = NSURL(string: gitHubURLString)
        var profilePhotoURL = NSURL()
        println("Connecting to GitHub...")
        self.imageActivity.startAnimating()
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(gitHubURL, completionHandler: { (data, response, error) -> Void in
            // if (error != nil) {
            // return completionHandler(nil, error) // doesn't work
            // }
            
            var error: NSError?
            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
            
            // if (error != nil) {
            // return completionHandler(nil, error) // doesn't work
            // } else {
            // return completionHandler(json["results"] as [NSDictionary], nil)
            // }
            
            if let avatarURL = json["avatar_url"] as? String {
                profilePhotoURL = NSURL(string: avatarURL)
                println("Retrieving GitHub avatar address")
            }
            
            println("Preparing to download avatar ")
            if profilePhotoURL != nil {
                println("profilePhotoURL does exist")
                var downloadOperation = NSBlockOperation { () -> Void in
                    var profilePhotoData = NSData(contentsOfURL: profilePhotoURL)
                    var profilePhotoImage = UIImage(data: profilePhotoData)
                    self.selectedPerson!.profileImage = profilePhotoImage
                    self.selectedPerson!.hasImage = true
                    self.saveImageToPhone(profilePhotoImage)
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.gitHubTxtField.text = self.selectedPerson!.gitHubUserName
                        self.imageView.image = profilePhotoImage
                        self.imageActivity.stopAnimating()
                    })
                }
                
                // downloadOperation.qualityOfService = NSQualityOfService.Background
                self.imageDownloadQueue.addOperation(downloadOperation)
                println("Threading executed")
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.imageActivity.stopAnimating()
                })
                
                var userVerificationAlert = UIAlertController(title: "Oops!", message: "This GitHub username doesn't exist.", preferredStyle: UIAlertControllerStyle.Alert)
                userVerificationAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(userVerificationAlert, animated: true, completion: nil)
            }
        })
        
        task.resume()
    }
    
    @IBAction func headlineAddButton(sender: UIButton) {
        var headlineAlert = UIAlertController(title: "Your Headline", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        headlineAlert.addTextFieldWithConfigurationHandler(configurationTextField)
        headlineAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        headlineAlert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
            if self.textField.text != "" {
                self.headlineFunc()
            } else if self.textField.text != " " {
                self.headlineFunc()
            }
            
        }))
        
        self.presentViewController(headlineAlert, animated: true, completion: nil)

    }
    
    func headlineFunc() {
        self.selectedPerson!.headline = self.textField.text
        self.headlineTxtField.text = self.selectedPerson!.headline
        self.headlineLbl.text = "\"\(self.selectedPerson!.headline!)\""
        println(self.selectedPerson!.headline!)
    }
    
}