//
//  ManagerTableViewCell.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 26/11/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit

class ManagerTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var nameLabel: UILabel!
}
