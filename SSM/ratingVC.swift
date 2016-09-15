//
//  otherViewController.swift
//  SSM
//
//  Created by Alexander Hart on 7/6/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import Firebase

class ratingVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func feedBtnTapped(sender: AnyObject) {
        let feedbackVC = myFeedBackVC()
        let newController = UINavigationController(rootViewController: feedbackVC)
        self.presentViewController(newController, animated: true, completion: nil)
    }
    
    var noStarImageView                             = UIImageView()
    var oneStarImageView                            = UIImageView()
    var twoStarImageView                            = UIImageView()
    var threeStarImageView                          = UIImageView()
    var fourStarImageView                           = UIImageView()
    var fiveStarImageView                           = UIImageView()
    var myTableView                                 = UITableView()
    var timer                                       : NSTimer?
    var loggedInUserID                              = "1297062513641808"
    var totalRating                                 = 0
    var numOfRatings                                = 0
    let rootRef                                     = FIRDatabase.database().reference()
    var messages                                    = [Message]()
    var directMessages                              = [DirectMessage]()
    var directMessagesDictionary                    = [String: DirectMessage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the dimensions for the view properties
       // self.feedbackIconImageView.frame = CGRect(x: self.view.frame.width * 0.2309375, y: self.view.frame.height * 0.047535211, width: self.view.frame.width * 0.051125, height: self.view.frame.height * 0.054577464788)
        self.noStarImageView.frame = CGRect(x: 0, y: self.view.frame.height * 0.270492958, width: self.view.frame.width, height: self.view.frame.height * 0.140845070)
        self.oneStarImageView.frame = CGRect(x: 0, y: self.view.frame.height * 0.270492958, width: self.view.frame.width, height: self.view.frame.height * 0.140845070)
        self.twoStarImageView.frame = CGRect(x: 0, y: self.view.frame.height * 0.270492958, width: self.view.frame.width, height: self.view.frame.height * 0.140845070)
        self.threeStarImageView.frame = CGRect(x: 0, y: self.view.frame.height * 0.270492958, width: self.view.frame.width, height: self.view.frame.height * 0.140845070)
        self.fourStarImageView.frame = CGRect(x: 0, y: self.view.frame.height * 0.270492958, width: self.view.frame.width, height: self.view.frame.height * 0.140845070)
        self.fiveStarImageView.frame = CGRect(x: 0, y: self.view.frame.height * 0.270492958, width: self.view.frame.width, height: self.view.frame.height * 0.140845070)
        
        self.myTableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Plain)
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.backgroundColor = UIColor.clearColor()
        self.myTableView.frame = CGRectMake(0, self.view.frame.height * 0.5, self.view.frame.width, 400)
        self.myTableView.registerNib(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "myIdentifier")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.feedbackIconImageView  = UIImageView(image: UIImage(named: "feedbackPageLogo"))
        self.oneStarImageView       = UIImageView(image: UIImage(named: "oneStar"))
        self.twoStarImageView       = UIImageView(image: UIImage(named: "twoStar"))
        self.threeStarImageView     = UIImageView(image: UIImage(named: "threeStar"))
        self.fourStarImageView      = UIImageView(image: UIImage(named: "fourStar"))
        self.fiveStarImageView      = UIImageView(image: UIImage(named: "fiveStar"))
        self.noStarImageView        = UIImageView(image: UIImage(named: "noStars"))
        
        //self.view.addSubview(self.feedbackIconImageView)
        self.view.addSubview(self.myTableView)
        
        self.oberveUserMessages()
        
        self.rootRef.child("feedback/").child(self.loggedInUserID).queryOrderedByChild("rating").observeEventType(.ChildAdded, withBlock: { snapshot in
            if let num = snapshot.value!["rating"] as? Int {
                self.totalRating = self.totalRating + num
                self.numOfRatings += 1
            }
        })
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

////         This will be moved to profile page
//        let myRating = self.totalRating / self.numOfRatings
//        
//        if myRating == 1 {
//            self.view.addSubview(self.oneStarImageView)
//        }
//        else if myRating == 2 {
//            self.view.addSubview(self.twoStarImageView)
//        }
//        else if myRating == 3 {
//            self.view.addSubview(self.threeStarImageView)
//        }
//        else if myRating == 4 {
//            self.view.addSubview(self.fourStarImageView)
//        }
//        else if myRating == 5 {
//            self.view.addSubview(self.fiveStarImageView)
//        }
//        else {
//            self.view.addSubview(self.noStarImageView)
//            
//        }
    }

    func handleReloadTable() {
        dispatch_async(dispatch_get_main_queue(), {
            self.myTableView.reloadData()
        })
    }
    
    func oberveUserMessages() {
        guard let uid = NSUserDefaults.standardUserDefaults().stringForKey("id") else {
            return
        }
        
        let ref = self.rootRef.child("user-messages").child(uid)
        
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let messageID = snapshot.key
            let messageRef = self.rootRef.child("messages").child(messageID)
            
            messageRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let directmessage = DirectMessage()
                    
                    directmessage.setValuesForKeysWithDictionary(dictionary)
                    
                    if let ChatPartnerID = directmessage.chatPartnerID() {
                        self.directMessagesDictionary[ChatPartnerID] = directmessage
                        
                        self.directMessages = Array(self.directMessagesDictionary.values)
                        self.directMessages.sortInPlace({ (dm1, dm2) -> Bool in
                            return dm1.timestamp?.intValue > dm2.timestamp?.intValue
                        })
                    }
                    
                    self.timer?.invalidate()
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                    
                    
                }
                
            })
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCellWithIdentifier("myIdentifier") as! MyTableViewCell
        myCell.backgroundColor = UIColor.clearColor()
        let directMessage = directMessages[indexPath.row]
        
        if let ID = directMessage.chatPartnerID() {
            self.rootRef.child("users").child(ID).observeEventType(.Value, withBlock: { (snapshot) in
                myCell.name.text = snapshot.value!.objectForKey("name") as? String
                
                let fullUrl = (snapshot.value!.objectForKey("urlOne") as? String)! + "&" + (snapshot.value!.objectForKey("urlTwo") as? String)!
                
                NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: fullUrl)!, completionHandler: { (data, response, error) ->
                    Void in
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        myCell.picture.image = UIImage(data: data!)
                    })
                }).resume()
            })
            
        }
        
        myCell.message.text = directMessage.text
        
        return myCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let directMessage = directMessages[indexPath.row]
        
        guard let chatPartnerID = directMessage.chatPartnerID() else {
            return
        }
        
        let ref = self.rootRef.child("users").child(chatPartnerID)
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let chatVC = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            chatVC.toNameString = (snapshot.value!.objectForKey("name") as? String)!
            chatVC.toIDString = snapshot.key // This may have to be reassigned as chatPartnerID
            let newController = UINavigationController(rootViewController: chatVC)
            self.presentViewController(newController, animated: true, completion: nil)
        })
        

    }
}