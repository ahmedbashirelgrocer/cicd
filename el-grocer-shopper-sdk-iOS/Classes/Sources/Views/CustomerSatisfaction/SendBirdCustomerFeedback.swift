//
//  sendBirdCustomerFeedback.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 22/04/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import FloatRatingView
import GrowingTextView

class SendBirdCustomerFeedback: UIView {

    @IBOutlet var starRatingView: FloatRatingView!
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var btnSubmitFeedback: UIButton! {
        didSet {
            btnSubmitFeedback.roundWithShadow(corners: [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner], radius: 22)
        }
    }
    @IBOutlet var growingTextView: GrowingTextView! {
        didSet{
            growingTextView.textColor = .newBlackColor()
        }
    }
    @IBOutlet var lblTextCount: UILabel!
    @IBOutlet var btnCross: UIButton!
    @IBOutlet var lbl_help_us_be_better: UILabel!{
        didSet{
            lbl_help_us_be_better.setCaptionOneBoldDarkStyle()
        }
    }
    typealias tapped = () -> Void
    var btnSubmitPressed: tapped?

    class func loadFromNib() -> SendBirdCustomerFeedback? {
        return self.loadFromNib(withName: "SendBirdCustomerFeedback")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpRatingView()
        setUpFonts()
        setDelegates()
    }
    func setUpRatingView(){
        
        starRatingView.fullImage = sdkManager.isShopperApp ?  UIImage(name: "eg-StarFilled") : UIImage(name: "starFilled")
        starRatingView.emptyImage = sdkManager.isShopperApp ? UIImage(name: "eg-StarUnfilled") : UIImage(name: "starUnfilled") 
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
        lbl_help_us_be_better.setCaptionOneBoldUperCaseDarkStyle()
        lblTextCount.setCaptionOneRegLightStyle()
        setUpTextView()
    }

    @IBAction func btnSubmitFeedbackHandler(_ sender: Any) {
        if let btnSubmitPressed = btnSubmitPressed {
            btnSubmitPressed()
        }
    }
    
    //textView
    @IBAction func btnCrossHandler(_ sender: Any) {
        self.growingTextView.text = ""
        self.growingTextView.resignFirstResponder()
    }
    func setDelegates(){
        growingTextView.delegate = self
    }
    
    func setUpTextView() {
        self.growingTextView.attributedPlaceholder =  NSAttributedString.init(string: self.growingTextView.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.newGreyColor() , NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14)])
        self.growingTextView.textColor = UIColor.newBlackColor()
        self.growingTextView.textColor = UIColor.newBlackColor()
    }


}
extension SendBirdCustomerFeedback:  UITextViewDelegate{
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
