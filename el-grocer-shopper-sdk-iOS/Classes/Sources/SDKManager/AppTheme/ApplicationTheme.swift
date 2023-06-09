//
//  ApplicationTheme.swift
//  Adyen
//
//  Created by Abdul Saboor on 15/11/2022.
//

import UIKit

public protocol Theme {

    var currentLocationBgColor: UIColor { get }
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
    
    //MARK: PrimaryTheme for activity indicators and things
    var themeBasePrimaryColor: UIColor { get }
    var themeBaseSecondaryDarkColor: UIColor { get }
    //MARK: Buttons
    var buttonEnableBGColor: UIColor { get }
    var buttonEnableSecondaryDarkBGColor: UIColor { get }
    var buttonDisableBGColor: UIColor { get }
    var buttonTextWithBackgroundColor: UIColor { get }
    var buttonTextWithClearBGColor: UIColor { get }
    var buttonPrimaryBlackTextWithClearBGColor: UIColor { get }
    var buttonOrderCancelTextColor: UIColor { get }
    var buttonWithBorderTextColor: UIColor { get }
    //MARK: Labels
    var labelHeadingTextColor: UIColor { get }
    var labeldiscriptionTextColor: UIColor { get }
    var labelLightgrayTextColor: UIColor { get }
    var labelPrimaryBaseTextColor: UIColor { get }
    var labelSecondaryBaseColor: UIColor { get }
    var labelTextWithBGColor: UIColor { get }
    var labelHighlightedOOSColor: UIColor { get }
    var labelPromotionalTextColor: UIColor { get }
    var labelGroceryCellSecondaryDarkTextColor: UIColor { get }
    //MARK: textField
    var textFieldGreyBGColor: UIColor { get }
    var textFieldWhiteBGColor: UIColor { get }
    var textFieldBorderActiveColor: UIColor { get }
    var textFieldBorderValidationBorderColor: UIColor { get }
    var textFieldBorderInActiveClearColor: UIColor { get }
    var textFieldPlaceHolderTextColor: UIColor { get }
    var textFieldTextColor: UIColor { get }
    //MARK: Views
    var viewPrimaryBGColor: UIColor { get }
    var viewSecondaryDarkBGColor: UIColor { get }
    var viewWhiteBGColor: UIColor { get }
    var viewSmilePurpleBGColor: UIColor { get }
    var viewPromotionRedColor: UIColor { get }
    var viewOOSItemRedColor: UIColor { get }
    var viewAlertLightYellowColor: UIColor { get }
    var viewLimmitedStockSecondaryDarkBGColor: UIColor { get }
    //MARK: Category Pills
    var pillSelectedBGColor: UIColor { get }
    var pillUnSelectedBGColor: UIColor { get }
    var pillSelectedTextColor: UIColor { get }
    var pillUnSelectedTextColor: UIColor { get }
    //MARK: tableView
    var tableViewBGGreyColor: UIColor { get }
    var tableViewBGWhiteColor: UIColor { get }
    //MARK: page Control
    var pageControlActiveColor: UIColor { get }
    var pageControlPrimaryInActiveColor: UIColor { get }
    var pageControlSecondaryInActiveColor: UIColor { get }
    //MARK: Selection view Borders and selcted view
    var primarySelectionColor: UIColor { get }
    var primaryNoSelectionColor: UIColor { get }
    var secondaryNoSelectionlightColor: UIColor { get }
    //MARK: Current Orders & OOS Product
    var currentOrdersCollectionCellBGColor: UIColor { get }
    var currentOrdersPageControlActiveColor: UIColor { get }
    var currentOrdersPageControlInActiveColor: UIColor { get }
    
    //MARK: StorePage
    var StorePageCategoryViewBgColor: UIColor { get }
    
    
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
    
    var currentLocationBgColor: UIColor = ElgrocerBaseColors.elgrocerLightGreenBgColor
    
