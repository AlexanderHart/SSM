//
//  matchViewController.swift
//  SSM
//
//  Created by Alexander Hart on 7/2/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import Firebase
import Canvas

class matchVC: UIViewController {
    
    @IBOutlet weak var meetButtonImg: UIImageView!
    @IBOutlet weak var skipButtonImg: UIImageView!
    @IBOutlet weak var mainLabel: UIImageView!
    @IBOutlet weak var userOnePic: UIImageView!
    @IBOutlet weak var userTwoPic: UIImageView!
    @IBOutlet weak var subLabel: UILabel!
    
    var userA = Users(meetAmount: 5, status: "", taken: "", email: "", name: "", gender: "", year: "", firstMajor: "", firstMinor: "Undefined", secondMajor: "Undefined", secondMinor: "Undefined", urlOne: "", urlTwo: "", latitude: "", longitude: "", destinationLatitude: "", destinationLongitude: "", matchKey: "", otherUserName: "", otherUserFirstMajor: "", otherUserID: "" , otherUserUrlOne: "", otherUserUrlTwo: "", otherUserLatitude: "", otherUserLongitude: "", releaseDate: 0)
    
    var profileImageUrlTwo     = ""
    var otherUserName          = ""
    var otherUserID            = ""
    
    let rootRef                = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Retrieve the current logged-in user's data
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.userA.urlOne               = snapshot.value!.objectForKey("urlOne")            as? String
            self.userA.urlTwo               = snapshot.value!.objectForKey("urlTwo")            as? String
            self.userA.firstMajor           = snapshot.value!.objectForKey("firstMajor")        as? String
            self.userA.name                 = snapshot.value!.objectForKey("name")              as? String
            self.userA.latitude             = snapshot.value!.objectForKey("latitude")          as? String
            self.userA.longitude            = snapshot.value!.objectForKey("longitude")         as? String
            
