//
//  ChatLogController.swift
//  SSM
//
//  Created by Alexander Hart on 7/19/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    var containerViewBottomAnchor:  NSLayoutConstraint?
    var directMessages =            [DirectMessage]()
    var toIDString =                ""
    var toNameString =              ""
    let cellId =                    "cellId"
    
    
    
    // MARK:- Main methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observerMessages()
        setUpContainter()
        setupKeyboardObservers()
        
        navigationItem.leftBarButtonItem        = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        navigationItem.title                    = toNameString // Perhaps move this to viewWillLoad?
        collectionView?.contentInset            = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets   = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.backgroundColor         = UIColor.whiteColor()
        collectionView?.alwaysBounceVertical    = true
        collectionView?.registerClass(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        // collectionView?.keyboardDismissMode = .Interactive MAYBE IMPLEMENT THIS LATER FOR APPEARANCE
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return directMessages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! ChatMessageCell
        
        let directMessage = directMessages[indexPath.row]
        
        cell.textView.text = directMessage.text
        
        setupCell(cell, directMessage: directMessage)
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(directMessage.text!).width + 32
        
        
        return cell
    }
    
             func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var height: CGFloat = 80
        
        if let text = directMessages[indexPath.item].text {
            height = estimateFrameForText(text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func setupKeyboardObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animateWithDuration(keyboardDuration!) { 
            self.view.layoutIfNeeded()        }
    }

    func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
        containerViewBottomAnchor?.constant = 0
        UIView.animateWithDuration(keyboardDuration!) {
            self.view.layoutIfNeeded()        }
    }
    
    func observerMessages() {
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!)
        
        userMessagesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let messageID = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageID)
            messageRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let directMessage = DirectMessage()
                // Potential of crashing if keys dont match
                directMessage.setValuesForKeysWithDictionary(dictionary)
                
                if directMessage.chatPartnerID() == self.toIDString { // This appears to be correct
                    self.directMessages.append(directMessage)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView?.reloadData()
                    })
                }
            })
            }, withCancelBlock: nil)
    }
    
    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setUpContainter() {
        let container = UIView()
        container.backgroundColor = UIColor.whiteColor()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        // iOS 9 Constraints
        container.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        containerViewBottomAnchor = container.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
        containerViewBottomAnchor?.active = true
        
        container.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        container.heightAnchor.constraintEqualToConstant(50).active = true
        
        let sendButton = UIButton(type: .System)
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), forControlEvents: .TouchUpInside)
        container.addSubview(sendButton)
        
        sendButton.rightAnchor.constraintEqualToAnchor(container.rightAnchor).active = true
        sendButton.centerYAnchor.constraintEqualToAnchor(container.centerYAnchor).active = true
        sendButton.widthAnchor.constraintEqualToConstant(80).active = true
        sendButton.heightAnchor.constraintEqualToAnchor(container.heightAnchor).active = true
        
        container.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraintEqualToAnchor(container.leftAnchor, constant: 8).active = true
        inputTextField.centerYAnchor.constraintEqualToAnchor(container.centerYAnchor).active = true
        inputTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor).active = true
        inputTextField.heightAnchor.constraintEqualToAnchor(container.heightAnchor).active = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: (220/255.0), green: (220/255.0), blue: (220/255.0), alpha: 1.0)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraintEqualToAnchor(container.leftAnchor).active = true
        separatorLineView.topAnchor.constraintEqualToAnchor(container.topAnchor).active = true
        separatorLineView.widthAnchor.constraintEqualToAnchor(container.widthAnchor).active = true
        separatorLineView.heightAnchor.constraintEqualToConstant(1).active = true
    }
    
    func handleSend() {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toID = self.toIDString
        let fromID = NSUserDefaults.standardUserDefaults().stringForKey("id")!
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        let values = ["text" : inputTextField.text!, "toID": toID, "fromID": fromID, "timestamp": timestamp]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromID)
            
            let messageID = childRef.key
            userMessageRef.updateChildValues([messageID: 1])
            
            let recipientMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toID)
            recipientMessagesRef.updateChildValues([messageID: 1])
        }
        
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        inputTextField.resignFirstResponder()
        return true
    }
    
    private func setupCell(cell: ChatMessageCell, directMessage: DirectMessage) {
        
        
        if directMessage.fromID == NSUserDefaults.standardUserDefaults().stringForKey("id")! {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.whiteColor()
            cell.profileImageView.hidden = true
            
            
            cell.bubbleViewRightAnchor?.active = true
            cell.bubbleViewLeftAnchor?.active = false
        } else {
            cell.bubbleView.backgroundColor = UIColor(red: (240/255.0), green: (240/255.0), blue: (240/255.0), alpha: 1.0)
            cell.textView.textColor = UIColor.blackColor()
            
            cell.profileImageView.hidden = false
            cell.bubbleViewRightAnchor?.active = false
            cell.bubbleViewLeftAnchor?.active = true
        }
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 100, height: 1000)
        
        let options = NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
        return NSString(string: text).boundingRectWithSize(size, options: options, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(16)], context: nil)
    }
}
