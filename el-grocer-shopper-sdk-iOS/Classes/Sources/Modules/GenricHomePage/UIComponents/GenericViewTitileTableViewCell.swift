//
//  GenericViewTitileTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
let KGenericViewTitileTableViewCell = "GenericViewTitileTableViewCell"
let KGenericViewTitileTableViewCellHeight : CGFloat = 27
class GenericViewTitileTableViewCell: UITableViewCell {
    
    
    var isTitleOnly : Bool = false {
        
        didSet{
            
            guard viewAllWidth != nil else {return}
            
            if isTitleOnly {
                viewAllWidth.constant = 0
            }else{
                viewAllWidth.constant = 80
            }
            
            self.layoutIfNeeded()
            self.setNeedsLayout()
        }
        
    }

    var viewAllAction: (()->Void)?
    @IBOutlet var lblTopHeader: UILabel!  {
        didSet {
            lblTopHeader.setH4SemiBoldStyle()
            if let lng = UserDefaults.getCurrentLanguage(){
                if lng == "ar"{
                    self.lblTopHeader.textAlignment = .right
                }else{
                    self.lblTopHeader.textAlignment = .left
                }
            }
        }
    }
    
    @IBOutlet var viewAllWidth: NSLayoutConstraint!
    @IBOutlet var viewAll: AWView!
    @IBOutlet var rightButtonText: UILabel! {
        didSet {
            rightButtonText.setCaptionOneBoldUpperCaseGreenButtonStyleWithFontScale14()
            rightButtonText.text = localizedString("view_more_title", comment: "")
        }
    }
    @IBOutlet var arrowImage: UIImageView! {
        didSet{
            arrowImage.image =  UIImage(name: sdkManager.isShopperApp ? "arrowRight" : "SettingArrowForward")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell( title : String , _ isNeedToShowViewMore : Bool = false) {
        lblTopHeader.text = title
        if self.contentView.frame.size.height > 5 {
            lblTopHeader.isHidden = false
             viewAll.isHidden = !isNeedToShowViewMore
             arrowImage.isHidden = !isNeedToShowViewMore
        }else{
             viewAll.isHidden = true
            lblTopHeader.isHidden = true
        }
        viewAll.visibility = viewAll.isHidden ? .goneX : .visible
       
        if ElGrocerUtility.sharedInstance.isArabicSelected(){
            arrowImage.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        
    }
    
    func configureCellWithEditOrder( title : String ) {
        lblTopHeader.text = title
        if self.contentView.frame.size.height > 5 {
            lblTopHeader.isHidden = false
            viewAll.isHidden = false
        }else{
            viewAll.isHidden = true
            lblTopHeader.isHidden = true
        }
        //viewAll.backgroundColor = .white
        viewAll.visibility = viewAll.isHidden ? .goneX : .visible
        arrowImage.isHidden = false
        rightButtonText.setBody1BoldButtonStyle()
        rightButtonText.text = localizedString("btn_txt_edit", comment: "")
    }
    
    
    @IBAction func viewAllAction(_ sender: Any) {
        if let click = viewAllAction {
            click()
        }
    }
    
}
