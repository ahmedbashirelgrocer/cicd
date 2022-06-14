//
//  Elgrocer+Styling.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 20/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
   
    func setBody3RegStyle() {
        self.font = UIFont.SFProDisplayNormalFont(14)
        self.textColor = UIColor.newBlackColor()
        self.attributedPlaceholder = NSAttributedString.init(string: self.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceHolderColor() , NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14) ])
    }
    func setBody1RegStyle() {
        self.font = UIFont.SFProDisplayNormalFont(17)
        self.textColor = UIColor.newBlackColor()
        self.attributedPlaceholder = NSAttributedString.init(string: self.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceHolderColor() , NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(17) ])
    }
    
    func setPlaceHolder(text: String, color: UIColor = .secondaryBlackColor()) {
        self.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
    }

    
}


extension UILabel {
    
    func setProductCountWhiteStyle(){
        self.font = UIFont.SFProDisplayNormalFont(10)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    
    func setApplePayWhiteStyle(){
        self.font = UIFont.SFProDisplaySemiBoldFont(19)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    
    func setBodyBoldDarkStyle() {
        self.font = UIFont.SFProDisplayBoldFont(14)
        self.textColor = UIColor.newBlackColor()
    }
    func setBodyBoldGreenStyle() {
        self.font = UIFont.SFProDisplayBoldFont(14)
        self.textColor = UIColor.navigationBarColor()
    }
    func setBodyBoldWhiteStyle() {
        self.font = UIFont.SFProDisplayBoldFont(14)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    
    func setBodyRegulrGreenStyle() {
        self.font = UIFont.SFProDisplayNormalFont(14)
        self.textColor = UIColor.navigationBarColor()
    }
    
    func setBody2RegDarkStyle() {
        self.font = UIFont.SFProDisplayNormalFont(16)
        self.textColor = UIColor.newBlackColor()
    }
    func setBody2RegWhiteStyle() {
        self.font = UIFont.SFProDisplayNormalFont(16)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    func setBody2RegErrorStyle() {
        self.font = UIFont.SFProDisplayNormalFont(16)
        self.textColor = UIColor.textfieldErrorColor()
    }
    
    func setBody2SemiboldDarkStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(16)
        self.textColor = UIColor.newBlackColor()
    }
    func setBody2SemiboldDarkGreenStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(16)
        self.textColor = UIColor.darkGreenColor()
    }
    func setBody2SemiboldGreenStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(16)
        self.textColor = UIColor.navigationBarColor()
    }
    func setBody2BoldDarkStyle() {
        self.font = UIFont.SFProDisplayBoldFont(16)
        self.textColor = UIColor.newBlackColor()
    }
    func setBody2BoldWhiteStyle() {
        self.font = UIFont.SFProDisplayBoldFont(16)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    
    func setBody3RegDarkStyle() {
        self.font = UIFont.SFProDisplayNormalFont(14)
        self.textColor = UIColor.newBlackColor()
    }
    func setBody3RegWhiteStyle() {
        self.font = UIFont.SFProDisplayNormalFont(14)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    func setBody3RegGreenStyle() {
        self.font = UIFont.SFProDisplayNormalFont(14)
        self.textColor = UIColor.navigationBarColor()
    }
    func setBody3RegDarkGreenStyle() {
        self.font = UIFont.SFProDisplayNormalFont(14)
        self.textColor = UIColor.replacementGreenTextColor()
    }
    func setBody3RegSecondaryDarkStyle() {
        self.font = UIFont.SFProDisplayNormalFont(14)
        self.textColor = UIColor.secondaryBlackColor()
    }
    func setBody3RegGreyStyle() {
        self.font = UIFont.SFProDisplayNormalFont(14)
        self.textColor = UIColor.textFieldPlaceHolderColor()
    }
    func setBody3RegSecondaryWhiteStyle() {
        self.font = UIFont.SFProDisplayNormalFont(14)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    func setBody3SemiBoldGreenStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(14)
        self.textColor = UIColor.navigationBarColor()
    }
    func setBody3SemiBoldDarkStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(14)
        self.textColor = UIColor.newBlackColor()
    }
    func setBody3SemiBoldWhiteStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(14)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    func setBody3SemiBoldDarkGreenStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(14)
        self.textColor = UIColor.secondaryDarkGreenColor()
    }
    func setBody3SemiBoldYellowStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(14)
        self.textColor = UIColor.promotionYellowColor()
    }
    
    func setBodyH4SemiBoldDarkGreenStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(17)
        self.textColor = UIColor.secondaryDarkGreenColor()
    }
    
    func setBody3BoldUpperStyle(_ isDefaultColor : Bool = true) {
        self.font = UIFont.SFProDisplayBoldFont(14)
        if isDefaultColor{
            self.textColor = UIColor.navigationBarColor()
        }else{
            self.textColor = UIColor.newBlackColor()
        }
    }
    func setBody3BoldUpperWhiteStyle() {
        self.font = UIFont.SFProDisplayBoldFont(14)
        self.textColor = UIColor.navigationBarWhiteColor()
        
    }
    func setBody3BoldReplacementGreenStyle() {
        self.font = UIFont.SFProDisplayBoldFont(14)
        self.textColor = UIColor.replacementGreenTextColor()
        
    }
    func setBody3BoldUpperYellowStyle() {
        self.font = UIFont.SFProDisplayBoldFont(14)
        self.textColor = UIColor.promotionYellowColor()
        
    }
    
    func setH2BoldDarkStyle(){
        self.font = UIFont.SFProDisplayBoldFont(22)
        self.textColor = UIColor.newBlackColor()
    }
    
    func setH2SemiBoldDarkStyle(){
        self.font = UIFont.SFProDisplaySemiBoldFont(22)
        self.textColor = UIColor.newBlackColor()
    }
    
    func setH3SemiBoldDarkStyle(){
        self.font = UIFont.SFProDisplayBoldFont(20)
        self.textColor = UIColor.newBlackColor()
    }
    func setH3SemiBoldWhiteStyle(){
        self.font = UIFont.SFProDisplayBoldFont(20)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    
    func setH4RegDarkStyle(){
        self.font = UIFont.SFProDisplayNormalFont(17)
        self.textColor = UIColor.newBlackColor()
    }
    func setH4SemiBoldStyle(){
        self.font = UIFont.SFProDisplayBoldFont(17)
        self.textColor = UIColor.newBlackColor()
    }
    func setH4SemiBoldWhiteStyle(){
        self.font = UIFont.SFProDisplayBoldFont(17)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    func setH4SemiBoldDarkGreenStyle(){
        self.font = UIFont.SFProDisplayBoldFont(17)
        self.textColor = UIColor.replacementGreenTextColor()
    }
    
    func setH4BoldWhiteStyle(){
        self.font = UIFont.SFProDisplayBoldFont(17)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    
    func setCaptionOneRegLightStyle() {
        self.font = UIFont.SFProDisplayNormalFont(12)
        self.textColor = UIColor.newGreyColor()
    }
    func setCaptionOneRegSecondaryDarkStyle() {
        self.font = UIFont.SFProDisplayNormalFont(12)
        self.textColor = UIColor.secondaryBlackColor()
    }
    func setCaptionOneRegDarkStyle() {
        self.font = UIFont.SFProDisplayNormalFont(12)
        self.textColor = UIColor.newBlackColor()
    }
    func setCaptionOneRegWhiteStyle() {
        self.font = UIFont.SFProDisplayNormalFont(12)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    func setCaptionOneRegErrorStyle() {
        self.font = UIFont.SFProDisplayNormalFont(12)
        self.textColor = UIColor.textfieldErrorColor()
    }
    func setCaptionOneBoldDarkStyle() {
        self.font = UIFont.SFProDisplayBoldFont(12)
        self.textColor = UIColor.newBlackColor()
    }
    func setCaptionOneBoldWhiteStyle() {
        self.font = UIFont.SFProDisplayBoldFont(12)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    func setCaptionOneBoldYellowStyle() {
        self.font = UIFont.SFProDisplayBoldFont(12)
        self.textColor = UIColor.promotionYellowColor()
    }
    func setCaptionOneBoldUperCaseDarkStyle() {
        self.font = UIFont.SFProDisplayBoldFont(12)
        self.textColor = UIColor.textViewPlaceHolderColor()
    }
    func setCaptionOneBoldUperCaseGreenStyle() {
        self.font = UIFont.SFProDisplayBoldFont(12)
        self.textColor = UIColor.navigationBarColor()
    }
    func setCaptionOneBoldUperCaseDarkGreenStyle() {
        self.font = UIFont.SFProDisplayBoldFont(12)
        self.textColor = UIColor.replacementGreenTextColor()
    }
    
    func setCaptionOneBoldUpperCaseGreenStyleWithFontScale14() {
        self.font = UIFont.SFProDisplayBoldFont(14)
        self.textColor = UIColor.navigationBarColor()
    }
    
    func setCaptionTwoRegDarkStyle() {
        self.font = UIFont.SFProDisplayNormalFont(11)
        self.textColor = UIColor.newBlackColor()
    }
    func setCaptionTwoRegWhiteStyle() {
        self.font = UIFont.SFProDisplayNormalFont(11)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    func setCaptionTwoRegSecondaryBlackStyle() {
        self.font = UIFont.SFProDisplayNormalFont(11)
        self.textColor = UIColor.secondaryBlackColor()
    }
    func setCaptionTwoSemiboldSecondaryDarkStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(11)
        self.textColor = UIColor.secondaryBlackColor()
    }
    func setCaptionTwoSemiboldGreenkStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(11)
        self.textColor = UIColor.navigationBarColor()
    }
    func setCaptionTwoSemiboldWhiteStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(11)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    func setCaptionTwoSemiboldYellowStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(11)
        self.textColor = UIColor.promotionYellowColor()
    }
    
    func setSubHead1SemiboldDarkStyle() {
        self.font = UIFont.SFProDisplayBoldFont(15)
        self.textColor = UIColor.newBlackColor()
    }
    func setSubHead1SemiboldWhiteStyle() {
        self.font = UIFont.SFProDisplayBoldFont(15)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    func setSubHead2RegDarkStyle() {
        self.font = UIFont.SFProDisplayNormalFont(13)
        self.textColor = UIColor.newBlackColor()
    }
    func setSubHead2RegWhiteStyle() {
        self.font = UIFont.SFProDisplayNormalFont(13)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    func setSubHead2BoldWhiteStyle() {
        self.font = UIFont.SFProDisplayBoldFont(13)
        self.textColor = UIColor.navigationBarWhiteColor()
    }
    func setSubHead2SemiBoldDarkGreenStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(13)
        self.textColor = UIColor.darkGreenColor()
    }
    
    func setBody1BoldStyle() {
        self.font = UIFont.SFProDisplaySemiBoldFont(17)
        self.textColor = UIColor.navigationBarColor()
    }
    func setBody1RegDarkStyle() {
        self.font = UIFont.SFProDisplayNormalFont(17)
        self.textColor = UIColor.newBlackColor()
    }
    
    func setH3SemiBoldStyle(){
        self.font = UIFont.SFProDisplayBoldFont(16)
        self.textColor = UIColor.newBlackColor()
    }
    
}

extension UIButton {
    
   
    
    func setCornerRadiusStyle() {
        self.layer.cornerRadius = self.frame.size.height / 2
    }
    func setBody1BoldWhiteStyle(){
        self.titleLabel?.font = UIFont.SFProDisplayBoldFont(17)
        self.setTitleColor(UIColor.navigationBarWhiteColor(), for: UIControl.State())
    }
    func setBody1BoldGreenStyle(){
        self.titleLabel?.font = UIFont.SFProDisplayBoldFont(17)
        self.setTitleColor(UIColor.navigationBarColor(), for: UIControl.State())
    }
    func setBody2RegSecondaryBlackStyle() {
        self.titleLabel?.font = UIFont.SFProDisplayNormalFont(16)
        self.setTitleColor(UIColor.secondaryBlackColor(), for: UIControl.State())
    }
    func setBody2SemiBoldDarkStyle() {
        self.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(16)
        self.setTitleColor(UIColor.newBlackColor(), for: UIControl.State())
    }
    func setBody2BoldGreenStyle() {
        self.titleLabel?.font = UIFont.SFProDisplayBoldFont(16)
        self.setTitleColor(UIColor.navigationBarWhiteColor(), for: UIControl.State())
    }
    
    func setBody3RegGreenStyle(){
        self.titleLabel?.font = UIFont.SFProDisplayNormalFont(14)
        self.setTitleColor(UIColor.navigationBarColor(), for: .normal)
    }
    func setBody3BoldGreenStyle(){
        self.titleLabel?.font = UIFont.SFProDisplayBoldFont(14)
        self.setTitleColor(UIColor.navigationBarColor(), for: .normal)
    }
    func setBody3BoldWhiteStyle(){
        self.titleLabel?.font = UIFont.SFProDisplayBoldFont(14)
        self.setTitleColor(UIColor.navigationBarWhiteColor(), for: UIControl.State())
    }
    
    func setBody3SemiBoldDarkStyle(){
        self.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(14)
        self.setTitleColor(UIColor.newBlackColor(), for: UIControl.State())
    }
    func setBody3SemiBoldWhiteStyle(){
        self.titleLabel?.setBody3SemiBoldWhiteStyle()
        self.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(14)
        self.setTitleColor(UIColor.navigationBarWhiteColor(), for: UIControl.State())
    }
    func setBody3SemiBoldYellowStyle(){
        self.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(14)
        self.setTitleColor(UIColor.promotionYellowColor(), for: UIControl.State())
    }
    
    func setButton2SemiBoldWhiteStyle() {
        self.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(16)
        self.setTitleColor(UIColor.navigationBarWhiteColor(), for: UIControl.State())
    }
    func setButton2SemiBoldDarkStyle() {
        self.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(16)
        self.setTitleColor(UIColor.newBlackColor(), for: UIControl.State())
    }
    
    func setH4SemiBoldWhiteStyle(_ isBackTransparent : Bool = false) {
        self.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(17)
        if isBackTransparent {
            self.backgroundColor = .clear
            self.setTitleColor(UIColor.navigationBarColor() , for: UIControl.State())
        }else{
            self.setTitleColor(UIColor.navigationBarWhiteColor() , for: UIControl.State())
            self.backgroundColor = .navigationBarColor()
        }
    }
    
    
    func setH4SemiBoldGreenStyle() {
        self.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(17)
        self.setTitleColor(UIColor.navigationBarColor(), for: UIControl.State())
    }
    
    func setSubHead1SemiBoldWhiteStyle(){
        self.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(15)
        self.setTitleColor(UIColor.navigationBarWhiteColor(), for: UIControl.State())
    }
    func setSubHead1SemiBoldGreenStyle(){
        self.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(15)
        self.setTitleColor(UIColor.navigationBarColor(), for: UIControl.State())
    }
    func setSubHead1BoldWhiteStyle() {
        self.titleLabel?.font = UIFont.SFProDisplayBoldFont(15)
        self.setTitleColor(UIColor.navigationBarWhiteColor() , for: UIControl.State())
    }
    
    func setCaption2SemiBoldWhiteStyle(){
        self.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(11)
        self.setTitleColor(UIColor.navigationBarColor(), for: .normal)
    }
    func setCaption1BoldWhiteStyle(){
        self.titleLabel?.font = UIFont.SFProDisplayBoldFont(12)
        self.setTitleColor(UIColor.navigationBarWhiteColor(), for: .normal)
    }
    
    func setCaptionBoldGreenStyle(){
        self.titleLabel?.font = UIFont.SFProDisplayBoldFont(12)
        self.setTitleColor(UIColor.navigationBarColor(), for: .normal)
    }
    func setCaptionBoldSecondaryGreenStyle(){
        self.titleLabel?.font = UIFont.SFProDisplayBoldFont(12)
        self.setTitleColor(UIColor.secondaryDarkGreenColor(), for: .normal)
    }
    func setCaptionBoldDarkStyle(){
        self.titleLabel?.font = UIFont.SFProDisplayBoldFont(12)
        self.setTitleColor(UIColor.newBlackColor(), for: .normal)
    }
    
    func setCaption3BoldGreenStyle(){
        self.titleLabel?.font = UIFont.SFProDisplayBoldFont(12)
        self.setTitleColor(UIColor.navigationBarColor(), for: .normal)
    }
    
    
    func centerVertically(padding: CGFloat = 10.0) {
            guard
                let imageViewSize = self.imageView?.frame.size,
                let titleLabelSize = self.titleLabel?.frame.size else {
                return
            }
            
            let totalHeight = imageViewSize.height + titleLabelSize.height + padding
            
        
        
            self.imageEdgeInsets = UIEdgeInsets(
                top: max(0, -(totalHeight - imageViewSize.height)) ,
                left: 0.0,
                bottom: 0.0,
                right: -titleLabelSize.width
            )
            
            self.titleEdgeInsets = UIEdgeInsets(
                top: 0.0,
                left: -imageViewSize.width,
                bottom: -(totalHeight - titleLabelSize.height),
                right: 0.0
            )
            
            self.contentEdgeInsets = UIEdgeInsets(
                top: 0.0,
                left: 0.0,
                bottom: titleLabelSize.height,
                right: 0.0
            )
    }
}
