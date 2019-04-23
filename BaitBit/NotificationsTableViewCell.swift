//
//  NotificationsTableViewCell.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 23/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class NotificationsTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var toggle: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
