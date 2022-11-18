//
//  SearchSuggestionCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 04/04/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

let kSearchSuggestionCellIdentifier = "SearchSuggestionCell"
let kSearchSuggestionCellHeight: CGFloat = 40

class SearchSuggestionCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var searchImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLbl.isHidden = true
        self.searchImgView.isHidden = true
    }
    
    // MARK: Data
    func configureCellWithSearchText(_ searchText: String, andWithSuggestion suggestionText: String){
        
        let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14.0), NSAttributedString.Key.foregroundColor : UIColor.lightTextGrayColor()]
        
        let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(15.0), NSAttributedString.Key.foregroundColor : UIColor.black]
        
        let attributedString1 = NSMutableAttributedString(string:searchText, attributes:attrs1)
        
        let attributedString2 = NSMutableAttributedString(string:String(format:" %@ %@",localizedString("in_title", comment: ""),suggestionText), attributes:attrs2)
        
        attributedString1.append(attributedString2)
        self.titleLbl.attributedText = attributedString1
        self.titleLbl.isHidden = false
        self.searchImgView.isHidden = false
    }
    
    func configureCellWithSearchText(_ searchText: String){
        self.titleLbl.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        self.titleLbl.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
        self.titleLbl.text = String(format:"%@ %@",localizedString("search_for_title", comment: ""),searchText)
        self.titleLbl.isHidden = false
        self.searchImgView.isHidden = false
    }
}

