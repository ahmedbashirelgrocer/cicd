//
//  NoStoreView.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/08/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit


protocol NoStoreViewDelegate : class {
    // All optional
    func noDataButtonDelegateClick(_ state : actionState) -> Void
  
}

extension NoStoreViewDelegate {
    func noDataButtonDelegateClick(_ state : actionState) -> Void{}
}


enum actionState : Int {
    
    case defaultAction = 1
    case RefreshAction = 2
    
}


class NoStoreView: UIView {
    
     weak var delegate : NoStoreViewDelegate?
    
    @IBOutlet var imageCenterPosstion: NSLayoutConstraint!
    @IBOutlet var btnBottomConstraint: NSLayoutConstraint!
    class func loadFromNib() -> NoStoreView? {
        return self.loadFromNib(withName: "NoStoreView")
    }
    @IBAction func changeStoreButtonHandler(_ sender: Any) {
        self.delegate?.noDataButtonDelegateClick(self.state)
    }
    @IBOutlet var imgNoData: UIImageView!
    @IBOutlet var lblTopMsg: UILabel!
    @IBOutlet var lblExtraDetail: UILabel!
    @IBOutlet var btnNoData: AWButton!
    
    var state : actionState = .defaultAction
    
    func setUpApearence() {
        
        self.lblTopMsg.setH3SemiBoldDarkStyle()
        self.lblExtraDetail.setBody3RegSecondaryDarkStyle()
        self.btnNoData.setH4SemiBoldWhiteStyle()
        self.btnNoData.backgroundColor = UIColor.navigationBarColor()
        
    }

