//
//  CharityTableViewCell.swift
//  omise-ios
//
//  Created by Ai on 1/8/20.
//  Copyright © 2020 Ai. All rights reserved.
//

import UIKit

class CharityTableViewCell: UITableViewCell {

    @IBOutlet weak var charityImage: UIImageView!
    
    @IBOutlet weak var charityName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