    //MARK: PrimaryTheme for activity indicators and things
    var themeBasePrimaryColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var themeBaseSecondaryDarkColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreenColour
    //MARK: Buttons
    var buttonEnableBGColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var buttonEnableSecondaryDarkBGColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreenColour
    var buttonDisableBGColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreyColor
    var buttonTextWithBackgroundColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var buttonTextWithClearBGColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var buttonPrimaryBlackTextWithClearBGColor: UIColor = ElgrocerBaseColors.elgrocerTextBlackColour
    var buttonOrderCancelTextColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    var buttonWithBorderTextColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    //MARK: Labels
    var labelHeadingTextColor: UIColor = ElgrocerBaseColors.elgrocerTextBlackColour
    var labeldiscriptionTextColor: UIColor = ElgrocerBaseColors.elgrocerSecondaryBlackTextColour
    var labelLightgrayTextColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreyColor
    var labelPrimaryBaseTextColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var labelSecondaryBaseColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreenColour
    var labelTextWithBGColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var labelHighlightedOOSColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    var labelPromotionalTextColor: UIColor = ElgrocerBaseColors.elgrocerPromotionYellowColour
    var labelGroceryCellSecondaryDarkTextColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreenColour
    //MARK: textField
    var textFieldGreyBGColor: UIColor = ElgrocerBaseColors.elgrocerBackgroundGreyColour
    var textFieldWhiteBGColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var textFieldBorderActiveColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var textFieldBorderValidationBorderColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    var textFieldBorderInActiveClearColor: UIColor = ElgrocerBaseColors.elgrocerClearColour
    var textFieldPlaceHolderTextColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreyColor
    var textFieldTextColor: UIColor = ElgrocerBaseColors.elgrocerTextBlackColour
    //MARK: Views
    var viewPrimaryBGColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var viewSecondaryDarkBGColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreenColour
    var viewWhiteBGColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var viewSmilePurpleBGColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var viewPromotionRedColor: UIColor = ElgrocerBaseColors.elgrocerRedPromotionColour
    var viewOOSItemRedColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    var viewAlertLightYellowColor: UIColor = ElgrocerBaseColors.elgrocerAlertYellowColour
    var viewLimmitedStockSecondaryDarkBGColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreenColour
    //MARK: Category Pills
    var pillSelectedBGColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var pillUnSelectedBGColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var pillSelectedTextColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var pillUnSelectedTextColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreenColour
    //MARK: tableView
    var tableViewBGGreyColor: UIColor = ElgrocerBaseColors.elgrocerBackgroundGreyColour
    var tableViewBGWhiteColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    //MARK: page Control
    var pageControlActiveColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var pageControlPrimaryInActiveColor: UIColor = ElgrocerBaseColors.elgrocerBorderGeyColour
    var pageControlSecondaryInActiveColor: UIColor = ElgrocerBaseColors.elgrocerLightGreenColour
    //MARK: Selection view Borders and selcted view
    var primarySelectionColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var primaryNoSelectionColor: UIColor = ElgrocerBaseColors.elgrocerSecondaryBlackTextColour
    var secondaryNoSelectionlightColor: UIColor = ElgrocerBaseColors.elgrocerBorderGeyColour
    //MARK: Current Orders & OOS Product
    var currentOrdersCollectionCellBGColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreenColour
    var currentOrdersPageControlActiveColor: UIColor = ElgrocerBaseColors.elgrocerGreenColour
    var currentOrdersPageControlInActiveColor: UIColor = ElgrocerBaseColors.elgrocerLightGreenColour
    
    //MARK: StorePage
    var StorePageCategoryViewBgColor: UIColor { ElgrocerBaseColors.elgrocerWhiteColour }
}

struct SmileSDKTheme: Theme {
    
