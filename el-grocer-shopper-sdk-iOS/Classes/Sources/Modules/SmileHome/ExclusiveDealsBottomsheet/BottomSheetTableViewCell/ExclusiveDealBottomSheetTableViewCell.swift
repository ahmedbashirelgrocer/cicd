//
//  ExclusiveDealBottomSheetTableViewCell.swift
//  Adyen
//
//  Created by ELGROCER-STAFF on 26/03/2024.
//

import UIKit
import SDWebImage

class ExclusiveDealBottomSheetTableViewCell: UITableViewCell {

    @IBOutlet weak var retailerImageView: UIImageView!
    @IBOutlet weak var retailerName: UILabel!{
        didSet{
            retailerName.numberOfLines = 1
            retailerName.setBodySemiBoldDarkStyle()
        }
    }
    @IBOutlet weak var voucherDesc: UILabel!{
        didSet{
            voucherDesc.setBody3RegDarkGreyStyle()
        }
    }
    @IBOutlet weak var voucherName: UILabel!{
        didSet{
            voucherName.setBodyBoldDarkStyle()
        }
    }
    @IBOutlet weak var voucherBgView: UIView!{
        didSet{
            voucherBgView.addDashedBorderAroundView(color: ApplicationTheme.currentTheme.newBlackColor)
        }
    }
    @IBOutlet weak var copyAndShopBtn: UIButton!{
        didSet{
            copyAndShopBtn.titleLabel?.setBody2BoldPurpleStyle()
            copyAndShopBtn.setTitle(localizedString("btn_copy_and_shop_title", comment: ""), for: UIControl.State())
        }
    }
    @IBOutlet weak var bgView: UIView!
    
    
    typealias tapped = (_ promo: ExclusiveDealsPromoCode?, _ grocery: Grocery?)-> Void
    var promoTapped: tapped?
    var grocery: Grocery?
    var promo: ExclusiveDealsPromoCode?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.newBorderGreyColor().cgColor
        bgView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func copyAndShopTapped(_ sender: Any) {
        
        if let promoTapped = self.promoTapped {
            promoTapped(self.promo, self.grocery)
        }
        
    }
    
    func configure(promoCode: ExclusiveDealsPromoCode, grocery: Grocery?) {
        self.grocery = grocery
        self.promo = promoCode
        self.retailerName.text = grocery?.name ?? ""
        self.voucherDesc.text = ElGrocerUtility.sharedInstance.isArabicSelected() ? (promoCode.title_ar ?? "") : (promoCode.title ?? "")
        self.voucherName.text = promoCode.code ?? ""
        
        if grocery?.smallImageUrl != nil && grocery?.smallImageUrl != "" {
            self.AssignImage(imageUrl: grocery?.smallImageUrl ?? "")
        }
    }

    func AssignImage(imageUrl: String){
        if imageUrl.range(of: "http") != nil {
            
            self.retailerImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.retailerImageView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.retailerImageView.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }

}
