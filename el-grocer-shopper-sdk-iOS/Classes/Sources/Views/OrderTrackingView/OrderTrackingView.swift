//
//  OrderTrackingView.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 21/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

protocol OrderTrackingViewProtocol : class {
    
    func closeOrderTrackingView()
    func connectToCustomerSupport()
    func showDeliveryViewWithOrderId(_ orderId:Int)
}


open class OrderTrackingView: UIView {
    
    
    //MARK: Outlets
    
    @IBOutlet weak var orderTitleLbl: UILabel!
    @IBOutlet weak var orderNumberLbl: UILabel!
    @IBOutlet weak var orderTimeLbl: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var deliveryButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    
    weak var delegate:OrderTrackingViewProtocol?
    
    
    // MARK: Life cycle
    
    override open func awakeFromNib() {
        
        setUpOrderTitleAppearance()
        setUpOrderNumberAppearance()
        setUpOrderTimeAppearance()
        setUpDeliveryButtonAppearance()
        setUpSupportButtonAppearance()
    }
    
    fileprivate func setUpOrderTitleAppearance() {
        
        self.orderTitleLbl.font = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.orderTitleLbl.textColor = UIColor.black
    }
    
    fileprivate func setUpOrderNumberAppearance() {
        
        self.orderNumberLbl.font = UIFont.bookFont(9.0)
        self.orderNumberLbl.textColor = UIColor.lightTextGrayColor()
    }
    
    fileprivate func setUpOrderTimeAppearance() {
        
        self.orderTimeLbl.font = UIFont.bookFont(9.0)
        self.orderTimeLbl.textColor = UIColor.lightTextGrayColor()
    }
    
    fileprivate func setUpDeliveryButtonAppearance() {
        
        self.deliveryButton.layer.cornerRadius = 9.0
        self.deliveryButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(13.0)
    }
    
    fileprivate func setUpSupportButtonAppearance() {
        
        self.supportButton.layer.cornerRadius = 9.0
        self.supportButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(13.0)
        self.supportButton.layer.borderWidth = 1
        self.supportButton.layer.borderColor = ApplicationTheme.currentTheme.buttonWithBorderTextColor.cgColor
        
        self.supportButton.imageEdgeInsets = UIEdgeInsets(top: 0,left: -8,bottom: 0,right: 0)
    }
    
    // MARK: OrderTrackingView
    
     class func getOrderTarckingView() -> OrderTrackingView {
        
        let view = Bundle.resource.loadNibNamed("OrderTrackingView", owner: nil, options: nil)![0] as! OrderTrackingView
        
        return view
    }
    
    // MARK: Button Handlers
    
    @IBAction func closeButtonHandler(_ sender: AnyObject) {
        self.delegate?.closeOrderTrackingView()
    }
    
    @IBAction func supportButtonHandler(_ sender: AnyObject) {
        self.delegate?.connectToCustomerSupport()
    }
    
    @IBAction func deliveryButtonHandler(_ sender: AnyObject) {
        
        let button = sender as! UIButton
        self.delegate?.showDeliveryViewWithOrderId(button.tag)
    }

}
