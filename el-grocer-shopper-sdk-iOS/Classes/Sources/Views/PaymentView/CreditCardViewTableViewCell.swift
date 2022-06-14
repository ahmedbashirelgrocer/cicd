//
//  CreditCardViewTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 03/03/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import Adyen

let KCreditCardViewTableViewCellIdentifier = "CreditCardViewTableViewCell"
let KCreditCardViewTableViewCellHeight : CGFloat = 60.0

class CreditCardViewTableViewCell: UITableViewCell {
    
     var rightButtonCLicked: (()->Void)?

    @IBOutlet var lblCardType: UILabel!
    @IBOutlet var lblCardNumber: UILabel!
    
    
    @IBOutlet var selectionImage: UIImageView!
    @IBOutlet var cardImage: UIImageView!
    @IBOutlet var btnAddNewCard: UIButton!
    
    @IBOutlet var radioButton: UIImageView!
    @IBOutlet var cardView: UIView!
    let kMaxCellTranslation: CGFloat = 80
    var currentTranslation:CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // self.addPanGesture()
        let cardTitle = " " + NSLocalizedString("Add_New_Card_Title", comment: "")
        btnAddNewCard.setTitle(cardTitle, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell (card : CreditCard) {
        self.radioButton.isHidden = false
        self.btnAddNewCard.isHidden = true
        self.lblCardType.isHidden = false
        self.lblCardNumber.isHidden = false
        self.cardImage.isHidden = false
        self.lblCardType.text =   NSLocalizedString("lbl_Card_ending_in", comment: "") + card.last4.convertEngNumToPersianNum()
     //   self.lblCardNumber.text = NSLocalizedString("card_title", comment: "") + ": **** **** **** " + card.last4.convertEngNumToPersianNum()
        self.cardImage.image = card.cardType.getCardColorImageFromType()
        
    }
    
    func configureCellAsPaymentOption (obj : PaymentOption) {
        self.btnAddNewCard.isHidden = true
        self.lblCardType.isHidden = false
        self.lblCardNumber.isHidden = false
        self.cardImage.isHidden = false
        self.radioButton.isHidden = false
        
        if obj == PaymentOption.cash {
            self.lblCardType.text = NSLocalizedString("cash_On_Delivery_string", comment: "")
             self.cardImage.image = UIImage(named: "cash-List")
        }else  if obj == PaymentOption.card {
            self.lblCardType.text = NSLocalizedString("pay_via_card", comment: "")
            self.cardImage.image = UIImage(named: "CardOnDelivery")
        }else  if obj == PaymentOption.applePay {
            self.lblCardType.text = NSLocalizedString("checkout_paymentlist_applepay_title", comment: "")
            self.cardImage.image = UIImage(named: "payWithApple")
        }
    }
    
    func configureCellAsApplePay (obj : ApplePayPaymentMethod) {
        self.btnAddNewCard.isHidden = true
        self.lblCardType.isHidden = false
        self.lblCardNumber.isHidden = false
        self.cardImage.isHidden = false
        self.radioButton.isHidden = false
        
        self.lblCardType.text = NSLocalizedString("checkout_paymentlist_applepay_title", comment: "")
        self.cardImage.image = UIImage(named: "payWithApple")
    }
    
    func configureCellAsPaymentOption (obj : Any) {
        
        self.radioButton.isHidden = true
        self.lblCardType.isHidden = false
        self.lblCardNumber.isHidden = false
        self.cardImage.isHidden = false
        self.btnAddNewCard.isHidden = false
        self.lblCardType.text = NSLocalizedString("lbl_text_new_card" , comment: "")
        
        
        self.cardImage.image = UIImage(named: "placeorder-card")
        
    }
    
    func configureEmptyView () {
         self.radioButton.isHidden = true
        self.btnAddNewCard.isHidden = true
        self.lblCardType.isHidden = true
        self.lblCardNumber.isHidden = true
        self.cardImage.isHidden = true
        
    }
    @IBAction func rightButtonHandler(_ sender: Any) {
        if let clouser = self.rightButtonCLicked {
            clouser()
        }
        
    }
    
//    func addPanGesture() {
//
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(DashboardLocationCell.handlePanGesture(_:)))
//        panGesture.cancelsTouchesInView = true
//        panGesture.delegate = self
//
//        self.addGestureRecognizer(panGesture)
//    }
//
//    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//
//        return true
//    }
//
//    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
//
//        switch recognizer.state {
//
//            case .changed:
//
//                let translation = recognizer.translation(in: self.cardView)
//                var xOffset: CGFloat = self.currentTranslation + translation.x
//
//                if xOffset > kMaxCellTranslation {
//
//                    xOffset = kMaxCellTranslation
//
//                } else if xOffset < -kMaxCellTranslation {
//                    xOffset = -kMaxCellTranslation
//                }
//
//                self.cardView.transform = CGAffineTransform(translationX: xOffset, y: 0)
//
//            case .ended:
//
//                let translation = recognizer.translation(in:  self.cardView)
//                var xOffset: CGFloat = self.currentTranslation + translation.x
//
//                let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
//
//                if xOffset >= kMaxCellTranslation / 2 {
//
//                    if UserDefaults.isUserLoggedIn(){
//                        xOffset = kMaxCellTranslation
//                    }else{
//                        if currentLang == "ar" {
//                            xOffset = kMaxCellTranslation
//                        }else{
//                            xOffset = 0
//                        }
//                    }
//
//                } else if xOffset < kMaxCellTranslation / 2 && xOffset > -kMaxCellTranslation / 2 {
//
//                    xOffset = 0
//
//                } else {
//
//                    if UserDefaults.isUserLoggedIn() == false && currentLang == "ar" {
//                        xOffset = 0
//                    }else{
//                        xOffset = -kMaxCellTranslation
//                    }
//                }
//
//                UIView.animate(withDuration: 0.33, animations: { () -> Void in
//
//                     self.cardView.transform = CGAffineTransform(translationX: xOffset, y: 0)
//                    self.currentTranslation = xOffset
//                })
//
//            default:
//                break
//        }
//    }
    
}
