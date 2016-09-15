//
//  countDown.swift
//  SSM
//
//  Created by Alexander Hart on 7/1/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import Firebase

class countdownVC: UIViewController {
    
    var userA = Users(meetAmount: 5, status: "", taken: "", email: "", name: "", gender: "", year: "", firstMajor: "", firstMinor: "Undefined", secondMajor: "Undefined", secondMinor: "Undefined", urlOne: "", urlTwo: "", latitude: "", longitude: "", destinationLatitude: "", destinationLongitude: "", matchKey: "", otherUserName: "", otherUserFirstMajor: "", otherUserID: "", otherUserUrlOne: "", otherUserUrlTwo: "", otherUserLatitude: "", otherUserLongitude: "", releaseDate: 0)
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBAction func cancelTapped(sender: AnyObject) {
        // Display warning
        let alert = UIAlertController(title: "Warning", message: "Cancelling a meet early will lower your meet limit", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Destructive, handler: { action in
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
                var meetAmount = -1
                var releaseDate: NSNumber
                
                meetAmount = (snapshot.value!.objectForKey("meetAmount") as? Int)!
                meetAmount = meetAmount - 1
                
                // 7.10.16 12:46 - Logical bug found
                //
                // Not sure why I was updating values in the other user ID's object, but I changed
                // it to the currently logged-in user
                if meetAmount == 0 {
                    releaseDate = NSDate().timeIntervalSince1970 + 84000 // 24 hours ahead of time
                    self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["meetAmount": meetAmount, "releaseDate": releaseDate])
                }
                else {
                    releaseDate = 0
                    self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["meetAmount": meetAmount, "releaseDate": releaseDate])
                }
            })
            
            // Update both parties
            self.rootRef.child("users/").child(self.userA.otherUserID).updateChildValues(["otherUserID": "", "matchKey": "10", "otherUserName": "","otherUserLatitude": "", "otherUserLongitude": "", "otherUserUrlOne": "", "otherUserUrlTwo": "", "otherUserFirstMajor": ""])
            
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["otherUserID": "", "matchKey": "10", "otherUserName": "","otherUserLatitude": "", "otherUserLongitude": "", "otherUserUrlOne": "", "otherUserUrlTwo": "", "otherUserFirstMajor": ""])
            
            // Redirect to mainVC
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("testVC")
            self.presentViewController(controller, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Go back", style: UIAlertActionStyle.Destructive, handler: { action in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    var count = 0
    var startCountDown = false
    var seconds = 0
    let rootRef     = FIRDatabase.database().reference()
    var timer = NSTimer()
    var timer2 = NSTimer() // Used to check updated cordinates
    
    @IBOutlet weak var defaultMsg: UILabel!
    
    var label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.userA.otherUserName            = (snapshot.value!.objectForKey("otherUserName") as? String)!
            self.userA.otherUserID              = (snapshot.value!.objectForKey("otherUserID") as? String)!
            self.userA.destinationLatitude      = (snapshot.value!.objectForKey("destinationLatitude") as? String)!
            self.userA.destinationLongitude     = (snapshot.value!.objectForKey("destinationLongitude") as? String)!
        })
        
        self.timerLabel.hidden = true
    
        seconds = 20
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.defaultMsg.text = "Waiting for " + userA.otherUserName
        
        timerLabel.text = "Time: \(seconds)"
        
        let radius = 0.00008938873734
        
        self.rootRef.child("users/").child(self.userA.otherUserID).observeEventType(.Value, withBlock: { snapshot in
            let latitude = (snapshot.value!.objectForKey("latitude") as! String)
            let longitude = (snapshot.value!.objectForKey("longitude") as! String)
            let profileURL = (snapshot.value!.objectForKey("urlOne") as! String) + "&" + (snapshot.value!.objectForKey("urlTwo") as! String)
            
            if Double(latitude) < (Double(self.userA.destinationLatitude)! + radius) && Double(latitude) > (Double(self.userA.destinationLatitude)! - radius) && Double(longitude) > (Double(self.userA.destinationLongitude)! - radius) && Double(longitude) < (Double(self.userA.destinationLongitude)! + radius) {
                self.timerLabel.hidden = false
                self.defaultMsg.hidden = true
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.subtractTime), userInfo: nil, repeats: true)
            }
            
            NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: profileURL)!, completionHandler: { (data, response, error) ->
                Void in
                
                if error != nil {
                    print(error)
                    return
                }
                
                self.profileImageView.image = UIImage(data: data!)
                
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
                self.profileImageView.clipsToBounds = true
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.view.addSubview(self.profileImageView)
                })
                
            }).resume()

        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.rootRef.child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).removeAllObservers()
        self.rootRef.child(self.userA.otherUserID).removeAllObservers()
    }
    
    func subtractTime() {
        seconds -= 1
        timerLabel.text = "Time: \(seconds)"
        
        if (seconds <= 5) {
            timerLabel.textColor = UIColor.redColor()
        }
        
        if(seconds == 0)  {
            timer.invalidate()
            
            
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                var meetAmount = -1
                var releaseDate: NSNumber
                
                meetAmount = (snapshot.value!.objectForKey("meetAmount") as? Int)!
                meetAmount = meetAmount - 1
                
                if meetAmount == 0 {
                     releaseDate = NSDate().timeIntervalSince1970 + 42000 // 12 hours ahead of time
                    self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["meetAmount": 0, "releaseDate": releaseDate])
                } else {
                    releaseDate = 0
                    self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["meetAmount": meetAmount, "releaseDate": releaseDate])
                }
                
                
            })
            
            // Switch to feedback V.C.
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("feedback")
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
}