    var currentLocationBgColor: UIColor { #colorLiteral(red: 0.9647058824, green: 0.9176470588, blue: 0.9882352941, alpha: 1) }
    var navigationBarWhiteColor: UIColor { #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    var replacementGreenBGColor: UIColor { #colorLiteral(red: 0.7647058824, green: 0.937254902, blue: 0.8549019608, alpha: 1) }
    var replacementGreenTextColor: UIColor { #colorLiteral(red: 0, green: 0.2784313725, blue: 0.2117647059, alpha: 1) }
    var navigationBarColor: UIColor { #colorLiteral(red: 0.937254902, green: 0.9411764706, blue: 0.9764705882, alpha: 1)  }
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
    //MARK: StorePage
    var StorePageCategoryViewBgColor: UIColor  { #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) }
//    { #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1) }
    
    //MARK: PrimaryTheme for activity indicators and things
    var themeBasePrimaryColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var themeBaseSecondaryDarkColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    //MARK: Buttons
    var buttonEnableBGColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var buttonEnableSecondaryDarkBGColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var buttonDisableBGColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreyColor
    var buttonTextWithBackgroundColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var buttonTextWithClearBGColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var buttonPrimaryBlackTextWithClearBGColor: UIColor = ElgrocerBaseColors.elgrocerTextBlackColour
    var buttonOrderCancelTextColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    var buttonWithBorderTextColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    //MARK: Labels
    var labelHeadingTextColor: UIColor = ElgrocerBaseColors.elgrocerTextBlackColour
    var labeldiscriptionTextColor: UIColor = ElgrocerBaseColors.elgrocerSecondaryBlackTextColour
    var labelLightgrayTextColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreyColor
    var labelPrimaryBaseTextColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var labelSecondaryBaseColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleSecondaryColor
    var labelTextWithBGColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var labelHighlightedOOSColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    var labelPromotionalTextColor: UIColor = ElgrocerBaseColors.elgrocerPromotionYellowColour
    var labelGroceryCellSecondaryDarkTextColor: UIColor = ElgrocerBaseColors.elgrocerTextBlackColour
    //MARK: textField
    var textFieldGreyBGColor: UIColor = ElgrocerBaseColors.elgrocerBackgroundGreyColour
    var textFieldWhiteBGColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var textFieldBorderActiveColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var textFieldBorderValidationBorderColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    var textFieldBorderInActiveClearColor: UIColor = ElgrocerBaseColors.elgrocerClearColour
    var textFieldPlaceHolderTextColor: UIColor = ElgrocerBaseColors.elgrocerDarkGreyColor
    var textFieldTextColor: UIColor = ElgrocerBaseColors.elgrocerTextBlackColour
    //MARK: Views
    var viewPrimaryBGColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var viewSecondaryDarkBGColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var viewWhiteBGColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var viewSmilePurpleBGColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var viewPromotionRedColor: UIColor = ElgrocerBaseColors.elgrocerRedPromotionColour
    var viewOOSItemRedColor: UIColor = ElgrocerBaseColors.elgrocerRedValidationColor
    var viewAlertLightYellowColor: UIColor = ElgrocerBaseColors.elgrocerAlertYellowColour
    var viewLimmitedStockSecondaryDarkBGColor: UIColor = ElgrocerBaseColors.elgrocerLimitedStockDarkGreenColour
    //MARK: Category Pills
    var pillSelectedBGColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var pillUnSelectedBGColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var pillSelectedTextColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    var pillUnSelectedTextColor: UIColor = ElgrocerBaseColors.elgrocerTextBlackColour
    //MARK: tableView
    var tableViewBGGreyColor: UIColor = ElgrocerBaseColors.elgrocerBackgroundGreyColour
    var tableViewBGWhiteColor: UIColor = ElgrocerBaseColors.elgrocerWhiteColour
    //MARK: page Control
    var pageControlActiveColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var pageControlPrimaryInActiveColor: UIColor = ElgrocerBaseColors.elgrocerBorderGeyColour
    var pageControlSecondaryInActiveColor: UIColor = ElgrocerBaseColors.elgrocerBorderGeyColour
    //MARK: Selection view Borders and selcted view
    var primarySelectionColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleColour
    var primaryNoSelectionColor: UIColor = ElgrocerBaseColors.elgrocerSecondaryBlackTextColour
    var secondaryNoSelectionlightColor: UIColor = ElgrocerBaseColors.elgrocerBorderGeyColour
    //MARK: Current Orders & OOS Product
    var currentOrdersCollectionCellBGColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleSecondaryColor
    var currentOrdersPageControlActiveColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleSecondarySelectionColor
    var currentOrdersPageControlInActiveColor: UIColor = ElgrocerBaseColors.elgrocerSmilePurpleSecondaryNoSelectionColor
    
   
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










