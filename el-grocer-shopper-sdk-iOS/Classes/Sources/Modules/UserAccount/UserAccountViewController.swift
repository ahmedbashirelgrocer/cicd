//
//  UserAccountViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 06.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

//protocol MenuTableProtocol : class  {
//    
//    func menuTableViewDidSelectViewController(selectedViewController: UIViewController)
//}

enum UserAccountEditingOptions : Int {
    
    case name = 0
    case email = 1
    case phone = 2
    case invoiceAddress = 3
    
    static let allValues = [name, email, phone /*, InvoiceAddress*/]
    static let labels = ["my_account_name_field_label", "my_account_detail_email_field_label", "my_account_phone_field_label", "my_account_invoice_field_label"]
}

class UserAccountViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var shopNowButton: UIButton!
    @IBOutlet weak var newAddressButton: UIButton!
    
    var userProfile:UserProfile!
    var invoiceAddress:DeliveryAddress!
    
    var menuControllers:[UIViewController]!
    
    //weak var delegate: MenuTableProtocol?
    
    // MARK: Life cycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.menuItem = MenuItem(title: localizedString("setting_user_account", comment: ""))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localizedString("setting_user_account", comment: "")
        
       /* addMenuButton()
        
        updateMenuButtonRedDotState(nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.updateMenuButtonRedDotState(_:)), name:kHelpshiftChatResponseNotificationKey, object: nil)*/
        
        addBackButton()
        
        setUpEditProfileButtonAppearance()
        setUpShopNowButtonAppearance()
        setUpNewAddressButtonAppearance()
        setButtonImagesAppearance()
        
        self.tableViewHeightConstraint.constant = CGFloat(UserAccountEditingOptions.allValues.count) * kUserAccountCellHeight + kUserAccountCellHeight / 2
        
        refreshUserProfile()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.editProfileButton.layer.cornerRadius = self.editProfileButton.frame.size.height / 2
        self.shopNowButton.layer.cornerRadius = self.shopNowButton.frame.size.height / 2
        self.newAddressButton.layer.cornerRadius = self.newAddressButton.frame.size.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
      //  self.navigationItem.leftBarButtonItem = nil
       // self.navigationItem.hidesBackButton = true
        
        refreshUserProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsUserAccountScreen)
        FireBaseEventsLogger.setScreenName( kGoogleAnalyticsUserAccountScreen , screenClass: String(describing: self.classForCoder))
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_accounts_screen")
    }
    
    // MARK: Actions
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Appearance
    
    func setUpEditProfileButtonAppearance() {
     
        self.editProfileButton.layer.borderColor = UIColor.navigationBarColor().cgColor
        self.editProfileButton.layer.borderWidth = 1
        self.editProfileButton.setTitle(localizedString("my_account_edit_profile_button", comment: ""), for: UIControl.State())
        self.editProfileButton.setTitleColor(UIColor.navigationBarColor(), for: UIControl.State())
        self.editProfileButton.titleLabel?.font = UIFont.lightFont(17.0)
    }
    
    func setUpShopNowButtonAppearance() {
        
        self.shopNowButton.layer.borderColor = UIColor.redTextColor().cgColor
        self.shopNowButton.layer.borderWidth = 1
        self.shopNowButton.setTitle(localizedString("my_account_shop_now_button", comment: ""), for: UIControl.State())
        self.shopNowButton.setTitleColor(UIColor.redTextColor(), for: UIControl.State())
        self.shopNowButton.titleLabel?.font = UIFont.lightFont(17.0)
    }
    
    func setUpNewAddressButtonAppearance() {
        
        self.newAddressButton.layer.borderColor = UIColor.black.cgColor
        self.newAddressButton.layer.borderWidth = 1
        self.newAddressButton.setTitle(localizedString("my_account_new_address_button", comment: ""), for: UIControl.State())
        self.newAddressButton.setTitleColor(UIColor.black, for: UIControl.State())
        self.newAddressButton.titleLabel?.font = UIFont.lightFont(17.0)
    }
    
    func setButtonImagesAppearance() {
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            self.editProfileButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 12)
            self.shopNowButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 12)
            self.newAddressButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 12)
        }else{
            self.editProfileButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 12,bottom: 0,right: 0)
            self.shopNowButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 12,bottom: 0,right: 0)
            self.newAddressButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 12,bottom: 0,right: 0)
        }
    }
    
    // MARK: Data
    
    func refreshUserProfile() {
        
        self.userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        self.invoiceAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)

        self.tableView.reloadData()
    }
    
    // MARK: UITableView
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return (indexPath as NSIndexPath).row != UserAccountEditingOptions.invoiceAddress.rawValue ? kUserAccountCellHeight : kUserAccountCellHeight * 1.5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return UserAccountEditingOptions.allValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UserAccountCell = tableView.dequeueReusableCell(withIdentifier: kUserAccountCellIdentifier, for: indexPath) as! UserAccountCell

        let placeholder = localizedString(UserAccountEditingOptions.labels[(indexPath as NSIndexPath).row], comment: "")
        
        cell.configure(placeholder, profile: self.userProfile, invoiceAddress: self.invoiceAddress, type: UserAccountEditingOptions(rawValue: (indexPath as NSIndexPath).row)!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let type = UserAccountEditingOptions(rawValue: (indexPath as NSIndexPath).row)!
        
        if type == .invoiceAddress {
            
            self.performSegue(withIdentifier: "UserAccountToInvoiceAddress", sender: self)
        }
    }

    // MARK: Actions
    
    @IBAction func onEditProfileButtonClick(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "MyAccountToEditProfile", sender: self)
    }
    
    @IBAction func onShopNowButtonClick(_ sender: AnyObject) {
        
        /*self.navigationController?.slideMenuViewController?.contentController.viewControllers = [ElGrocerViewControllers.mainCategoriesViewController()]*/
        let controller:UIViewController = self.menuControllers[0]
        self.navigationController?.slideMenuViewController?.contentController.viewControllers = [controller]
        ElGrocerUtility.sharedInstance.isHomeSelected = true
    }
    
    @IBAction func onNewAddressButtonClick(_ sender: AnyObject) {
        
        let locationsController = ElGrocerViewControllers.dashboardLocationViewController()
        locationsController.menuControllers = self.menuControllers
        locationsController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(locationsController, animated: true)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MyAccountToEditProfile" {
            
            let controller = segue.destination as! EditProfileViewController
            controller.userProfile = self.userProfile
        }
    }
}
