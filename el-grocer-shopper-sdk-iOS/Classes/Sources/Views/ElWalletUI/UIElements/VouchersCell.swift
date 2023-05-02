//
//  VouchersCell.swift
//  ElGrocerShopper
//
//  Created by Salman on 29/04/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage
class VouchersCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContainerView: UIView!{
        didSet {
            innerContainerView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 8, withShadow: false)
        }
    }
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var voucherGroceryNameLabel: UILabel!
    @IBOutlet weak var voucherNameLabel: UILabel!
    @IBOutlet var btnViewDetailsBGView: UIView!
    @IBOutlet weak var viewDetailLabel: UILabel!
    @IBOutlet weak var viewDetailButton: UIButton!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var redeemButton: UIButton! {
        didSet {
            redeemButton.setTitle(localizedString("txt_redeem_capital", comment: ""), for: UIControl.State())
        }
    }
    @IBOutlet weak var voucherCodeLabel: UILabel!
    @IBOutlet weak var voucherCodeBorderView: UIView!
    @IBOutlet weak var voucherDetailsLabel: UILabel!
    
    var showVoucherDetails: (()->Void)?
    var redeemVoucher:((_ voucher: Voucher)->Void)?
    var voucher: Voucher?
    static let reuseId: String = "VouchersCell"
    static var nib: UINib {
        return UINib(nibName: "VouchersCell", bundle: .resource)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpInitialAppearance()
    }

    func configure(_ voucher:Voucher) {
        self.voucher = voucher
        voucherGroceryNameLabel.text = voucher.name
        voucherNameLabel.text = voucher.title
        voucherCodeLabel.text = voucher.code
        voucherDetailsLabel.text = voucher.detail
        self.voucherDetailsLabel.isHidden = !voucher.showDetails
        if voucher.detail?.count ?? 0 == 0 {
            btnViewDetailsBGView.visibility = .gone
        }else {
            btnViewDetailsBGView.visibility = .visible
        }
        if voucher.isRedeemed {
            self.redeemButton.isEnabled = false
            self.redeemButton.setTitle(localizedString("txt_redeem_capital", comment: ""), for: UIControl.State())
        } else {
            self.redeemButton.isEnabled = true
            self.redeemButton.setTitle(localizedString("txt_redeem_capital", comment: ""), for: UIControl.State())
        }
        
        if self.voucherDetailsLabel.isHidden {
            viewDetailLabel.text = localizedString("txt_view_details", comment: "")
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: 0)
        } else {
            viewDetailLabel.text = localizedString("txt_hide_details", comment: "")
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
        }
        self.setStoreLogo(voucher.photoUrl ?? "")
    }
    fileprivate func setStoreLogo(_ imageURl : String?) {
        let placeholderPhoto = UIImage(name: "product_placeholder")!
        if imageURl != nil && imageURl?.range(of: "http") != nil {
            
            self.logoImageView.sd_setImage(with: URL(string: imageURl!), placeholderImage: placeholderPhoto , options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let  self = self else {return}
                if cacheType == SDImageCacheType.none {
                    UIView.transition(with: self.logoImageView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {() -> Void in
                        self.logoImageView.image = image
                    }, completion: nil)
                }
            })
        }
    }
    func setUpInitialAppearance() {

        self.innerContainerView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner], radius: 8, withShadow: false)
        
        voucherGroceryNameLabel.setBody3SemiBoldDarkStyle()
        voucherNameLabel.setBody3RegDarkStyle()
        viewDetailButton.setCaption1BoldGreenStyle()
        redeemButton.setBody3BoldGreenStyle()
        voucherCodeLabel.setCaptionOneBoldGreenStyle()
        voucherCodeBorderView.addDashedBorderAroundView(color: ApplicationTheme.currentTheme.buttonWithBorderTextColor)
        viewDetailLabel.setCaptionOneBoldDarkGreenStyle()
        voucherDetailsLabel.setBody3RegDarkStyle()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func viewDetailTapped(_ sender: UIButton) {
        
        if let showDetails = showVoucherDetails {
            showDetails()
        }
        
    }
    
    @IBAction func redeemBtnTapped(_ sender: UIButton) {
        if let redeemVoucher = redeemVoucher, let voucher = self.voucher {
            redeemVoucher(voucher)
        }
    }
}
