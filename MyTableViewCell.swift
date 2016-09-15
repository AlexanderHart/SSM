//
//  MyTableViewCell.swift
//  SSM
//
//  Created by Alexander Hart on 7/7/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit

class MyTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var picture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        picture.layer.cornerRadius = picture.frame.size.width / 2;
        picture.clipsToBounds = true
    }
}
