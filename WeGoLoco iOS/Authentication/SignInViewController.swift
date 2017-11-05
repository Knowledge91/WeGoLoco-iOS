//
//  ViewController.swift
//  AWS Mobile SDK
//
//  Created by Dirk Hornung on 8/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito
import AWSCognitoIdentityProvider
import FSPagerView

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var emailText: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.passwordTextField.text = nil
        self.emailTextField.text = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a pager view
        pagerView.dataSource = self
        pagerView.delegate = self
    }
    
    
    // MARK: FSPagerView
    var headers = ["Find interesting products in your area", "Slide the product to the right if you like it or to the left if you don't", "We adapt to your taste and filter your products"]
    var walkthroughImages = [#imageLiteral(resourceName: "walkthroughDiscover"), #imageLiteral(resourceName: "walkthroughLike"), #imageLiteral(resourceName: "walkthroughFilter")]
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(UINib(nibName: "WalkthroughCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
//            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    @IBOutlet weak var pageControl: UIPageControl! {
        didSet {
            self.pageControl.numberOfPages = 3
            self.pageControl.contentHorizontalAlignment = .center
            //self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            self.pageControl.hidesForSinglePage = true
        }
    }
    
    @IBAction func signInButtonTouched(_ sender: UIButton) {
        let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.emailTextField.text!, password: self.passwordTextField.text!)
        self.passwordAuthenticationCompletion?.set(result: authDetails)
    }
}


// MARK: FSPagerView
extension SignInViewController: FSPagerViewDataSource {
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 3
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index) as! WalkthroughCollectionViewCell
        cell.sliderImageView?.image = walkthroughImages[index]
        cell.headerLabel.text = headers[index]
        cell.contentView.layer.shadowRadius = 0;
        return cell
    }
}
extension SignInViewController: FSPagerViewDelegate {
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.pageControl.currentPage != pagerView.currentIndex else {
            return
        }
        self.pageControl.currentPage = pagerView.currentIndex // Or Use KVO with property "currentIndex"
    }
}

// API: http://docs.aws.amazon.com/AWSiOSSDK/latest/Protocols/AWSCognitoIdentityPasswordAuthentication.html
extension SignInViewController: AWSCognitoIdentityPasswordAuthentication {
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource passwordAuthenticationComplectionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationComplectionSource
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                let presentingVC = self.presentingViewController
                self.dismiss(animated: true){
                    print(presentingVC)
                    (presentingVC as! TabBarController).showSwiper()
                }
            }
        }
    }
}
