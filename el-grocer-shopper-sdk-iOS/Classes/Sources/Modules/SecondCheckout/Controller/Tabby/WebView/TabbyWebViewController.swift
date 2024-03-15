//
//  TabbyWebViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 26/06/2023.
//

import UIKit
import WebKit

typealias TabbyRegistrationCallback = (_ registrationStatus: TabbyRegistrationStatus) -> Void

enum TabbyRegistrationStatus: String {
    case success = "tabby_success"
    case failure = "tabby_failure"
    case cancel = "tabby_cancel"
}

class TabbyWebViewController: UIViewController, NavigationBarProtocol {
    @IBOutlet var viewForWeb: UIView!
    @IBOutlet weak var activtyIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblErrorMsg: UILabel!
    
    var tabbyRegistrationHandler: TabbyRegistrationCallback?
    var webView: WKWebView!
    var tabbyRedirectionUrl: String?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activtyIndicator.hidesWhenStopped = true
        
        webView =  WKWebView(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width , height: (view.frame.size.height - self.topbarHeight - 20)) , configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        self.viewForWeb.addSubview(webView)
        
        if let url = verifyUrl(urlString: self.tabbyRedirectionUrl) {
            self.activtyIndicator.startAnimating()
            self.webView.load(URLRequest(url: url))
            
            self.navigationController?.navigationBar.isHidden = true
            self.lblErrorMsg.isHidden = true
        } else {
            self.navigationController?.navigationBar.isHidden = false
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.hideSeparationLine()
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            self.title = "Tabby Registration"
            self.lblErrorMsg.isHidden = false
        }
    }
    
    func backButtonClickedHandler() {
        self.dismiss(animated: true)
    }
    
    private func verifyUrl (urlString: String?) -> URL? {
        if let urlString = urlString {
            if let url = NSURL(string: urlString), UIApplication.shared.canOpenURL(url as URL) {
                return url as URL
            }
        }
        return nil
    }
}

extension TabbyWebViewController:   WKUIDelegate , WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard self.activtyIndicator != nil else {return}
        
        self.activtyIndicator.stopAnimating()
        
        let code = (error as NSError).code
        if code == -999 {
            
        }else{
            let alert = UIAlertController(title: "Oppss ... ", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activtyIndicator.stopAnimating()
        
        guard let url = webView.url?.absoluteString, url.isNotEmpty else { return }
        
        if url.contains(TabbyRegistrationStatus.success.rawValue) {
            
            if let tabbyRegistrationHandler = self.tabbyRegistrationHandler {
                tabbyRegistrationHandler(.success)
            }
            
            self.backButtonClickedHandler()
        } else if url.contains(TabbyRegistrationStatus.failure.rawValue) {
            
            if let tabbyRegistrationHandler = self.tabbyRegistrationHandler {
                tabbyRegistrationHandler(.failure)
            }
            
            self.backButtonClickedHandler()
        } else if url.contains(TabbyRegistrationStatus.cancel.rawValue) {
            
            if let tabbyRegistrationHandler = self.tabbyRegistrationHandler {
                tabbyRegistrationHandler(.cancel)
            }
            
            self.backButtonClickedHandler()
        }
    }
}
