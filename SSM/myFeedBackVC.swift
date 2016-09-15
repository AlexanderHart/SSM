//
//  otherViewController.swift
//  SSM
//
//  Created by Alexander Hart on 7/6/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import Firebase

class myFeedBackVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var messages        = [Message]()
    var myTableView     = UITableView()
    let rootRef         = FIRDatabase.database().reference()
    
    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Go back", style: .Plain, target: self, action: #selector(handleCancel))
        navigationItem.title = "My Feedback"
        
        self.myTableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Plain)
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.backgroundColor = UIColor.clearColor()
        self.myTableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.myTableView.registerNib(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "myIdentifier")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addSubview(self.myTableView)
        
        self.rootRef.child("feedback/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeEventType(.ChildAdded, withBlock: { snapshot in
            if let messageValue = snapshot.value!["message"] as? String {
                if let idValue = snapshot.value!["fromID"] as? String {
                    let message = Message()
                    message.message = messageValue
                    message.fromID = idValue
                    self.messages.append(message)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.myTableView.reloadData()
                    })
                }
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCellWithIdentifier("myIdentifier") as! MyTableViewCell
        myCell.backgroundColor = UIColor.clearColor()
        let message = messages[indexPath.row]
        
        
        self.rootRef.child("users").child(message.fromID!).observeEventType(.Value, withBlock: { (snapshot) in
            myCell.name.text = snapshot.value!.objectForKey("name") as? String
            
            let fullUrl = (snapshot.value!.objectForKey("urlOne") as? String)! + "&" + (snapshot.value!.objectForKey("urlTwo") as? String)!
            
            NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: fullUrl)!, completionHandler: { (data, response, error) ->
                Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    myCell.picture.image = UIImage(data: data!)
                })
            }).resume()
        })
        
        myCell.message.text = message.message
        
        return myCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
}
