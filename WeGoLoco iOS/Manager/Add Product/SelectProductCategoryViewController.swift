//
//  selectProductCategoryViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 8/9/17.
//
//

class SelectProductCategoryViewController: SelectCategoryViewController, AddProductProtocol {
    // MARK: - AddProductProtocol
    var tinpon: Tinpon!
    var tinponImages: TinponImages!
    func guardTinpon() {
        tinpon.category = Tinpon.Category(rawValue: singleSelection!)
    }

    
    override func onContinue() {
        super.onContinue()
        performSegue(withIdentifier: "productSizesSegue", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guardTinpon()
        
        print(tinponImages.main.count)
        
        let sizesVC = segue.destination as! SizesViewController
        sizesVC.tinpon = tinpon
        sizesVC.tinponImages = tinponImages
        sizesVC.gender = gender
        sizesVC.category = tinpon.category
    }
}
