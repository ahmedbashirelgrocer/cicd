//
//  PrivacyPolicyViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 08/11/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
import WebKit
class PrivacyPolicyViewController: UIViewController, NavigationBarProtocol  {

    @IBOutlet var viewForWeb: UIView!
    var webView: WKWebView!
    @IBOutlet weak var activtyIndicator: UIActivityIndicatorView!
    var isTermsAndConditions = false
    var isFromEmbededWebView = false
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    
    override func loadView() {
        super.loadView()
        
        
//
//        let webConfiguration = WKWebViewConfiguration()
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        webView.uiDelegate = self
//        viewForWeb = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Nav bar apearance
        //addBackButtonWithCrossIcon()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.activtyIndicator.hidesWhenStopped = true
        
        var urlStr = "https://www.elgrocer.com/privacypolicymob"
        self.title = NSLocalizedString("setting_privacy_policy", comment: "")
        if (isTermsAndConditions == true){
            self.title = NSLocalizedString("terms_settings", comment: "")
            urlStr = "https:///www.elgrocer.com/termsconditionsmob"
        }
        
        
        webView =  WKWebView(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width , height: (view.frame.size.height - self.topbarHeight - 20)) , configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        self.viewForWeb.addSubview(webView)
        
        let url = URL (string: urlStr)
        let requestObj = URLRequest(url: url!)
        self.activtyIndicator.startAnimating()
        self.webView.load(requestObj)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController is ElGrocerNavigationController {
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
             self.addCustomTitleViewWithTitleDarkShade(self.title ?? "" , true)
        }
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
        if isTermsAndConditions {
            
             FireBaseEventsLogger.setScreenName(FireBaseScreenName.TermsConditions.rawValue, screenClass: String(describing: self.classForCoder))
        }else{
             FireBaseEventsLogger.setScreenName(FireBaseScreenName.PrivacyPolicy.rawValue, screenClass: String(describing: self.classForCoder))
        }
        
    }
    
    func backButtonClickedHandler() {
        self.backButtonClick()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
       // self.webView.delegate = nil
    }
    
    // MARK: Actions
    override func backButtonClick() {
        
        if isFromEmbededWebView {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        if let nav = self.navigationController {
            if nav.viewControllers.count == 1 {
                nav.dismiss(animated: true, completion: nil)
                return
            }
        }

        guard UserDefaults.isUserLoggedIn()  else {
            if let nav = self.navigationController {
                if  nav.viewControllers.count > 1 {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
            }
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    
//    // MARK: WebView Delegate
//    func webViewDidStartLoad(_ webView: UIWebView) {
//        self.activtyIndicator.startAnimating()
//    }
//
//    func webViewDidFinishLoad(_ webView: UIWebView) {
//        self.activtyIndicator.stopAnimating()
//    }
//
//    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
//
//        guard self.activtyIndicator != nil else {return}
//
//        self.activtyIndicator.stopAnimating()
//
//        let code = (error as NSError).code
//        if code == -999 {
//
//        }else{
//            let alert = UIAlertController(title: "Ooopsss ... ", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//
//
//    }
}
extension PrivacyPolicyViewController:   WKUIDelegate , WKNavigationDelegate {
    
   
   
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard self.activtyIndicator != nil else {return}
        
        self.activtyIndicator.stopAnimating()
        
        let code = (error as NSError).code
        if code == -999 {
            
        }else{
            let alert = UIAlertController(title: "Ooopsss ... ", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activtyIndicator.stopAnimating()
    }
    
    
    
    
}


