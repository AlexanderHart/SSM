//
//  HomeViewController.swift
//  YoutubeTutorial
//
//  Created by Shreyas B Hukkeri on 12/23/15.
//  Copyright © 2015 Shreyas B Hukkeri. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Firebase

class editmajorVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    
    let rootRef     = FIRDatabase.database().reference()
    
    
    var values = ["CompSci", "Art", "Film"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.clearColor()
        
//        get()
        
        //        // Background Image
        //        let image3 = UIImage(named: "profileBG")
        //        let imageView2 = UIImageView(image: image3)
        //        imageView2.contentMode = UIViewContentMode.ScaleAspectFill
        //        imageView2.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        //        view.addSubview(imageView2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).removeAllObservers()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SpecialCell
        cell.backgroundColor = UIColor.clearColor()
        tableView.rowHeight = UITableViewAutomaticDimension
        //let maindata = values[indexPath.row]
        
        cell.username.text = values[indexPath.row]
        
        //FIXME: - Randomly works
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: (0/255.0), green: (0/255.0), blue: (0/255.0), alpha: 0.35)
        cell.selectedBackgroundView = backgroundView
        
        return cell;
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SpecialCell
        //let maindata = values[indexPath.row]
        cell.username.text = values[indexPath.row]
        
        if let majorUpdate = cell.username.text {
            // Convert locally stored Optional email to a string
            var id = ""
            if let savedId = NSUserDefaults.standardUserDefaults().stringForKey("id") {
                id = savedId
            }
            
            let usersRef    = rootRef.child("users/")   // Container for all users
            let userRef     = usersRef.child(id)        // Specific to individual user
            
            userRef.updateChildValues(["firstMajor": majorUpdate])
        }
    }
    
}