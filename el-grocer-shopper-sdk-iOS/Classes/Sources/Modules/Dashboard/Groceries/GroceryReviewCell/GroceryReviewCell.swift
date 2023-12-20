//
//  GroceryReviewCell.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 21.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

let kGroceryReviewCellIdentifier = "GroceryReviewCell"
let kGroceryReviewCellHeight: CGFloat = 100

class GroceryReviewCell : UITableViewCell {
    
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var reviewText: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        setUpCustomerNameAppearance()
        setUpReviewTextAppearance()
        setUpRatingView()
    }
    
    // MARK: Appearance
    
    fileprivate func setUpCustomerNameAppearance() {
        
        self.customerName.textColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        self.customerName.font = UIFont.SFProDisplaySemiBoldFont(11.0)
    }
    
    fileprivate func setUpReviewTextAppearance() {
        
        self.reviewText.textColor = UIColor.black
        self.reviewText.font = UIFont.SFProDisplayNormalFont(11.0)
    }
    
    fileprivate func setUpRatingView() {
        
        self.ratingView.emptyImage = UIImage(name: "stars-gray")
        self.ratingView.fullImage = UIImage(name: "stars")
        
        self.ratingView.contentMode = UIView.ContentMode.scaleAspectFit
        self.ratingView.maxRating = 5
        self.ratingView.minRating = 0
        self.ratingView.editable = false
        self.ratingView.halfRatings = false
        self.ratingView.floatRatings = false
    }
    
    // MARK: Data
    
    func configureWithReview(_ review:GroceryReview) {
        
        self.customerName.text = review.reviewer
        self.reviewText.text = review.reviewText
        self.ratingView.rating = review.score.floatValue        
    }
}
