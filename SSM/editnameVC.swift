//
//  editName.swift
//  SSM
//
//  Created by Alexander Hart on 6/18/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import QuartzCore
import Firebase

class editnameVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    
    var nameUpdate = ""
    
    @IBAction func updateName(senvder: AnyObject) {
        var id = ""
        if let savedId = NSUserDefaults.standardUserDefaults().stringForKey("id") {
            id = savedId
        }
        
        let rootRef     = FIRDatabase.database().reference()
        let usersRef    = rootRef.child("users/")   // Container for all users
        let userRef     = usersRef.child(id)        // Specific to individual user
        
        userRef.updateChildValues(["name": nameUpdate])
    }
    
    func handleCancel() {
        print("test")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Go back", style: .Plain, target: self, action: #selector(handleCancel))
        navigationItem.title = "My Feedback"
        
        nameField.delegate = self
        
//        // Back button.
//        let label = UILabel(frame: CGRectMake(self.view.frame.width * 0.033, self.view.frame.height * 0.025, 60, 60))
//        label.text = "<"
//        label.textColor = UIColor(red: (0/255.0), green: (0/255.0), blue: (0/255.0), alpha: 0.5)
//        label.font = UIFont(name: "Helvetica-Bold", size: CGFloat(40))
//        self.view.addSubview(label)
//        
//        let attributes = [
//            NSForegroundColorAttributeName: UIColor(red: (0/255.0), green: (0/255.0), blue: (0/255.0), alpha: 0.5),
//            NSFontAttributeName : UIFont(name: "Helvetica-Bold", size: 29)!
//        ]
        
//        var id = ""
//        if let savedId = NSUserDefaults.standardUserDefaults().stringForKey("id") {
//            id = savedId
//        }
//        
//        let rootRef     = FIRDatabase.database().reference()
//        let usersRef    = rootRef.child("users/")   // Container for all users
//        let userRef     = usersRef.child(id)        // Specific to individual user
        
//        userRef.observeEventType(.Value, withBlock: { snapshot in
////            if let what = snapshot.value!.objectForKey("name") {
////                self.nameField.attributedPlaceholder = NSAttributedString(string: (what as? String)!, attributes:attributes)
//            }
//        })
        
        //nameField.layer.borderWidth = 1.0
        //nameField.layer.borderColor = UIColor(red: (255/255.0), green: (255/255.0), blue: (255/255.0), alpha: 0.1).CGColor
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        nameUpdate = textField.text!
    }
}
