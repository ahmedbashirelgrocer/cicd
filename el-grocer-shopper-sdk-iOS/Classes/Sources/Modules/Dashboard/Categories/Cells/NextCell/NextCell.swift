//
//  NextCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 13/05/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
let kNextCellIdentifier = "NextCell"

class NextCell: UICollectionViewCell {
    
    @IBOutlet weak var imgContainer: UIView!
    @IBOutlet weak var nextImgView: UIImageView!
    @IBOutlet var lblViewAll: UILabel!{
        didSet{
            lblViewAll.text = localizedString("txt_see_more", comment: "")
            lblViewAll.setCaptionOneBoldUperCaseGreenStyle()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(isForPreference : Bool = false){
        
        
        if isForPreference{
            lblViewAll.text = localizedString("search_more_replacement", comment: "").uppercased()
        }else{
            lblViewAll.text = localizedString("txt_see_more", comment: "")
        }

        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            lblViewAll.transform = CGAffineTransform(scaleX: -1, y: 1)
            lblViewAll.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
        
    }
}
