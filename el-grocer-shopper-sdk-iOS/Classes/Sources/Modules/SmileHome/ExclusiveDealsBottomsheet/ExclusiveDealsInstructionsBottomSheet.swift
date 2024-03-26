//
//  ExclusiveDealsInstructionsBottomSheet.swift
//  Pods
//
//  Created by ELGROCER-STAFF on 26/03/2024.
//

import UIKit

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
    
    
    var promoCode: ExclusiveDealsPromoCode?
    var grocery: Grocery?
    
    
    
    @IBAction func crossTapped(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func configureBottomSheet(promo: ExclusiveDealsPromoCode?, grocery: Grocery) {
        self.promoCode = promo
        self.grocery = grocery
        
        
    }
    
    
    
}
