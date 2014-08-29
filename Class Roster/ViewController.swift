//
//  ViewController.swift
//  Class Roster Final
//
//  Created by Kevin Pham on 8/26/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var teachers = [Person]()
    var students = [Person]()
    var classRoster = [[Person]]()
    var defaultProfileImage = UIImage(named: "default")
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        let path = NSBundle.mainBundle().pathForResource("Roster", ofType: "plist")
        let pListArray = NSArray(contentsOfFile: path)

        if let savedArray = NSKeyedUnarchiver.unarchiveObjectWithFile(self.pathForPListArchive()) as? NSArray {
            self.teachers = savedArray.objectAtIndex(0) as [Person]
            self.classRoster.append(teachers)
            self.students = savedArray.objectAtIndex(1) as [Person]
            self.classRoster.append(students)
            self.imageLoad()
        } else {
            for arrayIndex in 0...(pListArray.count-1) {
                let arrayInArray : AnyObject = pListArray.objectAtIndex(arrayIndex)
                
                if arrayIndex == 0 {
                    for personIndex in 0...(arrayInArray.count - 1) {
                        let personObject : AnyObject = arrayInArray.objectAtIndex(personIndex)
                        var pListPerson = Person(firstName: personObject["firstName"] as String, lastName: personObject["lastName"] as String)
                        self.teachers.append(pListPerson)
                    }
                    self.classRoster.append(teachers)
                } else {
                    for personIndex in 0...(arrayInArray.count - 1) {
                        let personObject : AnyObject = arrayInArray.objectAtIndex(personIndex)
                        var pListPerson = Person(firstName: personObject["firstName"] as String, lastName: personObject["lastName"] as String)
                        self.students.append(pListPerson)
                    }
                    self.classRoster.append(students)
                }
                
            }
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // super.viewWillAppear(true)
        self.saveData()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return self.classRoster.count
    }
    
    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        switch section {
        case 0:
            return "Teachers"
        default:
            return "Students"
        }
        
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.classRoster[section].count
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        var personForRow = self.classRoster[indexPath.section][indexPath.row]
        cell.textLabel.text = personForRow.fullName()

        // ** Adjust imageView frame and size OR should I pop a UIImageView controller inside prototype cell. **
        // cell.imageView.frame = CGRectMake(0, 0, 32, 32)
        // cell.imageView.bounds = CGRectMake(0, 0, 32, 32)
        if personForRow.profileImage != nil {
            cell.imageView.image = personForRow.profileImage
        } else {
            cell.imageView.image = defaultProfileImage
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "showDetail" {
            var detailViewController = segue.destinationViewController as DetailViewController
            let section = tableView.indexPathForSelectedRow().section
            let row = tableView.indexPathForSelectedRow().row

            var personForRow = self.classRoster[section][row]
            
            detailViewController.selectedPerson = personForRow
        }
        
    }
    
    @IBAction func cancelButton(segue: UIStoryboardSegue) {
        
    }

    @IBAction func unwindFromAddRoster(segue: UIStoryboardSegue) {
        
    }

    func saveData() {
        var saveArray = self.classRoster
        NSKeyedArchiver.archiveRootObject(saveArray, toFile: self.pathForPListArchive())
    }
    
    func pathForPListArchive() -> String {
        let documentsDirectory = self.pathForDocumentDirectory()
        let filePath = documentsDirectory + "/Archive"
        return filePath
    }
    
    func pathForDocumentDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as [String]
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func imageLoad() {
        for imageIndex in 0...1 {
            for personObject in classRoster[imageIndex] {
                if personObject.hasImage {
                    let filePath = self.pathForDocumentDirectory() + "/\(personObject.fullName()).png"
                    var pngData = NSData(contentsOfFile: filePath)
                    var image = UIImage(data: pngData)
                    personObject.profileImage = image
                }
            }
        }
        
    }
    
}

