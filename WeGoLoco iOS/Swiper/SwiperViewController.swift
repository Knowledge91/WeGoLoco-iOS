//
//  BackgroundAnimationViewController.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda
import pop
import PromiseKit


private let numberOfCards: Int = 5
private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1

class SwiperViewController: UIViewController, LoadingAnimationProtocol, NavigationBarGradientProtocol {
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    // MARK: AuthenticationProtocol
    var needsRefresh = true
    
    // Outlets
    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var outOfTinponsStack: UIStackView!
    
    var tinpons : [Tinpon] = []
    
    //MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        if UserAPI.isSignedIn() && needsRefresh {
            refresh()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //LoadingAnimationProtocol
        loadingAnimationView = view
        
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        // Navbar gradient
        setNavigationBarGradient()
    }
    
    //MARK: IBActions
    @IBAction func tryLoadingMoreButton(_ sender: UIButton) {
        loadTinpons()
    }
    @IBAction func leftButtonTapped(_ sender: Any) {
        kolodaView?.swipe(.left)
    }
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        kolodaView?.swipe(.right)
    }
    @IBAction func undoButtonTapped(_ sender: UIButton) {
        kolodaView?.revertAction()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let tinponDetailVC = segue.destination as? TinponDetailViewController {
//            tinponDetailVC.tinpon = self.tinpons[kolodaView.currentCardIndex]
//        }
    }
    
    // MARK: Helpers
    fileprivate func isAlreadyDownloaded(tinpon: Tinpon) -> Bool {
        for swiperTinpon in tinpons {
            if swiperTinpon.id == tinpon.id {
                return true
            }
        }
        return false
    }
    
    fileprivate func loadTinpons() {
        startLoadingAnimation()
        firstly {
            API.getNotSwipedTinpons()
        }.then { tinpons -> () in
            self.tinpons = tinpons!
            self.kolodaView.reloadData()
            self.showoutOfTinponsIfNecessary()
            self.stopLoadingAnimation()
        }.catch { error in
            print("SwiperVC.loadTinpons : not swiped tinpons error : \(error)")
        }
    }
    
    // additionally filters out already existing tinpons
    fileprivate func loadMoreTinpons() {
        firstly {
            API.getNotSwipedTinpons()
        }.then { tinpons -> () in
            for tinpon in tinpons! {
                if !self.isAlreadyDownloaded(tinpon: tinpon) {
                    self.tinpons.append(tinpon)
                }
            }
            self.kolodaView.reloadData()
        }.catch { error in
            print("SwiperVC.loadTinpons : not swiped tinpons error : \(error)")
        }
    }
    
    fileprivate func showoutOfTinponsIfNecessary() {
        if tinpons.count - kolodaView.currentCardIndex == 0 {
            outOfTinponsStack.isHidden = false
        } else {
            outOfTinponsStack.isHidden = true
        }
    }
    
    fileprivate func saveSwipe(tinpon: Tinpon, like: Int) {
        let swipedTinpon = SwipedTinpon(person_id: UserAPI.identityId(), tinpon_id: tinpon.id!, liked: like)
        firstly {
            API.saveSwipe(swipedTinpon: swipedTinpon)
        }.then {
            print("swipe saved")
        }.catch { error in
            print(error)
        }
    }
    
}

// MARK: ResetProtocol
extension SwiperViewController: Authentication {
    func refresh() {
        needsRefresh = false
        tinpons.removeAll()
        self.loadTinpons()
    }
    func clean() {
        needsRefresh = true
        tinpons.removeAll()
        kolodaView.reloadData()
    }
}

//MARK: KolodaViewDelegate
extension SwiperViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        outOfTinponsStack.isHidden = false
        //kolodaView.resetCurrentCardIndex()
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.left, .right, .down]
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        //performSegue(withIdentifier: "segueToTinponDetailViewController", sender: self)
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
}

// MARK: KolodaViewDataSource
extension SwiperViewController: KolodaViewDataSource {
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return tinpons.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let cell = Bundle.main.loadNibNamed("CustomOverlayView", owner: self, options: nil)?[0] as? CustomOverlayView
        cell?.tinpon = tinpons[index]
        return cell!
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("CustomOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        // free up some memory
//        tinpons[index].images.removeAll()
        
        // save swipedTinpon
        var liked = 0
        switch direction {
        case .right:
            liked = 1
        case .left:
            liked = 0
        case .down:
            liked = 2
        default: ()
        }
        
        self.saveSwipe(tinpon: tinpons[index], like: liked)
        
        // if less than 5 tinpons load next Tinpon
        if tinpons.count - koloda.currentCardIndex < 5 {
            self.loadMoreTinpons()
        }
    }
}

