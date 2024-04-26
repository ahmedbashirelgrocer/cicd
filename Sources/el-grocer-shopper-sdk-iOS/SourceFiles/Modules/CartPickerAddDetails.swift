//
//  CartPickerAddDetails.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 15/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import libPhoneNumber

enum CartCollectorType {
    case OrderCollector
    case AddNewCollector
}
class CartPickerAddDetails: UIViewController {
    
    @IBOutlet var collectorBackgroundView: UIView!
    @IBOutlet var lblHeading : UILabel!{
        didSet{
            lblHeading.setH3SemiBoldDarkStyle()
        }
    }
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnCross: UIButton!
    @IBOutlet var contactNameTextfield: ElgrocerTextField!{
        didSet{
            contactNameTextfield.layer.cornerRadius = 8
            contactNameTextfield.delegate = self
            contactNameTextfield.setBody1RegStyle()
            contactNameTextfield.setPlaceHolder(text: localizedString("contact_name_placeHolder", comment: ""))
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                contactNameTextfield.textAlignment = .right
            }
            
        }
    }
    @IBOutlet var mobileNumTextfield: ElgrocerTextField!{
        didSet{
            mobileNumTextfield.layer.cornerRadius = 8
            mobileNumTextfield.delegate = self
            mobileNumTextfield.setBody1RegStyle()
            mobileNumTextfield.setPlaceHolder(text: localizedString("mobile_num_placeHolder", comment: ""))
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                mobileNumTextfield.textAlignment = .right
            }
        }
    }
    @IBOutlet var btnCheckbox: UIButton!{
        didSet{
            btnCheckbox.setImage(UIImage(name: "CheckboxUnfilled"), for: .normal)
        }
    }
    @IBOutlet var lbl_save_details_future: UILabel! {
        didSet{
            lbl_save_details_future.text = localizedString("lbl_save_details_future", comment: "")
            lbl_save_details_future.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var btnConfirm: AWButton!
    @IBOutlet var mobileTopCOnstraint: NSLayoutConstraint!
    private lazy var phoneUtil: NBPhoneNumberUtil = NBPhoneNumberUtil(metadataHelper: NBMetadataHelper())
    var checked = false
    var collectorType : CartCollectorType = .AddNewCollector
    var currentVc : UIViewController?
    var priviousCollectorData = collector()
    var collectorSelected: ((_ collector : collector?)->Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.designBackGroundView()
        self.setupInitialAppearance()
        self.setupFontsAndColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpTextFieldConstraints()
        if priviousCollectorData.dbID != -1 {
            assignPriviousValues()
        }
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.btnBack.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    func assignPriviousValues(){
        self.contactNameTextfield.text = priviousCollectorData.name
        self.mobileNumTextfield.text = priviousCollectorData.phonenNumber
    }

    func designBackGroundView(){
        collectorBackgroundView.layer.cornerRadius = 12.0
        if #available(iOS 11.0, *) {
            collectorBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    func setUpTextFieldConstraints() {
        DispatchQueue.main.async {
            self.mobileTopCOnstraint.isActive = false
            self.mobileNumTextfield.topAnchor.constraint(equalTo: self.contactNameTextfield.lblError.bottomAnchor, constant: 16).isActive = true
            
//            self.mobileNumTextfield.setNeedsLayout()
//            self.mobileNumTextfield.layoutIfNeeded()
        }
       
        
    }
    func setupInitialAppearance(){
        switch collectorType {
        case .OrderCollector :
            self.btnConfirm.setTitle(localizedString("btn_Order_Collector", comment: ""), for: .normal)
            self.lblHeading.text = localizedString("lbl_Order_Collector", comment: "")
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                self.lblHeading.textAlignment = .right
            }else {
                self.lblHeading.textAlignment = .left
            }
            
            self.btnBack.visibility = .goneY
        default:
            self.btnConfirm.setTitle(localizedString("btn_Add_Order_Collector", comment: ""), for: .normal)
            self.lblHeading.text = localizedString("lbl_Add_Order_Collector", comment: "")
            self.lblHeading.textAlignment = .center
            self.btnBack.visibility = .visible
        }
    }
    func setupFontsAndColors(){
        //Labels
        self.lblHeading.font = UIFont.SFProDisplaySemiBoldFont(20)
        self.lblHeading.textColor = UIColor.newBlackColor()
        self.lbl_save_details_future.font = UIFont.SFProDisplayNormalFont(14)
        self.lbl_save_details_future.textColor = UIColor.newBlackColor()
        //textFields
        self.mobileNumTextfield.font = UIFont.SFProDisplayNormalFont(17)
        self.mobileNumTextfield.textColor = UIColor.newBlackColor()
        self.contactNameTextfield.font = UIFont.SFProDisplayNormalFont(17)
        self.contactNameTextfield.textColor = UIColor.newBlackColor()
        // buttons
        self.btnConfirm.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(17)
        self.btnConfirm.titleLabel?.textColor = UIColor.white
        self.btnConfirm.setBackgroundColor(ApplicationTheme.currentTheme.buttonEnableBGColor, forState: .normal)
        self.btnConfirm.layer.cornerRadius =  28
    }
    @IBAction func btnConfirmHandler(_ sender: Any) {
        
        guard self.contactNameTextfield.text?.count ?? 0 > 0 && self.contactNameTextfield.text?.count ?? 0 < 51 else {
            self.contactNameTextfield.showError(message: localizedString("error_enter_contactName", comment: ""))
            return
        }
        guard self.mobileNumTextfield.text?.count ?? 0 > 0 && self.mobileNumTextfield.text?.count ?? 0 < 16  else {
            self.mobileNumTextfield.showError(message: localizedString("error_enter_contact", comment: ""))
            return
        }
        
        if self.collectorType == .AddNewCollector {
            self.btnConfirm.showLoading()
            ElGrocerApi.sharedInstance.createNewCollector(name: self.contactNameTextfield.text ?? "" , phoneNumber: self.mobileNumTextfield.text ?? "" , isDeleted: !checked) { (result) in
                self.btnConfirm.hideLoading()
                switch result {
                    case .success(let response):
                       elDebugPrint(response)
                    
                        let newCreatedCollector = collector.init(name: self.contactNameTextfield.text ?? "" , phonenNumber: self.mobileNumTextfield.text ?? "" , dbID: ((response["data"] as? NSDictionary)?["id"] as? Int) ?? -1)
                    
//                    if let closure = self.collectorSelected{
//                        closure(newCreatedCollector)
//                    }
                        /*
                        if self.currentVc is MyBasketViewController {
                            let basketVc = self.currentVc as! MyBasketViewController
                            basketVc.dataHandler.collectorList.append(newCreatedCollector)
                            basketVc.dataHandler.selectedCollector = newCreatedCollector
                            if self.checked{
                                UserDefaults.setCurrentSelectedCollector(newCreatedCollector.dbID)
                            }
                            basketVc.collectorDataLoaded()
                        }*/
                        if self.currentVc is MyBasketPlaceOrderVC {
                            let basketVc = self.currentVc as! MyBasketPlaceOrderVC
                            basketVc.dataHandler.collectorList.append(newCreatedCollector)
                            basketVc.dataHandler.selectedCollector = newCreatedCollector
                            if self.checked{
                                UserDefaults.setCurrentSelectedCollector(newCreatedCollector.dbID)
                            }
                            basketVc.checkouTableView.reloadDataOnMain()
                        }
                        self.btnCrossHandler("")
                    case .failure(let error):
                        error.showErrorAlert()
                }
            }
            
        }else{
            let id = priviousCollectorData.dbID ?? -1
            self.btnConfirm.showLoading()
            ElGrocerApi.sharedInstance.editCollector(name: self.contactNameTextfield.text ?? "" , phoneNumber: self.mobileNumTextfield.text ?? "" , id: id) { (result) in
                self.btnConfirm.hideLoading()
                switch result {
                    case .success(let response):
                       elDebugPrint(response)
                    let newCreatedCollector = collector.init(name: self.contactNameTextfield.text ?? "" , phonenNumber: self.mobileNumTextfield.text ?? "" , dbID: id)
                    /*
                        if self.currentVc is MyBasketViewController {
                            let basketVc = self.currentVc as! MyBasketViewController
                            
                            basketVc.dataHandler.selectedCollector = newCreatedCollector
                            if self.checked{
                                UserDefaults.setCurrentSelectedCollector(newCreatedCollector.dbID)
                            }
                            basketVc.collectorDataLoaded()
                        }*/
                        if self.currentVc is MyBasketPlaceOrderVC {
                            let basketVc = self.currentVc as! MyBasketPlaceOrderVC
                            basketVc.dataHandler.collectorList.append(newCreatedCollector)
                            basketVc.dataHandler.selectedCollector = newCreatedCollector
                            if self.checked{
                                UserDefaults.setCurrentSelectedCollector(newCreatedCollector.dbID)
                            }
                            basketVc.checkouTableView.reloadDataOnMain()
                        }
                        self.btnCrossHandler("")
                    case .failure(let error):
                        error.showErrorAlert()
                }
            }
        }
        
        
    }
    @IBAction func btnCheckboxHandler(_ sender: Any) {
        if checked{
            btnCheckbox.setImage(UIImage(name: "CheckboxUnfilled"), for: .normal)
            checked = false
        }else{
            btnCheckbox.setImage(UIImage(name: "CheckboxFilled"), for: .normal)
            checked = true
        }
    }
    @IBAction func btnCrossHandler(_ sender: Any) {
        let isNeedTodissmisTwice =  self.presentingViewController is OrderCollectorDetailsVC
        if isNeedTodissmisTwice {
            self.presentingViewController?.presentingViewController?.presentedViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            return
        }
        self.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    @IBAction func btnBackHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
extension CartPickerAddDetails : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        var fullString = textField.text ?? ""
        fullString.append(string)
        
        if (textField == contactNameTextfield) {
            return fullString.count < 51
        }
        if (textField == mobileNumTextfield) {
            
            return fullString.count < 16
            
//            var fullString = textField.text ?? ""
//            fullString.append(string)
//            if range.length == 1 {
//                textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
//            } else {
//                textField.text = format(phoneNumber: fullString)
//            }
//            return false
        }
        return true
    }
    
    func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
        guard !phoneNumber.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")
        
        if number.count > 15 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 15)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }
        
        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }
        
        if number.count < 7 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)
            
        } else {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
        }
        
        return number
    }
    
    
}
