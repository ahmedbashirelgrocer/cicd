//
//  ExclusiveDealsInstructionsBottomSheet.swift
//  Pods
//
//  Created by ELGROCER-STAFF on 26/03/2024.
//

import UIKit
import SDWebImage

class ExclusiveDealsInstructionsBottomSheet: UIViewController {

    @IBOutlet weak var retailerImageView: UIImageView!
    @IBOutlet weak var retailerName: UILabel!{
        didSet{
            retailerName.numberOfLines = 1
            retailerName.text = "Smiles Market"
            retailerName.setBody2SemiboldGeoceryDarkGreenStyle()
        }
    }
    @IBOutlet weak var freeDeliveryLabel: UILabel!{
        didSet{
            freeDeliveryLabel.setBody3RegDarkGreyStyle()
        }
    }
    @IBOutlet weak var instructionsLabel: UILabel!{
        didSet{
            freeDeliveryLabel.setBody3RegDarkGreyStyle()
        }
    }
    @IBOutlet weak var voucherBgView: UIView!{
        didSet{
            voucherBgView.addDashedBorderAroundView(color: ApplicationTheme.currentTheme.newBlackColor)
        }
    }
    @IBOutlet weak var voucherName: UILabel!{
        didSet{
            voucherName.text = "UNIONPEPSI"
            voucherName.setBodyBoldDarkStyle()
        }
    }
    @IBOutlet weak var startShoppingBtn: UIButton!{
        didSet{
            startShoppingBtn.titleLabel?.setBody2BoldPurpleStyle()
        }
    }
    
    typealias tapped = (_ promo: ExclusiveDealsPromoCode?, _ grocery: Grocery?)-> Void
    var promoTapped: tapped?
    var promoCode: ExclusiveDealsPromoCode?
    var grocery: Grocery?
    
    
    
    @IBAction func crossTapped(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func startShoppingBtnTapped(_ sender: Any) {
        if let promoTapped = self.promoTapped {
            promoTapped(promoCode, grocery)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let grocer = self.grocery , let promoCode = self.promoCode {
            self.configure(promoCode: promoCode, grocery: grocer)
        }
        
    }
    
    func configure(promoCode: ExclusiveDealsPromoCode, grocery: Grocery?) {

        self.retailerName.text = grocery?.name ?? ""
        self.freeDeliveryLabel.text = promoCode.title ?? ""
        self.voucherName.text = promoCode.code ?? ""
        
        self.instructionsLabel.text = promoCode.detail ?? ""
        
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
