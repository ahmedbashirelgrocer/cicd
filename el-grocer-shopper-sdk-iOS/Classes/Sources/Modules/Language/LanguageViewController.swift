//
//  LanguageViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 07/06/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NavigationBarProtocol {
    
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var languageTitleLabel: UILabel!
    @IBOutlet weak var languageTableView: UITableView!
    @IBOutlet weak var confirmButton: AWButton!
    
    @IBOutlet weak var tableViewTopToSuperView: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopToLabel: NSLayoutConstraint!
    
    var languages = [String]()
    var Images = [String]()
    
    var lastSelection:IndexPath!
    var isFromSetting = false
 
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setConfirmButtonAppearance()
        self.setLanguageTitleLabelAppearance()
        self.setTableViewAppearance()
        
        languages =  ["English","عربى"]
        Images =  ["Uk-flag","UAE-flag"]
        
        if isFromSetting {
            self.title = localizedString("setting_language", comment: "")
            //addBackButton()
            self.hideLogoAndLabel(true)
        }else{
            self.hideLogoAndLabel(false)
        }
        
        self.lastSelection = IndexPath(row: 0, section: 0)
        let currentLanguage = UserDefaults.getCurrentLanguage()
        if currentLanguage == "ar" {
            self.lastSelection = IndexPath(row: 1, section: 0)
        }
        
        UserDefaults.setLanguageSelectionShown(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController is ElGrocerNavigationController {
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        }
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()

    }
    
    func backButtonClickedHandler() {
        self.backButtonClick()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.ChangeLanguage.rawValue, screenClass: String(describing: self.classForCoder))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setConfirmButtonAppearance() {
        
        self.confirmButton.layer.cornerRadius = 28
        self.confirmButton.setH4SemiBoldWhiteStyle()
        self.confirmButton.setTitle(localizedString("confirm_button_title", comment: ""), for: UIControl.State())
        self.confirmButton.backgroundColor = UIColor.navigationBarColor()
    }
    
    fileprivate func setLanguageTitleLabelAppearance() {
        
        self.languageTitleLabel.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        self.languageTitleLabel.textColor = UIColor.black
        self.languageTitleLabel.numberOfLines = 0
        self.languageTitleLabel.sizeToFit()
    }
    
    fileprivate func setTableViewAppearance() {
        self.languageTableView.backgroundColor = .clear
        self.languageTableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.languageTableView.separatorColor = UIColor.borderGrayColor()
        self.languageTableView.separatorInset = UIEdgeInsets.zero
        self.languageTableView.tableFooterView = UIView()
    }
    
    fileprivate func hideLogoAndLabel(_ hidden:Bool){
        
        if self.navigationController is ElGrocerNavigationController {
               (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        }
        
        
        
        
        
        
        
        
        
        languageTitleLabel.isHidden = hidden
        logoImgView.isHidden = hidden
        
        tableViewTopToSuperView.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
        tableViewTopToLabel.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
    }
    
    //MARK: TableView Data Source
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return kLanguageCellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:LanguageCell = tableView.dequeueReusableCell(withIdentifier: kLanguageCellIdentifier, for: indexPath) as! LanguageCell
        cell.backgroundColor = .clear
        let langTtile = languages[(indexPath as NSIndexPath).row]
        let langImage = Images[(indexPath as NSIndexPath).row]
        cell.configureCellWithTitle(langTtile, withImage: langImage)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.selectionImage.image = UIImage(name:"RadioButtonUnfilled")
        if self.lastSelection.row == indexPath.row {
            cell.selectionImage.image = UIImage(name:"RadioButtonFilled")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.lastSelection != indexPath {
            
            if self.lastSelection != nil {
                let cell = tableView.cellForRow(at: self.lastSelection) as! LanguageCell
                cell.selectionImage.image = UIImage(name:"RadioButtonUnfilled")
            }
            
            let cell = tableView.cellForRow(at: indexPath) as! LanguageCell
            cell.selectionImage.image = UIImage(name:"RadioButtonFilled")
            self.lastSelection = indexPath
        }
    }
    
    // MARK: Actions
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmHandler(_ sender: AnyObject) {
        
        var selectedLanguage = ""
        
        /* For English language support use keywork "Base" and for arabic language support use keywork "ar" */
        if self.lastSelection.row == 0 {
            selectedLanguage = "en"
            UIFont.isArabic = false
        }else{
            selectedLanguage = "ar"
            UIFont.isArabic = true
        }
        
        self.updateUserLanguage(selectedLanguage)
        if selectedLanguage == "en" {
            selectedLanguage = "Base"
        }
        
        UserDefaults.setCurrentLanguage(selectedLanguage)
        LanguageManager.sharedInstance.languageButtonAction(selectedLanguage: selectedLanguage, SDKManagers: getSDKManager() , updateRootViewController: true)
    }
    
    fileprivate func updateUserLanguage(_ selectedLanguage:String){
        
        guard UserDefaults.isUserLoggedIn() else {
            self.showLanguageChangeAlert()
            return
        }
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.updateUserLanguageToServer(selectedLanguage) { (result, responseObject) in
            SpinnerView.hideSpinnerView()
           elDebugPrint("Language Change Successfully")
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            userProfile?.language = selectedLanguage
            DatabaseHelper.sharedInstance.saveDatabase()
            FireBaseEventsLogger.trackChangeLanguageEvents(selectedLanguage)
            self.showLanguageChangeAlert()

        }
    }
    
    func showLanguageChangeAlert(){
        
//        var msg = "You have to restart the application to take effect this language change."
//        var btnTitle = "OK"
//        if !ElGrocerUtility.sharedInstance.isArabicSelected() {
//            msg = "يتوجب عليك إعادة تشغيل التطبيق لتفعيل التغيير في اللغة";
//            btnTitle = "حسنا";
//        }
//
//        ElGrocerAlertView.createAlert(msg ,
//                                      description:nil,
//                                      positiveButton: btnTitle,
//                                      negativeButton: nil,
//                                      buttonClickCallback: { (buttonIndex:Int) -> Void in
//
//                                        if buttonIndex == 0 {
//                                            self.navigationController?.popViewController(animated: true)
//                                        }
//        }).show()
    }
}

