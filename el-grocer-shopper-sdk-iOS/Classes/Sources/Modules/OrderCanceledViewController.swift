//
//  OrderCanceledViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 16.10.2015.
//  Copyright © 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

class OrderCanceledViewController : UIViewController {
    let BUTTON_CORNER_RADIUS: CGFloat = 4.0
    
    @IBOutlet weak var labelWeAreSorry: UILabel!
    @IBOutlet weak var labelOrderCanceled: UILabel!
    @IBOutlet weak var labelCancelMessage: UILabel!
    @IBOutlet weak var labelProductsHaveBeenPutBack: UILabel!
    
    @IBOutlet weak var btnOkOrder: UIButton!
    @IBOutlet weak var btnNoThanks: UIButton!
    
    var orderId = Int.min
    var message = ""
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    
    
    fileprivate func setOkOrderButtonAppearance() {
        btnOkOrder.layer.cornerRadius = BUTTON_CORNER_RADIUS
    }
    
    fileprivate func setNoThanksButtonAppearance() {
        btnNoThanks.layer.cornerRadius = BUTTON_CORNER_RADIUS
    }
    
    fileprivate func setNavigationBarTitle() {
        self.title = NSLocalizedString("title_order_canceled", comment: "")
    }
    
    fileprivate func findGroceryName() -> String? {
        var groceryName: String? = nil
        
       // let order = Order.getDeliveryOrderById(NSNumber(self.orderId), context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        let order = Order.getDeliveryOrderById(NSNumber(value:self.orderId), context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if order != nil {
            
            groceryName = order!.grocery.name
        }
        
        return groceryName
    }
    
    fileprivate func setLabelsText() {
        self.labelWeAreSorry.text = NSLocalizedString("label_we_are_sorry", comment: "")
        labelCancelMessage.text = self.message
        labelProductsHaveBeenPutBack.text = NSLocalizedString("label_products_have_been_put_back", comment: "")
        
        if let name = findGroceryName() {
            labelOrderCanceled.text = String(format: NSLocalizedString("label_order_had_to_be_canceled", comment: ""), name)
        }
    }
    
    fileprivate func setButtonsText() {
        btnOkOrder.setTitle(NSLocalizedString("btn_ok_order", comment: ""), for: UIControl.State())
        btnNoThanks.setTitle(NSLocalizedString("btn_no_thanks", comment: ""), for: UIControl.State())
    }
    
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        
        setOkOrderButtonAppearance()    
        setNoThanksButtonAppearance()
        setLabelsText()
        setButtonsText()
        addBackButton()
        
    }
    
    @IBAction func onOkOrderClicked(_ sender: AnyObject) {
        let controller = ElGrocerViewControllers.groceriesViewController()
        controller.isFromCancelOrder = true
        self.navigationController?.pushViewController(controller, animated: true)
      //  self.navigationController?.viewControllers = [controller]
    }
    
    @IBAction func onNoThanksClicked(_ sender: AnyObject) {
        backButtonClick()
    }
    
    func setCanceledOrderId(_ orderId: Int!) {
        self.orderId = orderId
    }
    
    func setCancelMessage(_ cancelMessage: String!) {
        self.message = cancelMessage;
    }
}
