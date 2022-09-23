//
//  PaymentSuccessVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 25/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import Adyen

enum PaymentControllerSuccessType: Int {
    case cardAdd = 1
    case payment = 2
    case voucher = 3
}

class PaymentSuccessVC: UIViewController {

    @IBOutlet var lblTransectionStatus: UILabel! {
        didSet {
            lblTransectionStatus.numberOfLines = 0
            lblTransectionStatus.textAlignment = .center
        }
    }
    @IBOutlet var backToElwalletBGView: AWView! {
        didSet {
            backToElwalletBGView.cornarRadius = 28
        }
    }
    @IBOutlet var lblBackToElWallet: UILabel! {
        didSet {
            lblBackToElWallet.text = localizedString("txt_btn_back_to_elwallet", comment: "")
        }
    }
    @IBOutlet var tryAgainBGView: AWView! {
        didSet {
            tryAgainBGView.cornarRadius = 28
//            tryAgainBGView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 28)
        }
    }
    @IBOutlet var lblTryAgain: UILabel! {
        didSet {
            lblTryAgain.text = localizedString("txt_btn_try_again", comment: "")
        }
    }
    var controlerType: PaymentControllerSuccessType = .payment
    var isSuccess: Bool = false
    var amount: String = ""
    var creditCard: CreditCard?
    var voucher: String?
    var voucherValue: String?
    var ispushed: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func btnBackToElWalletHandler(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
        
        if isSuccess {
            MixpanelEventLogger.trackElWalletAddFundsPaymentSuccessClose()
        }else {
            MixpanelEventLogger.trackElWalletAddFundsPaymentFaliureClose()
        }
    }
    
    @IBAction func btnTryAgainHandler(_ sender: Any) {
        MixpanelEventLogger.trackElwalletFundsErrorTryAgainClicked()
        if ispushed {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.navigationController?.dismiss(animated: true)
        }
    }
    
    func setupViews() {
        if self.controlerType == .payment {
            if isSuccess {
                lblTransectionStatus.text = amount + " " + CurrencyManager.getCurrentCurrency() + localizedString("txt_payment_process_success", comment: "")
                lblTransectionStatus.setH4SemiBoldGreenStyle()
            }else {
                lblTransectionStatus.text = localizedString("txt_payment_process_faliure", comment: "")
                lblTransectionStatus.setH4SemiBoldErrorStyle()
            }
        }else if self.controlerType == .cardAdd {
            if isSuccess {
                lblTransectionStatus.text = localizedString("txt_card_added_successfully", comment: "")
                lblTransectionStatus.setH4SemiBoldGreenStyle()
            }else {
                lblTransectionStatus.text = localizedString("txt_card_not_added", comment: "")
                lblTransectionStatus.setH4SemiBoldErrorStyle()
            }
        }else {
            //voucher
            if isSuccess {
                let successInitials = localizedString("txt_voucher", comment: "") + "\"" + (self.voucher ?? "" ) + "\"" + localizedString("txt_voucher_redeem_success", comment: "")
                let successStringLast = "\n" + (self.voucherValue ?? "") + " " + CurrencyManager.getCurrentCurrency() + localizedString("txt_amount_voucher_amount_elwallet", comment: "")
                
                lblTransectionStatus.text = successInitials + successStringLast
                lblTransectionStatus.setH4SemiBoldGreenStyle()
            }else {
                
                let faliureText = localizedString("txt_voucher", comment: "") + "\"" + (self.voucher ?? "" ) + "\"" + localizedString("txt_voucher_redeem_faliure", comment: "")
                
                lblTransectionStatus.text = faliureText
                lblTransectionStatus.setH4SemiBoldErrorStyle()
            }
        }
        
        setButtonViews()
    }
    
    func setButtonViews() {
        if isSuccess {
            tryAgainBGView.isHidden = true
            backToElwalletBGView.backgroundColor = .navigationBarColor()
            lblBackToElWallet.setH4SemiBoldWhiteStyle()
        }else {
            if self.controlerType == .payment {
                tryAgainBGView.isHidden = false
                backToElwalletBGView.backgroundColor = .navigationBarWhiteColor()
                lblBackToElWallet.setH4SemiBoldGreenStyle()
                backToElwalletBGView.borderWidth = 2
                backToElwalletBGView.borderColor = .navigationBarColor()
                tryAgainBGView.backgroundColor = .navigationBarColor()
                lblTryAgain.setH4SemiBoldWhiteStyle()
            }else {
                lblBackToElWallet.setH4SemiBoldWhiteStyle()
                tryAgainBGView.backgroundColor = .navigationBarWhiteColor()
                tryAgainBGView.borderWidth = 2
                tryAgainBGView.borderColor = .navigationBarColor()
                lblTryAgain.setH4SemiBoldGreenStyle()
                backToElwalletBGView.isHidden = false
                backToElwalletBGView.backgroundColor = .navigationBarColor()
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
