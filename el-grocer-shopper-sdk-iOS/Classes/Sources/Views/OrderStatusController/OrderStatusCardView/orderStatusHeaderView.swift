//
//  orderStatusHeaderView.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 15/06/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit


var orderStatusHeaderHeight : CGFloat = 180
var orderStatusHeaderMinHeight : CGFloat = 120


class orderStatusHeaderView: UIView {
    @IBOutlet var trackingView: UIView!
    var orderId : String = ""
    var trackingUrl : String = ""
    var statusId : String = ""
    @IBOutlet var lblTrackYourOrder: UILabel!{
        didSet{
            self.lblTrackYourOrder.text = NSLocalizedString("lbl_Track_your_order", comment: "")
        }
    }
    @IBOutlet var lblOrderTracking: UILabel!
    @IBAction func trackYourOrderAction(_ sender: Any) {
        if trackingUrl.count > 0 {
            TrackingNavigator.presentTrackingViewWith(self.trackingUrl, orderId: orderId, statusId: statusId)
        }
        
    }
    
    
    @IBOutlet var cardBGView: AWView!{
        didSet{
            //cardBGView.backgroundColor = UIColor.LightGreyBorderColor()
        }
    }
    @IBOutlet var orderStatusImageView: UIImageView!
    @IBOutlet var spinnerView: AnimatedSpinnerView!{
        didSet{
            spinnerView.animationColor = .navigationBarColor()
        }
    }
    @IBOutlet var lblOrderType: UILabel!{
        didSet{
            lblOrderType.setBody3RegSecondaryDarkStyle()
            lblOrderType.text = ""
        }
    }
    @IBOutlet var lblTime: UILabel!{
        didSet{
            lblTime.setBody2BoldDarkStyle()
            lblTime.text = ""
        }
    }
    @IBOutlet var orderProgressBar: UIProgressView!{
        didSet{
            orderProgressBar.progressTintColor = .navigationBarColor()
            orderProgressBar.layer.cornerRadius = 4
            orderProgressBar.clipsToBounds = true
        }
    }
    @IBOutlet var lblOrderStatus: UILabel!{
        didSet{
            lblOrderStatus.setBody3BoldUpperStyle(true)
            lblOrderStatus.textAlignment = .natural
            //lblOrderStatus.text = NSLocalizedString("Scheduled", comment: "")
        }
    }
    @IBOutlet var btnOrderStatus: AWButton!{
        didSet{
            btnOrderStatus.setCornerRadiusStyle()
            btnOrderStatus.setTitle(NSLocalizedString("choose_substitutions_title_cell", comment: ""), for: UIControl.State())
            btnOrderStatus.backgroundColor = UIColor.navigationBarColor()
            btnOrderStatus.setTitleColor(.white, for: UIControl.State())
        }
    }
    
    @IBOutlet var bGWidthConstraint: NSLayoutConstraint!
    @IBOutlet var bGTopConstraint: NSLayoutConstraint!
    var chooseReplacmentAction: ((_ isClicked : Bool?)->Void)?

