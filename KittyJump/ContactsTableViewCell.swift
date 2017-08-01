//
//  ContactsTableViewCell.swift
//  KittyJump
//
//  Created by Olivia Brown on 7/20/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {

 @IBOutlet weak var nameLabel: UILabel!

    var viewController: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
