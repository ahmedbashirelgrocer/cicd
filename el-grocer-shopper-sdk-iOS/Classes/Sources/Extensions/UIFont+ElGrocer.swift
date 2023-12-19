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
            return UIFont.getFont(name: "MarkaziText-SemiBold", size: size)!
        }
        return UIFont.getFont(name: "SFProDisplay-Semibold", size: size)!
        
    }
    class func SFProDisplayBoldFont(_ size:CGFloat) -> UIFont {
        if isArabic {
            return UIFont.getFont(name: "MarkaziText-Bold", size: size)!
        }
        return UIFont.getFont(name: "SFProDisplay-bold", size: size)!
    }
    class func SFProDisplayLightFont(_ size:CGFloat) -> UIFont {
        if isArabic {
            return UIFont.getFont(name: "MarkaziText-Regular", size: size)!
        }
        return UIFont.getFont(name: "SFProDisplay-Light", size: size)!
    }
    class func SFProDisplayMediumFont(_ size:CGFloat) -> UIFont {
        if isArabic {
            return UIFont.getFont(name: "MarkaziText-Medium", size: size)!
        }
        return UIFont.getFont(name: "SFProDisplay-Medium", size: size)!
    }
    class func SFProDisplayNormalFont(_ size:CGFloat) -> UIFont {
        if isArabic {
            return UIFont.getFont(name: "MarkaziText-Regular", size: size)!
        }
        return UIFont.getFont(name: "SFUIDisplay-Regular", size: size)!
    }
    
    class func SFProDisplayHeavyItalic(_ size: CGFloat) -> UIFont {
        if isArabic {
            return UIFont(name: "MarkaziText-Bold", size: size)!
        }
        
        return UIFont(name: "SFProDisplay-HeavyItalic", size: size)!
    }
    
    class func SFProDisplayRegularItalic(_ size: CGFloat) -> UIFont {
        if isArabic {
            return UIFont(name: "MarkaziText-Regular", size: size)!
        }
        
        return UIFont(name: "SFProDisplay-RegularItalic", size: size)!
    }
    
    //
    class func HelveticaBoldFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "HelveticaNeue-Bold", size: size)!
    }
    class func HelveticaMediumFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "HelveticaNeue-Medium", size: size)!
    }
    class func HelveticaRegularFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "HelveticaNeue", size: size)!
    }
    //HelveticaNeue-Medium
    
    class func SFUIRegularFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SFUIDisplay-Regular", size: size)!
    }
    class func SFUISemiBoldFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SFUIDisplay-Semibold", size: size)!
    }
    
    class func blackFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "Gotham-Black", size: size)!
    }
    
    class func boldFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "Gotham-Bold", size: size)!
    }
    
    class func lightFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "Gotham-Light", size: size)!
    }
    
    class func mediumFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "Gotham-Medium", size: size)!
    }
    
    class func thinFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "Gotham-Thin", size: size)!
    }
    
    class func ultraFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "Gotham-Ultra", size: size)!
    }
    
    class func lightItalicFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "Gotham-XLightItalic", size: size)!
    }
    
    class func bookItalicFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "Gotham-BookItalic", size: size)!
    }
    
    
    //MARK: Open Sans Fonts
    
    
    class func openSansBoldFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "OpenSans-Bold", size: size)!
    }
    
    class func openSansBoldItalicFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "OpenSans-BoldItalic", size: size)!
    }
    
    class func openSansExtraBoldFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "OpenSans-ExtraBold", size: size)!
    }
    
    class func openSansExtraBoldItalicFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "OpenSans-ExtraBoldItalic", size: size)!
    }
    
    class func openSansItalic(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "OpenSans-Italic", size: size)!
    }
    
    class func openSansLightFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "OpenSans-Light", size: size)!
    }
    
    class func openSansLightItalicFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "OpenSans-LightItalic", size: size)!
    }
    
    class func openSansRegularFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "OpenSans", size: size)!
    }
    
    class func openSansSemiBoldFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "OpenSans-Semibold", size: size)!
    }
    
    class func openSansSemiBoldItalicFont(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "OpenSans-SemiboldItalic", size: size)!
    }
    
    //MARK: San Francisco Display
    
    class func sanFranciscoDisplayBlack(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoDisplay-Black", size: size)!
    }
    
    class func sanFranciscoDisplayBold(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoDisplay-Bold", size: size)!
    }
    
    class func sanFranciscoDisplayHeavy(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoDisplay-Heavy", size: size)!
    }
    
    class func sanFranciscoDisplayLight(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoDisplay-Light", size: size)!
    }
    
    class func sanFranciscoDisplayMedium(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoDisplay-Medium", size: size)!
    }
    
    class func sanFranciscoDisplayRegular(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoDisplay-Regular", size: size)!
    }
    
    class func sanFranciscoDisplaySemiBold(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoDisplay-Semibold", size: size)!
    }
    
    class func sanFranciscoDisplayThin(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoDisplay-Thin", size: size)!
    }
    
    class func sanFranciscoDisplayUltralight(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoDisplay-Ultralight", size: size)!
    }
    
    
    //MARK: San Francisco Text
    
    class func sanFranciscoTextBold(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoText-Bold", size: size)!
    }
    
    class func sanFranciscoTextBoldItalic(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoText-BoldItalic", size: size)!
    }
    
    class func sanFranciscoTextHeavy(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoText-Heavy", size: size)!
    }
    
    class func sanFranciscoTextHeavyItalic(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoText-HeavyItalic", size: size)!
    }
    
    class func sanFranciscoTextLight(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoText-Light", size: size)!
    }
    
    class func sanFranciscoDisplay(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "OpenSans-SemiboldItalic", size: size)!
    }
    
    class func sanFranciscoTextLightItalic(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoText-LightItalic", size: size)!
    }
    
    class func sanFranciscoTextMedium(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoText-Medium", size: size)!
    }
    
    class func sanFranciscoTextMediumItalic(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoText-MediumItalic", size: size)!
    }
    
    class func sanFranciscoTextRegular(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoText-Regular", size: size)!
    }
    
    class func sanFranciscoTextRegularItalic(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoText-RegularItalic", size: size)!
    }
    
    class func sanFranciscoTextSemibold(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoText-Semibold", size: size)!
    }
    
    class func sanFranciscoTextSemiboldItalic(_ size:CGFloat) -> UIFont {
        
        return UIFont.getFont(name: "SanFranciscoText-SemiboldItalic", size: size)!
    }
}
extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        return self
        // following code is creating crash from ios 16.
