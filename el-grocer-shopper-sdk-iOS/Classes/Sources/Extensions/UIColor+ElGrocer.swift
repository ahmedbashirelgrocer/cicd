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
        return ApplicationTheme.currentTheme.smileBaseColor
    }
    class func smileSecondaryColor() -> UIColor {
        return ApplicationTheme.currentTheme.smileSecondaryColor
    }
    class func navigationBarWhiteColor() -> UIColor {
        return ApplicationTheme.currentTheme.navigationBarWhiteColor
    }
    class func navigationBarColor() -> UIColor {
        return #colorLiteral(red: 0.01960784314, green: 0.737254902, blue: 0.4, alpha: 1) //05bc66
    }
    class func replacementGreenBGColor() -> UIColor {
        return ApplicationTheme.currentTheme.replacementGreenBGColor
    }
    
    class func replacementGreenTextColor() -> UIColor {
        return ApplicationTheme.currentTheme.replacementGreenTextColor
    }

//    class func navigationBarColor() -> UIColor {
//        return ApplicationTheme.currentTheme.navigationBarColor
//    }
    class func unselectedPageControl() -> UIColor {
        return ApplicationTheme.currentTheme.unselectedPageControl
    }
    class func buttonSelectionColor() -> UIColor {
        return  ApplicationTheme.currentTheme.buttonSelectionColor
    }
    
    class func secondaryDarkGreenColor() -> UIColor {
        return ApplicationTheme.currentTheme.secondaryDarkGreenColor
    }
    
    class func textFieldPlaceHolderColor()  -> UIColor {
        return ApplicationTheme.currentTheme.textFieldPlaceHolderColor
    }
    class func bottomSheetShadowColor() -> UIColor {
        return ApplicationTheme.currentTheme.bottomSheetShadowColor
    }
    class func newBlackColor() -> UIColor {
        return ApplicationTheme.currentTheme.newBlackColor
    }
    class func textViewPlaceHolderColor() -> UIColor {
        return ApplicationTheme.currentTheme.textViewPlaceHolderColor
    }
    class func secondaryBlackColor() -> UIColor {
        return ApplicationTheme.currentTheme.secondaryBlackColor
    }
    class func  disableButtonColor() -> UIColor {
        return ApplicationTheme.currentTheme.disableButtonColor
    }
    class func  textfieldErrorColor() -> UIColor {
        return ApplicationTheme.currentTheme.textfieldErrorColor
    }
    class func  textfieldBackgroundColor() -> UIColor {
        return ApplicationTheme.currentTheme.textfieldBackgroundColor
    }
    class func  tableViewBackgroundColor() -> UIColor {
        return ApplicationTheme.currentTheme.tableViewBackgroundColor
    }
    class func elGrocerYellowColor() -> UIColor {
        return ApplicationTheme.currentTheme.elGrocerYellowColor
    }
    class func newBorderGreyColor() -> UIColor {
        return ApplicationTheme.currentTheme.newBorderGreyColor //used in Order Collector detaiils cell as a border color
    }
    class func searchBarBorderGreyColor() -> UIColor {
        return ApplicationTheme.currentTheme.searchBarBorderGreyColor //used in recipe boutique search textfield
    }
    class func promotionYellowColor() -> UIColor {
        return ApplicationTheme.currentTheme.promotionYellowColor
    }
    class func promotionRedColor() -> UIColor {
        return ApplicationTheme.currentTheme.promotionRedColor
    }
    class func limitedStockGreenColor() -> UIColor {
        return ApplicationTheme.currentTheme.limitedStockGreenColor
    }
    class func smilePrimaryPurpleColor() -> UIColor {
        return ApplicationTheme.currentTheme.smilePrimaryPurpleColor
    }
    class func smilePointBackgroundColor() -> UIColor {
        return ApplicationTheme.currentTheme.smilePointBackgroundColor
    }
    class func smilePrimaryOrangeColor() -> UIColor {
        return ApplicationTheme.currentTheme.smilePrimaryOrangeColor
    }

    class func dashedBorderDefaultColor()-> UIColor {
        return ApplicationTheme.currentTheme.dashedBorderDefaultColor
    }
    class func alertBackgroundColor()-> UIColor {
        return ApplicationTheme.currentTheme.alertBackgroundColor
    }
    class func lightGreyColor()-> UIColor {
        return ApplicationTheme.currentTheme.lightGreyColor
    }
    
    class func separatorColor() -> UIColor {

        //return UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 1)
        return ApplicationTheme.currentTheme.separatorColor
    }

    class func newGreyColor() -> UIColor {
        return  ApplicationTheme.currentTheme.newGreyColor
    }

    class func selectionTabDark() -> UIColor {
        return  ApplicationTheme.currentTheme.selectionTabDark
    }

    class func darkBorderGrayColor() -> UIColor {

        return ApplicationTheme.currentTheme.darkBorderGrayColor
    }

    class func borderGrayColor() -> UIColor {

        return ApplicationTheme.currentTheme.borderGrayColor
    }

    class func redInfoColor() -> UIColor {
        return ApplicationTheme.currentTheme.redInfoColor
    }

    class func lightGrayBGColor() -> UIColor {

        return ApplicationTheme.currentTheme.lightGrayBGColor
    }
    class func darkGrayTextColor() -> UIColor {
        
        return ApplicationTheme.currentTheme.darkGrayTextColor
    }
    class func lightTextGrayColor() -> UIColor {
        
        return ApplicationTheme.currentTheme.lightTextGrayColor
    }
    
    class func newUIrecipelightGrayBGColor() -> UIColor {
        return ApplicationTheme.currentTheme.newUIrecipelightGrayBGColor
    }

    class func emptyViewTextColor() -> UIColor {
        
        return ApplicationTheme.currentTheme.emptyViewTextColor
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
