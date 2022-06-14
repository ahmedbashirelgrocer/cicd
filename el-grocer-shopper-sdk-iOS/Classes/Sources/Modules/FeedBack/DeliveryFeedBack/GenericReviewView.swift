//
//  GenericReviewView.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 22/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class GenericReviewView: UIView {

    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var btnOption1: AWButton!
    @IBOutlet var btnOption2: AWButton!
    @IBOutlet var btnOption3: AWButton!
    @IBOutlet var btnOption4: AWButton!
    @IBOutlet var bottomConstraintBtn4: NSLayoutConstraint!
    
    class func loadFromNib() -> GenericReviewView? {
        return self.loadFromNib(withName: "GenericReviewView")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpFonts()
    }
    
    func hideBtnOption4(hiden : Bool) -> Bool{
        if hiden{
            bottomConstraintBtn4.constant = 0
            btnOption4.visibility = .gone
            layoutIfNeeded()
            return true
        }else{
            bottomConstraintBtn4.constant = 16
            btnOption4.visibility = .visible
            layoutIfNeeded()
            return true
        }
    }
    
    func setUpFonts(){
        
        lblHeading.setH3SemiBoldDarkStyle()
        btnOption1.setBody3SemiBoldDarkStyle()
        btnOption2.setBody3SemiBoldDarkStyle()
        btnOption3.setBody3SemiBoldDarkStyle()
        btnOption4.setBody3SemiBoldDarkStyle()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