    class func loadFromNib() -> orderStatusHeaderView? {
        return self.loadFromNib(withName: "orderSatusCardView")
    }
    
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.backgroundColor = .promotionYellowColor()
        //self.bGWidthConstraint.constant = ScreenSize.SCREEN_WIDTH - 32
        //loadOrderStatusLabel(status: 1)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //self.backgroundColor = .promotionYellowColor()
        //self.bGWidthConstraint.constant = ScreenSize.SCREEN_WIDTH - 32
        //loadOrderStatusLabel(status: 1)
    }
    
    @IBAction func btnOrderStatusHandler(_ sender: Any) {
        if let clouser = self.chooseReplacmentAction {
            clouser(true)
        }

    }
    
    
    func loadOrderStatusLabel(status : DynamicOrderStatus , orderType : OrderType , _ slotTime : String , _ trackingURL : String = "" , orderId : String) {
        self.statusId = status.getStatusKeyLogic().status_id.stringValue
        self.lblTime.text = slotTime
        self.trackingUrl = trackingURL
        self.orderId = orderId
        self.trackingView.isHidden = self.trackingUrl.count == 0

        if orderType == .delivery{
            self.lblOrderType.text = NSLocalizedString("title_Estimated_delivery", comment: "")
        }else{
            self.lblOrderType.text = NSLocalizedString("lbl_self_collection_time", comment: "")
        }
        let statusString : String = ElGrocerUtility.sharedInstance.isArabicSelected() ? status.nameAr : status.nameEn
        let statusUppercased = statusString.uppercased()
        self.lblOrderStatus.text = statusUppercased
        let data = status.getStatusKeyLogic()
        if data.status_id.intValue == OrderStatus.inSubtitution.rawValue {
            self.lblOrderType.textColor = .secondaryBlackColor()
            let orderStatusIcon = UIImage(name: status.imageName)
            self.orderStatusImageView.image = orderStatusIcon
            self.lblOrderStatus.textColor = status.color
            self.btnOrderStatus.visibility = .visible
            self.orderStatusImageView.changePngColorTo(color: status.color)
            self.spinnerView.animationColor = status.color
            self.spinnerView.animate()
           // self.lblOrderType.text = NSLocalizedString("title_Estimated_delivery", comment: "")
        }else if data.status_id.intValue == OrderStatus.delivered.rawValue {
            self.lblOrderType.textColor = .secondaryBlackColor()
            let orderStatusIcon = ElGrocerUtility.sharedInstance.getImageWithName(status.imageName)
            self.orderStatusImageView.image = orderStatusIcon
            self.lblOrderStatus.textColor = status.color
            self.btnOrderStatus.visibility = .goneY
            self.orderStatusImageView.changePngColorTo(color: status.color)
            self.spinnerView.animationColor = status.color
            self.lblTime.isHidden = false
            self.lblOrderType.isHidden = false
            self.spinnerView.animate(true)
            if orderType == .delivery{
                self.lblOrderType.text = NSLocalizedString("title_delivered", comment: "")
            }else{
                self.lblOrderType.text = NSLocalizedString("title_collected", comment: "")
            }
        }else if data.status_id.intValue == OrderStatus.canceled.rawValue {
            self.lblOrderType.textColor = .secondaryBlackColor()
            let orderStatusIcon = UIImage(name: status.imageName)
            self.orderStatusImageView.image = orderStatusIcon
            self.lblOrderStatus.textColor = status.color
            self.btnOrderStatus.visibility = .goneY
            self.orderStatusImageView.changePngColorTo(color: status.color)
            self.spinnerView.animationColor = status.color
            self.lblTime.isHidden = true
            self.lblOrderType.isHidden = true
            self.spinnerView.animate(true)
            //self.spinnerView.layer.removeAllAnimations()
            //self.spinnerView.isHidden = true
        }else if data.status_id.intValue == OrderStatus.enRoute.rawValue{
           // self.lblOrderType.text = NSLocalizedString("title_updated_delivery", comment: "")
            self.lblOrderType.textColor = status.color
            let orderStatusIcon = UIImage(name: status.imageName)
            self.orderStatusImageView.image = orderStatusIcon
            self.lblOrderStatus.textColor = status.color
            self.btnOrderStatus.visibility = .goneY
            self.orderStatusImageView.changePngColorTo(color: status.color)
            self.spinnerView.animationColor = status.color
            self.spinnerView.animate()
        }else{
            let orderStatusIcon = UIImage(name: status.imageName)
            self.lblOrderType.textColor = .secondaryBlackColor()
            self.orderStatusImageView.image = orderStatusIcon
            self.lblOrderStatus.textColor = status.color
            self.btnOrderStatus.visibility = .goneY
            self.orderStatusImageView.changePngColorTo(color: status.color)
            self.spinnerView.animationColor = status.color
            self.spinnerView.animate()
        }
        
    }
    
    func setProgressAccordingToStatus(_ status : DynamicOrderStatus? , totalStep : Int) {
        
        guard status != nil else {
            return
        }
        
        let progress : Float = status!.stepNumber.floatValue / Float(totalStep)
        self.orderProgressBar.setProgress(progress , animated: true)
        
        
    }
    
    
}
