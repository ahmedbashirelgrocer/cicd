//
//  MenuViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 02.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
//import Intercom

protocol MenuTableProtocol : class  {

    func menuTableViewDidSelectViewController(_ selectedViewController: UIViewController)
    func hideSideMeun()
}

class MenuViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelAppVersion: UILabel!
    
    weak var delegate: MenuTableProtocol?
    
    var menuControllers:[UIViewController]!
    var lastSelection:IndexPath!
    
    //orders,Wallet,Get FREE Groceries,Settings,login/signup
    var additionalMenuItems = [MenuItem]()
    var Images = [String]()
    var selectedImages = [String]()

    let border = CALayer()
    
    fileprivate func setAppVersion() {
        if let nsObject: AnyObject = (Bundle.resource.infoDictionary!["CFBundleShortVersionString"] as AnyObject??)! {
            let version = nsObject as! String
            
            labelAppVersion.textColor = UIColor.greenInfoColor()
            labelAppVersion.text = version
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.additionalMenuItems.append(MenuItem(title: localizedString("side_menu_orders", comment: "")))
        self.additionalMenuItems.append(MenuItem(title: localizedString("setting_favourites", comment: "")))
        self.additionalMenuItems.append(MenuItem(title: localizedString("side_menu_wallet", comment: "")))
        self.additionalMenuItems.append(MenuItem(title: localizedString("side_menu_free_groceries", comment: "")))
        self.additionalMenuItems.append(MenuItem(title: localizedString("setting_feedback", comment: "")))
        self.additionalMenuItems.append(MenuItem(title: localizedString("side_meun_setting", comment: ""), canShowNotificationDot: true))
        self.additionalMenuItems.append(MenuItem(title: localizedString("side_menu_login", comment: "")))
        
        if UserDefaults.isUserLoggedIn() {
            Images =  ["Shops","Order","Favorite","Wallet","Free Groceries","Live Chat","Settings"]
            selectedImages =  ["Shops-Selected","Order-Selected","Favorite-Selected","Wallet-Selected","Free Groceries-Selected","Live Chat-Selected","Settings-Selected"]
        }else{
            Images =  ["Signout","Shops"]
            selectedImages =  ["Signout-Selected","Shops-Selected"]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        self.view.layer.shadowOpacity = 0.5
        self.view.layer.shadowRadius = 3.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.reloadLiveChatMenuRow(_:)), name:NSNotification.Name(rawValue: kHelpshiftChatResponseNotificationKey), object: nil)
        
        registerTableViewCell()
        setAppVersion()
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.tableView.separatorColor = UIColor.borderGrayColor()
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.tableFooterView = UIView()
        
        if UserDefaults.isUserLoggedIn() {
            self.lastSelection = IndexPath(row: 0, section: 0)
        }else{
           self.lastSelection = IndexPath(row: 1, section: 0)
        }
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if ElGrocerUtility.sharedInstance.isHomeSelected {
            self.lastSelection = IndexPath(row: 0, section: 0)
            ElGrocerUtility.sharedInstance.isHomeSelected = false
        }
        
       elDebugPrint("Last Selection:%d",self.lastSelection.row)
        self.tableView.reloadData()
        
        //Helpshift
        /*HelpshiftCore.initialize(with: HelpshiftAll.sharedInstance())
        HelpshiftCore.install(forApiKey: kHelpShiftApiKey, domainName: kHelpShiftDomainName, appID:kHelpShiftAppId)*/
    }
    
    // MARK: Live chat row reload
    
    @objc func reloadLiveChatMenuRow(_ notification: Notification?) {
        self.tableView.reloadData()
    }
    
    //MARK: TableView
    
    func registerTableViewCell() {
        
        let nib = UINib(nibName: "MenuTableCell", bundle: Bundle.resource)
        self.tableView.register(nib, forCellReuseIdentifier: kMenuTableCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // The logic for the cell height depends on the table view having only one section. If there are more sections the logic needs to be reimplemented. 
        // This would be a programming error and should be detected early
        guard self.tableView.numberOfSections == 1 else { fatalError("The logic for cell height depends on the table view having only one section. More sections detected")}
        
        // The cells should scale to fit the content area of the menu tableView
        var cellHeight = floor(self.tableView.frame.height / CGFloat(self.tableView(tableView, numberOfRowsInSection: 0)))
        
        // On the other hand we dont want the cell height to be too big
        cellHeight = min(cellHeight, 44)
        
        // Or too small
        cellHeight = max(cellHeight, 30)
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        if UserDefaults.isUserLoggedIn() {
            rows = self.menuControllers.count + self.additionalMenuItems.count - 1
        } else {
            rows =  self.menuControllers.count - 3 + self.additionalMenuItems.count - 3
        }
        
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var menuItem:MenuItem
        var imageName:String
        
        if UserDefaults.isUserLoggedIn() {
            
          menuItem  = (indexPath as NSIndexPath).row < self.menuControllers.count ? self.menuControllers[(indexPath as NSIndexPath).row].menuItem! : self.additionalMenuItems[(indexPath as NSIndexPath).row - self.menuControllers.count]
         
            if (indexPath as NSIndexPath).row == self.lastSelection.row {
                 imageName = selectedImages[(indexPath as NSIndexPath).row]
            }else{
                 imageName = Images[(indexPath as NSIndexPath).row]
            }
            
        } else {
            
            if (indexPath as NSIndexPath).row == 0 {
                menuItem = self.additionalMenuItems[6]
            }else {
                menuItem = self.menuControllers[0].menuItem!
            }
            
            if (indexPath as NSIndexPath).row == self.lastSelection.row {
                imageName = selectedImages[(indexPath as NSIndexPath).row]
            }else{
                imageName = Images[(indexPath as NSIndexPath).row]
            }
        }
        
        let cell:MenuTableCell = tableView.dequeueReusableCell(withIdentifier: kMenuTableCellIdentifier, for: indexPath) as! MenuTableCell
       
        var showNotification = false
        if menuItem.canShowNotificationDot {
            
            showNotification = UserDefaults.isHelpShiftChatResponseUnread()
        }
        
        cell.configureCellWithMenuItem(menuItem, withImage: imageName, shouldShowNotificationDot: showNotification)
        if ((indexPath as NSIndexPath).row == 3) {
           cell.walletAmount.isHidden = false
           let amountStr = String(format: "%@ %@",ElGrocerUtility.sharedInstance.walletTotal,localizedString("aed", comment: ""))
           cell.walletAmount.text = amountStr
        }else{
            cell.walletAmount.isHidden = true
        }
        
        
        if (indexPath as NSIndexPath).row == self.lastSelection.row {
            
            let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
            if currentLang == "ar" {
                 border.frame = CGRect(x: cell.frame.width - 1.5, y: 0, width: 1.5, height: cell.frame.height)
            }else{
                 border.frame = CGRect(x: 0, y: 0, width: 1.5, height: cell.frame.height)
            }
            
            border.backgroundColor =  UIColor.meunGreenTextColor().cgColor;
            cell.contentView.layer.addSublayer(border)
            cell.contentView.backgroundColor = UIColor.meunCellSelectedColor()
            cell.itemTitle.textColor = UIColor.meunGreenTextColor()
            cell.walletAmount.textColor = UIColor.meunGreenTextColor()
            
        }else{
            
            cell.contentView.backgroundColor = UIColor.clear
            cell.itemTitle.textColor = UIColor.black
            cell.walletAmount.textColor = UIColor.black
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        if (indexPath as NSIndexPath).row == Images.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width);
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if UserDefaults.isUserLoggedIn() {
            
            if self.lastSelection != indexPath {
                
                let cell = tableView.cellForRow(at: self.lastSelection) as! MenuTableCell
                cell.contentView.backgroundColor = UIColor.clear
                cell.itemTitle.textColor = UIColor.black
                cell.walletAmount.textColor = UIColor.black
                let imageName = Images[self.lastSelection.row]
                cell.itemImage.image = UIImage(name:imageName)
                
                border.removeFromSuperlayer()
                
                let selectedCell = tableView.cellForRow(at: indexPath) as! MenuTableCell
                let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
                if currentLang == "ar" {
                    border.frame = CGRect(x: cell.frame.width - 1.5, y: 0, width: 1.5, height: cell.frame.height)
                }else{
                    border.frame = CGRect(x: 0, y: 0, width: 1.5, height: cell.frame.height)
                }
                border.backgroundColor =  UIColor.meunGreenTextColor().cgColor;
                selectedCell.contentView.layer.addSublayer(border)
                selectedCell.contentView.backgroundColor = UIColor.meunCellSelectedColor()
                selectedCell.itemTitle.textColor = UIColor.meunGreenTextColor()
                selectedCell.walletAmount.textColor = UIColor.meunGreenTextColor()
                let selectedImage = selectedImages[(indexPath as NSIndexPath).row]
                selectedCell.itemImage.image = UIImage(name:selectedImage)
                
                self.lastSelection = indexPath
            }
            
            
            if (indexPath as NSIndexPath).row < self.menuControllers.count {
                let controller:UIViewController = self.menuControllers[(indexPath as NSIndexPath).row]
                self.lastSelection = indexPath
                self.delegate?.menuTableViewDidSelectViewController(controller)
                
                if ElGrocerUtility.sharedInstance.isFromReorder {
                    ElGrocerUtility.sharedInstance.clearActiveBasketForReOrder()
                }
                
            } else {
                
                self.lastSelection = indexPath
                
                if (indexPath as NSIndexPath).row == self.menuControllers.count {
                    
                    let ordersController = ElGrocerViewControllers.ordersViewController()
                    self.delegate?.menuTableViewDidSelectViewController(ordersController)
                    
                }else if (indexPath as NSIndexPath).row == self.menuControllers.count + 1 {
                    let favouritesController = ElGrocerViewControllers.favouritesViewController()
                    self.delegate?.menuTableViewDidSelectViewController(favouritesController)
                }else if (indexPath as NSIndexPath).row == self.menuControllers.count + 2 {
                    let walletController = ElGrocerViewControllers.walletViewController()
                    self.delegate?.menuTableViewDidSelectViewController(walletController)
                } else if (indexPath as NSIndexPath).row == self.menuControllers.count + 3 {
                    let freeGroceriesController = ElGrocerViewControllers.freeGroceriesViewController()
                    self.delegate?.menuTableViewDidSelectViewController(freeGroceriesController)
                }else if (indexPath as NSIndexPath).row == self.menuControllers.count + 4 {
                    self.showLiveChat()
                }else {
                    let settingController = ElGrocerViewControllers.settingViewController()
                    settingController.menuControllers = self.menuControllers
                    self.delegate?.menuTableViewDidSelectViewController(settingController)
                }
            }
            
        }else{
            
            if (indexPath as NSIndexPath).row == 0 {
                
                // (UIApplication.sharedApplication().delegate as! SDKManager).showEntryView()
                
                let registrationProfileController = ElGrocerViewControllers.registrationPersonalViewController()
                let navController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                navController.viewControllers = [registrationProfileController]
                navController.modalPresentationStyle = .fullScreen
                guard let slideController = SDKManager.shared.rootViewController as? SlideMenuViewController else {
                    return
                }
                
                slideController.present(navController, animated: true, completion: nil)
                
                self.delegate?.hideSideMeun()
                
            }else if ((indexPath as NSIndexPath).row == 1) {
               /* let controller:UIViewController = self.menuControllers[indexPath.row - 1]
                self.lastSelection = indexPath
                self.delegate?.menuTableViewDidSelectViewController(controller)*/
                
                self.delegate?.hideSideMeun()
            }
        }
    }
    
    func showLiveChat(){
        
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_help_from_meun")
//        ZohoChat.showChat()
        let sendBirdManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
        sendBirdManager.setUpSenBirdDeskWithCurrentUser()
        // // Intercom.presentMessageComposer()
        
       /* if !UserDefaults.isUserLoggedIn() {
            //feedback
            HelpshiftSupport.showConversation(self, withOptions:["hideNameAndEmail" : "YES"])
            
            UserDefaults.setHelpshiftChatResponseUnread(false)
            NotificationCenter.default.post(name: Notification.Name(rawValue: kHelpshiftChatResponseNotificationKey), object: nil)
        } else {
            //set user name and email
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if userProfile != nil && userProfile?.name != nil {
                HelpshiftCore.setName(userProfile?.name, andEmail: userProfile?.email)
            }
            //feedback
            HelpshiftSupport.showConversation(self, withOptions:["hideNameAndEmail" : "YES"])
            UserDefaults.setHelpshiftChatResponseUnread(false)
            NotificationCenter.default.post(name: Notification.Name(rawValue: kHelpshiftChatResponseNotificationKey), object: nil)
        }*/
    }
}
