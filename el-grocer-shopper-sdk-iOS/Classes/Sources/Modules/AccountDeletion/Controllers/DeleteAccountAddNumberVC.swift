//
//  DeleteAccountAddNumberVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 27/06/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class DeleteAccountAddNumberVC: UIViewController, NavigationBarProtocol {

    @IBOutlet var lblConfirmMobileNum: UILabel! {
        didSet {
            lblConfirmMobileNum.textAlignment = .center
            lblConfirmMobileNum.setH3SemiBoldDarkStyle()
            lblConfirmMobileNum.text = localizedString("lbl_confirm_mobile_num", comment: "")
        }
    }
    @IBOutlet var lblPleaseEnterMobileNum: UILabel! {
        didSet {
            lblPleaseEnterMobileNum.numberOfLines = 0
            lblPleaseEnterMobileNum.textAlignment = .center
            lblPleaseEnterMobileNum.setBody2RegDarkStyle()
            lblPleaseEnterMobileNum.text = localizedString("lbl_please_enter_mobile", comment: "")
        }
    }
    @IBOutlet var countryCodeBGView: UIView! {
        didSet {
            countryCodeBGView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 8)
        }
    }
    @IBOutlet var lblFlagCountryCode: UILabel!
    @IBOutlet var btnSelectCountry: UIButton!
    @IBOutlet var phoneNumBGView: UIView! {
        didSet {
            phoneNumBGView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 8)
        }
    }
    @IBOutlet var phoneNumberTextField: FPNTextField! {
        didSet {
            phoneNumberTextField.hasPhoneNumberExample = false // true by default
            phoneNumberTextField.parentViewController = self
            phoneNumberTextField.layer.cornerRadius = 8.0
            phoneNumberTextField.placeholder = localizedString("enter_mobile_num_placeholder", comment: "")
            phoneNumberTextField.setFlag(for: FPNOBJCCountryKey.AE)
            phoneNumberTextField.customDelegate = self
            phoneNumberTextField.flagSize = CGSize.init(width: 30, height: 30)
            phoneNumberTextField.flagButton.isHidden = true
            phoneNumberTextField.leftView?.visibility = .goneX
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                phoneNumberTextField.textAlignment = .right
            }
        }
    }
    @IBOutlet var btnConfirmBGView: AWView! {
        didSet {
            btnConfirmBGView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 28)
        }
    }
    @IBOutlet var btnConfirm: UIButton! {
        didSet {
            btnConfirm.setTitle(localizedString("btn_continue_delete_account_add_num", comment: ""), for: UIControl.State())
            btnConfirm.setH4SemiBoldWhiteStyle(true)
        }
    }
    
    var finalPhoneNumber: String = ""
    var finalFormatedPhoneNumber: String = ""
    var priviousReason: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setInitialAppearence()
        validatePhoneNumAndSetButtonAppearance()
    }
    //MARK: Appearence
    func setInitialAppearence(){
        
        self.view.backgroundColor = .navigationBarWhiteColor()
        
        if self.navigationController is ElGrocerNavigationController{
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.hideSeparationLine()
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.navigationBar.topItem?.title = localizedString("delete_account", comment: "")
            self.title = localizedString("delete_account", comment: "")
            self.addBackButton(isGreen: false)
        }  
    }
    func backButtonClickedHandler() {
        self.navigationController?.popViewController(animated: true)
    }
    override func backButtonClick() {
        backButtonClickedHandler()
    }

    @IBAction func btnSelectCountry(_ sender: Any) {
        fpnDisplayCountryList()
    }
    @IBAction func btnConfirmHandler(_ sender: Any) {
//        +971558245565
        guard self.finalPhoneNumber.count > 0 else {
            return
        }
        self.sendOTP(phoneNum: self.finalPhoneNumber)
    }
    func fpnDisplayCountryList() {
        phoneNumberTextField.showSearchController()
    }
    private func getFlag(from countryCode: String) -> String {
        countryCode
            .unicodeScalars
            .map({ 127397 + $0.value })
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
    func validatePhoneNumberAndSetPasswordTextFieldAppearance(_ isValid : Bool = false) {
        if  isValid == false {
            self.phoneNumBGView.layer.borderColor = UIColor.redValidationErrorColor().cgColor
            self.phoneNumBGView.layer.borderWidth = 1
        } else {
            self.phoneNumBGView.layer.borderColor = UIColor.green.cgColor
            self.phoneNumBGView.layer.borderWidth = 0
        }
        validatePhoneNumAndSetButtonAppearance(isValid)
    }
    func validatePhoneNumAndSetButtonAppearance(_ isValid : Bool = false) {
        if  isValid == false {
            self.btnConfirmBGView.backgroundColor = .disableButtonColor()
            self.btnConfirm.isUserInteractionEnabled = false
        } else {
            self.btnConfirmBGView.backgroundColor = .navigationBarColor()
            self.btnConfirm.isUserInteractionEnabled = true
        }
    }
    
    func sendOTP(phoneNum: String) {
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        AccountDeletionManager.sendOTP(phoneNum: phoneNum) { responseDict in
           elDebugPrint(responseDict)
            SpinnerView.hideSpinnerView()
            let success = responseDict["status"] as? String ?? ""
            if success.elementsEqual("success") {
                let data = responseDict["data"] as? NSDictionary ?? [:]
                let message = data["message"] as? String ?? ""
                if message.elementsEqual("ok") {
                    Thread.OnMainThread {
                        self.navigateToVerifyCode(phoneNum: phoneNum)
                    }
                }
            }
        }
    }

    func navigateToVerifyCode(phoneNum: String) {
        let vc = ElGrocerViewControllers.getDeleteAccountVerifyCodeVC()
        vc.priviousPhoneNum = phoneNum
        vc.priviousReason = self.priviousReason
        self.navigationController?.pushViewController(vc, animated: true)
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
extension DeleteAccountAddNumberVC : FPNTextFieldCustomDelegate {

    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
       elDebugPrint(name, dialCode, code) // Output "France", "+33", "FR"
        ElGrocerUtility.sharedInstance.delay(0.5) { [unowned self] in
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                self.lblFlagCountryCode.text =  dialCode + " " + self.getFlag(from: code)
            }else {
                self.lblFlagCountryCode.text = self.getFlag(from: code) + " " + dialCode
            }
            self.phoneNumberTextField.becomeFirstResponder()
        }
        
    }
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if isValid {
            // Do something...
            self.finalPhoneNumber =   textField.getFormattedPhoneNumber(format: .E164) ?? ""
            self.finalFormatedPhoneNumber = textField.getFormattedPhoneNumber(format: .International) ?? ""
            textField.resignFirstResponder()
            
        } else {
            // Do something...
            self.finalPhoneNumber = ""
        }
        self.validatePhoneNumberAndSetPasswordTextFieldAppearance(isValid)
        
        elDebugPrint(isValid)
        elDebugPrint(finalPhoneNumber)
    }
}
