//
//  SizesViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 2/10/17.
//
//

import Foundation
import Eureka

class SizesViewController : FormViewController, AddProductProtocol {
    
    // MARK: - AddProductProtocol
    public var tinpon: Tinpon!
    func guardTinpon() {
    }
    
    // MARK: - Model
    public var gender: Gender!
    public var category: Tinpon.Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add Next button
        addNextBarButtonItem()
        
        form +++ Section("\(category!) Sizes")

        addSizesRows()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guardTinpon()
        let colorVC = segue.destination as! ColorsViewController
        colorVC.selectedSizes = getSelectedSizes()
        colorVC.tinpon = tinpon
    }
    
    // MARK: - Helpers
    private func addSizesRows() {
        let sizes = Sizes.getSizesFor(gender: gender, category: category)

        for size in sizes {
            switch size {
            case .double(let size):
                form.last! <<< CheckRow() {
                    $0.title = size.description
                    $0.value = false
                }.cellUpdate { _,_ in
                    self.validate()
                }
            case .string(let size):
                form.last! <<< CheckRow() {
                    $0.title = size
                    $0.value = false
                }.cellUpdate { _,_ in
                    self.validate()
                }
            case .doubleDouble(let width, let length):
                // dictionary normaly not sorted
                form.last! <<< CheckRow() {
                    $0.title = width.description + "/" + length.description
                    $0.value = false
                }.cellUpdate { _,_ in
                   self.validate()
                }
            }
        }
    }
    
    private func getSelectedSizes() -> [Tinpon.Variation.Size] {
        let sizes = Sizes.getSizesFor(gender: gender, category: category)
        var result = [Tinpon.Variation.Size]()
        for (i, size) in sizes.enumerated() {
            let row = form.allRows[i] as! CheckRow
            if row.value! {
                result.append(size)
            }
        }
        return result
    }
    
    private func isValid() -> Bool {
        if getSelectedSizes().count > 0 {
            return true
        } else {
            return false
        }
    }
    private func validate() {
        if isValid() {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
           self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func addNextBarButtonItem() {
        let barButtonItem = UIBarButtonItem.init(title: "Next", style: .plain, target: self, action: #selector(self.segueToColors))
        barButtonItem.isEnabled = false
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc private func segueToColors() {
        self.performSegue(withIdentifier: "productColorsSegue", sender: self)
    }
    
    @objc private func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}
