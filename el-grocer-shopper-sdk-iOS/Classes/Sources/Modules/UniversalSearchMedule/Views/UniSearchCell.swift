//
//  UniSearchCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 23/01/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class UniSearchCell: UITableViewCell {

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var subTitle: UILabel!
    @IBOutlet var btnSearchCross: UIButton!
    var currentObj : SuggestionsModelObj?
    var clearButtonClicked : ((_ data : String)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpApearance()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpApearance() {
        self.title.font = UIFont.SFProDisplayNormalFont(14)
        self.title.textColor = UIColor.newBlackColor()
        
    }
    
    func cellConfigureWith (_ obj : SuggestionsModelObj? , searchString : String) {
        
        guard obj != nil else{return}
        self.currentObj = obj
        
        UIView.performWithoutAnimation {
        var title = obj?.title ?? ""
            if obj?.modelType == SearchResultSuggestionType.brandTitles {
                title = searchString
                subTitle.isHidden = false
                subTitle.text = localizedString("In", comment: "") + " " + (obj?.title ?? "")
            }else if obj?.modelType == SearchResultSuggestionType.categoriesTitles {
                title = searchString
                subTitle.isHidden = false
                subTitle.text = localizedString("In", comment: "") + " " + (obj?.title ?? "")
            }else{
                subTitle.isHidden = true
            }
            
            let attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14)])
             let nsRange = NSString(string: title).range(of: searchString, options: String.CompareOptions.caseInsensitive)
            
            if nsRange.location != NSNotFound {
                attributedString.addAttribute(NSAttributedString.Key.font , value: UIFont.SFProDisplaySemiBoldFont(14) , range: nsRange )
            }
           self.title.attributedText = attributedString
        }
        
        
      
        if obj?.modelType == SearchResultSuggestionType.trendingSearch {
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                imgView.image = UIImage(name: "trendingSearch")?.imageFlippedForRightToLeftLayoutDirection()
            }else {
                imgView.image = UIImage(name: "trendingSearch")
            }
        }else if obj?.modelType == SearchResultSuggestionType.categoriesTitles {
            imgView.image = UIImage(name: "categorySearch")
        }else if obj?.modelType == SearchResultSuggestionType.brandTitles {
            imgView.image = UIImage(name: "categorySearch")
        }else if obj?.modelType == SearchResultSuggestionType.searchHistory {
            imgView.image = UIImage(name: "universalSearch")
        }else if obj?.modelType == SearchResultSuggestionType.recipeTitles {
            imgView.image = UIImage(name: "recipeImageSearch")
        }
        
        
        
        self.btnSearchCross.isHidden = (obj?.modelType != SearchResultSuggestionType.searchHistory )
    }
    
    @IBAction func btnSearchCrossAction(_ sender: Any) {
        
        if let clouser = self.clearButtonClicked {
            clouser(self.currentObj?.title ?? "")
        }
        
    }
    

}