            self.userA.otherUserName        = snapshot.value!.objectForKey("otherUserName")     as? String
            self.userA.otherUserID          = snapshot.value!.objectForKey("otherUserID")       as? String
            self.userA.otherUserUrlOne      = snapshot.value!.objectForKey("otherUserUrlOne")   as? String
            self.userA.otherUserUrlTwo      = snapshot.value!.objectForKey("otherUserUrlTwo")   as? String
        })
        
        self.userOnePic.layer.cornerRadius  = self.userOnePic.frame.size.width / 2;
        self.userOnePic.clipsToBounds       = true
        
        self.userTwoPic.layer.cornerRadius  = self.userTwoPic.frame.size.width / 2;
        self.userTwoPic.clipsToBounds       = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.rootRef.child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).removeAllObservers()
        self.rootRef.child(self.userA.otherUserID).removeAllObservers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.subLabel.adjustsFontSizeToFitWidth = true
        self.subLabel.text = "You and " + self.userA.otherUserName + " should meet"
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(meetTapped))
        meetButtonImg.userInteractionEnabled = true
        meetButtonImg.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:#selector(skipTapped))
        skipButtonImg.userInteractionEnabled = true
        skipButtonImg.addGestureRecognizer(tapGestureRecognizer2)
        
        
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: self.userA.urlOne + "&" + self.userA.urlTwo)!, completionHandler: { (data, response, error) ->
            Void in
            
            if error != nil {
                print(error)
                return
            }
            
            let image2 = UIImage(data: data!)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.userOnePic.image = image2
            })
            
        }).resume()
        
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: self.userA.otherUserUrlOne + "&" + self.userA.otherUserUrlTwo)!, completionHandler: { (data, response, error) ->
            Void in
            
            if error != nil {
                print(error)
                return
            }
            
            let image2 = UIImage(data: data!)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.userTwoPic.image = image2
            })
            
        }).resume()
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newWidth))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func meetTapped() {
        
        let alert = UIAlertController(title: "Where do you want to meet?", message: "Choose a building", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Boylan", style: UIAlertActionStyle.Destructive, handler: { action in
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["destinationLatitude": "40.631708", "destinationLongitude": "-73.951668"])
            
            self.rootRef.child("users/").child(self.userA.otherUserID).updateChildValues(["destinationLatitude": "40.631708", "destinationLongitude": "-73.951668", "otherUserName": self.userA.name, "otherUserLatitude": self.userA.latitude, "otherUserLongitude": self.userA.longitude, "otherUserUrlOne": self.userA.urlOne, "otherUserUrlTwo": self.userA.urlTwo, "otherUserFirstMajor": self.userA.firstMajor, "otherUserID": NSUserDefaults.standardUserDefaults().stringForKey("id")!])
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("active")
            self.presentViewController(controller, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "My House", style: UIAlertActionStyle.Destructive, handler: { action in
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["destinationLatitude": "40.806800", "destinationLongitude": "-73.024721"])
            
            self.rootRef.child("users/").child(self.userA.otherUserID).updateChildValues(["destinationLatitude": "40.806800", "destinationLongitude": "-73.024721", "otherUserName": self.userA.name, "otherUserLatitude": self.userA.latitude, "otherUserLongitude": self.userA.longitude, "otherUserUrlOne": self.userA.urlOne, "otherUserUrlTwo": self.userA.urlTwo, "otherUserFirstMajor": self.userA.firstMajor, "otherUserID": NSUserDefaults.standardUserDefaults().stringForKey("id")!])
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("active")
            self.presentViewController(controller, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Ingersoll", style: UIAlertActionStyle.Destructive, handler: { action in
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["destinationLatitude": "40.630991", "destinationLongitude": "-73.951571"])
            
            self.rootRef.child("users/").child(self.userA.otherUserID).updateChildValues(["destinationLatitude": "40.630991", "destinationLongitude": "-73.951571", "otherUserName": self.userA.name, "otherUserLatitude": self.userA.latitude, "otherUserLongitude": self.userA.longitude, "otherUserUrlOne": self.userA.urlOne, "otherUserUrlTwo": self.userA.urlTwo, "otherUserFirstMajor": self.userA.firstMajor, "otherUserID": NSUserDefaults.standardUserDefaults().stringForKey("id")!])
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("active")
            self.presentViewController(controller, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Library", style: UIAlertActionStyle.Destructive, handler: { action in
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["destinationLatitude": "40.631466", "destinationLongitude": "-73.950538"])
            
            
            
            self.rootRef.child("users/").child(self.userA.otherUserID).updateChildValues(["destinationLatitude": "40.631466", "destinationLongitude": "-73.950538", "otherUserName": self.userA.name, "otherUserLatitude": self.userA.latitude, "otherUserLongitude": self.userA.longitude, "otherUserUrlOne": self.userA.urlOne, "otherUserUrlTwo": self.userA.urlTwo, "otherUserFirstMajor": self.userA.firstMajor, "otherUserID": NSUserDefaults.standardUserDefaults().stringForKey("id")!])
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("active")
            self.presentViewController(controller, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Library Cafe", style: UIAlertActionStyle.Destructive, handler: { action in
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["destinationLatitude": "40.632122", "destinationLongitude": "-73.950641"])
            
            
            
            self.rootRef.child("users/").child(self.userA.otherUserID).updateChildValues(["destinationLatitude": "40.631924", "destinationLongitude": "-73.950202", "otherUserName": self.userA.name, "otherUserLatitude": self.userA.latitude, "otherUserLongitude": self.userA.longitude, "otherUserUrlOne": self.userA.urlOne, "otherUserUrlTwo": self.userA.urlTwo, "otherUserFirstMajor": self.userA.firstMajor, "otherUserID": NSUserDefaults.standardUserDefaults().stringForKey("id")!])
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("active")
            self.presentViewController(controller, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "James", style: UIAlertActionStyle.Destructive, handler: { action in
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["destinationLatitude": "40.631495", "destinationLongitude": "-73.953437"])
            
            
            
            self.rootRef.child("users/").child(self.userA.otherUserID).updateChildValues(["destinationLatitude": "40.631495", "destinationLongitude": "-73.953437", "otherUserName": self.userA.name, "otherUserLatitude": self.userA.latitude, "otherUserLongitude": self.userA.longitude, "otherUserUrlOne": self.userA.urlOne, "otherUserUrlTwo": self.userA.urlTwo, "otherUserFirstMajor": self.userA.firstMajor, "otherUserID": NSUserDefaults.standardUserDefaults().stringForKey("id")!])
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("active")
            self.presentViewController(controller, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Roosevelt", style: UIAlertActionStyle.Destructive, handler: { action in
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["destinationLatitude": "40.630713", "destinationLongitude": "-73.953275"])
            
            
            self.rootRef.child("users/").child(self.userA.otherUserID).updateChildValues(["destinationLatitude": "40.630713", "destinationLongitude": "-73.953275", "otherUserName": self.userA.name, "otherUserLatitude": self.userA.latitude, "otherUserLongitude": self.userA.longitude, "otherUserUrlOne": self.userA.urlOne, "otherUserUrlTwo": self.userA.urlTwo, "otherUserFirstMajor": self.userA.firstMajor, "otherUserID": NSUserDefaults.standardUserDefaults().stringForKey("id")!])
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("active")
            self.presentViewController(controller, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "W.E.B.", style: UIAlertActionStyle.Destructive, handler: { action in
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["destinationLatitude": "40.630354", "destinationLongitude": "-73.955314"])
            
            
            
            self.rootRef.child("users/").child(self.userA.otherUserID).updateChildValues(["destinationLatitude": "40.630354", "destinationLongitude": "-73.955314", "otherUserName": self.userA.name, "otherUserLatitude": self.userA.latitude, "otherUserLongitude": self.userA.longitude, "otherUserUrlOne": self.userA.urlOne, "otherUserUrlTwo": self.userA.urlTwo, "otherUserFirstMajor": self.userA.firstMajor, "otherUserID": NSUserDefaults.standardUserDefaults().stringForKey("id")!])
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("active")
            self.presentViewController(controller, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Whitehead", style: UIAlertActionStyle.Destructive, handler: { action in
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["destinationLatitude": "40.631924", "destinationLongitude": "-73.950202"])
            
            
            
            self.rootRef.child("users/").child(self.userA.otherUserID).updateChildValues(["destinationLatitude": "40.631924", "destinationLongitude": "-73.950202", "otherUserName": self.userA.name, "otherUserLatitude": self.userA.latitude, "otherUserLongitude": self.userA.longitude, "otherUserUrlOne": self.userA.urlOne, "otherUserUrlTwo": self.userA.urlTwo, "otherUserFirstMajor": self.userA.firstMajor, "otherUserID": NSUserDefaults.standardUserDefaults().stringForKey("id")!])
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("active")
            self.presentViewController(controller, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: { action in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func skipTapped() {
        // Reset both users back to their defaults values
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["matchKey": "10", "otherUserLatitude": "", "otherUserLongitude": "", "otherUserFirstMajor": "", "otherUserID": "" ,"otherUserName": "", "otherUserUrlOne": "", "otherUserUrlTwo": ""])
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("testVC")
        self.presentViewController(controller, animated: true, completion: nil)
    }
}



