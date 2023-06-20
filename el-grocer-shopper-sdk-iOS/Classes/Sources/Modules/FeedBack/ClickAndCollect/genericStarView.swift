//
//  GenericStarView.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 21/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import FloatRatingView

class genericStarView: UIView {

    @IBOutlet var starRatingView: FloatRatingView!
    @IBOutlet var lblHeading: UILabel!
    
    class func loadFromNib() -> genericStarView? {
        return self.loadFromNib(withName: "genericStarView")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpRatingView()
        setUpFonts()
    }
    func setUpRatingView(){
        
        starRatingView.fullImage = UIImage(name: sdkManager.isShopperApp ? "eg-StarFilled" : "starFilled")
        starRatingView.emptyImage = UIImage(name: sdkManager.isShopperApp ? "eg-StarUnfilled" : "starUnfilled")
        starRatingView.backgroundColor = UIColor.clear
        starRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        self.starRatingView.rating = 0;
        self.starRatingView.editable = true
        self.starRatingView.maxRating = 5
    }
    func setRatingViewDelegate(delegate : FloatRatingViewDelegate){
        self.starRatingView.delegate = delegate
    }
    func setUpFonts(){
        lblHeading.setH3SemiBoldDarkStyle()
    }

}

