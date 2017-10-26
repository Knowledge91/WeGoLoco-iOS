//
//  ProductCell.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 23/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit
import IGListKit
import PromiseKit

class ProductCell: UICollectionViewCell {
    let cache = NSCache<NSString, UIImage>()
    
    public var tinpon: Tinpon! {
        didSet {
            nameLabel.text = tinpon.name
            priceLabel.text = String(describing: tinpon.price!)+" €"
            categoryLabel.text = tinpon.category?.rawValue
            genderLabel.text = tinpon.gender?.rawValue
            if tinpon.active! == 1 {
                productStateSwitch.isOn = true
            } else {
                productStateSwitch.isOn = false
            }
            
            if let cachedImage = cache.object(forKey: NSString(string: "tinpon_\(tinpon.id!)")) {
                self.productImageView.image = cachedImage
            } else {
                firstly {
                    API.getTinponMainImage(tinponId: tinpon!.id!)
                }.then { image -> () in
                    self.cache.setObject(image!, forKey: NSString(string: "tinpon_\(self.tinpon.id!)"))
                    self.productImageView.image = image
                }.catch { error in
                    print(error)
                }
            }
        }
    }
    
    // MARK: outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productStateSwitch: UISwitch!
    
    // MARK: actions
    @IBAction func touchProductStateSwitch(_ sender: UISwitch) {

        if sender.isOn {
            tinpon.active = 1
        } else {
            tinpon.active = 0
        }
        firstly {
            API.changeProductState(tinpon: self.tinpon)
        }.catch { error in
            print(error)
        }
    }
}

extension ProductCell: ListBindable {
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? String else { return }
        nameLabel.text = viewModel
    }
    
}
