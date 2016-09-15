//
//  DirectMessage.swift
//  SSM
//
//  Created by Alexander Hart on 7/19/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit

class DirectMessage: NSObject {
    var fromID: String?
    var text: String?
    var timestamp: NSNumber?
    var toID: String?
    
    func chatPartnerID() -> String? {
        if fromID == NSUserDefaults.standardUserDefaults().stringForKey("id")! {
            return toID
        } else {
            return fromID
        }
    }
}
