//
//  StoreHeaderView.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 15/11/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

class StoreHeaderView: UIView {

    @IBOutlet var bGView: UIView!{
        didSet{
            bGView.backgroundColor = .navigationBarColor()
        }
    }
    @IBOutlet var groceryBGView: UIView!{
        didSet{
            groceryBGView.backgroundColor = .navigationBarColor()
        }
    }
    @IBOutlet var imgGrocery: UIImageView!{
        didSet{
            imgGrocery.backgroundColor = .navigationBarWhiteColor()
            imgGrocery.roundWithShadow(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 8, withShadow: false)
        }
    }
    @IBOutlet var lblGroceryName: UILabel!{
        didSet{
            lblGroceryName.setH3SemiBoldWhiteStyle()
        }
    }
    @IBOutlet var imgDeliverySlot: UIImageView!{
        didSet{
            imgDeliverySlot.image = UIImage(named: "clockWhite")
        }
    }
    @IBOutlet var lblGroceryDeliverySlot: UILabel!{
        didSet{
            lblGroceryDeliverySlot.setSubHead1SemiboldWhiteStyle()
        }
    }
    @IBOutlet var searchSuperBGView: UIView!{
        didSet{
            searchSuperBGView.backgroundColor = .navigationBarColor()
        }
    }
    @IBOutlet var searchBGView: UIView!{
        didSet{
            searchBGView.backgroundColor = .navigationBarWhiteColor()
            searchBGView.roundWithShadow(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 22, withShadow: false)
            searchBGView.layer.borderWidth = 1
            searchBGView.layer.borderColor = UIColor.newBorderGreyColor().cgColor
        }
    }
    @IBOutlet var imgSearch: UIImageView!{
        didSet{
            imgSearch.image = UIImage(named: "search-SearchBar")
        }
    }
    @IBOutlet var txtSearchBar: UITextField!{
        didSet{
            txtSearchBar.placeholder = NSLocalizedString("search_placeholder_store_header", comment: "")
            txtSearchBar.setPlaceHolder(text: NSLocalizedString("search_placeholder_store_header", comment: ""))
            if ElGrocerUtility.sharedInstance.isArabicSelected(){
                txtSearchBar.textAlignment = .right
            }else{
                txtSearchBar.textAlignment = .left
            }
        }
    }
    
    @IBOutlet var shoppingListBGView: UIView!{
        didSet{
            shoppingListBGView.backgroundColor = .navigationBarColor()
        }
    }
    @IBOutlet var imgShoppingList: UIImageView!{
        didSet{
            imgShoppingList.image = UIImage(named: "addShoppingListYellow")
        }
    }
    @IBOutlet var btnlblShopping: UILabel!{
        didSet{
            btnlblShopping.text = NSLocalizedString("btn_shopping_list_title", comment: "")
            btnlblShopping.setBody3SemiBoldYellowStyle()
        }
    }
    @IBOutlet var btnShoppingList: UIButton!{
        didSet{
            btnShoppingList.setTitle("", for: UIControl.State())
        }
    }
    @IBOutlet var btnLblHelp: UILabel!{
        didSet{
            btnLblHelp.text = NSLocalizedString("btn_help", comment: "")
            btnLblHelp.setBody3SemiBoldWhiteStyle()
        }
    }
    @IBOutlet var imgHelp: UIImageView!{
        didSet{
            imgHelp.image = UIImage(named: "nav_chat_icon")
        }
    }
    @IBOutlet var btnHelp: UIButton!

    let headerMaxHeight: CGFloat = 155
    
    typealias tapped = (_ isShoppingTapped: Bool)-> Void
    var shoppingListTapped: tapped?
    
    class func loadFromNib() -> StoreHeaderView? {
        return self.loadFromNib(withName: "StoreHeaderView")
    }
    
    override func awakeFromNib() {
        setInitialUI(isExpanded: false)
        super.awakeFromNib()
        hideSlotImage()
    }

    func setInitialUI(isExpanded: Bool = false){
        if isExpanded{
            self.searchSuperBGView.visibility = .visible
            self.shoppingListBGView.visibility = .visible
            self.groceryBGView.visibility = .visible
        }else{
            self.searchSuperBGView.visibility = .visible
            self.shoppingListBGView.visibility = .gone
            self.groceryBGView.visibility = .gone
        }
    }
    
    @IBAction func btnShoppingListHandler(_ sender: Any) {
        if let closure = self.shoppingListTapped{
            closure(true)
        }
    }
    @IBAction func btnHelpHandler(_ sender: Any) {
        if let closure = self.shoppingListTapped{
            closure(false)
        }
    }
    
    @IBAction func btnChangeSlotHandler(_ sender: Any) {
    }
    func configureHeader(grocery: Grocery){
        self.lblGroceryName.text = grocery.name
        self.setDeliveryDate(grocery.genericSlot ?? "")
        self.AssignImage(imageUrl: grocery.smallImageUrl ?? "")
    }
    
    func AssignImage(imageUrl: String){
        if imageUrl != nil && imageUrl.range(of: "http") != nil {
            
            self.imgGrocery.sd_setImage(with: URL(string: imageUrl), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.imgGrocery, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.imgGrocery.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }
    
    func setDeliveryDate (_ data : String) {
        
        let dataA = data.components(separatedBy: CharacterSet.newlines)
        var attrs1 = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Light", size: 11) , NSAttributedString.Key.foregroundColor : self.lblGroceryDeliverySlot.textColor ]
        if dataA.count == 1 {
            if self.lblGroceryDeliverySlot.text?.count ?? 0 > 13 {
                attrs1 = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Light", size: 9) , NSAttributedString.Key.foregroundColor : self.lblGroceryDeliverySlot.textColor ]
                 let attributedString1 = NSMutableAttributedString(string: dataA[0], attributes:attrs1 as [NSAttributedString.Key : Any])
                 self.lblGroceryDeliverySlot.attributedText = attributedString1
                return
            }
        }
        let attrs2 = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Semibold", size: 11) , NSAttributedString.Key.foregroundColor : self.lblGroceryDeliverySlot.textColor]
        
        let attributedString1 = NSMutableAttributedString(string:dataA[0], attributes:attrs1 as [NSAttributedString.Key : Any])
        let timeText = dataA.count > 1 ? dataA[1] : ""
        let attributedString2 = NSMutableAttributedString(string:"\n\(timeText)", attributes:attrs2 as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)
        self.lblGroceryDeliverySlot.attributedText = attributedString1
        
        self.lblGroceryDeliverySlot.minimumScaleFactor = 0.5;
        
    }
    
    fileprivate func hideSlotImage(_ isHidden: Bool = true){
        if isHidden{
            self.imgDeliverySlot.visibility = .goneX
        }else{
            self.imgDeliverySlot.visibility = .visible
        }
    }
    
}

extension StoreHeaderView : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == txtSearchBar {
            if let topVc = UIApplication.topViewController() {
                if let mainVc = topVc as? MainCategoriesViewController {
                    mainVc.navigationBarSearchTapped()
                }
            }
            return false
        }
        return true
    }
    
    
}
