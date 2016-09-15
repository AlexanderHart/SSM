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

class secondMinorVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let rootRef     = FIRDatabase.database().reference()
    
    @IBOutlet var tableView: UITableView!
    var values = ["Undecided","Achievement in Accounting - Certificate", "Actuarial Mathematics - B.S",
                  "Africana Studies - B.A", "American Studies - B.A", "Anthropology - B.A",
                  "Art - B.A",
                  "Art - B.F.A",
                  "Art History - B.A",
                  "Biology - B.A",
                  "Biology - B.S",
                  "Biology Teacher, Grades 7-12 - B.A",
                  "Broadcast Journalism - B.S",
                  "Business Administration - B.B.A",
                  "Business Management - B.S",
                  "CUNY Bacc: Unique & Interdisc.Stds - B.A",
                  "CUNY Bacc: Unique & Interdisc.Stds - B.S",
                  "CUNY Permit Graduate - GR",
                  "CUNY Permit Undergrad - UG",
                  "Caribbean Studies - B.A",
                  "Chemistry - B.A",
                  "Chemistry - B.S",
                  "Chemistry Teacher, Grade 712 - B.A",
                  "Childhood Education Teacher, Grades 1-6 - B.A",
                  "Children & Youth Studies - B.A",
                  "Classics - B.A",
                  "Communication - B.A",
                  "Comparative Literature - B.A",
                  "Computational Mathematics - B.S",
                  "Computer Science - B.S",
                  "Creative Writing - B.F.A",
                  "Early Childhood Education Teacher, B-Grade 2 - (Second Major Only)",
                  "Early Childhood Education Teacher, B-Grade 2 - B.A",
                  "Early Childhood Education Teacher/ Special Ed - (Second Major Only)",
                  "Early Childhood Education Teacher/ Special Ed - B.A",
                  "Earth Science Teacher, Grades 7-12 - B.A",
                  "Earth and Environmental Sciences - B.A",
                  "Earth and Environmental Sciences - B.S",
                  "Economics - B.A",
                  "English - B.A",
                  "English Teacher, Grades 7-12 - B.A",
                  "Exercise Science",
                  "Film - B.A",
                  "Film Production - Certificate",
                  "Finance - B.B.A",
                  "Financial Mathematics - B.S",
                  "French",
                  "French Teacher, Grades 7-12 - B.A",
                  "Health and Nutritional Sciences - B.A",
                  "Health and Nutritional Sciences - B.S",
                  "History - B.A",
                  "Information Systems - B.S",
                  "Internal Accounting - B.S",
                  "Italian - B.A",
                  "Italian Teacher, Grades 7-12 - B.A",
                  "Journalism - B.A",
                  "Judaic Studies - B.A",
                  "Linguistics - B.A",
                  "Mathematics - B.A",
                  "Mathematics - B.S",
                  "Mathematics Teacher, Grades 7-12 - B.A",
                  "Multimedia Computing - B.S",
                  "Music - B.A",
                  "Music Composition - BMUS",
                  "Music Teacher, All Grades - BMUS",
                  "Non-Profit Fiscal Management",
                  "Performance - BMUS",
                  "Philosophy - B.A",
                  "Physical Education - B.S",
                  "Physical Education Teacher - B.S",
                  "Physics - B.A",
                  "Physics - B.S",
                  "Physics Teacher, Grades 7-12 - B.A",
                  "Political Science - B.A",
                  "Psychology - B.A",
                  "Psychology - B.S",
                  "Public Accountancy - B.S",
                  "Public Accounting and Business, Management and Finance - B.S",
                  "Puerto Rican and Latino Studies - B.A",
                  "Religion - B.A",
                  "Russian - B.A",
                  "Social Studies Teacher - B.A",
                  "Sociology - B.A",
                  "Spanish - B.A",
                  "Spanish Teacher, Grades 7-12 - B.A",
                  "Speech - B.A",
                  "Speech-Language Pathology, Audiology, Speech and Hearing Science - B.A",
                  "Television and Radio - B.A",
                  "Theater - B.A",
                  "Theater - B.F.A",
                  "Urban Sustainability - B.A",
                  "Women’s and Gender Studies - B.A"]
    
    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(handleCancel))
        //navigationItem.rightBarButtonItem?.tintColor = UIColor(red: (153/255.0), green: (0/255.0), blue: (10/255.0), alpha: 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(red: (153/255.0), green: (0/255.0), blue: (10/255.0), alpha: 1.0)
        
        navigationController?.navigationBar.barTintColor = UIColor.clearColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        
        
        tableView.backgroundColor = UIColor.clearColor()
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
        
        
        cell.username.text = values[indexPath.row]
        
        //FIXME: - Randomly works
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: (0/255.0), green: (0/255.0), blue: (0/255.0), alpha: 0.0)
        cell.selectedBackgroundView = backgroundView
        
        return cell;
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SpecialCell
        
        cell.username.text = values[indexPath.row]
        
        if let majorUpdate = cell.username.text {
            // Convert locally stored Optional email to a string
            var id = ""
            if let savedId = NSUserDefaults.standardUserDefaults().stringForKey("id") {
                id = savedId
            }
            
            let usersRef    = self.rootRef.child("users/")   // Container for all users
            let userRef     = usersRef.child(id)        // Specific to individual user
            
            userRef.updateChildValues(["secondMinor": majorUpdate])
            
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("testVC")
            self.presentViewController(controller, animated: true, completion: nil)
            
            // Save data to specific VC's
            //let profileVC = profileViewController(nibName: "profileViewController", bundle: nil)
        }
    }
    
}