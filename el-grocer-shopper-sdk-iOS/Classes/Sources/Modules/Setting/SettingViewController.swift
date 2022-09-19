//
//  SettingViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 23/02/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit
import WebKit
let kMoveToOrdersFromTableViewNotificationKey = "NavigateUserToOrdersFromSetting"
class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var lblversionNumber: UILabel!
    
    var elGrocerNavigationController: ElGrocerNavigationController {
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        return navController
    }
    
    var Images = [String]()
    var selectedImages = [String]()
    var titles = [String]()
    
    var lastSelection:IndexPath!
    let border = CALayer()
    
    lazy var locationHeader : ElgrocerlocationView = {
        let locationHeader = ElgrocerlocationView.loadFromNib()
        return locationHeader!
    }()
    
    var menuControllers:[UIViewController]!
    
    let accountSectionCells = 7 //ElGrocerUtility.sharedInstance.isZenDesk ?  5 : 4
    let settingsSectionCells = 1
    let informationSectionCells = 3
    var smilePointSection: Int = 1
    let deleteAccountCell: Int = 1
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupClearNavBar()
        // Do any additional setup after loading the view.
        if let version = Bundle.resource.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.lblversionNumber.text = "v" + " " + version
            if let buildnumber = Bundle.resource.infoDictionary?["CFBundleVersion"] as? String  {
                self.lblversionNumber.text = (self.lblversionNumber.text ?? ("v" + " ")) + "-" + buildnumber
            }
        }else{
            self.lblversionNumber.text = "Unknown"
        }
       
        self.registerTableViewCell()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.separatorColor =  .separatorColor() //.borderGrayColor()
        self.tableView.backgroundColor = .tableViewBackgroundColor() //.navigationBarWhiteColor()
        self.navigationCustimzation()
        self.tableViewDataSetting()

        hidesBottomBarWhenPushed = true
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationCustimzation()
        self.tableViewDataSetting()

        ElGrocerUtility.sharedInstance.tabBarSelectedIndex = 4
        if ElGrocerUtility.sharedInstance.isUserProfileUpdated {
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.fade)
            ElGrocerUtility.sharedInstance.isUserProfileUpdated = false
        }
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_settings_screen")
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsSettingScreen)
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.Profile.rawValue, screenClass: String(describing: self.classForCoder))
        
        //hide tabbar
        self.hideTabBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationCustimzation()
    }
    
    
    @objc fileprivate func goToOrders() {
        if UserDefaults.isUserLoggedIn() {
            ElGrocerUtility.sharedInstance.delay(0.1) { [weak self] in
                guard let self = self else {return}
                elDebugPrint(self)
                
                let SDKManager = SDKManager.shared
                if let nav = SDKManager.rootViewController as? UINavigationController {
                    if nav.viewControllers.count > 0 {
                        if  nav.viewControllers[0] as? UITabBarController != nil {
                            let tababarController = nav.viewControllers[0] as! UITabBarController
                             tababarController.selectedIndex = 3
                        }
                    }
                }
            }
            ElGrocerUtility.sharedInstance.delay(0.2) { [weak self] in
                 guard let self = self else {return}
                self.showOrderVC()
            }
        }
    }

    func tableViewDataSetting() -> Void {

       
        
        if UserDefaults.isUserLoggedIn()  {
            
            
            if SDKManager.isSmileSDK {
                
                titles =  [localizedString("live_chat", comment: ""), localizedString("orders_Settings", comment: "") ,
                           localizedString("saved_recipies", comment: ""),
                           localizedString("saved_Cars", comment: ""),
                           localizedString("address_settings", comment: ""),
                           
                           localizedString("payment_methods", comment: ""),
                           localizedString("txt_title_elWallet", comment: ""),
                           localizedString("language_settings", comment: ""),
                           localizedString("delete_account", comment: ""),
                           localizedString("terms_settings", comment: ""),
                           localizedString("privacy_policy", comment: ""),
                           localizedString("FAQ_settings", comment: "")]
                
                Images = ["liveChatSettings","ordersSettings","savedRecipesSettings","savedCarsSettings","addressSettings" , "paymentMethodSettings", "paymentMethodSettings","languageSettings", "DeleteAccountSettings","termsSettings","privacyPolicySettings", "faqSettings"]
                
            } else {
                
                titles =  [localizedString("live_chat", comment: ""),
                           localizedString("orders_Settings", comment: "") ,
                           localizedString("saved_recipies", comment: ""),
                           localizedString("saved_Cars", comment: ""),
                           localizedString("address_settings", comment: ""),
                           
                           localizedString("payment_methods", comment: ""),
                           localizedString("txt_title_elWallet", comment: ""),
                           localizedString("password_settings", comment: ""),
                           localizedString("language_settings", comment: ""),
                           localizedString("delete_account", comment: ""),
                           localizedString("terms_settings", comment: ""),
                           localizedString("privacy_policy", comment: ""),
                           localizedString("FAQ_settings", comment: "")]
                
                Images =  ["liveChatSettings" , "ordersSettings","savedRecipesSettings","savedCarsSettings","addressSettings" ,"paymentMethodSettings","paymentMethodSettings","passwordSettings","languageSettings", "DeleteAccountSettings","termsSettings","privacyPolicySettings" , "faqSettings"]
                
            }

        }else{

            
            titles =  [localizedString("language_settings", comment: ""),
                       localizedString("terms_settings", comment: ""),
                       localizedString("privacy_policy", comment: ""),
                       localizedString("FAQ_settings", comment: "")]
            
            Images =  ["languageSettings","termsSettings","privacyPolicySettings" , "faqSettings"]

        }
        self.tableView.reloadData()

    }

    
    func navigationCustimzation(){
        
        if self.navigationController is ElGrocerNavigationController {
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            //(self.navigationController as? ElGrocerNavigationController)?.setNewLightBackgroundColor()
            
        }
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
         (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
         (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        self.title = localizedString("Profile_Title", comment: "")
//        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.navigationBar.backgroundColor = .navigationBarWhiteColor()
        self.view.backgroundColor = .navigationBarWhiteColor()
        
        
       
        
    }
    override func notifcationButtonClick() {
        self.showNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func getAccessoryViewWithSelection(_ selected:Bool) -> UIImageView {
        
        var ImageName = ""
        var imgView:UIImageView = UIImageView()
        imgView  = UIImageView(frame:CGRect(x: 0, y: 0, width: 6, height: 11))
        if selected {
            ImageName = "Disclosure Arrow-Selected"
        }else{
            ImageName = "Disclosure Arrow"
        }
        let image = ElGrocerUtility.sharedInstance.getImageWithName(ImageName)
        imgView.image = image
        imgView.contentMode = UIView.ContentMode.scaleAspectFit
        
        return imgView
    }
    @objc func editPressed(sender : UIButton){
        if UserDefaults.isUserLoggedIn(){
            let editProfileVC = ElGrocerViewControllers.editProfileViewController()
            editProfileVC.userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
//            let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
//            navigationController.hideSeparationLine()
//            navigationController.viewControllers = [editProfileVC]
//            navigationController.modalPresentationStyle = .fullScreen
            //self.navigationController?.present(navigationController, animated: true, completion: nil)
            self.navigationController?.pushViewController(editProfileVC, animated: true)
        }
    }
    //MARK: TableView Data Source
    
    func registerTableViewCell() {
        
        let userInfoCellNib  = UINib(nibName: "UserInfoCell", bundle: Bundle.resource)
        self.tableView.register(userInfoCellNib, forCellReuseIdentifier: kUserInfoCellIdentifier)
        
        let loginCellNib  = UINib(nibName: "loginCell", bundle: Bundle.resource)
        self.tableView.register(loginCellNib, forCellReuseIdentifier: KloginCellIdentifier)
        
        let settingCellNib = UINib(nibName: "SettingCell", bundle: Bundle.resource)
        self.tableView.register(settingCellNib, forCellReuseIdentifier: kSettingCellIdentifier)
        
        
        let SignOutCellNib = UINib(nibName: "SignOutCell", bundle: Bundle.resource)
        self.tableView.register(SignOutCellNib, forCellReuseIdentifier: kSignOutCellIdentifier)
        
        
        self.tableView.backgroundColor = UIColor.navigationBarWhiteColor()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if SDKManager.isSmileSDK {
            return 40
        }
        
        if UserDefaults.isUserLoggedIn() {
            if section > 0 && section != 4 + smilePointSection{
                return 40
            }else if section == 4 + smilePointSection{
                return 10
            }
        }else{
            if section > 0{
                return 40
            }
            
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if SDKManager.isSmileSDK {
            if section == 1 {
                return  localizedString("cell_Title_Account", comment: "")
            }else if section == 2 {
                return localizedString("Information_heading", comment: "")
            } else {
                return ""
            }
        }
        
        //Setting screen new text
        if UserDefaults.isUserLoggedIn() {
            if section == 1 && smilePointSection == 1 {
                return localizedString("txt_benifits", comment: "")
            }
            if section == 0 {
                return ""
            }else if section == 1 + smilePointSection{
                return  localizedString("cell_Title_Account", comment: "")
            }else if section == 2 + smilePointSection{
                return localizedString("settings_heading", comment: "")
            }else if section == 3 + smilePointSection{
                return localizedString("Information_heading", comment: "")
            }
        }else{
             if section == 1 {
                return localizedString("settings_heading", comment: "")
            }else if section == 2 {
                return localizedString("Information_heading", comment: "")
            }
            
        }
        return ""
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 20, y: 8, width: 320, height: 30)
        myLabel.setH4SemiBoldStyle()
        myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        let headerView = UIView()
        headerView.backgroundColor = .tableViewBackgroundColor()
        headerView.addSubview(myLabel)
        
        return headerView
        
    }
    
    //    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
    //
    //         let header = view as! UITableViewHeaderFooterView
    //         header.contentView.backgroundColor = UIColor.moreBGColor()
    //         var frame =  header.textLabel?.frame
    //             frame?.origin.x = 20
    //        header.textLabel?.frame = frame!
    //        header.textLabel?.font = UIFont.SFUIRegularFont(13)
    //
    //    }
    
    //
    //    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
    //        let footer = view as! UITableViewHeaderFooterView
    //        footer.contentView.backgroundColor = UIColor.colorWithHexString(hexString: "ECEDF0")
    //
    //    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if SDKManager.isSmileSDK {
            if indexPath.section == 0 {
                return kUserInfoCellHeight
            }
            return kSettingCellHeight
        }
        
        if UserDefaults.isUserLoggedIn() {
            if indexPath.section == 0 {
                return kUserInfoCellHeight
                //sabNew
                //return KloginCellHeight
            }
            if indexPath.section == 4 + smilePointSection{
                return kSignOutCellHeight
            }
            return kSettingCellHeight
        }else{
            
            if (indexPath as NSIndexPath).section == 0 {
                return KloginCellHeight
            }else{
                return kSettingCellHeight
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if SDKManager.isSmileSDK {
            return 3
            // -1 for Benifits (Smile points)
            // -1 for logout
            // -1 for settings language change option
        }
        
        if UserDefaults.isUserLoggedIn() {
            return 5 + smilePointSection
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if SDKManager.isSmileSDK {
            if section == 0 {
                return 1
            } else if section == 1 {
                return accountSectionCells - 2
                // -1 for recipes
                // -1 for change password
            }
            return informationSectionCells
        }
        
        if UserDefaults.isUserLoggedIn() {
            if section == 1 && smilePointSection == 1 {
                return 1
            }
            if section == 0 || section == 4 + smilePointSection {
                return 1
            }else if section == 1 + smilePointSection {
                return accountSectionCells
            }else if section == 2 + smilePointSection{
                return settingsSectionCells + deleteAccountCell
            }
            return informationSectionCells
        }else{
            if section == 1{
                return settingsSectionCells
            }else if section == 2{
                return informationSectionCells
            }
            return 1
        }

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if SDKManager.isSmileSDK {
            return
        }
        
        if UserDefaults.isUserLoggedIn() {
            if indexPath.section == 1 && smilePointSection == 1 {
                if UserDefaults.getIsSmileUser() {
                    let smilepoints = UserDefaults.getSmilesPoints()
                    SmilesEventsLogger.smilesImpressionEvent(isSmileslogin: true, smilePoints: smilepoints)
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if SDKManager.isSmileSDK {
            if indexPath.section == 0 {
                let cell:UserInfoCell = tableView.dequeueReusableCell(withIdentifier: kUserInfoCellIdentifier, for: indexPath) as! UserInfoCell
                let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                cell.configureCellWithTitle(userProfile?.name ?? "", withPhoneNumber:userProfile?.phone ?? "" , andWithEmail: userProfile?.email ?? "")
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.btnEditProfile.addTarget(self, action: #selector(self.editPressed(sender:)), for: .touchUpInside)
                return cell
            } else  if indexPath.section == 1  {

                let cell:SettingCell = tableView.dequeueReusableCell(withIdentifier: kSettingCellIdentifier, for: indexPath) as! SettingCell
                
                let row = (indexPath.row >= 2 || indexPath.row >= 3) ? (indexPath.row + 2) : indexPath.row // Skip recipie cell
                
                if  row < titles.count {
                    let title = titles[row]
                    let imageName = Images[row]
                    cell.configureCellWithTitle(title, withImage: imageName)
                }
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                return cell
            } else {
                
                let cell:SettingCell = tableView.dequeueReusableCell(withIdentifier: kSettingCellIdentifier, for: indexPath) as! SettingCell
                if indexPath.row < titles.count {
                    let addForIndex = accountSectionCells + settingsSectionCells + deleteAccountCell
                    let title = titles[(indexPath as NSIndexPath).row + addForIndex]
                    let imageName = Images[(indexPath as NSIndexPath).row + addForIndex]
                    cell.configureCellWithTitle(title, withImage: imageName)
                }
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                return cell
            }
        }
        
        
        if UserDefaults.isUserLoggedIn() {
            
            if indexPath.section == 1 && smilePointSection == 1 {
                let cell:SettingCell = tableView.dequeueReusableCell(withIdentifier: kSettingCellIdentifier, for: indexPath) as! SettingCell
                    //var title = NSLocalizedString("txt_smile_point", comment: "") +  NSLocalizedString("txt_bracket_login", comment: "")
                var title = localizedString("txt_earn_smiles", comment: "")
                if UserDefaults.getIsSmileUser() {
                    let points = UserDefaults.getSmilesPoints()
                    title = localizedString("txt_smile_point", comment: "") + "(\(points) " + localizedString("smile_point_unit", comment: "") + ")"
                }
                let imageName = "smilesCellLogo"
                cell.configureCellWithTitle(title, withImage: imageName)
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                return cell
            }
            
            if indexPath.section == 0 && indexPath.row == 0 {
                let cell:UserInfoCell = tableView.dequeueReusableCell(withIdentifier: kUserInfoCellIdentifier, for: indexPath) as! UserInfoCell
                let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                cell.configureCellWithTitle(userProfile?.name ?? "", withPhoneNumber:userProfile?.phone ?? "" , andWithEmail: userProfile?.email ?? "")
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.btnEditProfile.addTarget(self, action: #selector(self.editPressed(sender:)), for: .touchUpInside)
                
                return cell
                
                
                
                
            }else  if indexPath.section == 1 + smilePointSection  {
                
                let cell:SettingCell = tableView.dequeueReusableCell(withIdentifier: kSettingCellIdentifier, for: indexPath) as! SettingCell
                
                if  indexPath.row < titles.count {
                    let title = titles[(indexPath as NSIndexPath).row]
                    let imageName = Images[(indexPath as NSIndexPath).row]
                    cell.configureCellWithTitle(title, withImage: imageName)
                }
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                let lastRowIndex = tableView.numberOfRows(inSection: indexPath.section)
                
                
                return cell
                
            }else  if indexPath.section == 2 + smilePointSection{
                
                let cell:SettingCell = tableView.dequeueReusableCell(withIdentifier: kSettingCellIdentifier, for: indexPath) as! SettingCell
                let addForIndex = accountSectionCells
                let title = titles[(indexPath as NSIndexPath).row + addForIndex]
                let imageName = Images[(indexPath as NSIndexPath).row + addForIndex]
                cell.configureCellWithTitle(title, withImage: imageName)
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                return cell
                
                
            }else  if indexPath.section == 3 + smilePointSection{
                
                let cell:SettingCell = tableView.dequeueReusableCell(withIdentifier: kSettingCellIdentifier, for: indexPath) as! SettingCell
                if indexPath.row < titles.count {
                    let addForIndex = accountSectionCells + settingsSectionCells + deleteAccountCell
                    let title = titles[(indexPath as NSIndexPath).row + addForIndex]
                    let imageName = Images[(indexPath as NSIndexPath).row + addForIndex]
                    cell.configureCellWithTitle(title, withImage: imageName)
                }
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                return cell
                
                
            }else  if indexPath.section == 4 + smilePointSection{
                let cell:SignOutCell = tableView.dequeueReusableCell(withIdentifier: kSignOutCellIdentifier, for: indexPath) as! SignOutCell
                cell.signOutButton.setTitle(localizedString("sign_out_alert_title", comment: ""), for: .normal)
                cell.contentView.setNeedsLayout()
                cell.contentView.layoutIfNeeded()
                cell.signOutHandler = {[weak self] () in
                    guard let self = self else {return}
                    self.signOutUser()
                }
                cell.selectionStyle = .none
                return cell
                
                
            }
            
        }
        //not logged in state
        if indexPath.section == 0{
            let cell:loginCell = tableView.dequeueReusableCell(withIdentifier: KloginCellIdentifier, for: indexPath) as! loginCell

            return cell
        }else{
            let cell:SettingCell = tableView.dequeueReusableCell(withIdentifier: kSettingCellIdentifier, for: indexPath) as! SettingCell
            if indexPath.section == 2{
                if indexPath.row < titles.count  {
                    let title = titles[(indexPath as NSIndexPath).row + settingsSectionCells]
                    let imageName = Images[(indexPath as NSIndexPath).row + settingsSectionCells]
                    cell.configureCellWithTitle(title, withImage: imageName)
                }
                return cell
            }
            if indexPath.row < titles.count  {
                let title = titles[(indexPath as NSIndexPath).row]
                let imageName = Images[(indexPath as NSIndexPath).row]
                cell.configureCellWithTitle(title, withImage: imageName)
            }
            
            return cell
        }
        

    }
    
    //MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if SDKManager.isSmileSDK {
        
            switch indexPath.section {
            case 1:
                switch (indexPath as NSIndexPath).row {
                case 0: self.showLiveChat()
                case 1: self.showOrderVC()
                //case 2: self.goToSavedRecipesVC()
//                case 2: self.goToSavedCarsVC()
                case 2: self.locationHeader.changeLocation()
                case 3: self.goToAddNewCardVC()
                case 4: self.goToElWalletVC()
                default: break
                }
            case 2:
                switch (indexPath as NSIndexPath).row {
                case 0: self.navigateToPrivacyPolicyViewControllerWithTermsEnable(true)
                case 1: self.navigateToPrivacyPolicyViewControllerWithTermsEnable()
                case 2: self.showFAQs()
                default: break
                }
            default: return
            }
            
            return
        }
       
        if UserDefaults.isUserLoggedIn() {
            
            switch (indexPath as NSIndexPath).section {
                case 0 + smilePointSection:
                    switch (indexPath as NSIndexPath).row {
                        case 0:
                                //call api here
                            print("Show smiles point view")
                            if UserDefaults.getIsSmileUser() {
                                let smilepoints = UserDefaults.getSmilesPoints()//100
                                SmilesEventsLogger.smilePointsClickedEvent(isSmileslogin: true, smilePoints: smilepoints)
                                self.showSmilePointsVC()
                            } else {
                                SmilesEventsLogger.smilesSignUpClickedEvent()
                                    //self.goToSmileWithPermission()
                                self.gotToSmileLoginVC()
                            }
                            break
                        default:
                            break
                    }
                case 1 + smilePointSection:
                    switch (indexPath as NSIndexPath).row {
                        case 0:
                            print("Show Live Chat")
                            self.showLiveChat()
                            break
                        case 1:
                            print("show Order")
                            self.showOrderVC()
                            break
                        case 2:
                            print("saved recipes")
                            self.goToSavedRecipesVC()
                            break
                        case 3:
                            print("saved cars")
                            self.goToSavedCarsVC()
                            break
                        case 4:
                            print("addresses")
                            self.locationHeader.changeLocation()
                            break
                        case 5:
                            print("show card list")
                            self.goToAddNewCardVC()
                                //self.showManageCard()
                            break
                        case 6:
                            print("show elwallet")
                            self.goToElWalletVC()
                            break
                        case 7:
                            print("change Passowrd")
                            self.goToChangePasswordVC();
                            break
                            
                        default:
                            break
                    }
                case 2 + smilePointSection:
                    switch (indexPath as NSIndexPath).row {
                            
                        case 0:
                            print("Language Selection")
                            self.showLanguageSelectionVC()
                            break
                        case 1:
                            print("delete account selection")
                            self.showDeleteAccountVC()
                            break
                        default:
                            break
                    }
                case 3 + smilePointSection:
                    switch (indexPath as NSIndexPath).row {
                            
                        case 0:
                            print("Terms Conditions")
                            self.navigateToPrivacyPolicyViewControllerWithTermsEnable(true)
                            break
                        case 1:
                            print("Privacy Policy")
                            self.navigateToPrivacyPolicyViewControllerWithTermsEnable()
                            break
                        case 2:
                            print("FAQ's")
                            self.showFAQs()
                            break
                        default:
                            break
                    }
                default:
                    return;
            }
            
        }else{

            switch (indexPath as NSIndexPath).section {
                case 1:
                    switch (indexPath as NSIndexPath).row {
                        
                    case 0:
                       elDebugPrint("Language Selection")
                        self.showLanguageSelectionVC()
                        break
                    default:
                        break
                    }
                case 2:
                    switch (indexPath as NSIndexPath).row {
                        
                    case 0:
                       elDebugPrint("Terms Conditions")
                            self.navigateToPrivacyPolicyViewControllerWithTermsEnable(true)
                        break
                    case 1:
                       elDebugPrint("Privacy Policy")
                            self.navigateToPrivacyPolicyViewControllerWithTermsEnable()
                        break
                    case 2:
                       elDebugPrint("FAQ's")
                            self.showFAQs()
                        break
                    default:
                        break
                    }
                
            default:
                break
            }
        }
        
        
    }
    
    fileprivate func goToSmileWithPermission() {
        
        let alertDescription = localizedString("smile_login_permission_text", comment: "")
        let positiveBtnText = localizedString("Yes", comment: "")
        let negativeBtnText = localizedString("No", comment: "")
        let smileLoginAlert = ElGrocerAlertView.createAlert("", description: alertDescription, positiveButton: positiveBtnText, negativeButton: negativeBtnText) { btnTappedIndex in
            if btnTappedIndex == 0 {
                self.gotToSmileLoginVC()
            }
        }
        smileLoginAlert.show()
    }
    
    fileprivate func gotToSmileLoginVC() {
        
        let smileVC = ElGrocerViewControllers.getSmileLoginVC()
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [smileVC]
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: { });
        //self.navigationController?.pushViewController(smileVC, animated: true)
    }
    
    fileprivate func showSmilePointsVC() {
        
        let smileVC = ElGrocerViewControllers.getSmilePointsVC()
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [smileVC]
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: { });
        //self.navigationController?.pushViewController(smileVC, animated: true)
    }
    
    fileprivate func showRecipeDetial() {
        
        let recipeStory = ElGrocerViewControllers.recipesListViewController()
        let navigationController = ElGrocerNavigationController.init(rootViewController: recipeStory)
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: { });
        
    }
    
    fileprivate func showLiveChat(){
        
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_help_from_meun")
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("LiveChat")
        //FireBaseEventsLogger.trackSettingClicked("LiveChat")
       
//            ZohoChat.showChat()
        let sendBirdManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
        sendBirdManager.setUpSenBirdDeskWithCurrentUser()
        
    }

    
    fileprivate func showSignInVC(){
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("LogIn")
        let signInVC = ElGrocerViewControllers.signInViewController()
        let navController = self.elGrocerNavigationController
        signInVC.isForLogIn = true
        signInVC.isCommingFrom = .profile
        signInVC.dismissMode = .dismissModal
        navController.viewControllers = [signInVC]
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    fileprivate func showRegistrationVC(){
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("CreateAccount")
        let signInVC = ElGrocerViewControllers.signInViewController()
        signInVC.isForLogIn = false
        signInVC.isCommingFrom = .cart
        signInVC.dismissMode = .dismissModal
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [signInVC]
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    fileprivate func showDeliveryAddressVC(){
        let locationVC = ElGrocerViewControllers.dashboardLocationViewController()
        locationVC.menuControllers = self.menuControllers
        locationVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(locationVC, animated: true)
    }
    
    fileprivate func showRequestsVC(){
        
        let requestsVC = ElGrocerViewControllers.requestsViewController()
        requestsVC.isNavigateToRequest = true
        requestsVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(requestsVC, animated: true)
    }
    
    fileprivate func showFAQs(){
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("FAQ")
        let faqVC = ElGrocerViewControllers.faqViewController()
    
        if self.navigationController is ElgrocerGenericUIParentNavViewController {
             (self.navigationController as! ElgrocerGenericUIParentNavViewController).setWhiteBackgroundColor()
            (self.navigationController as! ElgrocerGenericUIParentNavViewController).setBackButtonHidden(false)
        }
        self.navigationController?.pushViewController(faqVC, animated: true)
    }
    
    fileprivate func showNotification(){
        // Notifications
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_notification")
        //// Intercom.presentConversationList()
        //// Intercom.presentMessageComposer(nil)
//         ZohoChat.showChat()
        let sendBirdManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
        sendBirdManager.setUpSenBirdDeskWithCurrentUser()
    }
    
    fileprivate func showLanguageSelectionVC() {
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("ChangeLanguage")
        let languageController = ElGrocerViewControllers.languageViewController()
        languageController.isFromSetting = true
        if self.navigationController is ElgrocerGenericUIParentNavViewController {
            (self.navigationController as! ElgrocerGenericUIParentNavViewController).setBackButtonHidden(false)
        }
        self.navigationController?.pushViewController(languageController, animated: true)
    }
    fileprivate func showDeleteAccountVC() {
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("DeleteAccount")
        let deleteAccountVC = ElGrocerViewControllers.getAccountDeletionReasonsVC()
        self.navigationController?.pushViewController(deleteAccountVC, animated: true)
    }
    
    fileprivate func showOrderVC(){
        
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("MyOrders")
        let ordersController = ElGrocerViewControllers.ordersViewController()
        
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [ordersController]
        navigationController.modalPresentationStyle = .fullScreen
        MixpanelEventLogger.trackProfileMyOrders()
        self.navigationController?.present(navigationController, animated: true, completion: { });
 
    }
    
    fileprivate func showManageCard(){
        
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("ManageCards")
        
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let creditVC = CreditCardListViewController(nibName: "CreditCardListViewController", bundle: Bundle.resource)
        creditVC.userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        creditVC.isFromSetting = true
        let navigation = ElgrocerGenericUIParentNavViewController.init(rootViewController: creditVC)
        navigation.modalPresentationStyle = .fullScreen
        present(navigation, animated: true, completion: nil)
        
        creditVC.creditCardSelected = { (creditCardSelected) in
           
          //  UserDefaults.setCardID(cardID: "\(String(describing: creditCardSelected?.cardID ?? -1))"  , userID: userProfile!.dbID.stringValue)
           // creditVC.dismiss(animated: true) {  }
        }
        
        creditVC.creditCardDeleted = { (creditCardSelected) in
         
//            let notification = ElGrocerAlertView.createAlert(localizedString("Card_AddCard_Title", comment: ""),description: localizedString("Setting_Credit_Card_Delete_Success", comment: "") ,positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
//            notification.showPopUp()
        }
        
        
        
        creditVC.addCard = {
            self.addNewCreditCard(creditVC)
            
        }
   
    }
    
    fileprivate func addNewCreditCard(_ viewController : CreditCardListViewController) {
        
        
         let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let url = ElGrocerApi.sharedInstance.baseApiPath + "/online_payments/credit_card" + "?" + "customer_email=\(userProfile!.email)" + "&" + "merchant_reference=\(ElGrocerUtility.sharedInstance.getRefernceFromWithOutAddBackEnd(isAddCard: true, orderID: userProfile!.dbID.stringValue, ammount: 1 , randomRef: String(format: "%.0f", Date.timeIntervalSinceReferenceDate) ))"
        let finalURL = url.replacingOccurrences(of: "/api/", with: "")
        DispatchQueue.main.async {
              viewController.loadFiler3dURL(finalURL)
        }
        /*
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let addCreditVC = AddCreditCardViewController(nibName: "AddCreditCardViewController", bundle: Bundle.resource)
        addCreditVC.userProfile = userProfile
        addCreditVC.isAddOnly = true
        addCreditVC.totalPrice = 1.0
        addCreditVC.modalPresentationStyle = .fullScreen
        viewController.navigationController?.pushViewController(addCreditVC, animated: true)
        addCreditVC.successData = { [weak self] (ref , ammount , creditCardSelected , tokenName , data) in
            guard let self = self else {return}
            var selectedCard = creditCardSelected
            if selectedCard.first6.isEmpty {
                selectedCard.first6 = String(selectedCard.cardNumber.prefix(6))
                selectedCard.last4   = String(selectedCard.cardNumber.suffix(4))
            }
            if !tokenName.isEmpty {
                selectedCard.transRef = tokenName
            }
            if let refData = ref {
                if !refData.isEmpty {
                    selectedCard.marchentRef = ref!
                }
            }
            
             let _ = SpinnerView.showSpinnerViewInView(addCreditVC.view)
            
            self.addCreditCardToServer( tokenName: tokenName , selectedCard, userProfile: userProfile!  , completion: { (isSuccess) in
                 SpinnerView.hideSpinnerView()
                if isSuccess {
                    viewController.navigationController?.popViewController(animated: true)
                    self.voidAuthCall(selectedCard.marchentRef)
                    
                }
                
                let msgString = isSuccess ? localizedString("Setting_Credit_Card_Add_Success", comment: "") : localizedString("Setting_Credit_Card_Add_Failure", comment: "")
                let notification = ElGrocerAlertView.createAlert(localizedString("Card_AddCard_Title", comment: ""),description: msgString ,positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
                notification.showPopUp()
                
            })
        }
        
        */
    }
    
    func addCreditCardToServer(  tokenName : String , _ card : CreditCard , userProfile : UserProfile , completion : ( @escaping (_ isSuccess : Bool)->Void) ) {
       
        ElGrocerApi.sharedInstance.addCreditCards(creditCard: card ) { (result) in
            switch (result) {
                case .success(let response) :
                    if let dataDict = response["data"] as? NSDictionary {
                        if let responseObjects = dataDict["credit_card"] as? NSDictionary {
                            let cardID = responseObjects["id"]
                            UserDefaults.setCardID(cardID: "\(String(describing: cardID ?? -1))"  , userID: userProfile.dbID.stringValue )
                            let _ = UserDefaults.setSecureCVV(userID: userProfile.dbID.stringValue , cardID: "\(String(describing: cardID ?? -1))", cvv: card.securityCode )
                            completion(true)
                            return
                        }
                    }
                    completion(false)
                case .failure(let error):
                    error.showErrorAlert()
            }
            SpinnerView.hideSpinnerView()
        }
        
    }
    
    func voidAuthCall(_ ref : String ) {
        ElgrocerAPINonBase.sharedInstance.voidAuthorization(fortID: ref ) { (isSuccess, dict) in
            if isSuccess {
            }else{
                if isSuccess == false  {
                    ElGrocerUtility.sharedInstance.delay(2) {  [weak self] in
                        guard let self = self else {return}
                        self.voidAuthCall(ref)
                    }
                    return
                }
            }
        }
        
    }
    
    
    fileprivate func signOutUser(){
        
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("signed_out")
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("SignOut")
        // Sign Out
        ElGrocerAlertView.createAlert(localizedString("sign_out_alert_title", comment: ""),
                                      description: localizedString("sign_out_alert_description", comment: ""),
                                      positiveButton: localizedString("sign_out_alert_yes", comment: ""),
                                      negativeButton: localizedString("sign_out_alert_no", comment: ""),
                                      buttonClickCallback: { (buttonIndex:Int) -> Void in
                                        if buttonIndex == 0 {
                                             let SDKManager = SDKManager.shared
                                            if UIApplication.topViewController() is GenericProfileViewController {
                                                SDKManager.currentTabBar?.dismiss(animated: false, completion: {
                                                    SDKManager.logoutAndShowEntryView()
                                                })
                                            }else {
                                                SDKManager.logoutAndShowEntryView()
                                            }
                                           
                                        }else{
                                             FireBaseEventsLogger.trackSignOut(false)
                                        }
        }).show()
    }
    
    
    private func navigateToPrivacyPolicyViewControllerWithTermsEnable(_ isTermsEnable:Bool = false){
        
        if isTermsEnable {
            ElGrocerEventsLogger.sharedInstance.trackSettingClicked("TermsConditions")
        }else{
            ElGrocerEventsLogger.sharedInstance.trackSettingClicked("PrivacyPolicy")
        }
        let ew = ElGrocerViewControllers.privacyPolicyViewController()
        ew.isTermsAndConditions = isTermsEnable
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [ew]
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: nil)

    }
    
    
    private func goToChangePasswordVC() {
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("ChangePassword")
        let passVC = ElGrocerViewControllers.changePasswordViewController()
        passVC.modalPresentationStyle = .fullScreen
        //  passVC.hidesBottomBarWhenPushed = true
        //self.navigationController?.present(passVC, animated: true, completion: nil)
        if self.navigationController is ElgrocerGenericUIParentNavViewController {
            (self.navigationController as! ElgrocerGenericUIParentNavViewController).setBackButtonHidden(false)
        }
        self.navigationController?.pushViewController(passVC, animated: true)
    }
    
    private func goToSavedRecipesVC() {
        
        //ElGrocerEventsLogger.sharedInstance.trackSettingClicked(FireBaseScreenName.SavedRecipes.rawValue)
        ElGrocerEventsLogger.sharedInstance.trackRecipeViewAllClickedFromNewGeneric(source: FireBaseScreenName.SavedRecipes.rawValue)
        let passVC = ElGrocerViewControllers.savedRecipeViewController()
        passVC.modalPresentationStyle = .fullScreen
        //  passVC.hidesBottomBarWhenPushed = true
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [passVC]
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    private func goToSavedCarsVC() {
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("saved recipes")
        let passVC = ElGrocerViewControllers.savedCarsViewController()
        passVC.modalPresentationStyle = .fullScreen
        //  passVC.hidesBottomBarWhenPushed = true
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [passVC]
        navigationController.modalPresentationStyle = .fullScreen
        //self.navigationController?.present(navigationController, animated: true, completion: nil)
        self.navigationController?.pushViewController(passVC, animated: true)
    }
    
    private func goToAddNewCardVC() {
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("saved recipes")
        let passVC = ElGrocerViewControllers.savedCarsViewController()
        passVC.modalPresentationStyle = .fullScreen
        passVC.saveType = .addNewCard
        //  passVC.hidesBottomBarWhenPushed = true
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [passVC]
        navigationController.modalPresentationStyle = .fullScreen
        //self.navigationController?.present(navigationController, animated: true, completion: nil)
        self.navigationController?.pushViewController(passVC, animated: true)
    }
    
    private func goToElWalletVC() {
        
            //ElGrocerEventsLogger.sharedInstance.trackSettingClicked("saved recipes")
        let passVC = ElGrocerViewControllers.getElWalletHomeVC()
        passVC.modalPresentationStyle = .fullScreen
        
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [passVC]
        navigationController.modalPresentationStyle = .fullScreen
        
            //self.navigationController?.present(navigationController, animated: true, completion: nil)
        self.navigationController?.pushViewController(passVC, animated: true)
    }
   
}

extension SettingViewController: NavigationBarProtocol {
    
    func backButtonClickedHandler() {
        self.backButtonClick()
    }
    
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
}
