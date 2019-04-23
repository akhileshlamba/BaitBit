//
//  UserProfileTableViewCell.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 23/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class UserProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var viewLicense: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var showLicense: UIButton!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
