//
//  settingsVC.swift
//  SSM
//
//  Created by Alexander Hart on 7/21/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import Firebase

class settingsVC: UIViewController {
    
    @IBAction func editNameTapped(sender: AnyObject) {
//        let editnameViewController = editnameViewController()
//        let newController = UINavigationController(rootViewController: editnameViewController)
//        self.presentViewController(newController, animated: true, completion: nil)
        
        let nameEditVC = nameEditViewController()
        let newController = UINavigationController(rootViewController: nameEditVC)
        self.presentViewController(newController, animated: true, completion: nil)
    }
    
    @IBAction func editFirstMajorTapped(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("firstMajorEdit")
        let newController = UINavigationController(rootViewController: controller)
        self.presentViewController(newController, animated: true, completion: nil)
    }

    @IBAction func editFirstMinorTapped(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("firstMinorEdit")
        let newController = UINavigationController(rootViewController: controller)
        self.presentViewController(newController, animated: true, completion: nil)
    }
    
    @IBAction func editSecondMajorTapped(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("secondMajorEdit")
        let newController = UINavigationController(rootViewController: controller)
        self.presentViewController(newController, animated: true, completion: nil)
    }
    
    @IBAction func editSecondMinorTapped(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("secondMinorEdit")
        let newController = UINavigationController(rootViewController: controller)
        self.presentViewController(newController, animated: true, completion: nil)
    }
    
    @IBAction func logOutTapped(sender: AnyObject) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        
        fbLoginManager.logOut()
        
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("mainScreen")
        
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(red: (153/255.0), green: (0/255.0), blue: (10/255.0), alpha: 1.0)
        
        navigationController?.navigationBar.barTintColor = UIColor.clearColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true

        // Do any additional setup after loading the view.
    }
    
    func titleIconTap() {
        print("success")
    }
    
    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
