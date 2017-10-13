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
        tinpon.colors = selectedColors
    }
    
    // MARK: - Model
    var selectedColors: [Color] {
        get {
            let colorSection = form.sectionBy(tag: "colorSection") as! SelectableSection<ListCheckRow<String>>
            let selectedRows = colorSection.selectedRows()
            
            var result = [Color]()
            for row in selectedRows {
                result.append(Color(name: row.value!))
            }
            return result
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sizes
        
        // Colors
        form +++ SelectableSection<ListCheckRow<String>>("Colors", selectionType: .multipleSelection) { $0.tag = "colorSection" }
        let colors = Color.spanishColors
        for option in colors {
            form.last! <<< ListCheckRow<String>(option){ listRow in
                listRow.title = option
                listRow.selectableValue = Color(spanishName: option).name
                listRow.value = nil
                }.cellUpdate { cell, row in
                    let color = Color.colorDictionary[row.selectableValue!]
                    cell.tintColor = color
                    cell.textLabel?.textColor = color
                    
                    self.validate()
                    
                    // text outline for better visibility
//                    if row.title == "blanco" || row.title == "amarillo" || row.title == "gris" {
//                        let strokeTextAttributes = [
//                            NSStrokeColorAttributeName : UIColor.black,
//                            NSForegroundColorAttributeName : color,
//                            NSStrokeWidthAttributeName : -2.0,
//                            ] as [String : Any]
//                        
//                        cell.textLabel?.attributedText = NSAttributedString(string: row.title!, attributes: strokeTextAttributes)
//                    }
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
