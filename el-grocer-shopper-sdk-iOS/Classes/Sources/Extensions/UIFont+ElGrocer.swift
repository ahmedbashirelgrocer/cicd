//
//  UIFont+ElGrocer.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 01.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {

    static var isArabic: Bool = ElGrocerUtility.sharedInstance.isArabicSelected()
    
    class func SFProDisplaySemiBoldFont(_ size:CGFloat) -> UIFont {
        if isArabic {
            return UIFont(name: "MarkaziText-SemiBold", size: size)!
        }
        return UIFont(name: "SFProDisplay-Semibold", size: size)!
        
    }
    class func SFProDisplayBoldFont(_ size:CGFloat) -> UIFont {
        if isArabic {
            return UIFont(name: "MarkaziText-Bold", size: size)!
        }
        return UIFont(name: "SFProDisplay-bold", size: size)!
    }
    class func SFProDisplayLightFont(_ size:CGFloat) -> UIFont {
        if isArabic {
            return UIFont(name: "MarkaziText-Regular", size: size)!
        }
        return UIFont(name: "SFProDisplay-Light", size: size)!
    }
    class func SFProDisplayMediumFont(_ size:CGFloat) -> UIFont {
        if isArabic {
            return UIFont(name: "MarkaziText-Medium", size: size)!
        }
        return UIFont(name: "SFProDisplay-Medium", size: size)!
    }
    class func SFProDisplayNormalFont(_ size:CGFloat) -> UIFont {
        if isArabic {
            return UIFont(name: "MarkaziText-Regular", size: size)!
        }
        return UIFont(name: "SFUIDisplay-Regular", size: size)!
    }
 
    //
    class func HelveticaBoldFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "HelveticaNeue-Bold", size: size)!
    }
    class func HelveticaMediumFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "HelveticaNeue-Medium", size: size)!
    }
    class func HelveticaRegularFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "HelveticaNeue", size: size)!
    }
//HelveticaNeue-Medium

    class func SFUIRegularFont(_ size:CGFloat) -> UIFont {

        return UIFont(name: "SFUIDisplay-Regular", size: size)!
    }
    class func SFUISemiBoldFont(_ size:CGFloat) -> UIFont {

        return UIFont(name: "SFUIDisplay-Semibold", size: size)!
    }

    class func blackFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "Gotham-Black", size: size)!
    }
    
    class func boldFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "Gotham-Bold", size: size)!
    }
    
    class func bookFont(_ size:CGFloat) -> UIFont {

        return UIFont(name: "Gotham-Book", size: size)!
    }
    
    class func lightFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "Gotham-Light", size: size)!
    }
    
    class func mediumFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "Gotham-Medium", size: size)!
    }
    
    class func thinFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "Gotham-Thin", size: size)!
    }
    
    class func ultraFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "Gotham-Ultra", size: size)!
    }
    
    class func lightItalicFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "Gotham-XLightItalic", size: size)!
    }
    
    class func bookItalicFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "Gotham-BookItalic", size: size)!
    }
    
    
    //MARK: Open Sans Fonts
    
    
    class func openSansBoldFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "OpenSans-Bold", size: size)!
    }
    
    class func openSansBoldItalicFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "OpenSans-BoldItalic", size: size)!
    }
    
    class func openSansExtraBoldFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "OpenSans-ExtraBold", size: size)!
    }
    
    class func openSansExtraBoldItalicFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "OpenSans-ExtraBoldItalic", size: size)!
    }
    
    class func openSansItalic(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "OpenSans-Italic", size: size)!
    }
    
    class func openSansLightFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "OpenSans-Light", size: size)!
    }
    
    class func openSansLightItalicFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "OpenSans-LightItalic", size: size)!
    }
    
    class func openSansRegularFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "OpenSans", size: size)!
    }
    
    class func openSansSemiBoldFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "OpenSans-Semibold", size: size)!
    }
    
    class func openSansSemiBoldItalicFont(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "OpenSans-SemiboldItalic", size: size)!
    }
    
    //MARK: San Francisco Display
    
    class func sanFranciscoDisplayBlack(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoDisplay-Black", size: size)!
    }
    
    class func sanFranciscoDisplayBold(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoDisplay-Bold", size: size)!
    }
    
    class func sanFranciscoDisplayHeavy(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoDisplay-Heavy", size: size)!
    }
    
    class func sanFranciscoDisplayLight(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoDisplay-Light", size: size)!
    }
    
    class func sanFranciscoDisplayMedium(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoDisplay-Medium", size: size)!
    }
    
    class func sanFranciscoDisplayRegular(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoDisplay-Regular", size: size)!
    }
    
    class func sanFranciscoDisplaySemiBold(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoDisplay-Semibold", size: size)!
    }
    
    class func sanFranciscoDisplayThin(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoDisplay-Thin", size: size)!
    }
    
    class func sanFranciscoDisplayUltralight(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoDisplay-Ultralight", size: size)!
    }
    
    
    //MARK: San Francisco Text
    
    class func sanFranciscoTextBold(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoText-Bold", size: size)!
    }
    
    class func sanFranciscoTextBoldItalic(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoText-BoldItalic", size: size)!
    }
    
    class func sanFranciscoTextHeavy(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoText-Heavy", size: size)!
    }
    
    class func sanFranciscoTextHeavyItalic(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoText-HeavyItalic", size: size)!
    }
    
    class func sanFranciscoTextLight(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoText-Light", size: size)!
    }
    
    class func sanFranciscoDisplay(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "OpenSans-SemiboldItalic", size: size)!
    }
    
    class func sanFranciscoTextLightItalic(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoText-LightItalic", size: size)!
    }
    
    class func sanFranciscoTextMedium(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoText-Medium", size: size)!
    }
    
    class func sanFranciscoTextMediumItalic(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoText-MediumItalic", size: size)!
    }
    
    class func sanFranciscoTextRegular(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoText-Regular", size: size)!
    }
    
    class func sanFranciscoTextRegularItalic(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoText-RegularItalic", size: size)!
    }
    
    class func sanFranciscoTextSemibold(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoText-Semibold", size: size)!
    }
    
    class func sanFranciscoTextSemiboldItalic(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "SanFranciscoText-SemiboldItalic", size: size)!
    }
    
    // MARK: Avenir Next Condensed Fonts
    
    class func AvenirNextCondensedRegular(_ size:CGFloat) -> UIFont {
        
        return UIFont(name: "AvenirNextCondensed-Regular", size: size)!
    }
}
extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes([.traits: [
            UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}
