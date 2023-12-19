//
//  GroceryReviewRatingCell.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 21.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

let kGroceryReviewRatingCellIdentifier = "GroceryReviewRatingCell"
let kGroceryReviewRatingCellHeight: CGFloat = 44

class GroceryReviewRatingCell : UITableViewCell {
    
    @IBOutlet weak var criteriaName: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpCriteriaNameLabelAppearance()
        setUpRatingView()
        
        addTapGestureToRatingView()
    }
    
    // MARK: Appearance
    
    fileprivate func setUpCriteriaNameLabelAppearance() {
        
        self.criteriaName.textColor = UIColor.black
        self.criteriaName.font = UIFont.SFProDisplayNormalFont(13.0)
    }
    
    fileprivate func setUpRatingView() {
    
        self.ratingView.emptyImage = UIImage(name: "stars-gray")
        self.ratingView.fullImage = UIImage(name: "stars")
        
        self.ratingView.contentMode = UIView.ContentMode.scaleAspectFit
        self.ratingView.maxRating = 5
        self.ratingView.minRating = 0
        self.ratingView.editable = true
        self.ratingView.halfRatings = false
        self.ratingView.floatRatings = false
    }
    
    // MARK: Data
    
    func configureWithLabel(_ label:String, isLastRow:Bool) {
        
        self.criteriaName.text = label
        self.separator.isHidden = isLastRow
    }
    
    // MARK: RatingView Tap (we are using gesture recognizer because touchesBegan is delayed and is to slow)
    
    func addTapGestureToRatingView() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GroceryReviewRatingCell.ratingViewTap(_:)))
        self.ratingView.addGestureRecognizer(tapGesture)
    }
    
    @objc func ratingViewTap(_ sender: UITapGestureRecognizer) {
        
        let touchLocation = sender.location(in: self.ratingView)
        self.ratingView.handleTouchAtLocation(touchLocation)
    }
    
}
