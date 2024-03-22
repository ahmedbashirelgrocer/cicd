//
//  NavigationBarLocationView.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 02/11/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class NavigationBarLocationView: UIView {

    @IBOutlet weak var imgLocationPinLeadingConstraint: NSLayoutConstraint! {
        didSet {
            imgLocationPinLeadingConstraint.constant = SDKManager.shared.isSmileSDK ? 50 : 45
        }
    }
    
    @IBOutlet var imgLocationPin: UIImageView!{
        didSet{
            imgLocationPin.tintColor = sdkManager.isSmileSDK ? .black : .black
            imgLocationPin.image = UIImage(name: "homeHeadeerLocationPin")?.withRenderingMode(.alwaysTemplate)
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                imgLocationPin.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
        }
    }
    @IBOutlet var imgArrowDown: UIImageView!{
        didSet{
            imgArrowDown.backgroundColor = ApplicationTheme.currentTheme.separatorColor
            imgArrowDown.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], radius: (imgArrowDown.bounds.height / 2))
            imgArrowDown.tintColor = sdkManager.isSmileSDK ? .black : .black
            imgArrowDown.image = UIImage(name: "yellowArrowDown")?.withRenderingMode(.alwaysTemplate)
        }
    }
    @IBOutlet var lblLocation: UILabel!{
        didSet{
            lblLocation.setBody3RegDarkStyle()
            if !sdkManager.isShopperApp { lblLocation.textColor = ApplicationTheme.currentTheme.newBlackColor }
            lblLocation.textColor = ApplicationTheme.currentTheme.themeBasePrimaryBlackColor
            lblLocation.text = "... "
            lblLocation.textAlignment = .natural
        }
    }
    @IBOutlet var btnLocation: UIButton!//to handle interaction
    
    var locationClick: (()->Void)?
    
    class func loadFromNib() -> NavigationBarLocationView? {
        return self.loadFromNib(withName: "NavigationBarLocationView")
    }
    
    override func awakeFromNib() {
        
        setupInitialAppearnce()
    }
    
    func setupInitialAppearnce(){
        self.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            imgLocationPinLeadingConstraint.constant = SDKManager.shared.isSmileSDK ? 50 : 30
        }else {
            imgLocationPinLeadingConstraint.constant = SDKManager.shared.isSmileSDK ? 50 : 45
        }
    }
    
    @IBAction func LocationButtonHandler(_ sender: Any) {
        
       
        changeLocation()
        MixpanelEventLogger.trackHomeAddressClick()
        
        // Logging segment event for address clicked
        SegmentAnalyticsEngine.instance.logEvent(event: AddressClickedEvent(source: .home))
    }
    func changeLocation() {
        
        DispatchQueue.main.async {
            if let top = UIApplication.topViewController() {
                top.locationButtonClick()
                //EGAddressSelectionBottomSheetViewController.showInBottomSheet(nil, mapDelegate: nil, presentIn: top)
            }
    }
        
        
        
        
//        let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
//        dashboardLocationVC.isFromNewHome = true
//        dashboardLocationVC.isRootController = true
//        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
//        navigationController.viewControllers = [dashboardLocationVC]
//        navigationController.modalPresentationStyle = .fullScreen
//        navigationController.setLogoHidden(true)
//        DispatchQueue.main.async {
//            if let top = UIApplication.topViewController() {
//                top.present(navigationController, animated: true, completion: nil)
//            }
//        }
    }
    func setLocationHidden(_ hidden:Bool) {
//        if let chat = self.navChatButton {
//            if hidden{
//                chat.visibility = .goneX
//            }else{
//                chat.visibility = .visible
//            }
//            
//        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
