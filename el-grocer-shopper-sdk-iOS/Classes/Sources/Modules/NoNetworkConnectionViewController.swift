//
//  NoNetworkConnectionViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 31.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

class NoNetworkConnectionViewController : UIViewController , NavigationBarProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    // MARK: Life cycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        setUpTitleLabelAppearance()
        setUpDescriptionLabelAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.hideBorder(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
    }
    func backButtonClickedHandler() {
            self.dismiss(animated: false, completion:nil)
    }
    // MARK: Appearance
    
    fileprivate func setUpTitleLabelAppearance() {
        
        self.titleLabel.textColor = UIColor.emptyViewTextColor()
        self.titleLabel.font = UIFont.boldFont(20.0)
        self.titleLabel.text = localizedString("no_network_screen_title", comment: "")
    }
    
    fileprivate func setUpDescriptionLabelAppearance() {
        
        self.descriptionLabel.textColor = UIColor.emptyViewTextColor()
        self.descriptionLabel.font = UIFont.bookFont(17.0)
        self.descriptionLabel.text = localizedString("no_network_screen_description", comment: "")
    }
    
    // MARK: Actions
    
    @IBAction func onRefreshButtonClick(_ sender: AnyObject) {
        
        
        let SDKManager: SDKManagerType! = sdkManager
        SDKManager.networkStatusDidChanged(nil)
    }
    
    class func checkInternet(showLoader: Bool = true, completionHandler:@escaping (_ internet:Bool) -> Void)
    {
      //  UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = URL(string: "https://www.google.com/")
        var req = URLRequest.init(url: url!)
        req.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        req.timeoutInterval = 10.0
        
        if showLoader {
    //       UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        let task = URLSession.shared.dataTask(with: req) { (data, response, error) in
            
            if showLoader {
       //         UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if error != nil  {
                completionHandler(false)
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                } else {
                    completionHandler(false)
                }
            }
        }
        task.resume()
    }
    
}
