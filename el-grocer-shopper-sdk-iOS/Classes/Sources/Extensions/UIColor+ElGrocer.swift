//
//  UIColor+ElGrocer.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 01.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

fileprivate extension UIColor {
    static var currentTheme: Theme { SDKManager.shared.launchOptions?.theme ?? ApplicationTheme.smilesSdkTheme()}
}

extension UIColor {
    
    class func smileBaseColor() -> UIColor {
        return currentTheme.smileBaseColor
    }
    class func smileSecondaryColor() -> UIColor {
        return currentTheme.smileSecondaryColor
    }
    class func navigationBarWhiteColor() -> UIColor {
        return currentTheme.navigationBarWhiteColor
    }
    class func replacementGreenBGColor() -> UIColor {
        return currentTheme.replacementGreenBGColor
    }
    
    class func replacementGreenTextColor() -> UIColor {
        return currentTheme.replacementGreenTextColor
    }

    class func navigationBarColor() -> UIColor {
        return currentTheme.navigationBarColor
    }
    class func unselectedPageControl() -> UIColor {
        return currentTheme.unselectedPageControl
    }
    class func buttonSelectionColor() -> UIColor {
        return  currentTheme.buttonSelectionColor
    }
    
    class func secondaryDarkGreenColor() -> UIColor {
        return currentTheme.secondaryDarkGreenColor
    }
    
    class func textFieldPlaceHolderColor()  -> UIColor {
        return currentTheme.textFieldPlaceHolderColor
    }
    class func bottomSheetShadowColor() -> UIColor {
        return currentTheme.bottomSheetShadowColor
    }
    class func newBlackColor() -> UIColor {
        return currentTheme.newBlackColor
    }
    class func textViewPlaceHolderColor() -> UIColor {
        return currentTheme.textViewPlaceHolderColor
    }
    class func secondaryBlackColor() -> UIColor {
        return currentTheme.secondaryBlackColor
    }
    class func  disableButtonColor() -> UIColor {
        return currentTheme.disableButtonColor
    }
    class func  textfieldErrorColor() -> UIColor {
        return currentTheme.textfieldErrorColor
    }
    class func  textfieldBackgroundColor() -> UIColor {
        return currentTheme.textfieldBackgroundColor
    }
    class func  tableViewBackgroundColor() -> UIColor {
        return currentTheme.tableViewBackgroundColor
    }
    class func elGrocerYellowColor() -> UIColor {
        return currentTheme.elGrocerYellowColor
    }
    class func newBorderGreyColor() -> UIColor {
        return currentTheme.newBorderGreyColor //used in Order Collector detaiils cell as a border color
    }
    class func searchBarBorderGreyColor() -> UIColor {
        return currentTheme.searchBarBorderGreyColor //used in recipe boutique search textfield
    }
    class func promotionYellowColor() -> UIColor {
        return currentTheme.promotionYellowColor
    }
    class func promotionRedColor() -> UIColor {
        return currentTheme.promotionRedColor
    }
    class func limitedStockGreenColor() -> UIColor {
        return currentTheme.limitedStockGreenColor
    }
    class func smilePrimaryPurpleColor() -> UIColor {
        return currentTheme.smilePrimaryPurpleColor
    }
    class func smilePointBackgroundColor() -> UIColor {
        return currentTheme.smilePointBackgroundColor
    }
    class func smilePrimaryOrangeColor() -> UIColor {
        return currentTheme.smilePrimaryOrangeColor
    }

    class func dashedBorderDefaultColor()-> UIColor {
        return currentTheme.dashedBorderDefaultColor
    }
    class func alertBackgroundColor()-> UIColor {
        return currentTheme.alertBackgroundColor
    }
    class func lightGreyColor()-> UIColor {
        return currentTheme.lightGreyColor
    }
    
    class func separatorColor() -> UIColor {

        //return UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 1)
        return currentTheme.separatorColor
    }

    class func newGreyColor() -> UIColor {
        return  currentTheme.newGreyColor
    }

    class func selectionTabDark() -> UIColor {
        return  currentTheme.selectionTabDark
    }

    class func darkBorderGrayColor() -> UIColor {

        return currentTheme.darkBorderGrayColor
    }

    class func borderGrayColor() -> UIColor {

        return currentTheme.borderGrayColor
    }

    class func redInfoColor() -> UIColor {
        return currentTheme.redInfoColor
    }

    class func lightGrayBGColor() -> UIColor {

        return currentTheme.lightGrayBGColor
    }
    class func darkGrayTextColor() -> UIColor {
        
        return currentTheme.darkGrayTextColor
    }
    class func lightTextGrayColor() -> UIColor {
        
        return currentTheme.lightTextGrayColor
    }
    
    class func newUIrecipelightGrayBGColor() -> UIColor {
        return currentTheme.newUIrecipelightGrayBGColor
    }

    class func emptyViewTextColor() -> UIColor {
        
        return UIColor(red: 164.0 / 255.0, green: 164.0 / 255.0, blue: 164.0 / 255.0, alpha: 1)
    }



    class func colorWithHexString(hexString:String) -> UIColor {
        
       // var cString:String = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        var cString:String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            //cString = cString.substringFrom(cString.startIndex.advancedBy(1)) let newStr = String(str[..<index])
            let index = cString.index(cString.startIndex, offsetBy: 1)
            cString = String(cString[..<index])
        }
        
        //if ((cString.characters.count) != 6) {
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
