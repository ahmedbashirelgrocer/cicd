//
//  ExclusiveDealsCollectionViewCell.swift
//  Adyen
//
//  Created by ELGROCER-STAFF on 25/03/2024.
//

import UIKit
import SDWebImage

class ExclusiveDealsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imageView: UIImageView!
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
    @IBOutlet weak var voucherBgView: UIView!
    @IBOutlet weak var copyAndShopBtn: UIButton!{
        didSet{
            copyAndShopBtn.titleLabel?.setBody2BoldPurpleStyle()
        }
    }
    
    
    typealias tapped = (_ promo: ExclusiveDealsPromoCode?, _ grocery: Grocery?)-> Void
    var promoTapped: tapped?
    var grocery: Grocery?
    var promo: ExclusiveDealsPromoCode?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setInitialAppearance()
    }
    
    func setInitialAppearance() {
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.newBorderGreyColor().cgColor
        bgView.layer.cornerRadius = 8
        
        copyAndShopBtn.setTitle(localizedString("btn_copy_and_shop_title", comment: ""), for: UIControl.State())
        
        self.retailerName.textAlignment = ElGrocerUtility.sharedInstance.isArabicSelected() ? .right : .left
        self.voucherDesc.textAlignment = ElGrocerUtility.sharedInstance.isArabicSelected() ? .right : .left
        self.voucherName.textAlignment = ElGrocerUtility.sharedInstance.isArabicSelected() ? .right : .left
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
        self.voucherDesc.text = ElGrocerUtility.sharedInstance.isArabicSelected() ?  (promoCode.title_ar ?? "") : (promoCode.title ?? "")
        self.voucherName.text = promoCode.code ?? ""
        
        if grocery?.smallImageUrl != nil && grocery?.smallImageUrl != "" {
            self.AssignImage(imageUrl: grocery?.smallImageUrl ?? "")
        }
    }

    func AssignImage(imageUrl: String){
        if imageUrl.range(of: "http") != nil {
            
            self.imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.imageView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.imageView.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }
}
