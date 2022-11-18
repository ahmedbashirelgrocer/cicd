//
//  GroceriesViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 08.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class GroceriesViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, GroceryCellProtocol, GroceriesEmptyViewDelegate,DashboardLocationProtocol{
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var locationButtonTitleLabel: UILabel!
    
    // MARK: Properties
    var arrayDetailShowingIndexes = NSMutableArray.init(array: [])
    var location: DeliveryAddress {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)!
    }

    var selectedGrocery:Grocery!
    var serverGroceries:[Grocery]?
    
    var showBackBtn = true
    var isFromCancelOrder = false
    var isFromEntryScreen = false
    
    var loadedGroceryId = ""
    
    /** Shown when there are no groceries */
    var groceriesEmptyView = GroceriesEmptyView.initFromNib()
    
    
    //var tableA : [Grocery] = []
    
    // MARK: Life cycle
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localizedString("dashboard_store_navigation_bar_title", comment: "")
       // self.tableA = ElGrocerUtility.sharedInstance.completeGroceries
        
        //Hunain 29Dec16
        if showBackBtn {
            addBackButton()
        }else{
            addLocationButton()
        }
        
        self.registerTableCell()
        self.configureEmptyView()
        
     
         self.fetchLatestGroceries()
        self.arrayDetailShowingIndexes = NSMutableArray.init(array: [])
        
       
    }

    override func viewWillAppear(_ animated: Bool) {
        self.setUpApearence()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsGroceriesScreen)
        FireBaseEventsLogger.setScreenName( FireBaseScreenName.ChangeStore.rawValue , screenClass: String(describing: self.classForCoder))
        
        NotificationCenter.default.addObserver(self,selector: #selector(GroceriesViewController.fetchLatestGroceries), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    func setUpApearence() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        self.navigationController?.navigationBar.barTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func refreshViewForUpdatedLocation(_ groceries: [Grocery]) {
        
        ElGrocerUtility.sharedInstance.completeGroceries = groceries
        
        let filteredArray = groceries.filter() {($0.isOpen.boolValue && Int($0.deliveryTypeId!) != 1) || ($0.isSchedule.boolValue && Int($0.deliveryTypeId!) != 0)}
        ElGrocerUtility.sharedInstance.groceries = filteredArray
        
        if ElGrocerUtility.sharedInstance.completeGroceries.count == 0 {
            self.showGroceriesEmptyViewWithMode(.noPartnerGrocery)
        }else{
           self.groceriesEmptyView.isHidden = true
           self.tableView.reloadData()
        }
    }
    
    // MARK: Helpers
    
    fileprivate func configureEmptyView() {
        
        self.groceriesEmptyView.isHidden = true
        self.tableViewContainer.addSubviewFullscreen(self.groceriesEmptyView)
         self.groceriesEmptyView.delegate = self
    }
    
    fileprivate func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    
    @objc fileprivate func fetchLatestGroceries() {
        
        guard let currentAddress = getCurrentDeliveryAddress() else {
            self.showGroceriesEmptyViewWithMode(.noPartnerGrocery)
            return
        }
        
        let latitude: CLLocationDegrees = currentAddress.latitude
        let longitude: CLLocationDegrees = currentAddress.longitude
        let location: CLLocation = CLLocation(latitude: latitude,
                                              longitude: longitude)
        CleverTapEventsLogger.setUserLocationCoardinatedName(location.coordinate)
        
        self.groceriesEmptyView.isHidden = true
        
        if ElGrocerUtility.sharedInstance.completeGroceries.count == 0 {
            _ = SpinnerView.showSpinnerViewInView(self.view)
        }
     
        ElGrocerApi.sharedInstance.getAllGroceries(currentAddress, completionHandler: { (result) in
            
            switch result {
                
            case .success(let response):
                
                let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
               elDebugPrint(response)
                let arrayGrocery = Grocery.insertOrReplaceGroceriesFromDictionary(response, context: context)
                ElGrocerUtility.sharedInstance.completeGroceries = arrayGrocery
                let filteredArray = arrayGrocery.filter() {($0.isOpen.boolValue && Int($0.deliveryTypeId!) != 1) || ($0.isSchedule.boolValue && Int($0.deliveryTypeId!) != 0)}
                ElGrocerUtility.sharedInstance.groceries = filteredArray
                self.tableView.reloadData()
                
            case .failure(let error):
                
                error.showErrorAlert()
                
            }
            
            SpinnerView.hideSpinnerView()
            
            if ElGrocerUtility.sharedInstance.completeGroceries.count == 0 {
                self.showGroceriesEmptyViewWithMode(.noPartnerGrocery)
            }
            
        })
        
    }
    
    
    
    
    // MARK: Actions
    
    override func backButtonClick() {
        
//        let transition = CATransition()
//        transition.duration = 0.3
//        transition.type = CATransitionType.moveIn
//        transition.subtype = CATransitionSubtype.fromLeft
//        view.window!.layer.add(transition, forKey: kCATransition)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onLocationButtonClick(_ sender: AnyObject) {
        
        self.naviagteUserToLocationView()
    }
    
    override func locationButtonClick() {
        self.naviagteUserToLocationView()
    }
    
    fileprivate func naviagteUserToLocationView(){
        
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        
        let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
        dashboardLocationVC.delegate = self
        navigationController.viewControllers = [dashboardLocationVC]
        navigationController.setLogoHidden(true)
        navigationController.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        
        
        self.navigationController?.present(navigationController, animated: false, completion: nil)
        
    }
    
    // MARK: Appearance
    fileprivate func showGroceriesEmptyViewWithMode(_ mode: NoGroceriesMode) {

        self.groceriesEmptyView.mode = mode
        self.groceriesEmptyView.isHidden = false
    }
    
    // MARK: Data
    
    /* func refreshData() {
        
        self.groceries = Grocery.getAllGroceries(serverGroceries: self.serverGroceries, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        self.tableView.reloadData()
        
        
        if self.groceries.count == 0 {
            self.showGroceriesEmptyViewWithMode(.Offline)
        }

        //tutorial
        /*if !UserDefaults.wasTutorialImageShown(TutorialView.TutorialImage.GroceryList) && self.groceries.count > 0 {
            
            TutorialView.showTutorialView(withImage: TutorialView.TutorialImage.GroceryList)
            UserDefaults.setTutorialImageAsShown(TutorialView.TutorialImage.GroceryList)
        }*/
    }*/
    
    // MARK: UITableView
    
    func registerTableCell() {
        
        let cellNib = UINib(nibName: "GroceryCell", bundle: Bundle.resource)
        self.tableView.register(cellNib, forCellReuseIdentifier: kGroceryCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
          return kGroceryCellHeightWithInfo
        /*
        let isRequiredToShowDetails = self.arrayDetailShowingIndexes.contains(NSNumber.init(value: (indexPath as NSIndexPath).row as Int))
        
        if isRequiredToShowDetails {
            return kGroceryCellHeightWithInfo
        }else{
            return kGroceryCellHeight
        }
 */
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ElGrocerUtility.sharedInstance.completeGroceries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kGroceryCellIdentifier, for: indexPath) as! GroceryCell
        let grocery = ElGrocerUtility.sharedInstance.completeGroceries[(indexPath as NSIndexPath).row]
        
        let isRequiredToShowDetails = self.arrayDetailShowingIndexes.contains(NSNumber.init(value: (indexPath as NSIndexPath).row as Int))
        
        cell.configureWithGrocery(grocery, isDetailsShown: isRequiredToShowDetails)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedGrocery = ElGrocerUtility.sharedInstance.completeGroceries[(indexPath as NSIndexPath).row]
        
        
        
        if (self.selectedGrocery.isOpen.boolValue && Int(self.selectedGrocery.deliveryTypeId!) != 1) || (self.selectedGrocery.isSchedule.boolValue && Int(self.selectedGrocery.deliveryTypeId!) != 0){
            
            
            let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if currentAddress != nil && self.selectedGrocery != nil {
                UserDefaults.setGroceryId(self.selectedGrocery.dbID , WithLocationId: (currentAddress?.dbID)!)
                ElGrocerUtility.sharedInstance.activeGrocery = self.selectedGrocery
            }
           
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromTop
            if let viewFor = view.window {
                viewFor.layer.add(transition, forKey: kCATransition)
            }
            
            
            if self.navigationController?.viewControllers[0]  is  MainCategoriesViewController {
                let  controller = self.navigationController?.viewControllers[0] as!  MainCategoriesViewController
                controller.refreshViewWithGrocery(self.selectedGrocery)
            }else{
                (SDKManager.shared).showAppWithMenu(true)
            }
            
            
            
            /*
            if (self.loadedGroceryId != self.selectedGrocery.dbID){
                if  self.navigationController?.viewControllers[0]  is  EntryViewController {
                    (SDKManager.shared).showAppWithMenu(true)
                }else if self.navigationController?.viewControllers[0]  is  MainCategoriesViewController {
                    let  controller = self.navigationController?.viewControllers[0] as!  MainCategoriesViewController
                    controller.grocerySelectedIndex = (indexPath as NSIndexPath).row
                    controller.refreshViewWithGrocery(self.selectedGrocery)
                }else{
                    
                }
            }else{
                
                if self.navigationController?.viewControllers[0]  is  MainCategoriesViewController {
                    let  controller = self.navigationController?.viewControllers[0] as!  MainCategoriesViewController
                    controller.grocerySelectedIndex = (indexPath as NSIndexPath).row
                    controller.addChangeStoreButtonWithStoreNameAtTop(self.selectedGrocery)
                }
            }
            */
        
            ElGrocerUtility.sharedInstance.resetRecipeView()
            if isFromCancelOrder {
                self.navigationController?.popToRootViewController(animated: false)
            }else{
               self.navigationController?.popViewController(animated: false)
            }
            
            ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("change_store")
            
        }else{
            
           elDebugPrint("Currently Grocery is closed")
            ElGrocerAlertView.createAlert(localizedString("store_close_alert_title", comment: ""),
                                          description:localizedString("store_close_alert_message", comment: ""),
                                          positiveButton: localizedString("store_close_alert_button", comment: ""),
                                          negativeButton: nil, buttonClickCallback: nil).show()
        }
    }
    
    func resetRecipeView () {
        
        let SDKManager = SDKManager.shared
        if SDKManager.rootViewController as? UITabBarController != nil {
            if let tababarController = SDKManager.rootViewController as? UITabBarController {
                let main : ElGrocerNavigationController =  tababarController.viewControllers![3] as! ElGrocerNavigationController
                if let  controller = main.viewControllers[0] as? RecipesListViewController {
                    controller.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    
    func didTapInfoButtonForCell(_ cell: GroceryCell, isDetailShowing: Bool) {
        let indexPath = self.tableView.indexPath(for: cell)
        if isDetailShowing {
            self.arrayDetailShowingIndexes.add(NSNumber.init(value: ((indexPath as NSIndexPath?)?.row)! as Int))
            self.tableView.reloadRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
        }else{
            if (self.arrayDetailShowingIndexes.contains(NSNumber.init(value: ((indexPath as NSIndexPath?)?.row)! as Int))) {
                self.arrayDetailShowingIndexes.remove(NSNumber.init(value: ((indexPath as NSIndexPath?)?.row)! as Int))
                self.tableView.reloadRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
            }
        }
    }
    
    //Hunain 30Dec16
    //MARK: Add Delivery Address for Logined User

    /** Adds a delivery address on the backend and on success saves the local instance in the db */
    func addAddressFromDeliveryAddress(_ deliveryAddress: DeliveryAddress, forUser: UserProfile, completionHandler: @escaping () -> Void) {
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.addDeliveryAddress(deliveryAddress) { (result, responseObject) -> Void in
            SpinnerView.hideSpinnerView()
            GoogleAnalyticsHelper.trackDeliveryLocationAction(DeliveryLocationActionType.Add)
            
            // Remove the temporary delivery address
            DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(deliveryAddress)
            
            if result == true {
                
                let addressDict = (responseObject!["data"] as! NSDictionary)["shopper_address"] as! NSDictionary
                
                let currentAddress = DeliveryAddress.insertOrUpdateDeliveryAddressForUser(forUser, fromDictionary: addressDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                _ = DeliveryAddress.setActiveDeliveryAddress(currentAddress, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                DatabaseHelper.sharedInstance.saveDatabase()
                completionHandler()
                
                
            } else {
                ElGrocerAlertView.createAlert(localizedString("registration_error_alert", comment: ""),
                                              description: nil,
                                              positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                              negativeButton: nil, buttonClickCallback: nil).show()
            }
        }
        
    }

    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GroceriesToMainCategories" {
            
           elDebugPrint("Categories Count:",self.selectedGrocery.categories.count)
            
            let controller = segue.destination as! MainCategoriesViewController
            controller.grocery = self.selectedGrocery
        }
        
        if segue.identifier == "GroceryToReviews" {
            
            let controller = segue.destination as! GroceryReviewsViewController
            controller.grocery = self.selectedGrocery
        }
    }
    
    // MARK: GroceryCellProtocol
    
    func groceryCellDidTouchFavourite(_ groceryCell: GroceryCell, grocery: Grocery) {
        
        if grocery.isFavourite.boolValue {
            
            ElGrocerApi.sharedInstance.addGroceryToFavourite(grocery, completionHandler: { (result) -> Void in
                
            })
            // IntercomeHelper.updateIntercomFavouritesDetails()
            // PushWooshTracking.updateFavouritesDetails()
            
        } else {
            
            ElGrocerApi.sharedInstance.deleteGroceryFromFavourites(grocery, completionHandler: { (result) -> Void in
                
            })
            // IntercomeHelper.updateIntercomFavouritesDetails()
            // PushWooshTracking.updateFavouritesDetails()
        }
        
    }
    
    func groceryCellDidTouchScore(_ groceryCell: GroceryCell, grocery: Grocery) {
        
        self.selectedGrocery = grocery
        
        self.performSegue(withIdentifier: "GroceryToReviews", sender: self)
    }
    
    //Hunain 30Dec16
    // MARK: Show Error
    func showErrorAlert() {
        ElGrocerAlertView.createAlert(localizedString("my_account_saving_error", comment: ""),
                                      description: nil,
                                      positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                      negativeButton: nil, buttonClickCallback: nil).show()
    }
    
    // MARK: GroceriesEmptyViewDelegate
    
    func presentChangeLocationView(){
        self.naviagteUserToLocationView()
    }
    
    func presentChatViewController(){
        
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_help_from_meun")
        //ZohoChat.showChat()
        let sendBirdManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
        sendBirdManager.setUpSenBirdDeskWithCurrentUser()
        // // Intercom.presentMessageComposer()
        
       /* if !UserDefaults.isUserLoggedIn() {
            //feedback
            HelpshiftSupport.showConversation(self, withOptions:["hideNameAndEmail" : "YES"])
            /* ----------------------- Old code before updating helpshift to latest ----------------------------*/
           // Helpshift.sharedInstance().showConversation(self, withOptions: ["hideNameAndEmail" : "YES"])
            
            UserDefaults.setHelpshiftChatResponseUnread(false)
            NotificationCenter.default.post(name: Notification.Name(rawValue: kHelpshiftChatResponseNotificationKey), object: nil)

        } else {
            //set user name and email
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            HelpshiftCore.setName(userProfile?.name, andEmail: userProfile?.email)
            /* ----------------------- Old code before updating helpshift to latest ----------------------------*/
           // Helpshift.setName(userProfile.name, andEmail: userProfile.email)
            
            //feedback
            HelpshiftSupport.showConversation(self, withOptions:["hideNameAndEmail" : "YES"])
            /* ----------------------- Old code before updating helpshift to latest ----------------------------*/
            // Helpshift.sharedInstance().showConversation(self, withOptions: ["hideNameAndEmail" : "YES"])
            
            UserDefaults.setHelpshiftChatResponseUnread(false)
            NotificationCenter.default.post(name: Notification.Name(rawValue: kHelpshiftChatResponseNotificationKey), object: nil)
        }*/

    }
    
}

//Hunain 30Dec16

extension GroceriesViewController: LocationMapViewControllerDelegate {
        
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) {
        
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withBuilding building: String? , withCity cityName: String?) {
        //Do nothing
        guard let location = location, let name = name else {return}
        if !UserDefaults.isUserLoggedIn() {
            addDeliveryAddressForAnonymousUser(withLocation: location, locationName: name,buildingName: building!) { (deliveryAddress) in
            
            (SDKManager.shared).showAppWithMenu()
            
            }
        }else{
                let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                deliveryAddress!.locationName = name
                deliveryAddress!.address = name
                deliveryAddress!.building = building
                deliveryAddress!.latitude = location.coordinate.latitude
                deliveryAddress!.longitude = location.coordinate.longitude
                
                ElGrocerApi.sharedInstance.updateDeliveryAddress(deliveryAddress!, completionHandler: { (result:Bool) -> Void in
                    SpinnerView.hideSpinnerView()
                    if result {
                        DatabaseHelper.sharedInstance.saveDatabase()
                        (SDKManager.shared).showAppWithMenu()
                    } else {
                        SpinnerView.hideSpinnerView()
                        DatabaseHelper.sharedInstance.mainManagedObjectContext.rollback()
                        self.showErrorAlert()
                    }
                })
        }
    }
    
    /** Since the user is anonymous, we cannot send the delivery address on the backend.
     We need to store the delivery address locally and continue as an anonymous user */
    fileprivate func addDeliveryAddressForAnonymousUser(withLocation location: CLLocation, locationName: String,buildingName: String,completionHandler: (_ deliveryAddress: DeliveryAddress) -> Void) {
        
        // Remove any previous area
        //DeliveryAddress.clearEntity()
        DeliveryAddress.clearDeliveryAddressEntity()
        
        // Insert new area
        //let deliveryAddress = DeliveryAddress.createObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let deliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        deliveryAddress.locationName = locationName
        deliveryAddress.latitude = location.coordinate.latitude
        deliveryAddress.longitude = location.coordinate.longitude
        deliveryAddress.address = locationName
        deliveryAddress.apartment = ""
        deliveryAddress.building = buildingName
        deliveryAddress.street = ""
        deliveryAddress.floor = ""
        deliveryAddress.houseNumber = ""
        deliveryAddress.additionalDirection = ""
        deliveryAddress.isActive = NSNumber(value: true as Bool)
        DatabaseHelper.sharedInstance.saveDatabase()
        UserDefaults.setDidUserSetAddress(true)
        completionHandler(deliveryAddress)
        
    }
}