    func configureNoStore() {
        
        self.setUpApearence()
        self.imgNoData.image = UIImage(name: "pinIcon")
        self.lblTopMsg.text = NSLocalizedString("lbl_No_Grocey_in_Area", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("lbl_Chose_different_location", comment: "")
        self.btnNoData.setTitle(NSLocalizedString("lbl_Chose_different_location", comment: ""), for: .normal)
        self.btnNoData.isHidden = false
        self.state = .defaultAction
    }
    
    
    func configureNoSelectedStore() {
        
        self.setUpApearence()
        self.imgNoData.image = UIImage(name: "pinIcon")
        self.lblTopMsg.text = NSLocalizedString("lbl_No_Grocey_in_Area", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("lbl_Chose_different_location", comment: "")
        self.btnNoData.setTitle(NSLocalizedString("lbl_Chose_different_location", comment: ""), for: .normal)
        self.btnNoData.isHidden = false
        self.state = .defaultAction
    }
    
    func configureNoDefaultSelectedStore() {
        
        self.setUpApearence()
        self.imgNoData.image = UIImage(name: "noSelectedStore")
        self.lblTopMsg.text = NSLocalizedString("No_Selected_Store", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("No_Selected_Store_Detail", comment: "")
        self.btnNoData.setTitle(NSLocalizedString("No_Choose_The_Store", comment: ""), for: .normal)
        self.btnNoData.isHidden = false
        self.state = .defaultAction
    }
    
    func configureNoDefaultSelectedStoreForShopingList() {
        
        self.setUpApearence()
        self.imgNoData.image = UIImage(name: "noSelectedStoreForSHoppingList")
        self.lblTopMsg.text = NSLocalizedString("No_Selected_Store_ShopingList", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("No_Selected_Store_Detail_Cart", comment: "")
        self.btnNoData.isHidden = false
        self.btnNoData.setTitle(NSLocalizedString("No_Choose_The_Store", comment: ""), for: .normal)
        self.state = .defaultAction
    }
    
    func configureNoSavedRecipe() {
        
        self.setUpApearence()
        self.imgNoData.image = UIImage(name: "noSavedRecipeWhite") //"noSavedRecipe"
        self.lblTopMsg.text = NSLocalizedString("no_saved_recipe_title", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("no_saved_recipe_description", comment: "")
        self.btnNoData.isHidden = false
        self.btnNoData.setTitle(NSLocalizedString("title_recipe_list", comment: ""), for: .normal)
        self.state = .defaultAction
        self.backgroundColor = .tableViewBackgroundColor()
    }
    
    func configureNoRecipe() {
        
        self.setUpApearence()
        self.imgNoData.image = UIImage(name: "noSavedRecipeWhite") //"noSavedRecipe"
        self.lblTopMsg.text = NSLocalizedString("no_recipe_title", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("no_recipe_description", comment: "")
        self.btnNoData.isHidden = true
        self.state = .defaultAction
        self.backgroundColor = .tableViewBackgroundColor()
    }
    
    func configureNoSavedCar() {
        
        self.setUpApearence()
        self.imgNoData.image = UIImage(name: "noSavedCar")
        self.lblTopMsg.text = NSLocalizedString("lbl_no_saved_car", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("lbl_no_saved_car_description", comment: "")
        self.btnNoData.isHidden = true
        self.state = .defaultAction
    }
    
    func configureNoSavedCard() {
        
        self.setUpApearence()
        self.imgNoData.image = UIImage(name: "noSavedCard")
        self.lblTopMsg.text = NSLocalizedString("lbl_no_saved_card", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("lbl_no_saved_card_description", comment: "")
        self.btnNoData.isHidden = true
        self.state = .defaultAction
    }
 
    
    
    func configureNoDefaultSelectedStoreCart() {
        //You elGrocer cart is empty
        self.setUpApearence()
        self.imgNoData.image = UIImage(name: "NoSelectedStoreCart")
        self.lblTopMsg.text = NSLocalizedString("No_Selected_Store_Cart", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("No_Selected_Store_Detail", comment: "")
        self.btnNoData.isHidden = false
        self.btnNoData.setTitle(NSLocalizedString("No_Choose_The_Store", comment: ""), for: .normal)
        self.state = .defaultAction
    }
    
    func configureNoProducts() {
        //You elGrocer cart is empty
        self.setUpApearence()
        self.imgNoData.image = UIImage(name: "SearchNoData")
        self.lblTopMsg.text = NSLocalizedString("lbl_NoProductFound", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("No_Item_Cart", comment: "")
        self.btnNoData.setTitle(NSLocalizedString("lbl_Contnue_shopping", comment: ""), for: .normal)
        self.state = .defaultAction
        self.btnNoData.isHidden = false
        self.lblExtraDetail.isHidden = true
    }
    
    func configureNoTicket() {
        //You elGrocer cart is empty
        self.setUpApearence()
        self.imgNoData.image = UIImage(name: "SearchNoData")
        self.lblTopMsg.text = NSLocalizedString("no_ticket_title", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("no_ticket_descr", comment: "")
        self.btnNoData.setTitle(NSLocalizedString("btn_no_data_create_ticket", comment: ""), for: .normal)
        self.state = .defaultAction
        self.btnNoData.isHidden = false
    }
    func configureNoCart() {
        //You elGrocer cart is empty
        self.setUpApearence()
        self.imgNoData.image = UIImage(name: "NoSelectedStoreCart")
        self.lblTopMsg.text = NSLocalizedString("No_Selected_Store_Cart", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("No_Item_Cart", comment: "")
        self.btnNoData.isHidden = false
        self.btnNoData.setTitle(NSLocalizedString("lbl_Contnue_shopping", comment: ""), for: .normal)
        self.state = .defaultAction
    }
    
    
        func setNoDataForLocation () {
            self.setUpApearence()
            
            lblTopMsg.text = NSLocalizedString("lbl_No_Grocey_in_Area", comment: "")
    
            lblExtraDetail.text = NSLocalizedString("lbl_Chose_different_location", comment: "")
    
            btnNoData.setTitle(NSLocalizedString("lbl_Chose_different_location", comment: "") , for: .normal)
    
            self.state = .defaultAction
    
    
        }
    
        func setNoDataForRefresh(_ msg : String) {
            self.setUpApearence()
    
            lblTopMsg.text = msg
    
            lblExtraDetail.text = NSLocalizedString("error_10000", comment: "")
    
            btnNoData.setTitle(NSLocalizedString("lbl_Refresh", comment: "") , for: .normal)
    
            self.state = .RefreshAction
    
        }
    
    
    
    func configureNoSearchResult(_ string : String) {
        //You elGrocer cart is empty
    
        self.setUpApearence()
        let finalSearchString = " \"" + string + "\" "
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.imgNoData.image = UIImage(name: "SearchNoData")?.imageFlippedForRightToLeftLayoutDirection()
        }else {
            self.imgNoData.image = UIImage(name: "SearchNoData")
        }
        
        self.lblTopMsg.text = NSLocalizedString("lbl_Initail_SearchFind", comment: "") + finalSearchString  +  NSLocalizedString("lbl_atOurStores", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("lbl_NoDataSearch", comment: "")
        self.btnNoData.isHidden = false
        self.btnNoData.setTitle(NSLocalizedString("lbl_ReturnHome", comment: ""), for: .normal)
        
        let title = self.lblTopMsg.text ?? ""
        let attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(20) , NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()])
        let nsRange = NSString(string: title).range(of: finalSearchString , options: String.CompareOptions.caseInsensitive)
        if nsRange.location != NSNotFound {
            attributedString.addAttribute(NSAttributedString.Key.font , value: UIFont.SFProDisplaySemiBoldFont(20) , range: nsRange )
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor , value: UIColor.secondaryDarkGreenColor() , range: nsRange )
        }
        self.lblTopMsg.attributedText = attributedString
        self.state = .defaultAction
      
    }
    
    
    func configureNoSearchResultForStore(_ string : String) {
        //You elGrocer cart is empty
        
        self.setUpApearence()
        let finalSearchString = " \"" + string + "\" "
        self.imgNoData.image = UIImage(name: "SearchNoData")
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            imgNoData.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        self.lblTopMsg.text = NSLocalizedString("lbl_Initail_SearchFind", comment: "") + finalSearchString +  NSLocalizedString("lbl_atOurStores", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("lbl_NoDataStoreSearch", comment: "")
        self.btnNoData.isHidden = false
        self.btnNoData.setTitle(" " + NSLocalizedString("btn_NoSearch_noDataView", comment: ""), for: .normal)
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            let flippedImage = UIImage(name: "searchButtonWhite")?.imageFlippedForRightToLeftLayoutDirection() ?? UIImage(name: "searchButtonWhite")
            self.btnNoData.setImage(flippedImage, for: UIControl.State())
        }else {
            self.btnNoData.setImage(UIImage(name: "searchButtonWhite"), for: .normal)
        }
        
        self.btnNoData.tintColor = . white
        let title = self.lblTopMsg.text ?? ""
        let attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(20) , NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()])
        let nsRange = NSString(string: title).range(of: finalSearchString , options: String.CompareOptions.caseInsensitive)
        if nsRange.location != NSNotFound {
            attributedString.addAttribute(NSAttributedString.Key.font , value: UIFont.SFProDisplaySemiBoldFont(20) , range: nsRange )
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor , value: UIColor.secondaryDarkGreenColor() , range: nsRange )
        }
        self.lblTopMsg.attributedText = attributedString
        self.state = .defaultAction
        
    }
    
    
    
    func configureNoSearchResultForMoreStore(_ searchString : String) {
        //You elGrocer cart is empty
        
        self.setUpApearence()
        let finalSearchString = "\n \"" + searchString + "\"\n"
        self.imgNoData.image = UIImage(name: "SearchNoData")
        self.lblTopMsg.text = NSLocalizedString("lbl_Initail_SearchFind", comment: "") + finalSearchString +  NSLocalizedString("lbl_atOurStores", comment: "")
        self.lblExtraDetail.text = NSLocalizedString("lbl_NoDataSearch", comment: "")
        self.btnNoData.isHidden = false
        self.btnNoData.setTitle( NSLocalizedString("lbl_Contnue_shopping_s", comment: ""), for: .normal)
        self.btnNoData.setImage(UIImage(), for: .normal)
        self.btnNoData.tintColor = . white
        let title = self.lblTopMsg.text ?? ""
        let attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(20) , NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()])
        let nsRange = NSString(string: title).range(of: finalSearchString , options: String.CompareOptions.caseInsensitive)
        if nsRange.location != NSNotFound {
            attributedString.addAttribute(NSAttributedString.Key.font , value: UIFont.SFProDisplaySemiBoldFont(20) , range: nsRange )
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor , value: UIColor.secondaryDarkGreenColor() , range: nsRange )
        }
        self.lblTopMsg.attributedText = attributedString
        self.state = .defaultAction
        
    }
    
    
    
    
    
    

}
