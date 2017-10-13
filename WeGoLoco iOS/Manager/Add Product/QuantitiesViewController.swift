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
    func guardTinpon() {
        
    }
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingAnimationView = navigationController?.view
        
        tableView.isEditing = false
        
        addColorSections()
    }
    
    
    
    // MARK: Sections
    
    fileprivate func addColorSections() {
        for color in tinpon.colors {
            form +++ colorSection(color)
        }
    }
    
    fileprivate func colorSection(_ color: Color) -> Section {
        let section = MultivaluedSection(multivaluedOptions: [.Reorder, .Delete],
                               header: color.name,
                               footer: "Swipe left to remove size")

        switch tinpon.sizes! {
        case .StringSize(let sizes):
            for size in sizes {
                section <<< IntRow() {
                    $0.title = "Quantity - \(size)"
                    $0.add(rule: RuleRequired())
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                }
            }
        case .DoubleSize(let sizes):
            for size in sizes {
                section <<< IntRow() {
                    $0.title = "Quantity - \(size)"
                    $0.add(rule: RuleRequired())
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                }
            }
        case .DoubleDoubleSize(let sizes):
            let widths = Array(sizes.keys.sorted())
            for width in widths {
                let lengths = sizes[width]!.sorted()
                for length in lengths {
                    section <<< IntRow() {
                        $0.title = "Quantity - \(width)/\(length)"
                        $0.add(rule: RuleRequired())
                    }.cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
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
    
    
    // MARK : Actions
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
//        if form.validate().isEmpty {
//            guardColorSizesQuantitiesAndImages()
//            startLoadingAnimation()
//            firstly {
////                TinponsAPI.save(tinpon)
//            }.then { tinponId -> () in
//                self.tinpon.id = tinponId
//            }.catch { error in
//                print("QuantityVC error \(error)")
//            }.then { () -> Any in 
////                return TinponsAPI.uploadMainImages(from: self.tinpon)
//                self.dismiss(animated: true)
//            }.always {
//                DispatchQueue.main.async {
//                    self.stopLoadingAnimation()
//                }
//
//            }
//        } else {
//            let message = Message(title: "Faltan cuantidades.", backgroundColor: .red)
//            Whisper.show(whisper: message, to: navigationController!, action: .show)
//        }
    }
    
    // MARK: guard Color, Sizes, Quantities and Images
    fileprivate func guardColorSizesQuantitiesAndImages() {
        tinpon.productVariations = [:]
        for section in form.allSections {
            let color = Color(spanishName: (section.header?.title)!)
            var sizeVariations = [SizeVariation]()
            var images = [TinponImage]()
            for row in section {
                if let intRow = row as? IntRow {
                    let rowTitle = intRow.title!
                    let sizeIndex = rowTitle.index(rowTitle.startIndex, offsetBy: 12)
                    let size = rowTitle.substring(from: sizeIndex)
                    let quantity = intRow.value!
                    
                    let sizeVariation = SizeVariation(size: size, quantity: quantity)
                    sizeVariations.append(sizeVariation)
                } else if let image = (row as? ImageRow)?.value {
                    images.append(TinponImage(image: image))
                }
            }
            
            let colorVariation = ColorVariation(sizeVariations: sizeVariations, images: images)
            tinpon.productVariations[color] = colorVariation
        }
    }
    
    // MARK : Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("segue")
//    }
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
