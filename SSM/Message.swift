//
//  Message.swift
//  SSM
//
//  Created by Alexander Hart on 7/9/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit

class Message: NSObject {
    var message: String?
    // Added 7.19.16 to help make the feedbackVC more useful
    var fromID: String?
    var rating: Double?
}
