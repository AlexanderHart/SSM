//
//  profileTestVC.swift
//  SSM
//
//  Created by Alexander Hart on 7/6/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class profileVC: UIViewController {
    
    var userA = Users(meetAmount: 5,    status: "",                 taken: "",                  email: "",              name: "",               gender: "",     year: "",
                      firstMajor: "",   firstMinor: "",             secondMajor: "",            secondMinor: "",        urlOne: "",             urlTwo: "",     latitude: "",
                      longitude: "",    destinationLatitude: "",    destinationLongitude: "",   matchKey: "",           otherUserName: "",      otherUserFirstMajor: "",
                      otherUserID: "",  otherUserUrlOne: "",        otherUserUrlTwo: "",        otherUserLatitude: "",  otherUserLongitude: "", releaseDate: 0)
    
    @IBOutlet weak var profileIconImageView:    UIImageView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel:               UILabel!
    @IBOutlet weak var magicNumber:             UILabel!
    @IBOutlet weak var majors:                  UILabel!
    @IBOutlet weak var major2:                  UILabel!
    @IBOutlet weak var ratingControl            : CosmosView!
    
    @IBOutlet weak var minor2: UILabel!
    @IBOutlet weak var minor: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    @IBAction func settingsBtnTapped(sender: AnyObject) {
        let settingsViewController = settingsVC()
        let newController = UINavigationController(rootViewController: settingsViewController)
        self.presentViewController(newController, animated: true, completion: nil)
    }
    
    var rootRef                             = FIRDatabase.database().reference()
    var messages                            = [Message]()
    var profilePictureUrl                   = ""
    var count                               = 0.0
    var totalRating                         = 0
    var numOfRatings                        = 0
    var totalPossible                       = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileIconImageView.image = UIImage(named: "profilePageLogo")!
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.majors.adjustsFontSizeToFitWidth = true
        
        self.count = 0
        
        self.rootRef.child("feedback/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeEventType(.ChildAdded, withBlock: { snapshot in
            if let ratingValue = snapshot.value!["rating"] as? Double {
                let message = Message()
                message.rating = ratingValue
                if self.messages.contains(message) {
                }else {
                    self.messages.append(message)}
            }
        })
        
        self.totalPossible = 0
        
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeEventType(.Value, withBlock: { snapshot in
            self.userA.name = (snapshot.value!.objectForKey("name") as? String)!
            self.userA.year = (snapshot.value!.objectForKey("year") as? String)!
            self.userA.firstMajor    = (snapshot.value!.objectForKey("firstMajor") as? String)!
            self.userA.secondMajor    = (snapshot.value!.objectForKey("secondMajor") as? String)!
            self.userA.firstMinor    = (snapshot.value!.objectForKey("firstMinor") as? String)!
            self.userA.secondMinor    = (snapshot.value!.objectForKey("secondMinor") as? String)!
            self.userA.urlOne = (snapshot.value!.objectForKey("urlOne") as? String)!
            self.userA.urlTwo = (snapshot.value!.objectForKey("urlTwo") as? String)!
        })
        
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.rootRef.child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).removeAllObservers()
        
        self.totalPossible = 0
        
        self.messages.removeAll()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        self.nameLabel.text     = self.userA.name
        self.majors.text        = self.userA.firstMajor
        self.profilePictureUrl  = self.userA.urlOne + "&" + self.userA.urlTwo
        
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
            self.minorLabel.hidden = true
        }
        else {
            self.minorLabel.hidden = false
        }
        
        
        self.view.addSubview(nameLabel)
        self.view.addSubview(majors)
        
        
        getAmount()
    
        self.magicNumber.text = "\((messages.count - 1) * 5)"
        
        print("\(messages.count)")
        print("\(messages.count - 1)")
        for index in 0...messages.count - 1 {
            count += messages[index].rating!
        }
        
        var modifiedCount = 0;
        
        if messages.count == 1 {
            modifiedCount = messages.count
        } else if messages.count > 1 {
            modifiedCount = messages.count - 1
        }
        
        let myRating = count / Double(modifiedCount)
        
        
        ratingControl.rating = myRating
        
        let url = NSURL(string: self.profilePictureUrl)!
        
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
        
        // Legacy
//        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: self.profilePictureUrl)!, completionHandler: { (data, response, error) ->
//            Void in
//            self.profilePictureImageView.image = UIImage(data: data!)
//            self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width / 2;
//            self.profilePictureImageView.clipsToBounds      = true
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.view.addSubview(self.profilePictureImageView)
//            })
//            
//        }).resume()
    }
    
    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getAmount() {
        
        self.rootRef.child("feedback/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).queryOrderedByChild("rating").observeEventType(.ChildAdded, withBlock: { snapshot in
            
            if let num = snapshot.value!["rating"] as? Int {
                self.totalRating = self.totalRating + num
                
                self.numOfRatings += 1
            }
            
        })
    }
}
