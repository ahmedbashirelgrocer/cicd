//
//  ElgrocerSwitchAppView.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 16/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class ElgrocerSwitchAppView: UIView {
    
    var deliverySelect: ((_ isDelivery : Bool?)->Void)?
    var clickAndCollectSelect: ((_ isDelivery : Bool?)->Void)?
    var isNeedToUpdateGlobalState : Bool = false
    @IBOutlet var deliveryView: AWView!
    @IBOutlet var cAndCView: AWView!
    @IBOutlet var deliveryImage: UIImageView!
    @IBOutlet var deliveryLable: UILabel!
    @IBOutlet var cAndCImage: UIImageView!
    @IBOutlet var cAndCLable: UILabel!
    var isDeliverySelected : Bool = true
 
    
    func setUpFonts() {
        guard  self.deliveryLable != nil ,  self.cAndCLable != nil else {return}
        
        self.deliveryLable.font = UIFont.SFProDisplaySemiBoldFont(15)
        self.cAndCLable.font = UIFont.SFProDisplaySemiBoldFont(15)
    }
    
    func setDefaultStates(_ isDelivery : Bool = ElGrocerUtility.sharedInstance.isDeliveryMode ) {
        self.setUpFonts()
        let deliveryColor = isDelivery ? ApplicationTheme.currentTheme.buttonEnableBGColor : .white
        let cAndcColor = !isDelivery ? ApplicationTheme.currentTheme.buttonEnableBGColor : .white
        let maskToBoundDelivery = isDelivery ? true : false
        let maskToBoundClickAndCollect = !isDelivery ? true : false
        self.isDeliverySelected = isDelivery
        UIView.performWithoutAnimation {
            deliveryLable.text = localizedString("lbl_Delivery", comment: "")
            cAndCLable.text = localizedString("dialog_CandC_Title", comment: "")
            deliveryView.backgroundColor = deliveryColor
            cAndCView.backgroundColor = cAndcColor
            deliveryView.layer.masksToBounds = maskToBoundDelivery
            cAndCView.layer.masksToBounds = maskToBoundClickAndCollect
            deliveryImage.image = UIImage(name: "orderInfoCar")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cAndCImage.image = UIImage(name: "Home_Click")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            deliveryImage.tintColor = cAndcColor
            cAndCImage.tintColor = deliveryColor
            
            deliveryLable.textColor = cAndcColor
            cAndCLable.textColor = deliveryColor
        }
 
    }
    
    
    @IBAction func deliveryHandler(_ sender: Any) {
        
        setDefaultStates(true)
        if let clousre = self.deliverySelect {
            clousre(ElGrocerUtility.sharedInstance.isDeliveryMode)
        }
        if isNeedToUpdateGlobalState {
            ElGrocerUtility.sharedInstance.isDeliveryMode = true
        }
    }
    
    @IBAction func cAndcHandler(_ sender: Any) {
        setDefaultStates(false)
        if let clousre = self.clickAndCollectSelect {
            clousre(ElGrocerUtility.sharedInstance.isDeliveryMode)
            if isNeedToUpdateGlobalState {
                ElGrocerUtility.sharedInstance.isDeliveryMode = false
            }
        }
    }
    
    
}
