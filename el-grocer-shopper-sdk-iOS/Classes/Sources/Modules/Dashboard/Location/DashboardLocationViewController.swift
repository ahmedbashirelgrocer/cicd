//
//  DashboardLocationViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 06.07.2015.
//  Copyright (c) 2015 elGrocer. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GooglePlaces

protocol DashboardLocationProtocol : class {
    
    func refreshViewForUpdatedLocation(_ groceries:[Grocery])
}

class DashboardLocationViewController : UIViewController, UITableViewDataSource, UITableViewDelegate,DashboardLocationCellProtocol, NavigationBarProtocol {
    
    @IBOutlet var lbl_Note: UILabel! {
        didSet{
            lbl_Note.text = localizedString("lbl_Note", comment: "")
            lbl_Note.setCaptionOneRegDarkStyle()
        }
    }
    @IBOutlet var btnNewAddress: AWButton! {
        didSet{
            btnNewAddress.setButton2SemiBoldWhiteStyle()
            btnNewAddress.setTitle(" " + localizedString("lbl_add_new_Address", comment: ""), for: .normal)
            btnNewAddress.setBackgroundColorForAllState(ApplicationTheme.currentTheme.buttonEnableBGColor)
        }
    }
    weak var delegate:DashboardLocationProtocol?
    @IBOutlet var topView: UIView!
    
    @IBOutlet var btnConfirmTitile: UILabel!
    @IBOutlet var btnCOnfirm: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.roundWithShadow(corners: [.layerMinXMinYCorner , .layerMaxXMinYCorner], radius: 24)
            tableView.clipsToBounds = true
            tableView.bounces = false
            tableView.backgroundColor = .textfieldBackgroundColor()
        }
    }

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationImgView: UIImageView!
    
    @IBOutlet weak var currLocView: UIView!
    @IBOutlet weak var currLocImgView: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var currentLocLabel: UILabel!
    
   // @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var noCoverageTitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailDoneButton: UIButton!
    @IBOutlet weak var noCoverageView: UIView!
    
//    @IBOutlet weak var tableViewTopToSearchView: NSLayoutConstraint!
//    @IBOutlet weak var tableViewTopToLocationView: NSLayoutConstraint!
//
//    @IBOutlet weak var tableViewTopToCurrentLocView: NSLayoutConstraint!
//
//    @IBOutlet weak var tableViewBottomToSuperView: NSLayoutConstraint!
//    @IBOutlet weak var tableViewBottomToDoneButton: NSLayoutConstraint!
//
//    @IBOutlet weak var noCoverageViewTopToSearchView: NSLayoutConstraint!
    
    var selectdIndex = 0
    
    var isFormCart:Bool = false
    
    var isForNewAddress:Bool = false
    
    var isFromNewHome:Bool = false
    
    var isRootController:Bool = false
    
    var isComeAfterLogin:Bool = false
    
    var isNeedToRemoveBackButton : Bool = false
    
    var isNoCoverage:Bool = false
    
    var isFindStore:Bool = false
    
    var searchString:String = ""
    
    var locShopId:NSNumber = 0.0
    
    @IBOutlet var topViewWidth: NSLayoutConstraint!
    @IBOutlet var bottomViewHeight: NSLayoutConstraint!
    
    var fetcher: GMSAutocompleteFetcher?
    
    let viewModel = LocationMapViewModel()
    
    var locations:[DeliveryAddress] = [DeliveryAddress]()
    var predictionsArray: [GMSAutocompletePrediction] = [GMSAutocompletePrediction]()
    
    var menuControllers:[UIViewController]!
    
    var currentPlace:GMSPlace?
    
    var oldAddressLat = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)?.latitude  ?? 0
    var oldAddressLng = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)?.longitude ?? 0
    var oldAddressID = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)?.dbID ?? ""
    var oldAddressName = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)?.address ?? ""
    var newSelectedAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    
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
        
        self.title = localizedString("dashboard_My_ddresses_navigation_bar_title", comment: "")
        
