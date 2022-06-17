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
        
        
//        self.imgContainer.layer.cornerRadius = 0.5 * self.imgContainer.bounds.size.width
//        self.imgContainer.clipsToBounds = true
//        self.imgContainer.backgroundColor = UIColor.white
        
//        let arrowIcon = ElGrocerUtility.sharedInstance.getImageWithName("next-arrow")
//        self.nextImgView.image = arrowIcon
//        self.nextImgView.image = self.nextImgView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
//        self.nextImgView.tintColor = UIColor.navigationBarColor()
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
//            self.nextImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
//            self.nextImgView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            
            lblViewAll.transform = CGAffineTransform(scaleX: -1, y: 1)
            lblViewAll.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
        
    }
}
