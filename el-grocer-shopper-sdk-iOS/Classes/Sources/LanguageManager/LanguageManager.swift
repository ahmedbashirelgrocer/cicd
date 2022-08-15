//
//  LanguageManager.swift
//  SMSLocalization
//
//  Created by Macuser on 5/19/16.
//  Copyright © 2016 Macuser. All rights reserved.
//

import UIKit

class LanguageManager: NSObject {
    
    
    var availableLocales = [CustomLocale]()
    public static let sharedInstance = LanguageManager()
    var lprojBasePath = String()
    
    override init() {
        
        super.init()
        let english = CustomLocale(languageCode: GlobalConstants.englishCode, countryCode: "gb", name: "United Kingdom")
        let arabic  = CustomLocale(languageCode: GlobalConstants.arabicCode, countryCode: "Ar", name: "Dubai")
        self.availableLocales = [english,arabic]
        self.lprojBasePath =  getSelectedLocale()
    }
    
    
   /* fileprivate func getSelectedLocale()->String{
        
        let lang = Locale.preferredLanguages//returns array of preferred languages
        let languageComponents: [String : String] = Locale.components(fromIdentifier: lang[0])
        if let languageCode: String = languageComponents["kCFLocaleLanguageCodeKey"]{
            
            for customlocale in availableLocales {
                
                if(customlocale.languageCode == languageCode){
                    
                    return customlocale.languageCode!
                }
            }
        }
        return "en"
    }*/
    
    func getSelectedLocale()->String{
//        let phoneLanguage = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as? String
//        return phoneLanguage!
        
        let lang = Locale.preferredLanguages//returns array of preferred languages
        let languageComponents: [String : String] = Locale.components(fromIdentifier: lang[0])
        if let languageCode: String = languageComponents["kCFLocaleLanguageCodeKey"]{
            
            for customlocale in availableLocales {
                
                if(customlocale.languageCode == languageCode){
                    
                    return customlocale.languageCode!
                }
            }
        }
        return "Base"
    }
    
    func getCurrentBundle()-> Bundle{
        
       /* if let bundle = NSBundle.resource.path(forResource: lprojBasePath, ofType: "lproj"){
            
            return NSBundle(path: bundle)!
            
        }else{
            
            fatalError("lproj files not found on project directory. /n Hint:Localize your strings file")
        }*/
        
        
//        if let bundle = Bundle.resource.path(forResource: lprojBasePath, ofType: "lproj"){
//            return Bundle(path: bundle)!
//        }else{
//            // return NSBundle.resourceBundle()
//            fatalError("lproj files not found on project directory. /n Hint:Localize your strings file")
//        }
        return Bundle.resource
    }
    
    public func setLocale(_ langCode:String){
        
       /* UserDefaults.standard.set([langCode], forKey: "AppleLanguages")//replaces Locale.preferredLanguages
        UserDefaults.standard.synchronize()*/
        //if !SDKManager.isSmileSDK {
        var langCode = langCode
        
        if langCode == "en" { langCode = "Base" }
        Foundation.UserDefaults.standard.setValue([langCode], forKey: "AppleLanguages")
        //}
        Foundation.UserDefaults.standard.synchronize()
        
        self.lprojBasePath =  getSelectedLocale()
    }
    
    func localizedStringWithKey(_ keyStr:String) -> String{
        
        let bundle = self.getCurrentBundle()
        let localStr = NSLocalizedString(keyStr, tableName: "", bundle: bundle, value: "", comment: "")
        
        return localStr
    }
    
    
    func languageButtonAction(selectedLanguage : String , SDKManagers : SDKManager? = nil , updateRootViewController : Bool = false) {
        
        updateUserLanguage(selectedLanguage)
        Bundle.setLanguage(selectedLanguage)
        
        if SDKManager.isSmileSDK {
            if selectedLanguage == "ar" {
                LanguageManager.sharedInstance.setLocale("ar")
            }else{
                Thread.OnMainThread {
                    LanguageManager.sharedInstance.setLocale("Base")
                }
            }
        } else {
            if selectedLanguage == "ar" {
                UISearchBar.appearance().semanticContentAttribute = .forceRightToLeft
                UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
                SDKManagers?.rootViewController?.view?.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
                UITabBar.appearance().semanticContentAttribute = .forceRightToLeft
                LanguageManager.sharedInstance.setLocale("ar")

            }else{
                Thread.OnMainThread {
                    UISearchBar.appearance().semanticContentAttribute = .forceLeftToRight
                    UINavigationBar.appearance().semanticContentAttribute = .forceLeftToRight
                    SDKManagers?.rootViewController?.view?.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
                    UIView.appearance().semanticContentAttribute = .forceLeftToRight
                    UITabBar.appearance().semanticContentAttribute = .forceLeftToRight
                    LanguageManager.sharedInstance.setLocale("Base")
                }
                
            }
        }
        
        if updateRootViewController {
            
            SDKManagers?.showAnimatedSplashView()
           // SDKManagers.showAppWithMenu()
        }
       
    }
    
    func updateUserLanguage(_ selectedLanguage:String){
                
        guard UserDefaults.isUserLoggedIn() else {return}
        
        ElGrocerApi.sharedInstance.updateUserLanguageToServer(selectedLanguage) { (result, responseObject) in
            if result == true {
               elDebugPrint("Language Change Successfully")
                let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                userProfile?.language = selectedLanguage
                DatabaseHelper.sharedInstance.saveDatabase()
                
            }else{
               elDebugPrint("Some Issue orrcus while changing language")
            }
        }
    }
}
