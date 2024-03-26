//
//  ElWalletAddFundsVC.swift
//  ElGrocerShopper
//
//  Created by Salman on 19/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import Adyen

class ElWalletAddFundsVC: UIViewController {

    var creditCard: CreditCard?
    var paymentOption: Any?
    var applePaymentMethod: ApplePayPaymentMethod?
    
    var amount: Int = 0
    
    @IBOutlet weak var lblTitle: UILabel! {
        didSet {
            lblTitle.text = localizedString("title_how_much_like_to_add", comment: "")
        }
    }
    @IBOutlet weak var amountTextField: ElgrocerTextField! {
        didSet {
            amountTextField.setPlaceHolder(text: localizedString("aed", comment: ""))
            amountTextField.keyboardType = .asciiCapableNumberPad
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                amountTextField.textAlignment = .right
            }
            amountTextField.backgroundColor = ApplicationTheme.currentTheme.viewWhiteBGColor
            amountTextField.borderColor = ApplicationTheme.currentTheme.borderGrayColor
            amountTextField.borderWidth = 1.0
            
        }
    }
    @IBOutlet weak var addFundsButton: UIButton!{
        didSet {
            addFundsButton.layer.cornerRadius = addFundsButton.frame.height / 2.0
            addFundsButton.setTitle(localizedString("btn_add_funds", comment: ""), for: UIControl.State())
            addFundsButton.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        }
    }
    @IBOutlet var btnAddFundsBottomConstraint: NSLayoutConstraint!
    @IBOutlet var btnAddFundsTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setInitialAppearence()
    }
    
    private func setInitialAppearence() {
        self.setAddFundsButtonPosition(isKeyBoardVisible: false)
        self.setupNavigationAppearence()
        self.bindData()
    }
    
    private func bindData() {
    
    }
    
    func setupNavigationAppearence() {
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        //self.addBackButton()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
        self.title = localizedString("txt_add_funds", comment: "")
        
    }
    
    func setAddFundsButtonPosition(isKeyBoardVisible: Bool) {
        if isKeyBoardVisible {
            btnAddFundsBottomConstraint.isActive = false
            btnAddFundsTopConstraint.isActive = true
        }else {
            btnAddFundsBottomConstraint.isActive = true
            btnAddFundsTopConstraint.isActive = false
        }
    }
    
    @IBAction func addFundsTapped(_ sender: UIButton) {
        self.amount = Int(self.amountTextField.text ?? "") ?? 0
        if amount > 0 {
            MixpanelEventLogger.trackElwalletFundAddEnteredAddfundsClicked()
            self.startPaymentProcess()
        }else{
            //
           //  print("enter a valid amount please")
        }
        
    }
    
    func startPaymentProcess() {
        
        if self.paymentOption is CreditCard {
            
            if let card = self.paymentOption as? CreditCard,let selectedMethod = card.adyenPaymentMethod {
                SpinnerView.showSpinnerViewInView(self.view)
                AdyenManager.sharedInstance.makePaymentWithCard(controller: self, amount: NSDecimalNumber(value: self.amount), orderNum: "1234", method: selectedMethod, isForWallet: true )
                AdyenManager.sharedInstance.walletPaymentMade = {(error, response, adyenObj) in
                    SpinnerView.hideSpinnerView()
                    if error {
                        let vc = ElGrocerViewControllers.getPaymentSuccessVC()
                        vc.isSuccess = false
                        vc.ispushed = true
                        vc.controlerType = .payment
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                AdyenManager.sharedInstance.isPaymentMade = { (error, response,adyenObj) in
                    
                    SpinnerView.hideSpinnerView()
                    let vc = ElGrocerViewControllers.getPaymentSuccessVC()
                    if error {
                        if let resultCode = response["resultCode"] as? String {
                           //  print(resultCode)
                            vc.isSuccess = false
                            vc.ispushed = true
                            vc.controlerType = .payment
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }else {
                        //TODO: success case
                       //  print(" funds transfer successfully")
                        vc.isSuccess = true
                        vc.ispushed = true
                        vc.amount = "\(adyenObj.amount)"
                        vc.controlerType = .payment
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                        // Logging segment event for fund added
                        SegmentAnalyticsEngine.instance.logEvent(event: FundAddedEvent(paymentOption: PaymentOption.creditCard, amount: adyenObj.amount.doubleValue))
                        //show message/view here
                        //self.showConfirmationView()
                    }
                    
                }
            }
            
        } else if self.paymentOption is PaymentOption{
            guard let paymentOption = paymentOption as? PaymentOption else {
                return
            }
            if paymentOption == PaymentOption.voucher {
               //  print("voucher")
                return
            }
            if let selectedApplePayMethod = self.applePaymentMethod {
                SpinnerView.showSpinnerViewInView(self.view)
                AdyenManager.sharedInstance.makePaymentWithApple(controller: self, amount: NSDecimalNumber(value: self.amount), orderNum: "", method: selectedApplePayMethod, isForWallet: true)
                AdyenManager.sharedInstance.isPaymentMade = { (error, response, adyenObj) in
                    
                    SpinnerView.hideSpinnerView()
                    
                    if error {
                        if let resultCode = response["resultCode"] as? String {
                           //  print(resultCode)
                            let vc = ElGrocerViewControllers.getPaymentSuccessVC()
                            vc.isSuccess = false
                            vc.ispushed = true
                            vc.controlerType = .payment
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }else {
                        
                        let vc = ElGrocerViewControllers.getPaymentSuccessVC()
                        vc.isSuccess = true
                        vc.amount = "\(adyenObj.amount)"
                        vc.controlerType = .payment
                        vc.ispushed = true
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                        // Logging segment event for fund added
                        SegmentAnalyticsEngine.instance.logEvent(event: FundAddedEvent(paymentOption: PaymentOption.applePay, amount: adyenObj.amount.doubleValue))
                    }
                }
            }
            
        }
            
    }

}


extension ElWalletAddFundsVC : NavigationBarProtocol {
    
    override func backButtonClick() {
        MixpanelEventLogger.trackElwalletAddFundsClose()
        guard let navCount = self.navigationController else {
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        if  navCount.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }else{
             self.navigationController?.popViewController(animated: true)
        }
    }
    
    func backButtonClickedHandler() {
        backButtonClick()
    }
}

extension ElWalletAddFundsVC : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        setAddFundsButtonPosition(isKeyBoardVisible: true)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        setAddFundsButtonPosition(isKeyBoardVisible: false)
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text?.count == 0 {
            self.amount = 0
        } else {
            self.amount = Int("\(textField.text)") ?? 0// Int(textField.text)
        }
        setAddFundsButtonPosition(isKeyBoardVisible: false)
    }
    
}
