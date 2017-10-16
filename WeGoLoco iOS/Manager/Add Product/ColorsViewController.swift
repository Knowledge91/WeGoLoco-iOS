//
//  ColorsAndSizesViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 10/8/17.
//
//

import UIKit
import Eureka
import Whisper

class ColorsViewController: FormViewController, AddProductProtocol {
    // MARK: - AddProductProtocoll
    var tinpon: Tinpon!
    func guardTinpon() {
        // clear previous variations
        tinpon.variations = nil
        
        for color in selectedColors {
            for size in selectedSizes {
                let variation = Tinpon.Variation(color: color, size: size, quantity: 0)
                if tinpon.variations != nil {
                    tinpon.variations?.append(variation)
                } else {
                    tinpon.variations = [variation]
                }
            }
        }
    }
    
    // MARK: - Model
    public var selectedSizes: [Tinpon.Variation.Size]!
    var selectedColors: [Tinpon.Variation.Color] {
        get {
            let colorSection = form.sectionBy(tag: "colorSection") as! SelectableSection<ListCheckRow<String>>
            let selectedRows = colorSection.selectedRows()
            
            var result = [Tinpon.Variation.Color]()
            for row in selectedRows {
                result.append(Tinpon.Variation.Color(rawValue: row.value!)!)
            }
            return result
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sizes
        
        // Colors
        form +++ SelectableSection<ListCheckRow<String>>("Colors", selectionType: .multipleSelection) { $0.tag = "colorSection" }
        for color in iterateEnum(Tinpon.Variation.Color.self) {
            let colorName = color.rawValue
            form.last! <<< ListCheckRow<String>(){ listRow in
                listRow.title = colorName
                listRow.selectableValue = colorName
                listRow.value = nil
                }.cellUpdate { cell, row in
                    let uiColor = Tinpon.Variation.Color.colorDictionary[colorName]
                    cell.tintColor = uiColor
                    cell.textLabel?.textColor = uiColor
                    
                    self.validate()
            }
        }
        
        addNextBarButtonItem()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guardTinpon()
        
        let quantitiesViewController = segue.destination as! QuantitiesViewController
        quantitiesViewController.tinpon = tinpon
    }
    
    
    // MARK: - Helpers
    private func validate() -> Void {
        if isValid() {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func isValid() -> Bool {
        let colorSection = form.sectionBy(tag: "colorSection") as! SelectableSection<ListCheckRow<String>>
        return colorSection.selectedRows().count > 0 ? true : false
    }
    
    private func addNextBarButtonItem() {
        let barButtonItem = UIBarButtonItem.init(title: "Next", style: .plain, target: self, action: #selector(self.segueToQuantities))
        barButtonItem.isEnabled = false
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc private func segueToQuantities() {
        self.performSegue(withIdentifier: "productQuantitiesSegue", sender: self)
    }
}
