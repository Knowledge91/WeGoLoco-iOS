/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import IGListKit
import PromiseKit

final class ManagerViewController: UIViewController, ListAdapterDataSource, SearchSectionControllerDelegate, NavigationBarGradientProtocol {
    
    // MARK: AuthenticationProtocol
    var needsRefresh = true
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 5)
    }()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var words: Set<String> = {
        // swiftlint:disable:next
        let str = "Humblebrag skateboard tacos viral small batch blue bottle, schlitz fingerstache etsy squid. Listicle tote bag helvetica XOXO literally, meggings cardigan kickstarter roof party deep v selvage scenester venmo truffaut. You probably haven't heard of them fanny pack austin next level 3 wolf moon. Everyday carry offal brunch 8-bit, keytar banjo pinterest leggings hashtag wolf raw denim butcher. Single-origin coffee try-hard echo park neutra, cornhole banh mi meh austin readymade tacos taxidermy pug tattooed. Cold-pressed +1 ethical, four loko cardigan meh forage YOLO health goth sriracha kale chips. Mumblecore cardigan humblebrag, lo-fi typewriter truffaut leggings health goth."
        var words = Set<String>()
        let range = str.startIndex ..< str.endIndex
        str.enumerateSubstrings(in: range, options: .byWords) { (substring, _, _, _) in
            words.insert(substring!)
        }
        return words
    }()
    var filterString = ""
    let searchToken: NSNumber = 42
    var tinpons: [Tinpon]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTinpons()
        
        collectionView.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        // NavBar gradient
        setNavigationBarGradient()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        if tinpons != nil {
            print("tinpon objects")
            guard filterString != "" else { return [searchToken] + tinpons!.map { $0 as ListDiffable } }
            return [searchToken] + tinpons!.filter { $0.name!.lowercased().contains(filterString.lowercased()) }.map { $0 as ListDiffable }
        } else {
            return [String]().map { $0 as ListDiffable }
        }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let obj = object as? NSNumber, obj == searchToken {
            let sectionController = SearchSectionController()
            sectionController.delegate = self
            return sectionController
        } else {
            return ProductSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    // MARK: SearchSectionControllerDelegate
    
    func searchSectionController(_ sectionController: SearchSectionController, didChangeText text: String) {
        filterString = text
        adapter.performUpdates(animated: true, completion: nil)
    }
    
    // MARK: Helper
    private func loadTinpons() {
        firstly {
            API.getRetailerTinpons()
        }.then { tinpons -> Void in
            print("loaded Tinpons")
            self.tinpons = tinpons
            self.adapter.reloadData(completion: nil)
        }.catch { error in
            print(error)
        }
    }
    
}

extension ManagerViewController: Authentication {
    func refresh() {
        print("refresh")
    }
    
    func clean() {
         tinpons?.removeAll()
        adapter.reloadData(completion: nil)
    }
}

