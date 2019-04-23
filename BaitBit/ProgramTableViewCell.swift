//
//  BaitProgramTableViewCell.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 7/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit

class ProgramTableViewCell: UITableViewCell {
    
    @IBOutlet weak var program_name: UILabel!
    @IBOutlet weak var start_date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
