//
//  UIColor+ElGrocer.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 01.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
  
    class func navigationBarWhiteColor() -> UIColor {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // ffffff
    }
    class func replacementGreenBGColor() -> UIColor {
        return #colorLiteral(red: 0.7647058824, green: 0.937254902, blue: 0.8549019608, alpha: 1) //C3EFDA
    }
    
    class func replacementGreenTextColor() -> UIColor {
        return #colorLiteral(red: 0, green: 0.2784313725, blue: 0.2117647059, alpha: 1) //C3EFDA
    }

    class func navigationBarColor() -> UIColor {
        return #colorLiteral(red: 0.01960784314, green: 0.737254902, blue: 0.4, alpha: 1) //05bc66  
    }
    class func unselectedPageControl() -> UIColor {
        return #colorLiteral(red: 0.7647058824, green: 0.937254902, blue: 0.8549019608, alpha: 1) //c3efda
    }
    class func buttonSelectionColor() -> UIColor {
        return  #colorLiteral(red: 0.01960784314, green: 0.737254902, blue: 0.4, alpha: 1) //05bc66
    }
    
    class func secondaryDarkGreenColor() -> UIColor {
        return #colorLiteral(red: 0, green: 0.2784313725, blue: 0.2117647059, alpha: 1)  //004736
    }
    
    class func textFieldPlaceHolderColor()  -> UIColor {
        return #colorLiteral(red: 0.5647058824, green: 0.5647058824, blue: 0.5647058824, alpha: 1) //909090
    }
    class func bottomSheetShadowColor() -> UIColor {
        return #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.16) // 333333 - 16%
    }
    class func newBlackColor() -> UIColor {
        return #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)  // 333333
    }
    class func textViewPlaceHolderColor() -> UIColor {
        return #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.74)  // 333333 - 74%
    }
    class func secondaryBlackColor() -> UIColor {
        return #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.3490196078, alpha: 1) // 595959
    }
    class func  disableButtonColor() -> UIColor {
        return #colorLiteral(red: 0.5647058824, green: 0.5647058824, blue: 0.5647058824, alpha: 1) //909090
    }
    class func  textfieldErrorColor() -> UIColor {
        return #colorLiteral(red: 0.5960784314, green: 0.04705882353, blue: 0, alpha: 1) //980C00, 100%
    }
    class func  textfieldBackgroundColor() -> UIColor {
        return #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) //f5f5f5, 100%
    }
    class func  tableViewBackgroundColor() -> UIColor {
        return #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) //f5f5f5, 100%
    }
    class func elGrocerYellowColor() -> UIColor {
        return #colorLiteral(red: 1, green: 0.8352941176, blue: 0.1803921569, alpha: 1) //"FFD52E"
    }
    class func newBorderGreyColor() -> UIColor {
        return #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1) //  "D8D8D8" //used in Order Collector detaiils cell as a border color
    }
    class func searchBarBorderGreyColor() -> UIColor {
        return #colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.8941176471, alpha: 1) //  "E4E4E4" //used in recipe boutique search textfield
    }
    class func promotionYellowColor() -> UIColor {
        return #colorLiteral(red: 0.9803921569, green: 0.8901960784, blue: 0.2980392157, alpha: 1) //"FAE34C"
    }
    class func promotionRedColor() -> UIColor {
        return #colorLiteral(red: 0.8, green: 0.2235294118, blue: 0.1921568627, alpha: 1) //"CC3931"
    }
    class func limitedStockGreenColor() -> UIColor {
        return #colorLiteral(red: 0, green: 0.2784313725, blue: 0.2117647059, alpha: 1) //"004736"
    }
    class func smilePrimaryPurpleColor() -> UIColor {
        return #colorLiteral(red: 0.5294117647, green: 0.3294117647, blue: 0.631372549, alpha: 1) //"8754A1"
    }
    class func smilePointBackgroundColor() -> UIColor {
        return #colorLiteral(red: 0.5529411765, green: 0.3215686275, blue: 0.5921568627, alpha: 1) //"8754A1"
    }
    class func smilePrimaryOrangeColor() -> UIColor {
        return #colorLiteral(red: 0.8784313725, green: 0.2392156863, blue: 0.1490196078, alpha: 1) //"E03D26"
    }
    
    
    
    
    
    class func moreBGColor() -> UIColor {
        return UIColor.colorWithHexString(hexString: "F8F8FA")
    }
    class func recipelightGrayBGColor() -> UIColor {
        return UIColor.colorWithHexString(hexString: "f5f6f8")
    }
    class func newUIrecipelightGrayBGColor() -> UIColor {
        return UIColor.colorWithHexString(hexString: "ebecee")
    }
    
    class func buttonNonSelectionColor() -> UIColor {
        return UIColor.colorWithHexString(hexString: "909090")
    }
    class func elGrocerOrderBorderColor() -> UIColor {
        return  UIColor(red: 0.847, green: 0.847, blue: 0.847, alpha: 1)
    }
    
    class func locationScreenLightColor() -> UIColor {
        return  UIColor.colorWithHexString(hexString: "F5F5F5")
    }
    
    
    //
    
    class func newGreyColor() -> UIColor {
        return  UIColor.colorWithHexString(hexString: "909090")
    }
    
    
    
    class func selectionTabDark() -> UIColor {
        return  UIColor.colorWithHexString(hexString: "595959")
    }
    

    
    
    class func newborderColor() -> UIColor {
        return UIColor(red: 0.894 , green: 0.894 , blue: 0.894 , alpha: 1)
    }

    
    
    class func lightNavigationBarColor() -> UIColor {
        
        return UIColor(red: 98.0 / 255.0, green: 173.0 / 255.0, blue: 89.0 / 255.0, alpha: 1)
    }
        
    class func darkGreenColor() -> UIColor {
        
        return UIColor(red: 15.0 / 255.0, green: 91.0 / 255.0, blue: 47.0 / 255.0, alpha: 1)
    }
    
    class func darkBorderGrayColor() -> UIColor {
        
        return UIColor(red: 216.0 / 255.0, green: 216.0 / 255.0, blue: 216.0 / 255.0, alpha: 1)
    }
        
    class func borderGrayColor() -> UIColor {
        
        return UIColor(red: 230.0 / 255.0, green: 230.0 / 255.0, blue: 230.0 / 255.0, alpha: 1)
    }
    
    class func darkTextGrayColor() -> UIColor {
        
        return UIColor(red: 143.0 / 255.0, green: 143.0 / 255.0, blue: 143.0 / 255.0, alpha: 1)
    }
    
    class func lightTextGrayColor() -> UIColor {
        
        return UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1)
    }
    
    class func lightGrayBGColor() -> UIColor {
        
        return UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1)
    }
    
    class func lightBlackColor() -> UIColor {
        
        return UIColor(red: 57.0 / 255.0, green: 57.0 / 255.0, blue: 57.0 / 255.0, alpha: 1)
    }
    
    class func productBGColor() -> UIColor {
        
        return .white //UIColor(red: 243.0 / 255.0, green: 243.0 / 255.0, blue: 243.0 / 255.0, alpha: 1)
    }
    
    class func separatorColor() -> UIColor {
        
        //return UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 1)
        return .colorWithHexString(hexString: "E4E4E4")
    }
    
    class func redValidationErrorColor() -> UIColor {
        
        return .colorWithHexString(hexString: "980c00")
    }
    
    class func redInfoColor() -> UIColor {
        return .colorWithHexString(hexString: "980c00")
    }
    
    class func greenInfoColor() -> UIColor {
        return UIColor(red: 0.3137, green: 0.651, blue: 0.2784, alpha: 1.0)
    }
    
    class func redTextColor() -> UIColor {
        
        return .colorWithHexString(hexString: "980c00")
    }
    
    class func emptyViewTextColor() -> UIColor {
        
        return UIColor(red: 164.0 / 255.0, green: 164.0 / 255.0, blue: 164.0 / 255.0, alpha: 1)
    }
    
    class func searchPlaceholderTextColor() -> UIColor {
        
        return UIColor(red: 0.2, green: 0.2, blue: 0.2 , alpha: 0.74)
    }
    
    class func textFieldPlaceholderTextColor() -> UIColor {
        
        return UIColor(red: 0.396, green: 0.396, blue: 0.396, alpha: 1)
    }
    
    
    
    class func introGreenColor() -> UIColor {
        
        return UIColor(red: 80.0 / 255.0, green: 166.0 / 255.0, blue: 70.0 / 255.0, alpha: 1)
    }
    
    class func meunGreenTextColor() -> UIColor {
        
        return UIColor(red: 1.0 / 255.0, green: 128.0 / 255.0, blue: 57.0 / 255.0, alpha: 1)
    }
    
    class func meunCellSelectedColor() -> UIColor {
        
        return UIColor(red: 212.0 / 255.0, green: 242.0 / 255.0, blue: 226.0 / 255.0, alpha: 1)
    }
    
    class func darkGrayTextColor() -> UIColor {
        
        return UIColor(red: 142.0 / 255.0, green: 142.0 / 255.0, blue: 147.0 / 255.0, alpha: 1)
    }
    
    class func mediumGreenColor() -> UIColor {
        
        return UIColor(red: 66.0 / 255.0, green: 157.0 / 255.0, blue: 57.0 / 255.0, alpha: 1)
        //return #colorLiteral(red: 0.3490196078, green: 0.6666666667, blue: 0.2745098039, alpha: 1)
        //return #colorLiteral(red: 0.01960784314, green: 0.737254902, blue: 0.4, alpha: 1)

        //return UIColor(red: 5.0, green: 188.0, blue: 102.0, alpha: 1)
    }
    
    class func lightGreenColor() -> UIColor {
        
        return UIColor(red: 227.0 / 255.0, green: 255.0 / 255.0, blue: 224.0 / 255.0, alpha: 0.95)
    }
    class func searchBarTextGreenColor() -> UIColor {
        
        return  UIColor.colorWithHexString(hexString: "429D39")
    }

    class func blurLightProductColor() -> UIColor {

        return UIColor.colorWithHexString(hexString: "81be6e")
    }
    class func LightGreyBorderColor() -> UIColor {

        return UIColor.colorWithHexString(hexString: "E5ECED")
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
