//
//  nameEditViewController.swift
//  SSM
//
//  Created by Alexander Hart on 7/29/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import Firebase

class nameEditViewController: UIViewController, UITextFieldDelegate {
    
   func savedTapped() {
        var id = ""
        if let savedId = NSUserDefaults.standardUserDefaults().stringForKey("id") {
            id = savedId
        }
        let usersRef    = rootRef.child("users/")   // Container for all users
        let userRef     = usersRef.child(id)        // Specific to individual
        
        if nameUpdate.rangeOfString(" ") != nil { // Display warning
            let alert = UIAlertController(title: "Warning", message: "Name can not contain spaces.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.Destructive, handler: { action in
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else if nameUpdate == "" {
            let alert = UIAlertController(title: "Warning", message: "Please enter a new name if you wish to change your current one", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.Destructive, handler: { action in
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            userRef.updateChildValues(["name": nameUpdate])
            
            // Display message
            let alert = UIAlertController(title: "Success", message: "Your name has been changed.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Destructive, handler: { action in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewControllerWithIdentifier("testVC")
                self.presentViewController(controller, animated: true, completion: nil)
                
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
    }
    
    @IBOutlet var nameTextField: UITextField!
    
    let rootRef     = FIRDatabase.database().reference()
    var nameUpdate  = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.nameTextField.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action:
            #selector(handleCancel))
       navigationItem.leftBarButtonItem?.tintColor = UIColor(red: (153/255.0), green: (0/255.0), blue: (10/255.0), alpha: 1.0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(savedTapped))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: (153/255.0), green: (0/255.0), blue: (10/255.0), alpha: 1.0)
        navigationItem.title = ""
        navigationController?.navigationBar.barTintColor = UIColor.clearColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
    }
    
    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        nameTextField.text = ""
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        nameUpdate = textField.text!
    }
}
