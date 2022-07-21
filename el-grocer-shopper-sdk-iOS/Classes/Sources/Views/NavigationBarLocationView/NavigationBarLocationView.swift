//
//  NavigationBarLocationView.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 02/11/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class NavigationBarLocationView: UIView {

    @IBOutlet var imgLocationPin: UIImageView!{
        didSet{
            imgLocationPin.image = UIImage(name: "yellowLocationPin")
        }
    }
    @IBOutlet var imgArrowDown: UIImageView!{
        didSet{
            imgArrowDown.image = UIImage(name: "yellowArrowDown")
        }
    }
    @IBOutlet var lblLocation: UILabel!{
        didSet{
            lblLocation.setBody3BoldUpperYellowStyle()
            lblLocation.text = "Dubai, JLT, Cluser... "
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
        self.backgroundColor = UIColor.navigationBarColor()
        
    }
    
    @IBAction func LocationButtonHandler(_ sender: Any) {
        changeLocation()
        if let clouser = locationClick {
            clouser()
        }
        MixpanelEventLogger.trackHomeAddressClick()
    }
    func changeLocation() {
        
        let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
        dashboardLocationVC.isFromNewHome = true
        dashboardLocationVC.isRootController = true
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [dashboardLocationVC]
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.setLogoHidden(true)
        DispatchQueue.main.async {
            if let top = UIApplication.topViewController() {
                top.present(navigationController, animated: true, completion: nil)
            }
        }
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
