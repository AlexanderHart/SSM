//
//  AppDelegate.swift
//  SSM
//
//  Created by Alexander Hart on 2/6/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

import Rollout


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Facebook SDK.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        Rollout.setupWithKey("57cc90e3399ec2ed25124780")

        
        // Google SDK.
        // Updated 7.22.16
        GMSServices.provideAPIKey("AIzaSyAV4rGUmN_gg50AHtg-SJ9fBnHtVfgq5Xo")
        
        
        // Firebase SDK
        FIRApp.configure()
        
        // To set up notifications
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Alert, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        self.createLocalNotification()
        
//      Make navigation bar dark themed
        UITabBar.appearance().barTintColor = UIColor.clearColor()
    
//      FIX:- BUG - Two horizontal bars stacked on top of one another.
//      UITabBar.appearance().backgroundImage = UIImage(named: "blackBar")
//      UITabBar.appearance().shadowImage = UIImage()
        
//      Make selected tab bar item text color Brooklyn Maroon.
        UITabBar.appearance().tintColor = UIColor(red: (136/255.0), green: (35/255.0), blue: (69/255.0), alpha: 1.0)
        
        return true
    }
    
    func createLocalNotification() {
        
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        var id = ""
        
        if let saved = NSUserDefaults.standardUserDefaults().stringForKey("id") {
            id = saved
        }
        
        let rootRef     = FIRDatabase.database().reference()
        let usersRef    = rootRef.child("users/")   // Container for all users
        let userRef     = usersRef.child(id)        // Specific to individual user
        
        userRef.updateChildValues(["matchKey": "00"])
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        if let saved = NSUserDefaults.standardUserDefaults().stringForKey("id") {
            
            let rootRef     = FIRDatabase.database().reference()
            let usersRef    = rootRef.child("users/")   // Container for all users
            let userRef     = usersRef.child(saved)        // Specific to individual user
            
            userRef.updateChildValues(["matchKey": "10"])
        }

    }

    func applicationWillTerminate(application: UIApplication) {
        
        var id = ""
        
        if let saved = NSUserDefaults.standardUserDefaults().stringForKey("id") {
            id = saved
        }
        
        let rootRef     = FIRDatabase.database().reference()
        let usersRef    = rootRef.child("users/")   // Container for all users
        let userRef     = usersRef.child(id)        // Specific to individual user
        
        
        // Why isn't this resetting the majority of these values??? - 7.19.16
        userRef.updateChildValues(["matchKey": "00", "otherUserName": "", "otherUserLatitude": "", "otherUserLongitude": "", "otherUserUrlOne": "", "otherUserUrlTwo": "", "otherUserFirstMajor": "", "otherUserID": ""])
    }
}

