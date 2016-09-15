//
//  feedBackViewController.swift
//  SSM
//
//  Created by Alexander Hart on 7/3/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase
import Cosmos

class feedbackVC: UIViewController, UITextFieldDelegate {
    
    var userA = Users(meetAmount: 5,    status: "",                 taken: "",                  email: "",              name: "",               gender: "",     year: "",
                      firstMajor: "",   firstMinor: "",             secondMajor: "",            secondMinor: "",        urlOne: "",             urlTwo: "",     latitude: "",
                      longitude: "",    destinationLatitude: "",    destinationLongitude: "",   matchKey: "",           otherUserName: "",      otherUserFirstMajor: "",
                      otherUserID: "",  otherUserUrlOne: "",        otherUserUrlTwo: "",        otherUserLatitude: "",  otherUserLongitude: "", releaseDate: 0)
    
    @IBOutlet weak var ratingControl:   RatingControl!
    @IBOutlet weak var msgField:        UITextField!
    @IBOutlet weak var cosmosControl:   CosmosView!
    
    @IBAction func Test(sender: AnyObject) {
        if msg != "" {
            self.rootRef.child("feedback/").child(self.userA.otherUserID).observeEventType(.Value, withBlock: { snapshot in
                // Check if this user is already in the database
                if snapshot.hasChild(NSUserDefaults.standardUserDefaults().stringForKey("id")!) {
                }
                else
                {
                    let msgRef      = self.rootRef.child("feedback/").child(self.userA.otherUserID).child(NSUserDefaults.standardUserDefaults().stringForKey("id")!)
                    let feedback    = Feedback(message: self.msg, rating: self.cosmosControl.rating, fromID: self.userA.otherUserID)
                    
                    msgRef.setValue(feedback.toAnyObject())
                }
            })
            
            let alert = UIAlertController(title: "Thank You ", message: "Your feedback will only be shared with your match.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Destructive, handler: { action in
                self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["matchKey": "10", "otherUserFirstMajor": "","otherUserName": "", "otherUserID" : "", "otherUserLatitude": "", "otherUserLongitude": "", "otherUserUrlOne": "", "otherUserUrlTwo": ""])
                
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("testVC")
                self.presentViewController(controller, animated: true, completion: nil)
                
                //if (self.interstital.isReady) {
                //self.interstital.presentFromRootViewController(self)
                //interstital = CreateAd()
                //}
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error ", message: "You must provide feedback", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Destructive, handler: { action in
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    var interstital                     : GADInterstitial!
    let rootRef                         = FIRDatabase.database().reference()
    var msg                             = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstital = GADInterstitial(adUnitID: "ca-app-pub-2095883331397557/4710834622")
        
        let request = GADRequest()
        interstital.loadRequest(request)
        
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.userA.otherUserID   = (snapshot.value!.objectForKey("otherUserID") as? String)!
        })
        
        msgField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        if (interstital.isReady) {
            interstital.presentFromRootViewController(self)
            interstital = CreateAd()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.rootRef.child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).removeAllObservers()
        self.rootRef.child(self.userA.otherUserID).removeAllObservers()
    }
    
    func CreateAd() -> GADInterstitial {
        let interstital = GADInterstitial(adUnitID: "ca-app-pub-2095883331397557/4710834622")
        interstital.loadRequest(GADRequest())
        return interstital
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.msg = textField.text!
    }
}
