//
//  OrderStatusDetailCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 16/06/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

enum statusDetailType {
    case pickrInfoWithoutChat
    case chatButton
    case callButton
    case orderDetailButton
    case location
    case carDetails
    case collectorDetails
}

let OrderStatusDetailCellHeight : CGFloat = 75

class OrderStatusDetailCell: UITableViewCell {

    @IBOutlet var statusImageView: UIImageView!
    @IBOutlet var lblHeading: UILabel!{
        didSet{
            lblHeading.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var lblDetails: UILabel!{
        didSet{
            lblDetails.setBody3RegDarkStyle()
        }
    }
    
    @IBOutlet var chatWithPickerBGView: AWView!
    @IBOutlet var btnChatWithPicker: AWButton!{
        didSet{
            btnChatWithPicker.setCornerRadiusStyle()
            btnChatWithPicker.setCaption1BoldWhiteStyle()
            btnChatWithPicker.layer.backgroundColor = UIColor.navigationBarColor().cgColor
            //self.chatWithPickerBGView.isHidden = true
        }
    }
    @IBOutlet var orderDetailsBGView: AWView!
    @IBOutlet var imgOrderDetailsForward: UIImageView!
    @IBOutlet var lblOrderDetails: UILabel!{
        didSet{
            lblOrderDetails.setBody3BoldUpperStyle(true)
            self.lblOrderDetails.text = NSLocalizedString("lbl_Order_Details", comment: "")
        }
    }
    @IBOutlet var btnOrderDetails: UIButton!
    
    
    var cellType : statusDetailType = .pickrInfoWithoutChat
    var orderdetailAction: ((_ isOrderDetail : Bool?)->Void)?
    var chatwithPickerAction: ((_ isChatWithPicker : Bool?)->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.setAppearence(cellType: cellType)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    
    func setAppearence(cellType : statusDetailType){
        
        if cellType == .pickrInfoWithoutChat {
            self.chatWithPickerBGView.isHidden = true // currently chat is not included
            self.orderDetailsBGView.isHidden = true
            self.btnChatWithPicker.setTitle(NSLocalizedString("title_chat_with_Picker", comment: ""), for: UIControl.State())
            self.statusImageView.image = UIImage(name: "riderOrPicker")
            self.lblHeading.setBody3BoldUpperStyle(false)
            self.lblDetails.setBody3RegDarkStyle()
        }else if cellType == .chatButton {
            
            self.chatWithPickerBGView.visibility = .visible
            self.orderDetailsBGView.visibility = .visible
            self.chatWithPickerBGView.isHidden = false
            self.orderDetailsBGView.isHidden = true
            self.btnChatWithPicker.setTitle(NSLocalizedString("title_chat_with_Picker", comment: ""), for: UIControl.State())
            self.statusImageView.image = UIImage(name: "riderOrPicker")
            self.lblHeading.setBody3BoldUpperStyle(false)
            self.lblDetails.setBody3RegDarkStyle()
            
        }else if cellType == .callButton {
            
            self.chatWithPickerBGView.isHidden = false
            self.orderDetailsBGView.isHidden = true
            self.btnChatWithPicker.setTitle("CALL THE DRIVER", for: UIControl.State())
            self.statusImageView.image = UIImage(name: "riderOrPicker")
            
            self.lblHeading.setBody3BoldUpperStyle(false)
            self.lblDetails.setBody3RegDarkStyle()
            
//            self.lblHeading.text = "Muhammad"
//            self.lblDetails.text = "elGrocer Picker"
            
        }else if cellType == .orderDetailButton {
            
            self.chatWithPickerBGView.visibility = .visible
            self.orderDetailsBGView.visibility = .visible
            self.chatWithPickerBGView.isHidden = true
            self.orderDetailsBGView.isHidden = false
            self.orderDetailsBGView.visibility = .visible
            self.lblOrderDetails.text = NSLocalizedString("lbl_Order_Details", comment: "")
            self.statusImageView.image = UIImage(name: "storeDetailsIcon")
            
            self.lblHeading.setBody3BoldUpperStyle(false)
            self.lblDetails.setBody3RegDarkStyle()
            
            if ElGrocerUtility.sharedInstance.isArabicSelected(){
                imgOrderDetailsForward.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            
//            self.lblHeading.text = "Prime Gourmet"
//            self.lblDetails.text = "Order # 13587313011200"
            
        }else if cellType == .location{
            
            self.chatWithPickerBGView.visibility = .goneX
            self.orderDetailsBGView.visibility = .goneX
            self.statusImageView.image = UIImage(name: "locationDetailsIcon")

            
        }else if cellType == .carDetails{
            
            self.chatWithPickerBGView.visibility = .goneX
            self.orderDetailsBGView.visibility = .goneX
            self.statusImageView.image = UIImage(name: "carDetailsIcon")
//            self.lblHeading.text = "Car details:"
//            self.lblDetails.text = "Q63642, SUV, Mercedes, Silver"
            
        }else if cellType == .collectorDetails{
            
            self.chatWithPickerBGView.visibility = .goneX
            self.orderDetailsBGView.visibility = .goneX
            self.statusImageView.image = UIImage(name: "collectorDetailsIcon")
//            self.lblHeading.text = "Order collector details:"
//            self.lblDetails.text = "James, 055 123 45 66"
            
        }
    }
    
    func configureStoreNameAndOrderId(_ storeName : String , _ orderId : String) {
        
        self.lblHeading.text = storeName
        self.lblDetails.text = NSLocalizedString("order_lbl_numner", comment: "") + " "  + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: orderId)
        
    }
    
    func configureLocationName(_ locationName : String ) {
        
        self.lblHeading.text = locationName
        self.lblDetails.text = ""
        
        
    }
    
    func configurePickerName(_ pickerName : String ) {
        
        if pickerName != ""{
            self.lblHeading.text = pickerName
        }else{
            self.lblHeading.text = NSLocalizedString("txt_Picker", comment: "")
        }
        
        self.lblDetails.text = NSLocalizedString("txt_elGrocer_Picker", comment: "")
        
        
    }
    
    func configureCandCLocation(_ locationAddres : String) {

        self.lblHeading.text = NSLocalizedString("title_self_collection_point", comment: "")
        self.lblDetails.attributedText = self.setBoldForText(CompleteValue: locationAddres, textForAttribute: locationAddres)
        
    }
    
    func configureCandCCollectorDetails(_ name : String , phoneNumber : String) {
        
        self.lblHeading.text = NSLocalizedString("title_order_collector_details", comment: "")
        let finalName = name + ", "
        let text = finalName + phoneNumber
        self.lblDetails.attributedText = self.setBoldForText(CompleteValue: text, textForAttribute: finalName)

    }
    
    func configureCandCCarDetails(_ platNumber : String , model : String , type : String , color : String) {
        
        self.lblHeading.text = NSLocalizedString("title_car_details", comment: "")
        let text = platNumber + ", " +  model  + ", " + type  + ", " + color
        self.lblDetails.attributedText = self.setBoldForText(CompleteValue: text, textForAttribute: platNumber)
        
    }
    
    
    @IBAction func btnOrderDetailAction(_ sender: Any) {
        
        if let clouser = orderdetailAction {
            clouser(true)
        }
    }
    @IBAction func chatWithPicker(_ sender: Any) {
        if let clouser = chatwithPickerAction {
            clouser(true)
        }
    }
    
    //Mark:- Helpers
    
    //for setting multiple font in a label
    func setBoldForText(CompleteValue : String , textForAttribute: String) -> NSMutableAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: CompleteValue)
        let range: NSRange = attributedString.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        let attrs = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
        attributedString.addAttributes(attrs, range: range)
        return attributedString
    }

}