//        if isRootController == false {
//            addBackButton()
//        }else{
//            removeBackButton()
//        }
//        if isComeAfterLogin || isNeedToRemoveBackButton {
//             removeBackButton()
//        }
        
        fetchLocations()
        setUpSearchTextFieldAppearance()
        setupDoneButtonAppearance()
        showViewAccordingToLocationService()
        setupTableViewAppearance()
        setupNoCoverageViewAppearance()
        
        NotificationCenter.default.addObserver(self,selector: #selector(DashboardLocationViewController.showViewAccordingToLocationService), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self
            .keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
      //  self.checkLocation()
        if   isFromNewHome ||  isFormCart {
            if isFormCart {
                self.btnConfirmTitile.text = localizedString("intro_next_button", comment: "")
                self.bottomViewHeight.constant = 77
                removeBackButton()
            }else{
                removeBackButton()
            }
        }
        
        self.topViewWidth.constant = self.view.frame.size.width
        self.tableView.backgroundColor = .textfieldBackgroundColor()
        self.tableView.tableHeaderView = self.topView
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.hideSeparationLine()
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        self.addRightCrossButton(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshData()
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsDeliveryAddressScreen)
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.DashBoard.rawValue, screenClass: String(describing: self.classForCoder))
    }
    
    func checkLocation() {
        
        let isServiceEnabled = self.checkLocationService()
        if isServiceEnabled {
            
           elDebugPrint("Current Location is enabled")
            
            if let location = LocationManager.sharedInstance.currentLocation.value {
                
                let lat = location.coordinate.latitude
                let long = location.coordinate.longitude
                let offset = 200.0 / 1000.0
                let latMax = lat + offset
                let latMin = lat - offset
                let lngOffset = offset * cos(lat * .pi / 200.0)
                let lngMax = long + lngOffset
                let lngMin = long - lngOffset
                let initialLocation = CLLocationCoordinate2D(latitude: latMax, longitude: lngMax)
                let otherLocation = CLLocationCoordinate2D(latitude: latMin, longitude: lngMin)
                
                //let bounds = GMSCoordinateBounds(coordinate: initialLocation, coordinate: otherLocation)
                
                // Set up the autocomplete filter.
                let filter = GMSAutocompleteFilter()
                //filter.type = .Geocode
                
                if !(LocationManager.sharedInstance.countryCode == nil){
                    filter.country = LocationManager.sharedInstance.countryCode
                }
                filter.locationBias  = GMSPlaceRectangularLocationOption(initialLocation, otherLocation)
                // Create the fetcher.
                self.fetcher = GMSAutocompleteFetcher( filter: filter)
                self.fetcher?.delegate = self
               elDebugPrint("Fetcher is init with bounds")
                
            }else{
               elDebugPrint("Current Location is enabled but Fetcher is init without bounds")
                self.fetcher = GMSAutocompleteFetcher()
                self.fetcher?.delegate = self
            }
            
        }else{
           elDebugPrint("Current Location is not enabled so Fetcher is init without bounds")
            self.fetcher = GMSAutocompleteFetcher()
            self.fetcher?.delegate = self
        }
        
        
    }
    
    // MARK: TextField Actions
    @IBAction func textFieldTextChange(_ sender: AnyObject) {
        
        self.isNoCoverage = false
        self.noCoverageView.isHidden = true
        
        self.searchString = self.searchTextField.text!
        self.fetcher?.sourceTextHasChanged(self.searchTextField.text!)
    }
    
    // MARK: Button Actions
    
    override func backButtonClick() {
        
        if self.presentingViewController != nil {
            if isNoCoverage {
                self.hideNoCoverageView()
            }else{
                self.presentingViewController!.dismiss(animated: true, completion: nil)
            }
        }else{
            
            if isNoCoverage {
                self.hideNoCoverageView()
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        if isRootController{
            self.removeBackButton()
        }
    }
    
    @IBAction func doneHandler(_ sender: AnyObject) {
        
        var indexOfDefaultLocation = self.locations.firstIndex(where: {$0.isActive.boolValue == true})
        if self.isFormCart {
           indexOfDefaultLocation =  self.selectdIndex
        }
        if sender is DeliveryAddress {
            indexOfDefaultLocation = self.locations.firstIndex(of: sender as! DeliveryAddress)
        }
        if (indexOfDefaultLocation != nil){
            let location = self.locations[indexOfDefaultLocation!]
            guard !SDKManager.isGroverySingleStore else {
                self.updateStore(location: location) { [weak self ] (isStoreChange) in
                    if isStoreChange {
                        self?.startUpdatingLocationToServerProcess(location)
                    }
                }
                return
            }
            startUpdatingLocationToServerProcess(location)
        }
        
        
        FireBaseEventsLogger.trackChangeLocationFromHome(oldLocationID: oldAddressID, oldLocationName: oldAddressName, oldlocationLat: oldAddressLat, oldlocationLng: oldAddressLng, newLocation: self.newSelectedAddress)
        
    }
    
    @IBAction func emailDoneHandler(_ sender: AnyObject) {
        
        //_ = SpinnerView.showSpinnerViewInView(self.view)
//        ElGrocerApi.sharedInstance.requestForGroceryWithEmail(self.emailTextField.text!, locShopId: locShopId)
//        {(result) in
//
//            switch result {
//            case .success(let result):
//                if result == true {
//                    let alert  = ElGrocerAlertView.createAlert(localizedString("thank_you", comment: ""), description: localizedString("delivery_location_request", comment: ""), positiveButton: localizedString("ok_button_title", comment: ""), negativeButton: "", buttonClickCallback: nil)
//                    alert.show()
//                   elDebugPrint("Record update successfully.")
//                    self.isNoCoverage = false
//                    self.noCoverageView.isHidden = true
//                    self.refreshData()
//                } else {
//                   elDebugPrint("Error from server.")
//                }
//            case .failure(let error):
//                error.showErrorAlert()
//            }
//
//            SpinnerView.hideSpinnerView()
//        }
    }
    
    // MARK: Helpers
    
    
    
    fileprivate func startUpdatingLocationToServerProcess(_ location: DeliveryAddress) {
        
        guard !isFormCart else {

            let storeID = ElGrocerUtility.sharedInstance.activeGrocery?.dbID
            let parentID = ElGrocerUtility.sharedInstance.activeGrocery?.parentID.stringValue
            let _ = SpinnerView.showSpinnerViewInView(self.view)
            ElGrocerApi.sharedInstance.checkIfGroceryAvailable(CLLocation.init(latitude: location.latitude, longitude: location.longitude), storeID: storeID ?? "", parentID: parentID ?? "") { (result) in
                
                switch result {
                    
                    case .success(let responseObject):
                        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                        if  let groceryDict = responseObject["data"] as? NSDictionary {
                            if groceryDict.allKeys.count > 0 {
                                    let arrayGrocery = Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)
                                    if arrayGrocery.count > 0 {
                                        ElGrocerUtility.sharedInstance.groceries = arrayGrocery
                                        ElGrocerUtility.sharedInstance.activeGrocery = arrayGrocery[0]
                                        self.makeLocationToDefault(location)
                                        SpinnerView.hideSpinnerView()
                                        return
                                    }
                                }
                        }
                        
                        SpinnerView.hideSpinnerView()
                        
                        let SDKManager = SDKManager.shared
                        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "locationPop") , header: "", detail: localizedString("lbl_NoCoverage_msg", comment: ""),localizedString("add_address_alert_yes", comment: "") , localizedString("add_address_alert_no", comment: ""), withView: SDKManager.window!) { (index) in
                            
                            if index == 0 {
                                ElGrocerUtility.sharedInstance.activeGrocery = nil
                                ElGrocerUtility.sharedInstance.resetRecipeView()
                                self.makeLocationToDefault(location)
                            }else{
                               SpinnerView.hideSpinnerView()
                            }
                    }
                    case .failure(let error):
                        SpinnerView.hideSpinnerView()
                        error.showErrorAlert()
                }
            }
            return
        }
        
            self.makeLocationToDefault(location)
        
        if !SDKManager.isGroverySingleStore {
            ElGrocerUtility.sharedInstance.activeGrocery = nil
                ElGrocerUtility.sharedInstance.resetRecipeView()
        }
       
        
    }
    
    fileprivate func fetchLocations() {
        
        guard UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext) != nil else {
            return
        }
        
        //get user locations
        _ = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.getDeliveryAddresses({ (result:Bool, responseObject:NSDictionary?) -> Void in
            
            if result {
                
                let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                context.performAndWait({ () -> Void in
                    
                    guard let userProfile = UserProfile.getUserProfile(context) else {
                        SpinnerView.hideSpinnerView()
                        return
                    }
                    
                   _ = DeliveryAddress.insertOrUpdateDeliveryAddressesForUser(userProfile, fromDictionary: responseObject!, context: context)
                    DatabaseHelper.sharedInstance.saveDatabase()
                    DispatchQueue.main.async(execute: { 
                        self.refreshData()
                        SpinnerView.hideSpinnerView()
                    })
                })
            } else {
                
                SpinnerView.hideSpinnerView()
            }
        })
        
    }
    
    func refreshData(_ isNeedShowAniamtion : Bool = true) {
        
        self.newSelectedAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        self.locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        self.locations.sort {$0.isActive.boolValue && !$1.isActive.boolValue}
        
       elDebugPrint("Locations Array Count:%d",self.locations.count)
        
        if (self.searchString.isEmpty) {
            
            //Show view according to location service
            self.showViewAccordingToLocationService()
            
            // Hide done button if no location is added or found
             self.hideDoneButton(self.locations.count == 0)
            
        }else{
            self.hideCurrentLocationView(true)
            self.hideDisableLocationView(true)
            self.hideDoneButton(true)
        }
        
        /*if self.searchString.isEmpty && self.locations.count == 0 {
            self.hideDoneButton(true)
        }else{
            
            if self.searchString.isEmpty{
                self.hideDoneButton(false)
                self.showViewAccordingToLocationService()
            }else{
                self.hideCurrentLocationView(true)
                self.hideDisableLocationView(true)
                self.hideDoneButton(true)
            }
        }*/
        
        self.tableView.isHidden = false
        self.tableView.reloadData()
        
        //tutorial
         if !UserDefaults.wasLocationTutorialShown() {
//            self.tableView.isScrollEnabled = false
//            if isNeedShowAniamtion {
//                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DashboardLocationViewController.addAnimationEffect), userInfo: nil, repeats: false)
//            }
            
         }
    }
    
    // MARK: Animation
    
    fileprivate func performBackAnimation() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromLeft
        if let viewWindows = view.window {
            viewWindows.layer.add(transition, forKey: kCATransition)
        }

    }
    
    @objc fileprivate func addAnimationEffect(){
        
        if self.locations.count > 0 && self.searchString.isEmpty {
            
            let indexPath = IndexPath(row:0, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as! DashboardLocationCell
            
            UIView.animate(withDuration: 0.7, delay:0.0, options: (UIView.AnimationOptions()), animations: {() -> Void in
              //  cell.mainContainer.transform = CGAffineTransform(translationX: 25, y: 0)
                
                }, completion: {(finished: Bool) -> Void in
                    
                    UIView.animate(withDuration: 0.7, delay:0.0, options: (UIView.AnimationOptions()), animations: {() -> Void in
                   //     cell.mainContainer.transform = CGAffineTransform(translationX: 0, y: 0)
                        
                        }, completion: {(finished: Bool) -> Void in
                            
                            UIView.animate(withDuration: 0.7, delay:0.0, options: (UIView.AnimationOptions()), animations: {() -> Void in
                            //    cell.mainContainer.transform = CGAffineTransform(translationX: -25, y: 0)
                                
                                }, completion: {(finished: Bool) -> Void in
                                    
                                    
                                    UIView.animate(withDuration: 0.7, delay:0.0, options: (UIView.AnimationOptions()), animations: {() -> Void in
                                      //  cell.mainContainer.transform = CGAffineTransform(translationX: 0, y: 0)
                                        
                                        }, completion: {(finished: Bool) -> Void in
                                           UserDefaults.setLectionTutorialAsShown(true)
                                           self.tableView.isScrollEnabled = true
                                    })
                            })
                    })
            })
        }
    }
    
    
    // MARK: Appearance
    
    func setUpSearchTextFieldAppearance(){
        
        self.searchTextField.placeholder = localizedString("dashboard_location_search_placeholder", comment: "")
        self.searchTextField.font = UIFont.bookFont(13.0)
        self.searchTextField.textColor = UIColor.darkGrayTextColor()
        self.searchTextField.backgroundColor = UIColor.lightGrayBGColor()
        
         self.searchTextField.attributedPlaceholder =
            NSAttributedString(string: self.searchTextField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        
        if(self.isFindStore == true){
            self.isFindStore = false
            //self.searchTextField.becomeFirstResponder()
        }
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.searchTextField.frame.height))
        self.searchTextField.leftView = paddingView
        self.searchTextField.leftViewMode = UITextField.ViewMode.always
        
        
        if self.searchViewHeight != nil {
            self.searchViewHeight.constant = .leastNonzeroMagnitude
        }
    }
    
    func setupDoneButtonAppearance() {
    }
    
    func setUpLocationViewAppearance(_ isEnabled:Bool){
        
        var titleStr = NSMutableAttributedString()
        // Unused view review and remove
        if isEnabled {
            self.locationView.backgroundColor =  ApplicationTheme.currentTheme.unselectedPageControl
            self.locationImgView.image = UIImage(name: "location-pin-selected")
            self.locationLabel.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            
            titleStr = NSMutableAttributedString(string: localizedString("dashboard_enable_location_services", comment: ""))
            
        }else{
            self.locationView.backgroundColor =  ApplicationTheme.currentTheme.viewOOSItemRedColor
            self.locationImgView.image = UIImage(name: "location-pin-white")
            self.locationLabel.textColor = ApplicationTheme.currentTheme.labelTextWithBGColor
            
            titleStr = NSMutableAttributedString(string: localizedString("dashboard_enable_location_services_2", comment: ""))
        }
        
        self.locationLabel.font = UIFont.SFProDisplaySemiBoldFont(13.0)
        self.locationLabel.numberOfLines = 0
        self.locationLabel.sizeToFit()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.0
        titleStr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, titleStr.length))
        self.locationLabel.attributedText = titleStr
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DashboardLocationViewController.onEnableLocationClick))
        self.locationView.addGestureRecognizer(tapGesture)
    }
    
    func setUpCurrentLocationViewAppearance(){
    
        self.currentLabel.textColor = UIColor.darkGrayTextColor()
        self.currentLabel.font = UIFont.SFProDisplaySemiBoldFont(14.0)
        self.currentLabel.text = localizedString("current_location_title", comment: "")
        self.currentLabel.numberOfLines = 0
        self.currentLabel.sizeToFit()
        
        self.currentLocLabel.textColor = UIColor.darkGrayTextColor()
        self.currentLocLabel.font = UIFont.bookFont(13.0)
        self.currentLocLabel.text = localizedString("finding_address_title", comment: "")
        self.currentLocLabel.numberOfLines = 0
        self.currentLocLabel.sizeToFit()
        
        let image = ElGrocerUtility.sharedInstance.getImageWithName("locate_icon")
        self.currLocImgView.image = image
        
        var titleStr = NSMutableAttributedString()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.0
        
        
        self.activityView.isHidden = true
        self.currLocImgView.isHidden = false
        
        titleStr = NSMutableAttributedString(string: (self.currentPlace?.formattedAddress ?? " "))
        titleStr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, titleStr.length))
        self.currentLocLabel.attributedText = titleStr
        
       
        
        /*
        if let currentLoc = self.currentPlace {
            
            self.activityView.isHidden = true
            self.currLocImgView.isHidden = false
            
            titleStr = NSMutableAttributedString(string: (currentLoc.formattedAddress ?? " "))
            titleStr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, titleStr.length))
            self.currentLocLabel.attributedText = titleStr
            
        }else{
            
            self.currLocImgView.isHidden = true
            self.activityView.isHidden = false
            self.activityView.hidesWhenStopped = true
            self.activityView.startAnimating()
            
            let placesClient = GMSPlacesClient()
            placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
                
                self.activityView.stopAnimating()
                self.currLocImgView.isHidden = false
                
                if let error = error {
                   elDebugPrint("Pick Place error: \(error.localizedDescription)")
                    self.currentLocLabel.text = localizedString("failed_to_find_current_address_title", comment: "")
                    return
                }
                if let placeLikelihoodList = placeLikelihoodList {
                    if placeLikelihoodList.likelihoods.count > 0 {
                        let likelihood = placeLikelihoodList.likelihoods[0]
                        let place = likelihood.place
                        self.currentPlace = place
                        titleStr = NSMutableAttributedString(string: (place.formattedAddress ?? " "))
                        titleStr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, titleStr.length))
                        self.currentLocLabel.attributedText = titleStr
                    }
                }
            })
        }
        
    */
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DashboardLocationViewController.onCurrentLocationClick))
        self.currLocView.addGestureRecognizer(tapGesture)
    }
    
    func setupTableViewAppearance() {
        
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.tableFooterView = UIView()
      //  self.tableView.separatorColor = UIColor.borderGrayColor()
        
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 185
        self.tableView.reloadData()
        
       
    
    }
    override func rightBackButtonClicked() {
        backButtonClickedHandler()
        MixpanelEventLogger.trackChooseLocationClose()
    }
    func backButtonClickedHandler(){
        self.backButtonClick()
    }
    
    func setupNoCoverageViewAppearance() {
        
        let tapGesture  = UITapGestureRecognizer(target: self,action:#selector(DashboardLocationViewController.handleTapGesture(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.noCoverageView.addGestureRecognizer(tapGesture)
        
        self.noCoverageTitleLabel.font = UIFont.bookFont(12.0)
        self.noCoverageTitleLabel.textColor = UIColor.black
       
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
        let titleStr = NSMutableAttributedString(string: localizedString("txt_not_cover_area_1", comment: ""))
        titleStr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, titleStr.length))
        
        self.noCoverageTitleLabel.attributedText = titleStr
        
        self.noCoverageTitleLabel.numberOfLines = 0
        self.noCoverageTitleLabel.sizeToFit()
        
        self.emailDoneButton.titleLabel!.font = UIFont.SFProDisplaySemiBoldFont(18.0)
        self.emailDoneButton.setTitleColor(UIColor.white, for: UIControl.State())
        self.emailDoneButton.setTitle(localizedString("delivery_note_done_button_title", comment: ""), for:UIControl.State())
        self.emailDoneButton.setBackgroundColor(ApplicationTheme.currentTheme.buttonEnableBGColor, forState: UIControl.State())
        
        self.emailDoneButton.layer.cornerRadius = 5.0
        self.emailDoneButton.clipsToBounds = true
        setEmailDoneButtonEnabled(false)
        
        self.emailTextField.placeholder = localizedString("enter_email_placeholder_text", comment: "")
        self.emailTextField.font = UIFont.bookFont(13.0)
        self.emailTextField.textColor = UIColor.darkGrayTextColor()
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if(userProfile != nil){
                self.emailTextField.text = userProfile?.email
                _ = self.validateEmail((userProfile?.email)!)
            }
        }
    }
    
    // MARK: TapGesture
    
    @objc func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        
        self.emailTextField.resignFirstResponder()
    }
    
    // MARK: Validations
    
    func validateEmail(_ email:String) -> Bool {
        
        let enableSubmitButton = email.isValidEmail()
        
        self.emailTextField.layer.borderColor = (!enableSubmitButton && !email.isEmpty) ? UIColor.textfieldErrorColor().cgColor : UIColor.borderGrayColor().cgColor
        
        setEmailDoneButtonEnabled(enableSubmitButton)
        
        return enableSubmitButton
    }
    
    func setEmailDoneButtonEnabled(_ enabled:Bool) {
        
        self.emailDoneButton.isEnabled = enabled
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.emailDoneButton.alpha = enabled ? 1 : 0.3
        })
    }
    
    // MARK: Enable location
    @objc func onEnableLocationClick() {
        
        ElGrocerAlertView.createAlert(localizedString("dashboard_enable_location_alert_title", comment: ""),
                                      description: localizedString("dashboard_enable_location_services_3", comment: ""),
                                      positiveButton: localizedString("sign_out_alert_yes", comment: ""),
                                      negativeButton: localizedString("sign_out_alert_no", comment: ""),
                                      buttonClickCallback: { (buttonIndex:Int) -> Void in
                                        
                                        if buttonIndex == 0 {
                                           elDebugPrint("Yes Tapped")
                                            UIApplication.shared.openURL(URL(string:UIApplication.openSettingsURLString)!)
                                        }else{
                                            self.setUpLocationViewAppearance(false)
                                        }
        }).show()
    }
    
    @objc func onCurrentLocationClick() {
        
        if let currentLoc = self.currentPlace {
            
            self.searchTextField.resignFirstResponder()
            
            if let placeId = currentLoc.placeID {
              self.getPlaceWithPlaceId(placeId)
            }
            
        }else{
            //print("Failed to find your current address")
            let currentLocation = LocationManager.sharedInstance.currentLocation.value
            let location = CLLocation(latitude: currentLocation?.coordinate.latitude ?? 0 , longitude: currentLocation?.coordinate.longitude ?? 0)
            self.viewModel.selectedLocation.value = location
            let locationMapController = ElGrocerViewControllers.locationMapViewController()
            locationMapController.delegate = self
            locationMapController.locationCurrentCoordinates = location.coordinate
            //locationMapController.place = place
            locationMapController.isConfirmAddress = false
            self.navigationController?.pushViewController(locationMapController, animated: true)
            SpinnerView.hideSpinnerView()
        }
    }
    
    
    // MARK: Check Location Services
    
    @objc func showViewAccordingToLocationService(){
        
        let isServiceEnabled = false//self.checkLocationService()
        if isServiceEnabled {
            self.hideDisableLocationView(true)
            self.hideCurrentLocationView(false)
            self.setUpCurrentLocationViewAppearance()
        }else{
            self.hideCurrentLocationView(true)
            self.hideDisableLocationView(false)
            setUpLocationViewAppearance(true)
        }
    }
    
    func checkLocationService() -> Bool {
        
        var isCurrentLocationEnabled = false
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined:
                LocationManager.sharedInstance.requestLocationAuthorization()
                NotificationCenter.default.addObserver(self, selector: #selector(self.locationUpdate(_:)), name:NSNotification.Name(rawValue: KLocationChange), object: nil)
                isCurrentLocationEnabled = false
            case  .restricted, .denied:
               elDebugPrint("No Access to Location services")
                isCurrentLocationEnabled = false
            case .authorizedAlways, .authorizedWhenInUse:
               elDebugPrint("Have Location services Access")
                isCurrentLocationEnabled = true
                @unknown default:
               elDebugPrint("Default Location services Access")
            }
        }
        
        return isCurrentLocationEnabled
    }
    @objc func locationUpdate(_ notification: NSNotification?)  {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: KLocationChange), object: nil);
        LocationManager.sharedInstance.stopUpdatingCurrentLocation()
        self.checkLocation()
        ElGrocerUtility.sharedInstance.delay(1) { [weak self] in
            guard let self = self else {return}
            self.refreshData()
        }
    }
    
    // MARK: Hide Location View
    fileprivate func hideCurrentLocationView(_ hidden:Bool){
        
        self.currLocView.isHidden = hidden
        
//        tableViewTopToSearchView.constant = hidden ? 0 : 60
//        tableViewTopToSearchView.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
//        tableViewTopToCurrentLocView.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
//
//        tableViewTopToLocationView.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
    }
    
    fileprivate func hideDisableLocationView(_ hidden:Bool){
        
        locationView.isHidden = hidden
        
//        tableViewTopToSearchView.constant = hidden ? 0 : 60
//        tableViewTopToSearchView.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
//        tableViewTopToLocationView.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
//
//        tableViewTopToCurrentLocView.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
    }
    
    fileprivate func hideDoneButton(_ hidden:Bool){
        
//        doneButton.isHidden = hidden
//
//        tableViewBottomToSuperView.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
//        tableViewBottomToDoneButton.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
    }
    
    fileprivate func hideNoCoverageView(){
        
        self.performBackAnimation()
        self.isNoCoverage = false
        self.noCoverageView.isHidden = true
        self.refreshData()
    }
    
    // MARK: UITableView
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
//        if self.searchString.isEmpty{
//            if (indexPath as NSIndexPath).row == self.locations.count{
//               return kLocationSearchCellHeight
//            }else{
//               return kDashboardLocationCellHeight
//            }
//        }else{
//            return kLocationSearchCellHeight
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.locations.count // self.searchString.isEmpty ? self.locations.count :  self.predictionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let location = self.locations[(indexPath as NSIndexPath).row]
        
        if UserDefaults.isUserLoggedIn() {
            
            
            
            let cell:DashboardLocationCell = tableView.dequeueReusableCell(withIdentifier: kDashboardLocationCellIdentifier, for: indexPath) as! DashboardLocationCell
            
            if self.isFormCart {
                cell.configureWithLocation(location, true)
                if indexPath.row == self.selectdIndex {
                    cell.borderContainer.layer.borderColor = ApplicationTheme.currentTheme.themeBasePrimaryColor.cgColor
                    cell.borderContainer.layer.borderWidth = 2
                    cell.borderContainer.backgroundColor = .navigationBarWhiteColor()
                    cell.defaultButton.isHidden = false
                }else{
                    cell.borderContainer.layer.borderColor = UIColor.clear.cgColor
                    cell.borderContainer.layer.borderWidth = 0
                    cell.borderContainer.backgroundColor = .navigationBarWhiteColor()
                    cell.defaultButton.isHidden = true
                }
            }else{
                cell.configureWithLocation(location)
            }
            cell.delegate = self
            return cell
            
            
        }else{
            
            let cell:AddAddressCell = tableView.dequeueReusableCell(withIdentifier: kAddAddressCellIdentifier, for: indexPath) as! AddAddressCell
            cell.configureWithLocation(location)
            return cell
            
        }
        
        
        
            /*
        if self.searchString.isEmpty{
            
           
            
     
            if (indexPath as NSIndexPath).row == self.locations.count{

                let cell:AddAddressCell = tableView.dequeueReusableCell(withIdentifier: kAddAddressCellIdentifier, for: indexPath) as! AddAddressCell
                cell.configureCell()
                return cell

            }else{

                let location = self.locations[(indexPath as NSIndexPath).row]

                let cell:DashboardLocationCell = tableView.dequeueReusableCell(withIdentifier: kDashboardLocationCellIdentifier, for: indexPath) as! DashboardLocationCell
                cell.configureWithLocation(location)
                cell.delegate = self
                return cell
            }
            
        }else{
            
            if (indexPath as NSIndexPath).row == self.predictionsArray.count{
                
                let cell:AddAddressCell = tableView.dequeueReusableCell(withIdentifier: kAddAddressCellIdentifier, for: indexPath) as! AddAddressCell
                cell.configureCell()
                return cell
                
            }else{
                
                let cell:LocationSearchCell = tableView.dequeueReusableCell(withIdentifier: kLocationSearchCellIdentifier, for: indexPath) as! LocationSearchCell
                
                let prediction = self.predictionsArray[(indexPath as NSIndexPath).row]
                cell.configureWithPrediction(prediction)
                return cell
                
            }
        }
        
        
        */
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           
            if (indexPath as NSIndexPath).row == self.locations.count {
                
                let locationMapController = ElGrocerViewControllers.locationMapViewController()
                locationMapController.delegate = self
                self.navigationController?.pushViewController(locationMapController, animated: true)
                
                isNoCoverage = false
                self.noCoverageView.isHidden = true
                
            } else {
            
                if self.isFormCart {
                    self.selectdIndex = indexPath.row
                    self.tableView.reloadData()
//                    let location = self.locations[(indexPath as NSIndexPath).row]
//                    self.doneHandler(location as AnyObject)
                    return
                }
                 let location = self.locations[(indexPath as NSIndexPath).row]
                
                guard !SDKManager.isGroverySingleStore else {
                    self.updateStore(location: location) { [weak self ] (isStoreChange) in
                        if isStoreChange {
                            self?.startUpdatingLocationToServerProcess(location)
                        }
                        SpinnerView.hideSpinnerView()
                    }
                    return
                }
                startUpdatingLocationToServerProcess(location)
                ElGrocerUtility.sharedInstance.activeGrocery = nil
                ElGrocerUtility.sharedInstance.resetRecipeView()
            }
            
            let location = self.locations[indexPath.row]
            MixpanelEventLogger.trackChooseLocationSelected(locAddress: location.address, locId: location.dbID)

    }

    private func getPlaceWithPlaceId(_ placeID: String){
        
        let placesClient = GMSPlacesClient()
        
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
               elDebugPrint("lookup place id query error: \(error.localizedDescription)")
                SpinnerView.hideSpinnerView()
                self.showLocationErrorAlert()
                return
            }
            
            guard let place = place else {
               elDebugPrint("No place details for \(placeID)")
                SpinnerView.hideSpinnerView()
                self.showLocationErrorAlert()
                return
            }
            
            let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            self.viewModel.selectedLocation.value = location
            self.viewModel.predictionlocationName.value = place.name
            self.viewModel.predictionlocationAddress.value = place.formattedAddress
            self.viewModel.buildingName.value = ElGrocerUtility.sharedInstance.getPremiseFrom(place)
            
            if let placeType = place.types {
                if(placeType.count > 1){
                    let locationMapController = ElGrocerViewControllers.locationMapViewController()
                    locationMapController.delegate = self
                    locationMapController.place = place
                    locationMapController.isConfirmAddress = true
                    self.navigationController?.pushViewController(locationMapController, animated: true)
                    SpinnerView.hideSpinnerView()
                    return
                }
            }
            
           
            
            self.checkForCoveredArea()
        })
    }
    
    // MARK: DashboardLocationCellProtocol
    
    func dashboardLocationCellDidTouchEditButton(_ cell: DashboardLocationCell) {
        
        MixpanelEventLogger.trackChooseLocationEditClick()
        let indexPath = self.tableView.indexPath(for: cell)
        let location = self.locations[(indexPath! as NSIndexPath).row]
        
        let editLocationController = ElGrocerViewControllers.editLocationViewController()
        editLocationController.deliveryAddress = location
        editLocationController.editScreenState = .isFromEdit
        redirectIfLogged(editLocationController)
    }
    
    func dashboardLocationCellDidTouchDeleteButton(_ cell: DashboardLocationCell) {
        
        MixpanelEventLogger.trackChooseLocationDeleteClick()
        let indexPath = self.tableView.indexPath(for: cell)
        let address = self.locations[(indexPath! as NSIndexPath).row]
        
        let allLocations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        // User cannot delete the last delivery address
        guard allLocations.count > 1 else {
            
        
            ElGrocerAlertView.createAlert(localizedString("dashboard_location_delete_alert_title", comment: ""),
                  description: localizedString("dashboard_location_cant_delete_message", comment: ""),
                  positiveButton: localizedString("dashboard_location_delete_alert_ok_button", comment: ""),
                  negativeButton: nil,
                  buttonClickCallback: nil).show()
            return
        }
        
        // User cannot delete the active delivery address
        guard address.isActive.boolValue == false else {
            
            ElGrocerAlertView.createAlert(localizedString("dashboard_location_delete_alert_title", comment: ""),
                  description: localizedString("dashboard_location_cant_delete_active_location_error", comment: ""),
                  positiveButton: localizedString("dashboard_location_delete_alert_ok_button", comment: ""),
                  negativeButton: nil,
                  buttonClickCallback: nil).show()
            return
        }
        
        let SDKManager = SDKManager.shared
        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "LocationDelete") , header: "", detail: localizedString("dashboard_location_delete_alert_message", comment: ""),localizedString("sign_out_alert_yes", comment: ""),localizedString("sign_out_alert_no", comment: "") , withView: SDKManager.window!) { (index) in
            
            if index == 0 {
                 self.removeUserLocation(cell)
            }else{
                SpinnerView.hideSpinnerView()
            }
        }
    
        /*ElGrocerAlertView.createAlert(localizedString("dashboard_location_delete_alert_title", comment: ""),
          description: localizedString("dashboard_location_delete_alert_message", comment: ""),
          positiveButton: localizedString("sign_out_alert_yes", comment: ""),
          negativeButton: localizedString("sign_out_alert_no", comment: ""),
          buttonClickCallback: { (buttonIndex:Int) -> Void in
            
            if buttonIndex == 0 {
                
                self.removeUserLocation(cell)
            }
            
        }).show()*/
    }
    
    fileprivate func removeUserLocation(_ selectedLocationCell:DashboardLocationCell) {
        
        let indexPath = self.tableView.indexPath(for: selectedLocationCell)
        let address = self.locations[(indexPath! as NSIndexPath).row]
        
        if UserDefaults.isUserLoggedIn() {
            
            _ = SpinnerView.showSpinnerViewInView(self.view)
            //remove location on the server
            ElGrocerApi.sharedInstance.deleteDeliveryAddress(address, completionHandler: { (result:Bool , msg : String) -> Void in
                
                GoogleAnalyticsHelper.trackDeliveryLocationAction(DeliveryLocationActionType.Remove)
                
                SpinnerView.hideSpinnerView()
                
                if result {
                    
                    //remove address from table
                    self.locations.remove(at: (indexPath! as NSIndexPath).row)
                    self.tableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
                    
                    //remove from database
                    DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(address)
                    
                    DatabaseHelper.sharedInstance.saveDatabase()
                    
                } else {
                    
                    var msgToDisplay = localizedString("dashboard_location_deletion_error", comment: "")
                    if msg.count > 0 {
                        msgToDisplay = msg
                    }
                    
                    ElGrocerAlertView.createAlert(msgToDisplay,
                                                  description: nil,
                                                  positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                                  negativeButton: nil, buttonClickCallback: nil).show()
                    
                }
                
            })
        
        }else{
            
            //remove address from table
            self.locations.remove(at: (indexPath! as NSIndexPath).row)
            self.tableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
            
            //remove from database
            DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(address)
            DatabaseHelper.sharedInstance.saveDatabase()
        }
    }
    
    func redirectIfLogged(_ controller:UIViewController , _ animated : Bool = true ) {
        
        if UserDefaults.isUserLoggedIn() {
            self.navigationController?.pushViewController(controller, animated: animated)
        } else {
            // The user is not logged in so we can only let him change his current location
            let locationSelectionController = ElGrocerViewControllers.locationMapViewController()
            locationSelectionController.delegate = self
            self.navigationController?.pushViewController(locationSelectionController, animated: true)
        }
        self.removeBackButton()
    }
    
    fileprivate func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    fileprivate func updateStore(location: DeliveryAddress?, completion:@escaping ((Bool) -> Void)) {
        
        if var launch = SDKManager.shared.launchOptions {
            launch.marketType = .singleStore
            launch.latitude = location?.latitude ?? 0.0
            launch.longitude = location?.longitude ?? 0.0
            FlavorAgent.restartEngineWithLaunchOptions(launch) {
                let _ = SpinnerView.showSpinnerViewInView(self.view)
            } completion: { isLoaded, grocery in
                if isLoaded ?? false {
                    ElGrocerUtility.sharedInstance.activeGrocery = grocery
                    completion(true)
                } else {
                    FlavorNavigation.shared.navigateToNoLocation()
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
        
    }
    
    fileprivate func fetchGroceries() {
        
        guard let currentAddress = getCurrentDeliveryAddress() else {
            SpinnerView.hideSpinnerView()
            return
        }
         
        DynamicLinksHelper.sharedInstance.setNewGroceryAccordingToLink(currentAddress.dbID)
        ElGrocerUtility.sharedInstance.CurrentLoadedAddress = ""
        SpinnerView.hideSpinnerView()
        guard !self.isFormCart else {
            self.dismiss(animated: true) {}
            return
        }
        
        self.dismiss(animated: true) {
            
            if SDKManager.isSmileSDK {
                if UIApplication.topViewController() is UniversalSearchViewController, ElGrocerUtility.sharedInstance.activeGrocery == nil {
                    
                    if let topVc = UIApplication.topViewController() {
                        topVc.dismiss(animated: false)
                        topVc.tabBarController?.selectedIndex = 0
                    }
                }
                
            } else if UIApplication.topViewController() is GenericStoresViewController {

            } else if UIApplication.topViewController() is MainCategoriesViewController {
                
                UIApplication.topViewController()?.tabBarController?.selectedIndex = 0;
                ElGrocerUtility.sharedInstance.delay(0.2){
                    if UIApplication.topViewController() is MainCategoriesViewController{
                        let mainca = UIApplication.topViewController()
                            mainca?.viewWillAppear(true)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: KReloadGenericView), object: nil)
                    } else {
                        (SDKManager.shared).showAppWithMenu()
                    }
                    
                }
                
            } else {
                
                (SDKManager.shared).showAppWithMenu()
            }
        }
    }
    
    func checkForCoveredArea(){
        
        guard let location = self.viewModel.selectedLocation.value else {
            SpinnerView.hideSpinnerView()
            return
        }
        
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.checkCoveredAreaForGroceries(location) { (result) -> Void in
            
            switch result {
                
            case .success(let response):
                
               elDebugPrint("Success")
                
                let dataDict = response["data"] as? NSDictionary
                let isCovered = dataDict!["is_covered"] as? Bool
                // IntercomeHelper.updateIsLiveToIntercom(isCovered!)
                // PushWooshTracking.updateIsLive(isCovered!)
                
                if(isCovered == true){
                    
                     guard let location = self.viewModel.selectedLocation.value else {return}
                    
                     guard let locName = self.viewModel.predictionlocationName.value else {return}
                    elDebugPrint("Location Name:%@",locName)
                    
                     guard let locAddress = self.viewModel.predictionlocationAddress.value else {return}
                    elDebugPrint("Location Address:%@",locAddress)
                    
                    self.addDeliveryAddressWithLocation(selectedLocation: location, withLocationName: locName, andWithUserAddress: locAddress, building: self.viewModel.buildingName.value ?? "", cityName:  self.viewModel.locationCity.value)
                }else{
                    
                    SpinnerView.hideSpinnerView()
                    self.locShopId =  dataDict!["location_without_shop_id"] as! NSNumber
                   elDebugPrint("ShopID:%@",self.locShopId)
                    self.isNoCoverage = true
                    self.noCoverageView.isHidden = false
                    
//                    if(self.isRootController){
//                        self.addBackButton()
//                    }
                }
                
            case .failure(let error):
                SpinnerView.hideSpinnerView()
                error.showErrorAlert()
            }
        }
    }
    
    
    func addDeliveryAddressWithLocation(selectedLocation:CLLocation, withLocationName locName:String, andWithUserAddress userAddress:String , building : String , cityName : String?) {
        
        
    
        
        self.oldAddressName = self.newSelectedAddress?.address ?? ""
        self.oldAddressID = self.newSelectedAddress?.dbID ?? ""
        self.oldAddressLat = self.newSelectedAddress?.latitude ?? 0
        self.oldAddressLng = self.newSelectedAddress?.longitude ?? 0
        
        
        if self.isForNewAddress {
            self.isForNewAddress = false
            let selectedLocLatitude  = String(format: "%.6f",selectedLocation.coordinate.latitude)
            let selectedLocLongitude  = String(format: "%.6f",selectedLocation.coordinate.longitude)
            let existingLocationIndex = self.locations.firstIndex(where: {String(format: "%.6f",$0.latitude) == selectedLocLatitude && String(format: "%.6f",$0.longitude) == selectedLocLongitude})
            if existingLocationIndex != nil {
                if UserDefaults.isUserLoggedIn(){
                    ElGrocerAlertView.createAlert(localizedString("exist_location_title", comment: ""),description: localizedString("exist_location_message", comment: ""),positiveButton: localizedString("sign_out_alert_yes", comment: ""),negativeButton: localizedString("sign_out_alert_no", comment: ""),buttonClickCallback: { (buttonIndex:Int) -> Void in
                        if buttonIndex == 0 {
                            let existingLocation = self.locations[existingLocationIndex!]
                            let editLocationController = ElGrocerViewControllers.editLocationViewController()
                            editLocationController.deliveryAddress = existingLocation
                            self.redirectIfLogged(editLocationController)
                        }else{
                            self.refreshData()
                        }
                    }).show()
                }else{
                    self.refreshData()
                    ElGrocerAlertView.createAlert( localizedString("add_location_title", comment: ""),description:localizedString("already_added_location_message", comment: ""),positiveButton:nil,negativeButton:nil,buttonClickCallback:nil).showPopUp()
                }
                SpinnerView.hideSpinnerView()
                return
            }
        }
        
        //let deliveryAddress = DeliveryAddress.createObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let deliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        deliveryAddress.locationName = locName
        deliveryAddress.latitude = selectedLocation.coordinate.latitude
        deliveryAddress.longitude = selectedLocation.coordinate.longitude
        deliveryAddress.address = userAddress
        deliveryAddress.apartment = ""
        deliveryAddress.building = building
        deliveryAddress.city = cityName
        var streetStr = ""
        if(userAddress.isEmpty == false){
            let strComponents = userAddress.components(separatedBy: "-")
            if (strComponents.count >= 3){
                let trimmedString = strComponents[0].trimmingCharacters(in: .whitespacesAndNewlines)
                streetStr = String(format:"%@,%@",trimmedString,strComponents[1])
            }
        }
        
        deliveryAddress.street = streetStr
        deliveryAddress.floor = ""
        deliveryAddress.houseNumber = ""
        deliveryAddress.additionalDirection = ""
        deliveryAddress.addressType = "0"
        
        
        
        guard UserDefaults.isUserLoggedIn() else {
            
            let locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            for tempLoc in locations {
                if tempLoc.latitude == deliveryAddress.latitude &&  tempLoc.longitude == deliveryAddress.longitude {  }else{
                 DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(tempLoc)
                }
            }
            deliveryAddress.isActive = NSNumber(value: true as Bool)
            UserDefaults.setDidUserSetAddress(true)
            DatabaseHelper.sharedInstance.saveDatabase()
            // PushWooshTracking.updateAreaWithCoordinates(deliveryAddress.latitude, longitude: deliveryAddress.longitude , delAddress: deliveryAddress)
            self.refreshData()
          //  self.fetchGroceries()
            return
        }
        
        deliveryAddress.isActive = NSNumber(value: false as Bool)
        
         let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
         
          if userProfile != nil {
            deliveryAddress.userProfile = userProfile!
            }
        
            ElGrocerApi.sharedInstance.addDeliveryAddress(deliveryAddress, completionHandler: { (result:Bool, responseObject:NSDictionary?) -> Void in
                
                GoogleAnalyticsHelper.trackDeliveryLocationAction(DeliveryLocationActionType.Add)
                
                if result {
                    
                    let addressDict = (responseObject!["data"] as! NSDictionary)["shopper_address"] as! NSDictionary
                    
                    let dbID = addressDict["id"] as! NSNumber
                    let dbIDString = "\(dbID)"
                    deliveryAddress.dbID = dbIDString
                    if userProfile != nil {
                          let newAddress = DeliveryAddress.insertOrUpdateDeliveryAddressForUser(userProfile!, fromDictionary: addressDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        
                        DatabaseHelper.sharedInstance.saveDatabase()
                        
                        // We need to set the new address as the active address
                        ElGrocerApi.sharedInstance.setDefaultDeliveryAddress(newAddress, completionHandler: { (result) in
                            //  SpinnerView.hideSpinnerView()
                            UserDefaults.setDidUserSetAddress(true)
                            self.refreshData()
                           // self.fetchGroceries()
                            self.presentContactInfoViewController(newAddress)

                        })
                    }
                   
                    
                } else {
                    
                    DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(deliveryAddress)
                    DatabaseHelper.sharedInstance.saveDatabase()
                    
                    ElGrocerAlertView.createAlert(localizedString("my_account_saving_error", comment: ""),
                                                  description: nil,
                                                  positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                                  negativeButton: nil, buttonClickCallback: nil).show()
                }
            })

        
    }
    
    func makeLocationToDefault(_ location: DeliveryAddress){
        
        let currentAddress = getCurrentDeliveryAddress()
        if currentAddress != nil && ElGrocerUtility.sharedInstance.activeGrocery != nil {
            UserDefaults.setGroceryId((ElGrocerUtility.sharedInstance.activeGrocery?.dbID)!, WithLocationId: (currentAddress?.dbID)!)
        }
        
        if UserDefaults.isUserLoggedIn() {
            
            ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("change_location")
            _ = SpinnerView.showSpinnerViewInView(self.view)
            
            
            ElGrocerApi.sharedInstance.setDefaultDeliveryAddress(location) { (result) in
                
               elDebugPrint(result)
                if result {
                    self.refreshData(false)
                    if self.isFormCart  {
                        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        let isDataFilled = ElGrocerUtility.sharedInstance.validateUserProfile(userProfile, andUserDefaultLocation: location)
                        if isDataFilled || ElGrocerUtility.sharedInstance.activeGrocery == nil {
                            self.dismiss(animated: true) {
                                if ElGrocerUtility.sharedInstance.activeGrocery == nil {
                                    if let topVc = UIApplication.topViewController() {
                                        topVc.tabBarController?.selectedIndex = SDKManager.isGroverySingleStore ? 1 : 0
                                    }
                                    //self.tabBarController?.selectedIndex = 0
                                }
                            }
                            
                           
                        }else{
                            
                            let editLocationController = ElGrocerViewControllers.editLocationViewController()
                            editLocationController.deliveryAddress = location
                            editLocationController.editScreenState = .isFromCart
                            self.redirectIfLogged(editLocationController,  false)
                        }
                    }else {
                        if !SDKManager.isGroverySingleStore { self.fetchGroceries() } else {
                            self.dismiss(animated: true)
                        }
                    }
                    
                  
                     
                } else {
                    SpinnerView.hideSpinnerView()
                    ElGrocerError.unableToSetDefaultLocationError().showErrorAlert()
                }
            }
            
        }else{
            
            let locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            for tempLoc in locations {
                
                if tempLoc.locationName == location.locationName{
                    tempLoc.isActive = NSNumber(value: true as Bool)
                }else{
                    tempLoc.isActive = NSNumber(value: false as Bool)
                }
            }
            
            DatabaseHelper.sharedInstance.saveDatabase()
            self.refreshData(false)
            self.fetchGroceries()
        }
    }
    
    
    func showGenericStoreUI() {

//       if  let SDKManager = SDKManager.shared {
        SDKManager.shared.showAppWithMenu()
//        }else {
//        let entryController =  ElGrocerViewControllers.ElgrocerParentTabbarController()
//        let navController = ElgrocerGenericUIParentNavViewController(navigationBarClass: ElgrocerWhilteLogoBar.self, toolbarClass: nil)
//        navController.viewControllers = [entryController]
//        navController.modalPresentationStyle = .fullScreen
//            self.present(navController, animated: true, completion: nil)
//        }

    }
    
    
    
    func presentContactInfoViewController(_ location: DeliveryAddress) {
        
        
        let editLocationController = ElGrocerViewControllers.editLocationViewController()
        editLocationController.deliveryAddress = location
        redirectIfLogged(editLocationController,  false)
        
        
        /*
        
        let contactInfoVC = ElGrocerViewControllers.contactInfoViewController()
        contactInfoVC.userInfo = userProfile
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [contactInfoVC]
        self.navigationController?.present(navController, animated: true, completion: nil)
 */
        
    }
    
    //MARK: KeyBoard Handling
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if isNoCoverage{
            
            let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
            let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 0.5, delay:0.0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
              //  self.noCoverageViewTopToSearchView.constant = self.searchView.frame.height - keyboardHeight
               elDebugPrint("noCoverageViewTopToSearchView",self.searchView.frame.height - keyboardHeight)
                }, completion: { finished in
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if isNoCoverage{
            
            UIView.animate(withDuration: 0.5, delay:0.0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
              //  self.noCoverageViewTopToSearchView.constant = 0
                }, completion: { finished in
                    
            })
        }
    }
    
    private func showLocationErrorAlert(){
        
        ElGrocerAlertView.createAlert(localizedString("location_error_title", comment: ""),
                                      description: localizedString("location_error_message", comment: ""),
                                      positiveButton: localizedString("location_error_ok_button", comment: ""),
                                      negativeButton: nil,
                                      buttonClickCallback: { (buttonIndex:Int) -> Void in
                                        if buttonIndex == 0 {
                                            
                                            let locationMapController = ElGrocerViewControllers.locationMapViewController()
                                            locationMapController.delegate = self
                                            self.navigationController?.pushViewController(locationMapController, animated: true)
                                            
                                            self.isNoCoverage = false
                                            self.noCoverageView.isHidden = true
                                        }
        }).show()
    }
    
    @IBAction func addNewAddressAction(_ sender: Any) {
        
        MixpanelEventLogger.trackChooseLocationAddAddressClick()
        let locationMapController = ElGrocerViewControllers.locationMapViewController()
        locationMapController.delegate = self
        locationMapController.isFromCart = self.isFormCart
        self.isForNewAddress = true
        self.navigationController?.pushViewController(locationMapController, animated: true)
        
    }
    
    
}