//        let newDescriptor = fontDescriptor.addingAttributes([.traits: [
//            UIFontDescriptor.TraitKey.weight: weight]])
//        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}


extension UIFont {
    static func getFont(name: String, size: CGFloat) -> UIFont? {
        if let font = UIFont.init(name: name, size: size) {
            return font
        } else {
            for fileName in fontFiles {
                jbs_registerFont(withFilenameString: fileName, bundle: .resource)
            }
            return UIFont.init(name: name, size: size)
        }
    }
    
    private static var fontFiles: [String] { [
        "MarkaziText-Bold.ttf",
        "MarkaziText-Medium.ttf",
        "MarkaziText-Regular.ttf",
        "MarkaziText-SemiBold.ttf",
        "Gotham-Black.otf",
        "Gotham-Bold.otf",
        "Gotham-Book-Italic.otf",
        "Gotham-Light-Italic.otf",
        "Gotham-Light.otf",
        "Gotham-Medium.otf",
        "Gotham-Thin.otf",
        "Gotham-Ultra.otf",
        "OpenSans-Bold.ttf",
        "OpenSans-BoldItalic.ttf",
        "OpenSans-ExtraBold.ttf",
        "OpenSans-ExtraBoldItalic.ttf",
        "OpenSans-Italic.ttf",
        "OpenSans-Light.ttf",
        "OpenSans-LightItalic.ttf",
        "OpenSans-Regular.ttf",
        "OpenSans-Semibold.ttf",
        "OpenSans-SemiboldItalic.ttf",
        "SF-Pro-Display-Black.otf",
        "SF-Pro-Display-BlackItalic.otf",
        "SF-Pro-Display-Bold.otf",
        "SF-Pro-Display-BoldItalic.otf",
        "SF-Pro-Display-Heavy.otf",
        "SF-Pro-Display-HeavyItalic.otf",
        "SF-Pro-Display-Light.otf",
        "SF-Pro-Display-LightItalic.otf",
        "SF-Pro-Display-Medium.otf",
        "SF-Pro-Display-MediumItalic.otf",
        "SF-Pro-Display-Regular.otf",
        "SF-Pro-Display-RegularItalic.otf",
        "SF-Pro-Display-Semibold.otf",
        "SF-Pro-Display-SemiboldItalic.otf",
        "SF-Pro-Display-Thin.otf",
        "SF-Pro-Display-ThinItalic.otf",
        "SF-Pro-Display-Ultralight.otf",
        "SF-Pro-Display-UltralightItalic.otf",
        "SF-UI-Display-Medium.otf",
        "SF-UI-Display-Regular.otf",
        "SF-UI-Display-Semibold.otf",
        "SanFranciscoDisplay-Black.otf",
        "SanFranciscoDisplay-Bold.otf",
        "SanFranciscoDisplay-Heavy.otf",
        "SanFranciscoDisplay-Light.otf",
        "SanFranciscoDisplay-Medium.otf",
        "SanFranciscoDisplay-Regular.otf",
        "SanFranciscoDisplay-Semibold.otf",
        "SanFranciscoDisplay-Thin.otf",
        "SanFranciscoDisplay-Ultralight.otf",
        "SanFranciscoText-Bold.otf",
        "SanFranciscoText-BoldItalic.otf",
        "SanFranciscoText-Heavy.otf",
        "SanFranciscoText-HeavyItalic.otf",
        "SanFranciscoText-Light.otf",
        "SanFranciscoText-LightItalic.otf",
        "SanFranciscoText-Medium.otf",
        "SanFranciscoText-MediumItalic.otf",
        "SanFranciscoText-Regular.otf",
        "SanFranciscoText-RegularItalic.otf",
        "SanFranciscoText-Semibold.otf",
        "SanFranciscoText-SemiboldItalic.otf"
    ] }
    
    private static func jbs_registerFont(withFilenameString filenameString: String, bundle: Bundle) {
        
        guard let pathForResourceString = bundle.path(forResource: filenameString, ofType: nil) else {
           elDebugPrint("UIFont+:  Failed to register font - path for resource not found.")
            return
        }
        
        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
           elDebugPrint("UIFont+:  Failed to register font - font data could not be loaded.")
            return
        }
        
        guard let dataProvider = CGDataProvider(data: fontData) else {
           elDebugPrint("UIFont+:  Failed to register font - data provider could not be loaded.")
            return
        }
        
        guard let font = CGFont(dataProvider) else {
           elDebugPrint("UIFont+:  Failed to register font - font could not be loaded.")
            return
        }
        
        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
           elDebugPrint("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }
}
