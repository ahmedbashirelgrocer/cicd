//
//  GenericWriteReviewView.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 22/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import GrowingTextView
class GenericWriteReviewView: UIView {

    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var lbl_help_us_be_better: UILabel!{
        didSet{
            lbl_help_us_be_better.setCaptionOneBoldDarkStyle()
        }
    }
    
    @IBOutlet var growingTextView: GrowingTextView!{
        didSet{
            growingTextView.textColor = .newBlackColor()
        }
    }
    @IBOutlet var lblTextCount: UILabel!
    @IBOutlet var btnCross: UIButton!
    
    class func loadFromNib() -> GenericWriteReviewView? {
        return self.loadFromNib(withName: "GenericWriteReviewView")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpFonts()
        setDelegates()
    }
    @IBAction func btnCrossHandler(_ sender: Any) {
        self.growingTextView.text = ""
        self.growingTextView.resignFirstResponder()
    }
    func setDelegates(){
        growingTextView.delegate = self
    }
    func setUpFonts(){
        
        lblHeading.setH3SemiBoldDarkStyle()
        lbl_help_us_be_better.setCaptionOneBoldUperCaseDarkStyle()
        lblTextCount.setCaptionOneRegLightStyle()
        setUpTextView()
        
    }
    
    func setUpTextView() {
        self.growingTextView.attributedPlaceholder =  NSAttributedString.init(string: self.growingTextView.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.newGreyColor() , NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14)])
        self.growingTextView.textColor = UIColor.newBlackColor()
        self.growingTextView.textColor = UIColor.newBlackColor()
    }

}
extension GenericWriteReviewView:  UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        defer{
            self.btnCross.isHidden = self.growingTextView.text.count == 0
        }
        
        var isEnableToChangeText = true
        var maxLenght = 0
        maxLenght = 100
        self.lblTextCount.text = String(format: "%d/%d",textView.text!.count,maxLenght)
        if (textView.text!.count >= maxLenght && range.length == 0){
            isEnableToChangeText = false // return NO to not change text
        }else{
            commentFeedBack = textView.text
        }
        
        return isEnableToChangeText
    }
}