// MARK: LocationMapViewControllerDelegate
extension DashboardLocationViewController: LocationMapViewControllerDelegate {
    
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withAddress address: String? ,  withBuilding building: String? , withCity cityName: String?) {
        
        self.navigationController?.popViewController(animated: true)
        self.addDeliveryAddressWithLocation(selectedLocation: location!, withLocationName: name!, andWithUserAddress: address!, building: building ?? "", cityName: cityName)
        
        
    }
    
    
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withBuilding address: String? ,  withCity building: String? ,  withCity cityName: String?){
        
        self.navigationController?.popViewController(animated: true)
        self.addDeliveryAddressWithLocation(selectedLocation: location!, withLocationName: name!, andWithUserAddress: address!, building: building ?? "", cityName: cityName)
    }
    
    //Hunain 26Dec16
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withBuilding building: String?  , withCity cityName: String?) {
        
        self.navigationController?.popViewController(animated: true)
        self.addDeliveryAddressWithLocation(selectedLocation: location!, withLocationName: name!, andWithUserAddress: building!, building: building ?? "", cityName: cityName)
    }
}

// MARK: UITextFieldDelegate

extension DashboardLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == self.searchTextField {
            isNoCoverage = false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        if isNoCoverage{
            self.emailTextField.resignFirstResponder()
        }else{
            
            self.searchTextField.resignFirstResponder()
            if(textField.returnKeyType == .search){
                let locationName = textField.text
                if  locationName != nil && locationName?.isEmpty == false {
                   elDebugPrint("Search String:%@",locationName ?? "NULL")
                    let _ = SpinnerView.showSpinnerViewInView(self.view)
                    LocationManager.sharedInstance.getPlaceIdFromLocationName(locationName,withCompletionHandler: { (status, success,placeID) -> Void in
                        if success {
                            self.searchTextField.text = ""
                            self.searchString = ""
                            self.getPlaceWithPlaceId(placeID!)
                        }else {
                            SpinnerView.hideSpinnerView()
                            self.showLocationErrorAlert()
                        }
                    })
                }
            }
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        self.searchString = ""
        self.refreshData()
        self.searchTextField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // check email validatoon
        if textField == self.emailTextField {
            var email = self.emailTextField.text
            email = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
            _ = validateEmail(email!)
        }
        
        return true
    }
}

// MARK: GMSAutocompleteFetcherDelegate

extension DashboardLocationViewController: GMSAutocompleteFetcherDelegate {
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        
        self.predictionsArray.removeAll()
        self.predictionsArray = predictions
        self.refreshData()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
       elDebugPrint("Error:%@",error.localizedDescription)
    }
}


