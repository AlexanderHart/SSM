//
//  SettingsViewController.swift
//  SSM
//
//  Created by Alexander Hart on 6/6/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class SettingsViewController: UIViewController {
    
    @IBAction func logOutTapped(sender: AnyObject) {
        let loginManger : FBSDKLoginManager = FBSDKLoginManager()
        loginManger.logOut()
    
        // Convert locally stored Optional email to a string
        var id = ""
        if let savedId = NSUserDefaults.standardUserDefaults().stringForKey("id") {
            id = savedId
        }
        
        
        let rootRef     = FIRDatabase.database().reference()
        let usersRef    = rootRef.child("users/")   // Container for all users
        let userRef     = usersRef.child(id)        // Specific to individual user
        
        userRef.updateChildValues(["status": "0", "taken": "0"])
        
        // Switch views
       let controller = self.storyboard!.instantiateViewControllerWithIdentifier("mainScreen")
  
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = "Settings"
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Helvetica", size: 35)!];
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: (136/255.0), green: (35/255.0), blue: (69/255.0), alpha: 1.0)]
    }
}
