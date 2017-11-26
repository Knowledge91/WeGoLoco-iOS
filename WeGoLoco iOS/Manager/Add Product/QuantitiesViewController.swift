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
import ImageRow
import TOCropViewController
import PromiseKit

// Maps quantities of every possible product variation (Color & Size)
// Displayed as Color Sections with Sizes as Rows
class QuantitiesViewController: FormViewController, AddProductProtocol, LoadingAnimationProtocol {
    //MARK: - AddProductProtocol
    var tinpon: Tinpon!
    var tinponImages: TinponImages!
    func guardTinpon() {
    }
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var createTinponButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTinponButton.isEnabled = false
        
        loadingAnimationView = navigationController?.view
        tableView.isEditing = false
        
        addColorSections()
    }
    
    
    
    // MARK: Sections
    
    fileprivate func addColorSections() {
        // group tinpon.variations in groups of different color
        var xColor : Tinpon.Variation.Color? = nil
        for variation in tinpon.variations! {
            if xColor != variation.color {
                xColor = variation.color
                form +++ colorSection(xColor!)
            }
        }
    }
    
    fileprivate func colorSection(_ color: Tinpon.Variation.Color) -> Section {
        let section = MultivaluedSection(multivaluedOptions: [], // [.Delete]
                                        header: color.rawValue
                                        )
//                               footer: "Swipe left to remove size")
        for variation in tinpon.variations! {
            if color == variation.color {
                switch variation.size {
                case .double(let size):
                    section <<< IntRow() {
                        $0.title = "Quantity - \(size)"
                        $0.add(rule: RuleRequired())
                    }.cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                    }.onChange{ row in
                        if let quantity = row.value {
                            self.addQuantityToTinponVariationFor(color: variation.color, size: variation.size, quantity: quantity)
                        }
                        self.validate()
                    }
                case .doubleDouble(let width, let length):
                    section <<< IntRow() {
                        $0.title = "Quantity - \(width)/\(length)"
                        $0.add(rule: RuleRequired())
                    }.cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                    }.onChange{ row in
                        if let quantity = row.value {
                            self.addQuantityToTinponVariationFor(color: variation.color, size: variation.size, quantity: quantity)
                        }
                        self.validate()
                    }
                case .string(let size):
                    section <<< IntRow() {
                        $0.title = "Quantity - \(size)"
                        $0.add(rule: RuleRequired())
                    }.cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                    }.onChange{ row in
                        if let quantity = row.value {
                            self.addQuantityToTinponVariationFor(color: variation.color, size: variation.size, quantity: quantity)
                        }
                        self.validate()
                    }
                }
            }
        }
        
        //section <<< recursiveImageRow(color)
        
        return section
    }
    
    // MARK: RecursiveImageRow
    var editingImageRow: ImageRow?
    func recursiveImageRow(_ color: Color) -> ImageRow {
        let imageRow = ImageRow() {
            $0.title = "Añadir Imagen"
            $0.sourceTypes = [.PhotoLibrary, .Camera]
            $0.clearAction = .yes(style: UIAlertActionStyle.destructive)
            }.cellUpdate { [weak self] cell, row in
                guard let strongSelf = self else { return }
                
                if row.title != "Imagen" {
                    cell.textLabel?.textAlignment = .center
                    cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.8166723847, blue: 0.9823040366, alpha: 1)
                } else {
                    cell.textLabel?.textAlignment = .left
                    cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.03529411765, blue: 0.0862745098, alpha: 1)
                }
                
                if let image = row.value, strongSelf.editingImageRow == nil {
                    strongSelf.editingImageRow = row
                    strongSelf.presentCropViewController(image)
                }
            }.onChange { [weak self] row in
                guard let strongSelf = self else { return }
                let rowIndex = row.indexPath!.row
                if row.value == nil {
                    // delete row
                    row.section?.remove(at: rowIndex)
                } else if row.title != "Imagen" {
                    // add row
                    row.title = "Imagen"
                    row.section?.insert(strongSelf.recursiveImageRow(color), at: rowIndex+1)
                }
        }
        
        return imageRow
    }
    
    
    // MARK : - Actions
    @IBAction func createTinponButton(_ sender: UIBarButtonItem) {
        startLoadingAnimation()
        firstly {
            API.createTinpon(tinpon: tinpon, tinponImages: tinponImages)
        }.then { [weak self] _ -> Void in
            guard let strongSelf = self else { return }
            strongSelf.stopLoadingAnimation()
            
            // display new Tinpon in table view
            strongSelf.performSegue(withIdentifier: "unwindSegueToManagerTableViewController", sender: self)
            
            // go back to Manager table view
            // strongSelf.presentingViewController?.dismiss(animated: true)
        }.catch{ error in
            print(error)
        }
    }
    
    // MARK: - Helpers
    private func addQuantityToTinponVariationFor(color: Tinpon.Variation.Color, size: Tinpon.Variation.Size, quantity: Int) -> Void {
        for (index, variation) in (tinpon.variations!.enumerated()) {
            if variation.color == color && variation.size == size {
                tinpon.variations![index].quantity = quantity
            }
        }
    }
    private func validate() {
        if isValid() {
            createTinponButton.isEnabled = true
        } else {
            createTinponButton.isEnabled = false
        }
    }
    private func isValid() -> Bool {
        // is valid when every quantity row has a quantity
        if form.validate().count > 0 {
            return false
        } else {
            return true
        }
    }
}

extension QuantitiesViewController:  TOCropViewControllerDelegate {
    func presentCropViewController(_ image: UIImage) {
        let image = image
        
        let cropViewController = TOCropViewController(image: image)
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.delegate = self
        startLoadingAnimation()
        self.present(cropViewController, animated: true, completion: {
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
            }
        })
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: NSInteger) {
        dismiss(animated: false)
        presentFilterViewController(image)
    }
}

extension QuantitiesViewController: SHViewControllerDelegate {
    func presentFilterViewController(_ image: UIImage) {
        let imageToBeFiltered = image
        let vc = SHViewController(image: imageToBeFiltered)
        vc.delegate = self
        startLoadingAnimation()
        present(vc, animated:true, completion: {
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
            }
        })
        
    }
    
    func shViewControllerImageDidFilter(image: UIImage) {
        editingImageRow?.value = image
        editingImageRow?.reload()
        editingImageRow = nil
    }
    
    func shViewControllerDidCancel() {
        // This will be called when you cancel filtering the image.
    }
}


