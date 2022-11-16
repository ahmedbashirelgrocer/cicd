//
//  ApplicationTheme.swift
//  Adyen
//
//  Created by Abdul Saboor on 15/11/2022.
//

import UIKit

public protocol Theme {

    var navigationBarWhiteColor: UIColor { get }
    var replacementGreenBGColor: UIColor { get }
    var replacementGreenTextColor: UIColor { get }
    var navigationBarColor: UIColor { get }
    var unselectedPageControl: UIColor { get }
    var buttonSelectionColor: UIColor { get }
    var secondaryDarkGreenColor: UIColor { get }
    var textFieldPlaceHolderColor: UIColor { get }
    var bottomSheetShadowColor: UIColor { get }
    var newBlackColor: UIColor { get }
    var textViewPlaceHolderColor: UIColor { get }
    var secondaryBlackColor: UIColor { get }
    var disableButtonColor: UIColor { get }
    var textfieldErrorColor: UIColor { get }
    var textfieldBackgroundColor: UIColor { get }
    var tableViewBackgroundColor: UIColor { get }
    var elGrocerYellowColor: UIColor { get }
    var newBorderGreyColor: UIColor { get }
    var searchBarBorderGreyColor: UIColor { get }
    var promotionYellowColor: UIColor { get }
    var promotionRedColor: UIColor { get }
    var limitedStockGreenColor: UIColor { get }
    var smilePrimaryPurpleColor: UIColor { get }
    var smilePointBackgroundColor: UIColor { get }
    var smilePrimaryOrangeColor: UIColor { get }
    var dashedBorderDefaultColor: UIColor { get }
    var alertBackgroundColor: UIColor { get }
    var lightGreyColor: UIColor { get }
    var smileBaseColor: UIColor { get }
    var smileSecondaryColor: UIColor { get }
    
    var separatorColor: UIColor { get }
    var newGreyColor: UIColor { get }
    var selectionTabDark: UIColor { get }
    var darkBorderGrayColor: UIColor { get }
    var borderGrayColor: UIColor { get }
    var redInfoColor: UIColor { get }
    var lightGrayBGColor: UIColor { get }
    var darkGrayTextColor: UIColor { get }
    var lightTextGrayColor: UIColor { get }
    var newUIrecipelightGrayBGColor: UIColor { get }
    var emptyViewTextColor: UIColor { get }
    
    //MARK: Buttons
    var buttonEnableBGColor: UIColor { get }
    var buttonDisableBGColor: UIColor { get }
    var buttonTextWhiteColor: UIColor { get }
    var buttonTextGreenColor: UIColor { get }
    var buttonOrderCancelTextColor: UIColor { get }
    //MARK: Labels
    var labelHeadingTextColor: UIColor { get }
    var labeldiscriptionTextColor: UIColor { get }
    var labelLightgrayTextColor: UIColor { get }
    var labelPrimaryGreenTextColor: UIColor { get }
    var labelDarkGreenColor: UIColor { get }
    var labelWhiteTextColor: UIColor { get }
    var labelRedHighlightedOOSColor: UIColor { get }
    //MARK: textField
    var textFieldGreyBGColor: UIColor { get }
    var textFieldWhiteBGColor: UIColor { get }
    var textFieldBorderGreenColor: UIColor { get }
    var textFieldBorderRedValidationBorderColor: UIColor { get }
    var textFieldBorderClearColor: UIColor { get }
    var textFieldPlaceHolderTextColor: UIColor { get }
    var textFieldTextColor: UIColor { get }
    //MARK: Views
    var viewGreenBGColor: UIColor { get }
    var viewDarkGreenBGColor: UIColor { get }
    var viewWhiteBGColor: UIColor { get }
    var viewSmilePurpleBGColor: UIColor { get }
    var viewPromotionRedColor: UIColor { get }
    var viewOOSItemRedColor: UIColor { get }
    var viewAlertLightYellowColor: UIColor { get }
    //MARK: Category Pills
    var pillSelectedGreenBGColor: UIColor { get }
    var pillUnSelectedWhiteBGColor: UIColor { get }
    var pillSelectedTextColor: UIColor { get }
    var pillUnSelectedTextColor: UIColor { get }
    //MARK: tableView
    var tableViewBGGreyColor: UIColor { get }
    var tableViewBGWhiteColor: UIColor { get }
}


struct ElgrocerTheme: Theme {
    
