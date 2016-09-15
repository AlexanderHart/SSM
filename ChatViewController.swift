//
//  ChatLogController.swift
//  SSM
//
//  Created by Alexander Hart on 7/19/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit

class ChatLogController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpContainter()
    }
    
    func setUpContainter() {
        let container = UIView()
        container.backgroundColor = UIColor.redColor()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        // iOS 9 Constraints
        container.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        container.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        container.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        container.heightAnchor.constraintEqualToConstant(50).active = true
    }
}
