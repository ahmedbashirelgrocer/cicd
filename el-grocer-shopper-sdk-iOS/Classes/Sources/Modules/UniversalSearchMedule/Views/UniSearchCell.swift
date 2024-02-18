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
    @IBOutlet var title: UILabel! {
        didSet{
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                title.textAlignment = .right
            }
        }
    }
    @IBOutlet var subTitle: UILabel!
    @IBOutlet var btnSearchCross: UIButton! {
        didSet {
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                self.btnSearchCross.transform = CGAffineTransform(scaleX: -1, y: 1)
            } else {
                self.btnSearchCross.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    var currentObj : SuggestionsModelObj?
    var clearButtonClicked : ((_ data : String)->Void)?
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpApearance()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgView.sd_cancelCurrentImageLoad()
        self.imgView.image = UIImage(name: "category_placeholder")!
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
            
            self.updateTitleWithSearchHighlight(title: title, searchString: searchString)
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
            imgView.sd_setImage(with: URL(string: obj!.retailerImageUrl), placeholderImage: UIImage(name: "universalSearch"))
        }else if obj?.modelType == SearchResultSuggestionType.recipeTitles {
            imgView.image = UIImage(name: "recipeImageSearch")
        }else if obj?.modelType == SearchResultSuggestionType.retailer {
            imgView.assignImage(imageUrl: self.currentObj?.retailerImageUrl)
            
            
            self.btnSearchCross.setImage(UIImage(name: "arrowForwardBlackSmallSearchCell"), for: .normal)
        }
       
        self.imgView.visibility = obj?.modelType == .noDataFound ? .goneX : .visible
        self.btnSearchCross.isHidden = (obj?.modelType != SearchResultSuggestionType.retailer)
        self.btnSearchCross.isUserInteractionEnabled = (obj?.modelType == SearchResultSuggestionType.retailer)
    }
    
    func updateTitleWithSearchHighlight(title: String, searchString: String) {
        var attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.SFProDisplayNormalFont(14)])
        
        let queryArray = searchString.split(separator: " ")
        
        var found = [(String, NSRange)]()
        for query in queryArray {
            let nsRange = NSString(string: title).range(of: String(query), options: .caseInsensitive)
            
            if nsRange.location != NSNotFound {
                found.append((String(query), nsRange))
            }
        }
        
        if found.isNotEmpty {
            attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(14)])
            
            found.forEach { (string, range) in
                attributedString.addAttribute(NSAttributedString.Key.font , value: UIFont.SFProDisplayNormalFont(14), range: range)
            }
        }
        
        self.title.attributedText = attributedString
    }
    
    @IBAction func btnSearchCrossAction(_ sender: Any) {
        
        if let clouser = self.clearButtonClicked {
            clouser(self.currentObj?.title ?? "")
        }
        
    }
    

}
