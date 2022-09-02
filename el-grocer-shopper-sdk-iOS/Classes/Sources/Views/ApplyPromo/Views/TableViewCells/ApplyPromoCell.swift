    //
    //  ApplyPromoCell.swift
    //  ElGrocerShopper
    //
    //  Created by Abdul Saboor on 20/04/2022.
    //  Copyright © 2022 elGrocer. All rights reserved.
    //

import UIKit
import SDWebImage
class ApplyPromoCell: UITableViewCell {
    
    @IBOutlet var superBGView: UIView!
    @IBOutlet var backGroundView: UIView! {
        didSet {
            backGroundView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 8)
        }
    }
    @IBOutlet var imgVoucher: UIImageView! {
        didSet {
            imgVoucher.roundCorners(corners: UIRectCorner.allCorners, radius: 12)
        }
    }
    @IBOutlet var lblVoucherName: UILabel! {
        didSet {
            lblVoucherName.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var lblGroceryName: UILabel! {
        didSet {
            lblGroceryName.setBody3BoldUpperStyle(false)
            lblGroceryName.text = "Elgrocer"
        }
    }
    @IBOutlet var lblVoucherDetails: UILabel! {
        didSet {
            lblVoucherDetails.numberOfLines = 0
            lblVoucherDetails.font = UIFont.SFProDisplayNormalFont(14)
            lblVoucherDetails.textColor = UIColor.newBlackColor()        }
    }
    @IBOutlet var viewDetailsBGView: UIView! {
        didSet {
            imgArrowViewDetails.image = UIImage(named: "arrowDown16")
        }
    }
    @IBOutlet var lblViewDetails: UILabel! {
        didSet {
            lblViewDetails.setCaptionOneBoldUperCaseGreenStyle()
        }
    }
    @IBOutlet var imgArrowViewDetails: UIImageView!
    @IBOutlet var btnViewDtails: UIButton! {
        didSet {
            btnViewDtails.setTitle("", for: UIControl.State())
        }
    }
    @IBOutlet var lineView: UIView!
    @IBOutlet var voucherCodeBGView: UIView! {
        didSet {
                //            voucherCodeBGView.backgroundColor = .yellow
                // voucherCodeBGView.addDashedBorderAroundView(color: .darkGreenColor())
        }
    }
    @IBOutlet var lblVoucherCode: UILabel! {
        didSet {
            lblVoucherCode.setCaptionOneBoldUperCaseDarkGreenStyle()
            lblVoucherCode.textAlignment = .center
        }
    }
    @IBOutlet var btnRedeem: AWButton! {
        didSet {
                //            btnRedeem.setBody3BoldGreenStyle()
            btnRedeem.setTitle(localizedString("txt_btn_apply", comment: ""), for: UIControl.State())
        }
    }
    @IBOutlet var imgVoucherCupon: UIImageView! {
        didSet {
            imgVoucherCupon.image = UIImage(named: "EnterPromoDark")
        }
    }
    @IBOutlet var promoMessageBGView: UIView! {
        didSet {
            promoMessageBGView.backgroundColor = .aletBackgroundColor()
            promoMessageBGView.roundWithShadow(corners: [.layerMinXMinYCorner, .layerMaxXMaxYCorner], radius: 8)
        }
    }
    @IBOutlet var lblPromoMessage: UILabel! {
        didSet {
            lblPromoMessage.setCaptionOneBoldDarkStyle()
        }
    }
    @IBOutlet var lblAppliedBGView: UIView! {
        didSet {
            lblAppliedBGView.isHidden = true
        }
    }
    @IBOutlet var imgCheck: UIImageView!
    @IBOutlet var lblApplied: UILabel! {
        didSet {
            lblApplied.setCaptionOneBoldGreyStyle()
            lblApplied.text = "(" + localizedString("txt_btn_applied", comment: "") + ")"
        }
    }
    
    typealias tapped = (_ promo: PromotionCode,_ isAppled: Bool)-> Void
    typealias tappedView = (_ viewDetailsTapped: Bool)-> Void
    var isRedeemTapped: tapped?
    var isShowDetailsTapped: tappedView?
    var isExpanded: Bool = false
    var promoCode: PromotionCode?
    var isApplied: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
            // Initialization code
        self.contentView.backgroundColor = .tableViewBackgroundColor()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
    }
    
    @IBAction func btnViewDetailsHandler(_ sender: Any) {
        if let isShowDetailsTapped = isShowDetailsTapped {
            if isExpanded {
                isShowDetailsTapped(false)
            }else {
                isShowDetailsTapped(true)
            }
            
        }
    }
    @IBAction func btnRedeemHandler(_ sender: Any) {
        if let isRedeemTapped = isRedeemTapped, let promoCode = self.promoCode {
            isRedeemTapped(promoCode, self.isApplied)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
            // Configure the view for the selected state
    }
    
    fileprivate func setViewDetailsButtonView(isExpanded: Bool) {
        if isExpanded {
            self.lblVoucherDetails.visibility = .visible
            self.lblViewDetails.text = localizedString("txt_hide_details", comment: "")
            self.imgArrowViewDetails.image = UIImage(named: "arrowUp16")
        }else {
            self.lblVoucherDetails.visibility = .gone
            self.lblViewDetails.text = localizedString("txt_view_details", comment: "")
            self.imgArrowViewDetails.image = UIImage(named: "arrowDown16")
        }
    }
    
    func showInfoMessage (isHidden: Bool = false, message: String = "") {
        self.promoMessageBGView.isHidden = isHidden
        self.btnRedeem.isHidden = !isHidden
        self.lblPromoMessage.text = localizedString("txt_add_to_use_initial", comment: "") + " \(message) " + localizedString("txt_add_to_use_end", comment: "")
    }
    fileprivate func setApplyButtonState(isApplied: Bool = false) {
        self.isApplied = isApplied
        Thread.OnMainThread { [weak self] in
            if isApplied {
                self?.btnRedeem.setTitle(localizedString("txt_remove", comment: ""), for: UIControl.State())
                self?.btnRedeem.setTitleColor(.textfieldErrorColor(), for: UIControl.State())
                self?.lblAppliedBGView.isHidden = false
            }else {
                self?.btnRedeem.setTitle(localizedString("txt_btn_apply", comment: ""), for: UIControl.State())
                self?.btnRedeem.setTitleColor(.navigationBarColor(), for: UIControl.State())
                self?.lblAppliedBGView.isHidden = true
            }
        }
        
    }
    fileprivate func AssignImage(imageUrl: String , imageView: UIImageView){
        if imageUrl != nil && imageUrl.range(of: "http") != nil {
            
            imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: imageView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        imageView.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }
    
    func configureCell(promoCode: PromotionCode, isExpanded: Bool, isApplied: Bool, grocery: Grocery?) {
        self.promoCode = promoCode
        
        if let grocery = grocery {
            self.lblGroceryName.text = promoCode.groceryName ?? grocery.name
            self.AssignImage(imageUrl: promoCode.groceryImage ?? grocery.smallImageUrl ?? "", imageView: self.imgVoucher)
        }else {
            self.lblGroceryName.text = promoCode.groceryName
            self.AssignImage(imageUrl: promoCode.groceryImage ?? "", imageView: self.imgVoucher)
        }
        
        self.lblVoucherName.text = promoCode.title
        self.lblVoucherCode.text = promoCode.code
        self.lblVoucherDetails.text = promoCode.detail
        self.viewDetailsBGView.isHidden = (promoCode.detail.count <= 0)
        self.isExpanded = isExpanded
       // self.promoMessageBGView.isHidden = true
        self.setViewDetailsButtonView(isExpanded: isExpanded)
        setApplyButtonState(isApplied: isApplied)
    }
    
    func setBorderForPromo() {
        
        voucherCodeBGView.addDashedBorderAroundView(color: .darkGreenColor())
    }
}
