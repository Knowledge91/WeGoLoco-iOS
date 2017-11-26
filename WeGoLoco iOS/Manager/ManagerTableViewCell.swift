//
//  ManagerTableViewCell.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 26/11/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit
import PromiseKit

class ManagerTableViewCell: UITableViewCell {
    
    public var tinpon: Tinpon! {
        didSet {
            nameLabel.text = tinpon.name
            categoryLabel.text = tinpon.category?.rawValue
            activeSwitch.isOn = Bool(truncating: tinpon.active! as NSNumber)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print(self.contentView.frame.size)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activeSwitch: UISwitch!
    @IBAction func activeSwitchValueChanged(_ sender: UISwitch) {
        self.tinpon.active = (sender.isOn ? 1 : 0)
        firstly {
            API.changeProductState(tinpon: self.tinpon)
        }.then {
            print("Changed Tinpon \(self.tinpon.id!) state")
        }.catch { error in
            print("Could not change product state, \(error)")
        }
    }
}
