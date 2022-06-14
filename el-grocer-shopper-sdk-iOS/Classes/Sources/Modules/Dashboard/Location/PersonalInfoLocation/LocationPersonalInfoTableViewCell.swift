//
//  LocationPersonalInfoTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 24/11/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import FlagPhoneNumber
class LocationPersonalInfoTableViewCell: UITableViewCell , AWSegmentViewProtocol {
    
    var indexSelected: ((Int)->Void)?
    var buttonClick: (()->Void)?
    @IBOutlet var txtMobileNumber: ElgrocerTextField! {
        didSet {
            txtMobileNumber.dtLayer.backgroundColor = UIColor.navigationBarWhiteColor().cgColor
        }
    }
    @IBOutlet var txtShopperName: ElgrocerTextField! {
        didSet {
            txtShopperName.dtLayer.backgroundColor = UIColor.navigationBarWhiteColor().cgColor
        }
    }
    @IBOutlet var segmenntCollectionView: AWSegmentView! {
        didSet {
            segmenntCollectionView.segmentViewType = .editLocation
            segmenntCollectionView.commonInit()
        }
    }
    

    @IBOutlet var lblChoseLocation: UILabel!{
        didSet {
            lblChoseLocation.text = NSLocalizedString("lbl_choose_nick", comment: "")
        }
    }
    @IBOutlet var btnDone: AWButton!{
        didSet {
            btnDone.setTitle( NSLocalizedString("lbl_save_changes", comment: "") , for: .normal)
        }
    }
    @IBOutlet var lblPersonalInfo: UILabel!{
        didSet {
            lblPersonalInfo.text = NSLocalizedString("lbl_personal", comment: "")
        }
    }
    @IBOutlet var viewName: AWView!
    @IBOutlet var viewPhoneNumber: AWView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        txtMobileNumber.delegate = self
        txtShopperName.delegate = self
        setInitialAppearence()
    }

    func setInitialAppearence() {
        self.backgroundColor = .textfieldBackgroundColor()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureView (_ segmentData : [Dictionary<String, Any>] , index : NSIndexPath , editScreenState : editLocationState) {
        segmenntCollectionView.lastSelection = index as IndexPath
        let array = segmentData.compactMap {$0["name"] }
        segmenntCollectionView.refreshWith(dataA: array as! [String])
        segmenntCollectionView.segmentDelegate = self
        
   
        
        txtMobileNumber.placeholder = NSLocalizedString("lbl_MobileNumber_location", comment: "")
        txtShopperName.placeholder = NSLocalizedString("lbl_Name_location", comment: "")
        
        self.txtMobileNumber.attributedPlaceholder = NSAttributedString.init(string: self.txtMobileNumber.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderTextColor()])
        self.txtShopperName.attributedPlaceholder = NSAttributedString.init(string: self.txtShopperName.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderTextColor()])
        
        
        if editScreenState == .isForSignUp {
            self.btnDone.setTitle(NSLocalizedString("btn_add_address_alert_title", comment: ""), for: .normal)
        }else if editScreenState == .isForAddNew {
             self.btnDone.setTitle(NSLocalizedString("btn_add_address_alert_title", comment: ""), for: .normal)
        }else if editScreenState == .isFromEdit {
              self.btnDone.setTitle(NSLocalizedString("lbl_save_changes", comment: "") , for: .normal)
        }else {
             self.btnDone.setTitle(NSLocalizedString("lbl_delivery", comment: ""), for: .normal)
        }
        
        
        
        
        
        
    }
    @IBAction func nextAction(_ sender: Any) {
        if let clouser =  self.buttonClick {
            
            if self.txtMobileNumber.text?.count == 0 {
                //self.viewPhoneNumber.layer.borderWidth = 1
                //self.viewPhoneNumber.layer.borderColor = UIColor.redValidationErrorColor().cgColor
                self.txtMobileNumber.showError(message: "Please enter your mobile number.")
            }
            if self.txtShopperName.text?.count == 0 {
                //self.viewName.layer.borderWidth = 1
                //self.viewName.layer.borderColor = UIColor.redValidationErrorColor().cgColor
                self.txtMobileNumber.showError(message: "Please enter your name.")
            }
            
            clouser()
        }
    }
    
    func subCategorySelectedWithSelectedIndex(_ selectedSegmentIndex:Int) {
        if let clouser = self.indexSelected {
           clouser(selectedSegmentIndex)
        }
        
    }
    
}
extension LocationPersonalInfoTableViewCell : UITextFieldDelegate {
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
        if textField == self.txtMobileNumber {
            if newText.count < 18 {
                return true
            }
         return false
        }
        if newText.count < 31 {
            return true
        }
        return false
        
    }
    
    
}