    var navigationBarWhiteColor: UIColor { #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    var replacementGreenBGColor: UIColor { #colorLiteral(red: 0.7647058824, green: 0.937254902, blue: 0.8549019608, alpha: 1) }
    var replacementGreenTextColor: UIColor { #colorLiteral(red: 0, green: 0.2784313725, blue: 0.2117647059, alpha: 1) }
    var navigationBarColor: UIColor { #colorLiteral(red: 0.01960784314, green: 0.737254902, blue: 0.4, alpha: 1)  }
    var unselectedPageControl: UIColor {  #colorLiteral(red: 0.7647058824, green: 0.937254902, blue: 0.8549019608, alpha: 1) }
    var buttonSelectionColor: UIColor { #colorLiteral(red: 0.01960784314, green: 0.737254902, blue: 0.4, alpha: 1) }
    var secondaryDarkGreenColor: UIColor { #colorLiteral(red: 0, green: 0.2784313725, blue: 0.2117647059, alpha: 1)  }
    var textFieldPlaceHolderColor: UIColor { #colorLiteral(red: 0.5647058824, green: 0.5647058824, blue: 0.5647058824, alpha: 1)  }
    var bottomSheetShadowColor: UIColor { #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.16) }
    var newBlackColor: UIColor { #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) }
    var textViewPlaceHolderColor: UIColor { #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.74)  }
    var secondaryBlackColor: UIColor { #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.3490196078, alpha: 1) }
    var disableButtonColor: UIColor { #colorLiteral(red: 0.5647058824, green: 0.5647058824, blue: 0.5647058824, alpha: 1) }
    var textfieldErrorColor: UIColor { #colorLiteral(red: 0.5960784314, green: 0.04705882353, blue: 0, alpha: 1) }
    var textfieldBackgroundColor: UIColor { #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) }
    var tableViewBackgroundColor: UIColor { #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) }
    var elGrocerYellowColor: UIColor { #colorLiteral(red: 1, green: 0.8352941176, blue: 0.1803921569, alpha: 1) }
    var newBorderGreyColor: UIColor { #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1) }
    var searchBarBorderGreyColor: UIColor { #colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.8941176471, alpha: 1) }
    var promotionYellowColor: UIColor { #colorLiteral(red: 0.9803921569, green: 0.8901960784, blue: 0.2980392157, alpha: 1) }
    var promotionRedColor: UIColor { #colorLiteral(red: 0.8, green: 0.2235294118, blue: 0.1921568627, alpha: 1) }
    var limitedStockGreenColor: UIColor { #colorLiteral(red: 0, green: 0.2784313725, blue: 0.2117647059, alpha: 1) }
    var smilePrimaryPurpleColor: UIColor { #colorLiteral(red: 0.5294117647, green: 0.3294117647, blue: 0.631372549, alpha: 1) }
    var smilePointBackgroundColor: UIColor { #colorLiteral(red: 0.5529411765, green: 0.3215686275, blue: 0.5921568627, alpha: 1) }
    var smilePrimaryOrangeColor: UIColor { #colorLiteral(red: 0.8784313725, green: 0.2392156863, blue: 0.1490196078, alpha: 1) }
    var dashedBorderDefaultColor: UIColor { #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1)}
    var alertBackgroundColor: UIColor { #colorLiteral(red: 1, green: 0.9490196078, blue: 0.7294117647, alpha: 1) }
    var lightGreyColor: UIColor { #colorLiteral(red: 0.568627451, green: 0.568627451, blue: 0.568627451, alpha: 1) }
    var smileBaseColor: UIColor { #colorLiteral(red: 0.5294117647, green: 0.3294117647, blue: 0.631372549, alpha: 1) }
    var smileSecondaryColor: UIColor { #colorLiteral(red: 0.8784313725, green: 0.2392156863, blue: 0.1490196078, alpha: 1) }
    
    var separatorColor: UIColor { #colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.8941176471, alpha: 1) }
    var newGreyColor: UIColor { #colorLiteral(red: 0.5647058824, green: 0.5647058824, blue: 0.5647058824, alpha: 1) }
    var selectionTabDark: UIColor { #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.3490196078, alpha: 1) }
    var darkBorderGrayColor: UIColor { #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1) }
    var borderGrayColor: UIColor { #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1) }
    var redInfoColor: UIColor { #colorLiteral(red: 0.5960784314, green: 0.04705882353, blue: 0, alpha: 1) }
    var lightGrayBGColor: UIColor { #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) }
    var darkGrayTextColor: UIColor { #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5568627451, alpha: 1) }
    var lightTextGrayColor: UIColor { #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) }
    var newUIrecipelightGrayBGColor: UIColor { #colorLiteral(red: 0.9215686275, green: 0.9254901961, blue: 0.9333333333, alpha: 1) }
    var emptyViewTextColor: UIColor { #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1) }
    
    //MARK: Buttons
    var buttonEnableBGColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var buttonDisableBGColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreyColor
    var buttonTextWhiteColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var buttonTextGreenColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var buttonOrderCancelTextColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    //MARK: Labels
    var labelHeadingTextColor: UIColor = ElgrocerBaseColors.elgrocerTextBlackColour
    var labeldiscriptionTextColor: UIColor = ElgrocerBaseColors.elgrocerSecondaryBlackTextColour
    var labelLightgrayTextColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreyColor
    var labelPrimaryGreenTextColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var labelDarkGreenColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreenColour
    var labelWhiteTextColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var labelRedHighlightedOOSColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    //MARK: textField
    var textFieldGreyBGColor: UIColor = ElgrocerBaseColors.elgrocerBackgroundGreyColour
    var textFieldWhiteBGColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var textFieldBorderGreenColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var textFieldBorderRedValidationBorderColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    var textFieldBorderClearColor: UIColor = ElgrocerBaseColors.elgrocerClearColour
    var textFieldPlaceHolderTextColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreyColor
    var textFieldTextColor: UIColor = ElgrocerBaseColors.elgrocerTextBlackColour
    //MARK: Views
    var viewGreenBGColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var viewDarkGreenBGColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreenColour
    var viewWhiteBGColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var viewSmilePurpleBGColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var viewPromotionRedColor: UIColor = ElgrocerBaseColors.elgrocerRedPromotionColour
    var viewOOSItemRedColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    var viewAlertLightYellowColor: UIColor = ElgrocerBaseColors.elgrocerAlertYellowColour
    //MARK: Category Pills
    var pillSelectedGreenBGColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var pillUnSelectedWhiteBGColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var pillSelectedTextColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var pillUnSelectedTextColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreenColour
    //MARK: tableView
    var tableViewBGGreyColor: UIColor = ElgrocerBaseColors.elgrocerBackgroundGreyColour
    var tableViewBGWhiteColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
  
}

struct SmileSDKTheme: Theme {
    
    var navigationBarWhiteColor: UIColor { #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    var replacementGreenBGColor: UIColor { #colorLiteral(red: 0.7647058824, green: 0.937254902, blue: 0.8549019608, alpha: 1) }
    var replacementGreenTextColor: UIColor { #colorLiteral(red: 0.5529411765, green: 0.3215686275, blue: 0.5921568627, alpha: 1)  }
    var navigationBarColor: UIColor { #colorLiteral(red: 0.5529411765, green: 0.3215686275, blue: 0.5921568627, alpha: 1)   }
    var unselectedPageControl: UIColor {  #colorLiteral(red: 0.7647058824, green: 0.937254902, blue: 0.8549019608, alpha: 1) }
    var buttonSelectionColor: UIColor { #colorLiteral(red: 0.5529411765, green: 0.3215686275, blue: 0.5921568627, alpha: 1)  }
    var secondaryDarkGreenColor: UIColor { #colorLiteral(red: 0.5529411765, green: 0.3215686275, blue: 0.5921568627, alpha: 1)   }
    var textFieldPlaceHolderColor: UIColor { #colorLiteral(red: 0.5647058824, green: 0.5647058824, blue: 0.5647058824, alpha: 1)  }
    var bottomSheetShadowColor: UIColor { #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.16) }
    var newBlackColor: UIColor { #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) }
    var textViewPlaceHolderColor: UIColor { #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.74)  }
    var secondaryBlackColor: UIColor { #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.3490196078, alpha: 1) }
    var disableButtonColor: UIColor { #colorLiteral(red: 0.5647058824, green: 0.5647058824, blue: 0.5647058824, alpha: 1) }
    var textfieldErrorColor: UIColor { #colorLiteral(red: 0.5960784314, green: 0.04705882353, blue: 0, alpha: 1) }
    var textfieldBackgroundColor: UIColor { #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) }
    var tableViewBackgroundColor: UIColor { #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) }
    var elGrocerYellowColor: UIColor { #colorLiteral(red: 1, green: 0.8352941176, blue: 0.1803921569, alpha: 1) }
    var newBorderGreyColor: UIColor { #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1) }
    var searchBarBorderGreyColor: UIColor { #colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.8941176471, alpha: 1) }
    var promotionYellowColor: UIColor { #colorLiteral(red: 0.9803921569, green: 0.8901960784, blue: 0.2980392157, alpha: 1) }
    var promotionRedColor: UIColor { #colorLiteral(red: 0.8, green: 0.2235294118, blue: 0.1921568627, alpha: 1) }
    var limitedStockGreenColor: UIColor { #colorLiteral(red: 0.4588235294, green: 0.7529411765, blue: 0.7568627451, alpha: 1) }
    var smilePrimaryPurpleColor: UIColor { #colorLiteral(red: 0.5294117647, green: 0.3294117647, blue: 0.631372549, alpha: 1) }
    var smilePointBackgroundColor: UIColor { #colorLiteral(red: 0.5529411765, green: 0.3215686275, blue: 0.5921568627, alpha: 1) }
    var smilePrimaryOrangeColor: UIColor { #colorLiteral(red: 0.8784313725, green: 0.2392156863, blue: 0.1490196078, alpha: 1) }
    var dashedBorderDefaultColor: UIColor { #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1)}
    var alertBackgroundColor: UIColor { #colorLiteral(red: 1, green: 0.9490196078, blue: 0.7294117647, alpha: 1) }
    var lightGreyColor: UIColor { #colorLiteral(red: 0.568627451, green: 0.568627451, blue: 0.568627451, alpha: 1) }
    var smileBaseColor: UIColor { #colorLiteral(red: 0.5294117647, green: 0.3294117647, blue: 0.631372549, alpha: 1) }
    var smileSecondaryColor: UIColor { #colorLiteral(red: 0.8784313725, green: 0.2392156863, blue: 0.1490196078, alpha: 1) }
    
    var separatorColor: UIColor { #colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.8941176471, alpha: 1) }
    var newGreyColor: UIColor { #colorLiteral(red: 0.5647058824, green: 0.5647058824, blue: 0.5647058824, alpha: 1) }
    var selectionTabDark: UIColor { #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.3490196078, alpha: 1) }
    var darkBorderGrayColor: UIColor { #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1) }
    var borderGrayColor: UIColor { #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1) }
    var redInfoColor: UIColor { #colorLiteral(red: 0.5960784314, green: 0.04705882353, blue: 0, alpha: 1) }
    var lightGrayBGColor: UIColor { #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) }
    var darkGrayTextColor: UIColor { #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5568627451, alpha: 1) }
    var lightTextGrayColor: UIColor { #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) }
    var newUIrecipelightGrayBGColor: UIColor { #colorLiteral(red: 0.9215686275, green: 0.9254901961, blue: 0.9333333333, alpha: 1) }
    var emptyViewTextColor: UIColor { #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1) }
//    { #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1) }
    //MARK: Buttons
    var buttonEnableBGColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var buttonDisableBGColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreyColor
    var buttonTextWhiteColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var buttonTextGreenColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var buttonOrderCancelTextColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    //MARK: Labels
    var labelHeadingTextColor: UIColor = ElgrocerBaseColors.elgrocerTextBlackColour
    var labeldiscriptionTextColor: UIColor = ElgrocerBaseColors.elgrocerSecondaryBlackTextColour
    var labelLightgrayTextColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreyColor
    var labelPrimaryGreenTextColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var labelDarkGreenColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreenColour
    var labelWhiteTextColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var labelRedHighlightedOOSColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    //MARK: textField
    var textFieldGreyBGColor: UIColor = ElgrocerBaseColors.elgrocerBackgroundGreyColour
    var textFieldWhiteBGColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var textFieldBorderGreenColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var textFieldBorderRedValidationBorderColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    var textFieldBorderClearColor: UIColor = ElgrocerBaseColors.elgrocerClearColour
    var textFieldPlaceHolderTextColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreyColor
    var textFieldTextColor: UIColor = ElgrocerBaseColors.elgrocerTextBlackColour
    //MARK: Views
    var viewGreenBGColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var viewDarkGreenBGColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreenColour
    var viewWhiteBGColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var viewSmilePurpleBGColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var viewPromotionRedColor: UIColor = ElgrocerBaseColors.elgrocerRedPromotionColour
    var viewOOSItemRedColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    var viewAlertLightYellowColor: UIColor = ElgrocerBaseColors.elgrocerAlertYellowColour
    //MARK: Category Pills
    var pillSelectedGreenBGColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var pillUnSelectedWhiteBGColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var pillSelectedTextColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var pillUnSelectedTextColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreenColour
    //MARK: tableView
    var tableViewBGGreyColor: UIColor = ElgrocerBaseColors.elgrocerBackgroundGreyColour
    var tableViewBGWhiteColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
}

public struct ApplicationTheme {
    static var currentTheme: Theme = SDKManager.shared.launchOptions?.theme ?? ApplicationTheme.smilesSdkTheme()
}

public extension ApplicationTheme {
    static func elGrocerShopperTheme() -> Theme {
        ElgrocerTheme()
    }
}

public extension ApplicationTheme {
    static func smilesSdkTheme() -> Theme {
        SmileSDKTheme()
    }
}










