//
//  SpecialTableViewCell.swift
//  YoutubeTutorial
//
//  Created by Shreyas B Hukkeri on 12/23/15.
//  Copyright © 2015 Shreyas B Hukkeri. All rights reserved.
//

import UIKit

class SpecialCell: UITableViewCell {

    @IBOutlet var username: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
