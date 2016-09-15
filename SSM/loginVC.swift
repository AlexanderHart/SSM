//
//
// QUALITY RATING
//  Distinction between variable and functions = 5
//  Alphabetization of names, grouping of data types = 4
//
//
//  LoginViewController.swift
//  SSM
//
//
//  Created by Alexander Hart on 2/6/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Foundation
import Firebase
import CoreLocation

class loginVC: UIViewController, CLLocationManagerDelegate {
    
    var rootRef         = FIRDatabaseReference()
    var locationManager = CLLocationManager()
    var titleImageView  = UIImageView()
    var loginButton     = UIButton()
    
    @IBAction func loginFacebookAction(sender: AnyObject) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logInWithReadPermissions(["email"], fromViewController: self) { (result, error) -> Void in
            if (error == nil) {
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                
                if (fbloginresult.isCancelled) {
                    // Do nothing
                } else if(fbloginresult.grantedPermissions.contains("email")) {
                    self.getFBUserData()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rootRef = FIRDatabase.database().reference()
        
        self.loginButton = UIButton(frame: CGRectMake(0, self.view.frame.height * 0.912, self.view.frame.width, self.view.frame.height * 0.088))
        
        self.titleImageView = UIImageView(image: UIImage(named: "titleLogo.png"))
        self.loginButton.setImage(UIImage(named: "button"), forState: UIControlState.Normal)
        self.loginButton.addTarget(self, action: #selector(self.loginFacebookAction), forControlEvents: .TouchUpInside)
        
        view.addSubview(self.loginButton)
    }
  
    func getFBUserData() {
        if((FBSDKAccessToken.currentAccessToken()) != nil) {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email, first_name, gender, picture.type(large)"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil) {
                    if let id = result["id"] as? String {
                        if let email = result["email"] as? String {
                            if let name = result["first_name"] as? String {
                                if let gender = result["gender"] as? String {
                                    if let picture = result["picture"] as? NSDictionary, data = picture["data"] as? NSDictionary, url = data["url"] as? String {
                                        
                                        let urlArr = url.componentsSeparatedByString("&")
                                        
                                        let p1: String = urlArr[0]
                                        let p2: String = urlArr[1]
                                        
                                        //id = "admin"
                                        
                                        self.rootRef.child("users/").observeSingleEventOfType(.Value, withBlock: { snapshot in
                                            // Check if this user is already in the database
                                            // Otherwise add to database
                                            if snapshot.hasChild(id)
                                            {
                                                self.rootRef.child("users/").child(id).observeSingleEventOfType(.Value, withBlock: { snapshot in
                                                    
                                                    if let firstMajor = snapshot.value!.objectForKey("firstMajor") as? String
                                                    {
                                                        // I
                                                        if firstMajor == "Undefined"
                                                        {
                                                            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("major")
                                                            self.presentViewController(controller, animated: true, completion: nil)
                                                        }
                                                        else
                                                        {
                                                        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["matchKey": "10", "otherUserFirstMajor": "","otherUserName": "", "otherUserID" : "", "otherUserLatitude": "", "otherUserLongitude": "", "otherUserUrlOne": "", "otherUserUrlTwo": ""])
                                                            
                                                            let profileURLString = (snapshot.value!.objectForKey("urlOne") as! String) + "&" + (snapshot.value!.objectForKey("urlTwo") as! String)
                                                            
                                                            // Store data locally
                                                            NSUserDefaults.standardUserDefaults().setObject(profileURLString, forKey: "profileURLString");
                                                            
                                                            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("testVC")
                                                            self.presentViewController(controller, animated: true, completion: nil)
                                                            
                                                        }
                                                    }
                                                })
                                                
                                            }
                                            else
                                            {
                                                let user = Users(meetAmount: 5, status: "1", taken: "0", email: email, name: name, gender: gender, year: "Undefined", firstMajor: "Undefined", firstMinor: "Undefined", secondMajor: "Undefined", secondMinor: "Undefined", urlOne: p1, urlTwo: p2, latitude: "", longitude: "", destinationLatitude: "", destinationLongitude: "", matchKey: "", otherUserName: "", otherUserFirstMajor: "", otherUserID: "" ,otherUserUrlOne: "", otherUserUrlTwo: "", otherUserLatitude: "", otherUserLongitude: "", releaseDate: 0)
                                                self.rootRef.child("users/").child(id).setValue(user.toAnyObject())
                                                
                                                let feedback = Feedback(message: "Welcome to SSM!", rating: 0, fromID: "admin")
                                                self.rootRef.child("feedback/").child(id).child("first").setValue(feedback.toAnyObject())
                                                
                                                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("major")
                                                self.presentViewController(controller, animated: true, completion: nil)
                                                
                                            }
                                        })
                                        
                                        self.rootRef.child("users/").child(id).removeAllObservers()

                                        // Store logged-in user ID locally so other VC's can access the database node
                                        NSUserDefaults.standardUserDefaults().setObject(id, forKey: "id");
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
        else {print("We are logged out!!!!")}
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
}