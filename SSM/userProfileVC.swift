//
//  userProfileViewController.swift
//  SSM
//
//  Created by Alexander Hart on 7/10/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import Firebase

class userProfileVC: UIViewController {
    
    var userA = Users(meetAmount: 5,    status: "",                 taken: "",                  email: "",              name: "",               gender: "",     year: "",
                      firstMajor: "",   firstMinor: "",             secondMajor: "",            secondMinor: "",        urlOne: "",             urlTwo: "",     latitude: "",
                      longitude: "",    destinationLatitude: "",    destinationLongitude: "",   matchKey: "",           otherUserName: "",      otherUserFirstMajor: "",
                      otherUserID: "",  otherUserUrlOne: "",        otherUserUrlTwo: "",        otherUserLatitude: "",  otherUserLongitude: "", releaseDate: 0)
    
    @IBOutlet weak var minorsLabel: UILabel!
    @IBOutlet weak var minor: UILabel!
    @IBOutlet weak var minor2: UILabel!
    @IBOutlet weak var major2: UILabel!
    
    @IBOutlet weak var nameLabel                    : UILabel!
    @IBOutlet weak var majorsLabel                  : UILabel!
    @IBOutlet weak var profilePictureImageView      : UIImageView!
    
    @IBAction func meetButnTapped(sender: AnyObject) {
        self.rootRef.child("users/").child(idString).updateChildValues(["matchKey": "101", "otherUserName": self.userA.name, "otherUserID": NSUserDefaults.standardUserDefaults().stringForKey("id")! , "otherUserUrlOne": self.userA.urlOne, "otherUserUrlTwo": self.userA.urlTwo, "otherUserLatitude": self.userA.latitude, "otherUserLongitude": self.userA.longitude, "otherUserFirstMajor": self.userA.firstMajor])
        
        waitingAlert.view.tintColor = UIColor.blackColor()
        skippedAlert.view.tintColor = UIColor.blackColor()
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = UIColor.blackColor()
        loadingIndicator.startAnimating();
        
        waitingAlert.view.addSubview(loadingIndicator)
        
        presentViewController(waitingAlert, animated: true, completion: nil)
        
        
        // When meet request is sent, display activity view
        // Create Observer listener
        // If otherUserID changes
        // Stop the listener
        // Dismiss the UIViewAlert
        // Display active VC
        
        //
        // vs.
        //
        
        
        // When meet request is sent, display activity view
        // Create Observer listener
        // If otherUserID changes
        // Set bool to true
        // If bool is true
        // Stop the listener
        // Dismiss the UIViewAlert
        // Display active VC
        
        _ = false
        
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeEventType(.Value, withBlock: { snapshot in
            if (snapshot.value!.objectForKey("otherUserID") as? String)! != "" {
                
                // Dismiss waiting hub
                self.dismissViewControllerAnimated(false, completion: nil)
                
                // Dismiss profile VC
                self.handleCancel()
                
                
                
                
                //                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                //                let controller = storyboard.instantiateViewControllerWithIdentifier("active")
                //                self.presentViewController(controller, animated: true, completion: nil)
            }
        })
        
        self.rootRef.child("users/").child(self.idString).observeEventType(.Value, withBlock: { snapshot in
            if (snapshot.value!.objectForKey("otherUserID") as? String)! == "" {
                // Dismiss waiting hub
                self.dismissViewControllerAnimated(false, completion: nil)
                
                self.skippedAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Destructive, handler: { action in
                    // Dismiss waiting hub
                    self.dismissViewControllerAnimated(false, completion: nil)
                    
                    // Dismiss profile VC
                    self.handleCancel()
                }))
                
                self.presentViewController(self.skippedAlert, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func chatButnTapped(sender: AnyObject) {
        let chatVC = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatVC.toIDString = idString
        chatVC.toNameString = nameString
        let newController = UINavigationController(rootViewController: chatVC)
        self.presentViewController(newController, animated: true, completion: nil)
    }
    
    let waitingAlert                                = UIAlertController(title: nil, message: "", preferredStyle: .Alert)
    let skippedAlert                                = UIAlertController(title: nil, message: "", preferredStyle: .Alert)
    var profileIconImageView                        = UIImageView()
    var profileImageUrlString                       = ""
    var idString                                    = "" // For the current user profile
    var nameString                                  = ""
    var latitudeString                              = ""
    var longitudeString                             = ""
    let rootRef                                     = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        waitingAlert.message = "Waiting for response"
        skippedAlert.message = nameString + " is unavailable"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<", style: .Plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(red: (153/255.0), green: (0/255.0), blue: (10/255.0), alpha: 1.0)
        
        navigationController?.navigationBar.barTintColor = UIColor.clearColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        
        //self.navController = UINavigationController(rootViewController: self)
        
        // Retrieve the current logged-in user's data
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.userA.name          = snapshot.value!.objectForKey("name") as? String
            self.userA.otherUserID   = snapshot.value!.objectForKey("otherUserID") as? String
            //self.userA.otherUserName   = snapshot.value!.objectForKey("otherUserName") as? String // Possible delete
            self.userA.urlOne        = snapshot.value!.objectForKey("urlOne") as? String
            self.userA.urlTwo        = snapshot.value!.objectForKey("urlTwo") as? String
            self.userA.latitude      = snapshot.value!.objectForKey("latitude") as? String
            self.userA.longitude     = snapshot.value!.objectForKey("longitude") as? String
            self.userA.firstMajor    = snapshot.value!.objectForKey("firstMajor") as? String
            self.userA.firstMinor    = snapshot.value!.objectForKey("firstMinor") as? String
            self.userA.secondMajor    = snapshot.value!.objectForKey("secondMajor") as? String
            self.userA.secondMinor    = snapshot.value!.objectForKey("secondMinor") as? String
        })
        
        self.profileIconImageView = UIImageView(image: UIImage(named: "profilePageLogo"))
        
        self.profileIconImageView.frame = CGRect(x: self.view.frame.width * 0.2309375, y: self.view.frame.height * 0.047535211, width: self.view.frame.width * 0.051125, height: self.view.frame.height * 0.054577464788)
        
        self.view.addSubview(self.profileIconImageView)

    }
    
