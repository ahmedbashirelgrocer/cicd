//
//  OfferAlertViewController.swift
//  Adyen
//
//  Created by ELGROCCER on 28/03/2024.
//

import UIKit


class OfferAlertViewController: UIViewController {
    
    //MARK: - outlets
    @IBOutlet weak var offerImg:UIImageView!
    @IBOutlet weak var  alertLbl:UILabel!
    @IBOutlet weak var  descrptionLbl:UILabel!
    @IBOutlet weak var skipBtn:UIButton!
    var isSdKHome = false
    @IBOutlet weak var discoverBtn:AWButton! {
        didSet {
            discoverBtn.setH4SemiBoldEnableButtonStyle()
        }
    }
    
    //MARK: -  Varriables
    var skipBtnText = ""
    var alertTitle = ""
    var descrptionLblTitle = ""
    var discoverBtnTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
    
    func setUI() {
        self.alertLbl.text = alertTitle
        self.descrptionLbl.text = descrptionLblTitle
        self.skipBtn.setTitle(skipBtnText, for: .normal)
        self.discoverBtn.setTitle(discoverBtnTitle, for: .normal)
    }
    
    //MARK: - Button Actions
    @IBAction func discoverBtnClick() {
        self.dismiss(animated: true)
    }
    
    @IBAction func skipBtnClick() {
        //self.dismiss(animated: true)
        
        if !isSdKHome{
            SegmentAnalyticsEngine.instance.logEvent(event: SDKExitedEvent())
            NotificationCenter.default.removeObserver(SDKManager.shared, name: NSNotification.Name(rawValue: kReachabilityManagerNetworkStatusChangedNotificationCustom), object: nil)
            
            if let rootContext = SDKManager.shared.rootContext {
                rootContext.dismiss(animated: true)
            }else {
                if let _ = self.tabBarController {
                    self.tabBarController?.dismiss(animated: true)
                }else if let _ = SDKManager.shared.currentTabBar {
                    SDKManager.shared.currentTabBar?.dismiss(animated: true)
                }else if let _ = SDKManager.shared.rootViewController {
                    SDKManager.shared.rootViewController?.dismiss(animated: true)
                }
            }
        }
    }
    
    
    class func getViewController() -> OfferAlertViewController {
        return OfferAlertViewController(nibName: "OfferAlertViewController", bundle: Bundle.resource) as OfferAlertViewController
    }
}