    override func viewWillAppear(animated: Bool) {
        self.rootRef.child("users/").child(idString).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.nameLabel.text = snapshot.value!.objectForKey("name") as? String
            self.majorsLabel.text = snapshot.value!.objectForKey("firstMajor") as? String
            self.major2.text = snapshot.value!.objectForKey("secondMajor") as? String
            self.minor.text = snapshot.value!.objectForKey("firstMinor") as? String
            self.minor2.text = snapshot.value!.objectForKey("secondMinor") as? String
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.userA.secondMajor == "Undefined" || self.userA.secondMajor == "Undecided" {
            self.major2.text = ""
        }
        else {
            self.major2.text = self.userA.secondMajor
        }
        
        if self.userA.firstMinor == "Undefined" || self.userA.firstMinor == "Undecided" {
            self.minor.text = ""
        }
        else {
            self.minor.text = self.userA.firstMinor
        }
        
        if self.userA.secondMinor == "Undefined" || self.userA.secondMinor == "Undecided" {
            self.minor2.text = ""
        }
        else {
            self.minor2.text = self.userA.secondMinor
        }
        
        if (self.userA.firstMinor == "Undefined" || self.userA.firstMinor == "Undecided") && (self.userA.secondMinor == "Undefined" || self.userA.secondMinor == "Undecided") {
            self.minorsLabel.hidden = true
        }
        else {
            self.minorsLabel.hidden = false
        }

        let url = NSURL(string: self.profileImageUrlString)!
        
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { [weak self] (data, response, error) ->
            Void in
            
            guard let strongSelf = self else { return }
            
            // create the UIImage on the background thread
            let image = UIImage(data: data!)
            
            // then jump to the main thread to modify your UIImageView
            dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
                guard let strongSelfInner = self else { return }
                
                let profilePictureImageView = strongSelfInner.profilePictureImageView
                
                profilePictureImageView.image = image
                profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width / 2;
                profilePictureImageView.clipsToBounds = true
                
                strongSelf.view.addSubview(profilePictureImageView)
                })
            }).resume()
        
//        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: self.profileImageUrlString)!, completionHandler: { (data, response, error) ->
//            Void in
//            
//            if error != nil {
//                print(error)
//                return
//            }
//            
//            self.profilePictureImageView.image = UIImage(data: data!)
//            
//            self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width / 2;
//            self.profilePictureImageView.clipsToBounds = true
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.view.addSubview(self.profilePictureImageView)
//            })
//            
//        }).resume()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.rootRef.child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).removeAllObservers()
        self.rootRef.child(self.idString).removeAllObservers()
    }
    
    func cancelObserver() {
        self.rootRef.removeAllObservers()
    }
    
    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
