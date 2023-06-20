//
//  LocationMapViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 01/03/16.
//  Copyright © 2016 elGrocer. All rights reserved.


import UIKit
import GoogleMaps
import GooglePlaces
import RxSwift
import RxCocoa
import CoreLocation
import IQKeyboardManagerSwift
protocol LocationMapViewControllerDelegate: class {
    
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) -> Void
    //optional
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withAddress address: String? ,  withBuilding building: String? , withCity cityName: String?)
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withBuilding building: String? , withCity cityName: String?)
    func locationSelectedAddress(_ address: DeliveryAddress, grocery:Grocery?)
}
extension LocationMapViewControllerDelegate {
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withAddress address: String? ,  withBuilding building: String? , withCity cityName: String?){}
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withBuilding building: String? , withCity cityName: String?){}
    func locationSelectedAddress(_ address: DeliveryAddress, grocery:Grocery?){}
}

class LocationMapViewController: UIViewController,GroceriesPopUpViewProtocol , NavigationBarProtocol {
    @IBOutlet var lbl_chooselocation: UILabel!{
        didSet{
            lbl_chooselocation.text =  localizedString("lbl_yourlocation", comment: "")
            lbl_chooselocation.setBody3RegDarkStyle()
            
        }
        
    }
    
    @IBOutlet var lblManuallMsg: UILabel! {
        didSet{
            lblManuallMsg.text =  localizedString("lbl_Manuall_Location", comment: "")
            lblManuallMsg.setBody3RegDarkStyle()
        }
        
    }
    @IBOutlet weak var topView: UIView! {
        didSet {
            topView.layer.cornerRadius = 24
            topView.layer.masksToBounds = true
        }
    }
    
    // @IBOutlet var lblCurrentLocation: UILabel!
    // MARK: Outlets
    @IBOutlet weak var mapView: GMSMapView?
    
    @IBOutlet weak var locationMarker: UIImageView! {
        didSet {
            if sdkManager.isSmileSDK {
                locationMarker.image = UIImage(name: "smile_pin")
            }
        }
    }
  
    @IBOutlet weak var topBg: UIView! {
        didSet {
            topBg.backgroundColor = ApplicationTheme.currentTheme.navigationBarColor
        }
    }
    @IBOutlet weak var footerTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapToolTipBgView: UIView!
    @IBOutlet weak var mapPinToolTipText: UILabel!
    @IBOutlet weak var detectingLocationView: UIView!
    
    var shouldUpdatePinUpdate = false
    var isPinUpdate : Bool = false
    var isNeedToUpdateManual : Bool = false
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet var       manualTextField: CustomTextField!
    @IBOutlet weak var viewLocationIcon: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var addressTitleLabel: UILabel! {
        didSet{
            addressTitleLabel.text =  localizedString("lbl_use_current_location", comment: "")
            addressTitleLabel.setH4SemiBoldGreenStyle()
        }
    }
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var addressLableHeight: NSLayoutConstraint!
    @IBOutlet weak var lblDetectLocation: UILabel! {
        didSet {
            lblDetectLocation.setH4SemiBoldGreenStyle()
            lblDetectLocation.text = localizedString("eg_detecting_location", comment: "")
        }
    }
    @IBOutlet weak var detectLocationImage: UIImageView! {
        didSet{
            detectLocationImage.image = sdkManager.isSmileSDK ? UIImage(name: "LocationDetectingPurple") : UIImage(name: "LocationDetecting")
        }
    }
    
    @IBOutlet weak var imgCurrentLocation: UIImageView! {
        didSet{
            imgCurrentLocation.image = sdkManager.isShopperApp ? UIImage(name: "location_icon_green") : UIImage(name: "location_icon_purple")
        }
    }
    
    
    var isNeedToDismiss : Bool = false
    var selectAddress : String = ""
    var isNeedToShowNoCoverage = false
    @IBOutlet var lblError: UILabel!
    @IBOutlet var lblErrorTwo: UILabel!
    //@IBOutlet var viewHeight: NSLayoutConstraint!
    @IBOutlet var lblCurrentSearchView: AWView!
    @IBOutlet var maunalSearchView: AWView!
    
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnChangeAddress: UIButton! {
        didSet {
            btnChangeAddress.setBody3BoldGreenStyle()
            btnChangeAddress.setTitle(localizedString("grocery_review_already_added_alert_confirm_button", comment: ""), for: .normal)
            btnChangeAddress.addTarget(self, action: #selector(searchLocation), for: .touchUpInside)
        }
    }
    
    // MARK: Properties
    
    let viewModel = LocationMapViewModel()
    
    let disposeBag = DisposeBag()
    
    var mapConfigured = false
    fileprivate var locationFetched = false
    
    var locationCurrentCoordinates = CLLocationCoordinate2D()
    
    var locName = ""
    var locAddress = ""
    var buildingName = ""
    
    var groceriesPopUpView:GroceriesPopUp!
    var fetchDeliveryAddressFromEntry : DeliveryAddress?
    // MARK: Delegate
    weak var delegate: LocationMapViewControllerDelegate?
    
    var place:GMSPlace?
    var isConfirmAddress = false
    var lastCoverageDict : NSDictionary? = NSDictionary()
    
    var isFromAddress = false
    var isForNewAddress = false
    
    var isFromCart = false
    var cameraZoom : Float = 18.0 // camera zoom position
    
    // MARK: Lifecycle
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
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        
        if isConfirmAddress == true {
            self.navigationItem.title = localizedString("confirm_address_title", comment: "")
            if let place = self.place{
                self.viewModel.predictionlocationName.value = place.name
                self.viewModel.predictionlocationAddress.value = place.formattedAddress
            }
        }else{
            self.navigationItem.title = localizedString("lbl_setyourlocation", comment: "") //
        }
        
        self.setBindings()
        self.configureAddressTextField()
        self.setupInitialControllerAppearance()
        //self.addBackButton()
        
        //Set location view icon layout
        self.setLocationIconAppearence()
        
        //Add gestur on current location icon
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapCurrentLocationIcon))
        viewLocationIcon.addGestureRecognizer(tapGesture)
        viewLocationIcon.isUserInteractionEnabled = true
        
        
        if selectAddress.count > 0 {
            self.addressTextField.text = selectAddress
        }
        if let add = fetchDeliveryAddressFromEntry {
            let location = CLLocation(latitude: add.latitude, longitude: add.longitude)
            self.viewModel.selectedLocation.value = location
            self.viewModel.locationName.value = add.locationName
            self.viewModel.locationAddress.value = add.address
            self.shouldUpdatePinUpdate = false
            let camera = GMSCameraPosition.camera(withTarget: location.coordinate , zoom: cameraZoom)
            self.mapView?.camera = camera
            
        }
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 10
        
        // Logging Segment Event/Screen
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .searchLocationScreen))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        self.navigationItem.hidesBackButton = true
        sdkManager.isShopperApp ? addWhiteBackButton() : addBackButton(isGreen: false)
        // self.setUpBottomView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsLocationMap)
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.Map.rawValue, screenClass: String(describing: self.classForCoder))
        self.setUpBottomView()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.configureMapView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) { }
    
    // MARK: Actions
    
    func backButtonClickedHandler() {
        backButtonClick()
    }
    
    @objc func searchLocation() {
        _ = self.textFieldShouldBeginEditing(UITextField())
    }
    
    @IBAction func confirmButtonHandler(_ sender: Any) {
        
        guard !isNeedToShowNoCoverage else {
            var locShopId =  self.lastCoverageDict!["location_without_shop_id"]
            //Bellow code is to show GroceriesPopUp
            let appDelegate = sdkManager
            self.groceriesPopUpView = GroceriesPopUp.showGroceriesPopUp(self,topView: appDelegate?.window! ?? self.view, shopId:locShopId as? NSNumber ?? 0)
            return
        }
        
        guard let location = self.viewModel.selectedLocation.value else {return}
        
        guard !isFromCart else {
            
            self.checkConveredAreaForBasket(location) { [weak self] isCoverd in
                guard let self = self else {return}
                if isCoverd {
                    let storeID = ElGrocerUtility.sharedInstance.activeGrocery?.dbID
                    let parentID = ElGrocerUtility.sharedInstance.activeGrocery?.parentID.stringValue
                    ElGrocerApi.sharedInstance.checkIfGroceryAvailable(location, storeID: storeID ?? "", parentID: parentID ?? "") { [weak self]  (result) in
                        guard let self = self else {return}
                        switch result {
                        case .success(let responseObject):
                            let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                            if  let groceryDict = responseObject["data"] as? NSDictionary {
                                    if groceryDict.count > 0 {
                                        let arrayGrocery = Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)
                                        if arrayGrocery.count > 0 {
                                            ElGrocerUtility.sharedInstance.activeGrocery = arrayGrocery[0]
                                            var cityName = "null"
                                            if let administrativeArea =  self.viewModel.selectedAddress.value?.administrativeArea {
                                                cityName = administrativeArea
                                            }
                                            if let localicty =  self.viewModel.selectedAddress.value?.locality {
                                                cityName = localicty
                                            }
                                            (self.delegate as? LocationMapDelegation)?.type = .basketSuccess
                                            self.delegate?.locationMapViewControllerWithBuilding(self, didSelectLocation: self.viewModel.selectedLocation.value, withName:  self.locName, withAddress: self.locAddress, withBuilding: self.buildingName, withCity: cityName)
                                            return
                                        }
                                    }
                                
                            }
                            SpinnerView.hideSpinnerView()
                            StoreOutConverageAreaBottomSheetViewController.showInBottomSheet(location: location, address: self.viewModel.locationAddress.value ?? "Unknown", presentIn: self){ [weak self] (isChangeLocation) in
                                if isChangeLocation {
                                    guard let self = self else {return}
                                    
                                    var cityName = "null"
                                    if let administrativeArea =  self.viewModel.selectedAddress.value?.administrativeArea {
                                        cityName = administrativeArea
                                    }
                                    if let localicty =  self.viewModel.selectedAddress.value?.locality {
                                        cityName = localicty
                                    }
                                    self.delegate?.locationMapViewControllerWithBuilding(self, didSelectLocation: self.viewModel.selectedLocation.value, withName:  self.locName, withAddress: self.locAddress, withBuilding: self.buildingName, withCity: cityName)
                                }else {
                                    self?.backButtonClick()
                                }
                            }
                        case .failure(let error):
                            SpinnerView.hideSpinnerView()
                            error.showErrorAlert()
                        }
                    }
                    
                }
            }
            return
        }
        self.updateAddress(location)
    }
    
    func logMixpanelConfirmClick (_ location : CLLocation )  {
        
        self.viewModel.updateAddressForLocation(location) { (result, returnLocation) in
            var addressString = ""
            if result {
                if (self.viewModel.selectedAddress.value?.formattedAddress) != nil {
                    if self.lblAddress.text?.count ?? 0 > 0 {
                        addressString = self.viewModel.selectedAddress.value?.formattedAddress ?? "Current Location"
                    }
                }
                MixpanelEventLogger.trackCreateLocationConfirmClick(addressText: addressString)
            }
        }
    }
    
    func updateAddress(_ location : CLLocation )  {
        
        self.viewModel.updateAddressForLocation(location) { (result, returnLocation) in
            if result {
                // if let add =  self.viewModel.selectedAddress.value?.formattedAddress {
                
               // self.lblAddress.text  =  self.viewModel.selectedAddress.value?.formattedAddress ?? "Current Location"
                self.btnChangeAddress.isHidden = self.lblAddress.text?.count == 0
                self.checkCOnveredArea(returnLocation)
            }
        }
        
    }
    
    func checkConveredAreaForBasket(_ location : CLLocation, completion: ((_ isCoverd: Bool) -> Void)?  = nil){
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.checkCoveredAreaForGroceries(location) { (result) -> Void in
            
            switch result {
            case .success(let response):
                let dataDict = response["data"] as? NSDictionary
                let isCovered = dataDict!["is_covered"] as? Bool
                self.lastCoverageDict = dataDict
                if(isCovered == true){
                    if (self.viewModel.locationName.value != nil && self.viewModel.locationName.value?.isEmpty == false){
                        self.locName = self.viewModel.locationName.value!
                    }else if (self.viewModel.predictionlocationName.value != nil && self.viewModel.predictionlocationName.value?.isEmpty == false){
                        self.locName = self.viewModel.predictionlocationName.value!
                    }else{
                        self.locName = self.viewModel.userAddress.value!
                        if self.locName.count == 0 {
                            self.locName = self.viewModel.selectedAddress.value?.formattedAddress ?? "Current Location"
                        }
                        self.viewModel.locationName.value = self.locName
                    }
                    if (self.viewModel.locationAddress.value != nil && self.viewModel.locationAddress.value?.isEmpty == false){
                        self.locAddress = self.viewModel.locationAddress.value!
                    }else if (self.viewModel.predictionlocationAddress.value != nil && self.viewModel.predictionlocationAddress.value?.isEmpty == false){
                        self.locAddress = self.viewModel.predictionlocationAddress.value!
                    }else{
                        self.locAddress = self.viewModel.userAddress.value!
                        if self.locAddress.count == 0 {
                            self.locAddress = self.viewModel.selectedAddress.value?.formattedAddress ?? "Current Location"
                        }
                        self.viewModel.locationAddress.value = self.locAddress
                    }
                    if self.viewModel.buildingName.value?.isEmpty == false {
                        if let value = self.viewModel.buildingName.value {
                            self.buildingName = value
                        }
                    }
                    var cityName = "null"
                    if let administrativeArea =  self.viewModel.selectedAddress.value?.administrativeArea {
                        cityName = administrativeArea
                    }
                    if let localicty =  self.viewModel.selectedAddress.value?.locality {
                        cityName = localicty
                    }
                    completion?(true)
                } else {
                    SpinnerView.hideSpinnerView()
                    self.isNeedToShowNoCoverage = true
                    DispatchQueue.main.async {
                        
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                            self.view.setNeedsLayout()
                            self.view.layoutIfNeeded()
                            self.buttonsView.setNeedsLayout()
                            
                        }, completion: nil)
                        
                        self.setUpBottomView()
                        self.confirmButton.setTitle(localizedString("request_to_deliver_here", comment: ""), for: .normal)
                        self.confirmButton.setBackgroundColor(.white, forState: .normal)
                        self.confirmButton.setH4SemiBoldAppBaseColorStyle()
                        self.confirmButton.layer.cornerRadius = 28
                        self.confirmButton.layer.masksToBounds = true
                        self.confirmButton.layer.borderWidth = 2
                        self.confirmButton.layer.borderColor = ApplicationTheme.currentTheme.themeBasePrimaryColor.cgColor
                        
                        
                        if self.lblAddress.text?.count ?? 0 > 0 {
                            self.lblErrorTwo.text = localizedString("lbl_error_No_Grocery", comment: "")
                            self.maunalSearchView.layer.borderColor = UIColor.redInfoColor().cgColor
                        }else{
                            self.lblError.text = localizedString("lbl_error_No_Grocery", comment: "")
                            self.lblCurrentSearchView.layer.borderColor = UIColor.redInfoColor().cgColor
                            
                        }
                    }
                    completion?(false)
                }
                
            case .failure(let error):
                SpinnerView.hideSpinnerView()
                completion?(false)
                error.showErrorAlert()
            }
        }
        
        
    }
    
    func checkCOnveredArea(_ location : CLLocation){
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.checkCoveredAreaForGroceries(location) { (result) -> Void in
            
            SpinnerView.hideSpinnerView()
            
            switch result {
                
            case .success(let response):
                
                print("Success")
                
                let dataDict = response["data"] as? NSDictionary
                let isCovered = dataDict!["is_covered"] as? Bool
                
                
                
                self.lastCoverageDict = dataDict
                // IntercomeHelper.updateIsLiveToIntercom(isCovered!)
                // PushWooshTracking.updateIsLive(isCovered ?? false)
                
                if(isCovered == true){
                    
                    if (self.viewModel.locationName.value != nil && self.viewModel.locationName.value?.isEmpty == false){
                        self.locName = self.viewModel.locationName.value!
                    }else if (self.viewModel.predictionlocationName.value != nil && self.viewModel.predictionlocationName.value?.isEmpty == false){
                        self.locName = self.viewModel.predictionlocationName.value!
                    }else{
                        self.locName = self.viewModel.userAddress.value!
                        if self.locName.count == 0 {
                            self.locName = self.viewModel.selectedAddress.value?.formattedAddress ?? "Current Location"
                        }
                        self.viewModel.locationName.value = self.locName
                    }
                    
                    if (self.viewModel.locationAddress.value != nil && self.viewModel.locationAddress.value?.isEmpty == false){
                        self.locAddress = self.viewModel.locationAddress.value!
                    }else if (self.viewModel.predictionlocationAddress.value != nil && self.viewModel.predictionlocationAddress.value?.isEmpty == false){
                        self.locAddress = self.viewModel.predictionlocationAddress.value!
                    }else{
                        self.locAddress = self.viewModel.userAddress.value!
                        if self.locAddress.count == 0 {
                            self.locAddress = self.viewModel.selectedAddress.value?.formattedAddress ?? "Current Location"
                        }
                        self.viewModel.locationAddress.value = self.locAddress
                    }
                    
                    if self.viewModel.buildingName.value?.isEmpty == false {
                        if let value = self.viewModel.buildingName.value {
                            self.buildingName = value
                        }
                    }
                    
                    
                    var cityName = "null"
                    
                    
                    if let administrativeArea =  self.viewModel.selectedAddress.value?.administrativeArea {
                        cityName = administrativeArea
                    }
                    
                    if let localicty =  self.viewModel.selectedAddress.value?.locality {
                        cityName = localicty
                    }
                    
                    
                    
                    print("Location Name:%@",self.locName)
                    print("Location Address:%@",self.locAddress)
                    print("building Address:%@",self.buildingName)
                    print("cityName Address:%@", cityName)
                    
                    //Hunain 7Jan17
                    if UserDefaults.isUserLoggedIn(){
                        
                        if self.delegate != nil {
                            self.delegate?.locationMapViewControllerWithBuilding(self, didSelectLocation: self.viewModel.selectedLocation.value, withName: self.locName, withAddress: self.locAddress, withBuilding: self.buildingName, withCity: cityName)
                        }
                        
                        // self.delegate?.locationMapViewControllerWithBuilding(self, didSelectLocation: self.viewModel.selectedLocation.value, withName: self.locName, withBuilding: "" ) //self.locAddress
                        
                    }else{
                        
                        guard let location = self.viewModel.selectedLocation.value else {return}
                        
                        if UserDefaults.didUserSetAddress() {
                            
                            if self.delegate != nil {
                                self.delegate?.locationMapViewControllerWithBuilding(self, didSelectLocation: self.viewModel.selectedLocation.value, withName: self.locName, withAddress: self.locAddress, withBuilding: self.buildingName, withCity: cityName)
                            }
                            
                            // self.delegate?.locationMapViewControllerWithBuilding(self, didSelectLocation: self.viewModel.selectedLocation.value, withName: self.locName, withBuilding:"") // self.locAddress
                        }else{
                            
                            self.addDeliveryAddressForAnonymousUser(withLocation: location, locationName: self.locName, locationAddress: self.locAddress,buildingName: self.buildingName, cityName: cityName) { (deliveryAddress) in
                                sdkManager?.showAppWithMenu()
                            }
                        }
                    }
                    
                    self.mapView = nil
                    
                }else{
                    
                    self.isNeedToShowNoCoverage = true
                    //self.viewHeight.constant = 310
                    
                    DispatchQueue.main.async {
                        
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                            self.view.setNeedsLayout()
                            self.view.layoutIfNeeded()
                            self.buttonsView.setNeedsLayout()
                            
                        }, completion: nil)
                        
                        self.setUpBottomView()
                        self.confirmButton.setTitle(localizedString("request_to_deliver_here", comment: ""), for: .normal)
                        self.confirmButton.setBackgroundColor(.white, forState: .normal)
                        self.confirmButton.setH4SemiBoldAppBaseColorStyle()
                        self.confirmButton.layer.cornerRadius = 28
                        self.confirmButton.layer.masksToBounds = true
                        self.confirmButton.layer.borderWidth = 2
                        self.confirmButton.layer.borderColor = ApplicationTheme.currentTheme.themeBasePrimaryColor.cgColor
                        
                        
                        if self.lblAddress.text?.count ?? 0 > 0 {
                            self.lblErrorTwo.text = localizedString("lbl_error_No_Grocery", comment: "")
                            self.maunalSearchView.layer.borderColor = UIColor.redInfoColor().cgColor
                        }else{
                            self.lblError.text = localizedString("lbl_error_No_Grocery", comment: "")
                            self.lblCurrentSearchView.layer.borderColor = UIColor.redInfoColor().cgColor
                            
                        }
                    }
                }
                
            case .failure(let error):
                error.showErrorAlert()
            }
        }
        
        
    }
    
    @IBAction func cancelButtonHandler(_ sender: Any) {
        FireBaseEventsLogger.trackSelectLocationEvents("Cancel")
        delegate?.locationMapViewControllerDidTouchBackButton(self)
    }
    
    override func backButtonClick() {
        MixpanelEventLogger.trackCreateLocationClose()
        delegate?.locationMapViewControllerDidTouchBackButton(self)
    }
    
    //MARK : Add Data for Anonymous User
    fileprivate func addDeliveryAddressForAnonymousUser(withLocation location: CLLocation, locationName: String,locationAddress: String ,buildingName: String , cityName : String? ,completionHandler: (_ deliveryAddress: DeliveryAddress) -> Void) {
        
        // Insert new area
        //let deliveryAddress = DeliveryAddress.createObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let deliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        deliveryAddress.locationName = locationName
        deliveryAddress.latitude = location.coordinate.latitude
        deliveryAddress.longitude = location.coordinate.longitude
        deliveryAddress.address = locationAddress
        deliveryAddress.apartment = ""
        deliveryAddress.building = buildingName
        deliveryAddress.street = ""
        deliveryAddress.city = cityName ?? "null"
        deliveryAddress.isActive = NSNumber(value: true as Bool)
        DatabaseHelper.sharedInstance.saveDatabase()
        UserDefaults.setDidUserSetAddress(true)
        CleverTapEventsLogger.setUserLocationCoardinatedName(location.coordinate)
        completionHandler(deliveryAddress)
    }
    
    
    //MARK : Tap Current Location Icon
    
    @objc func tapCurrentLocationIcon(){
        
        guard locationCurrentCoordinates.latitude != 0, locationCurrentCoordinates.longitude != 0 && CLLocationCoordinate2DIsValid(locationCurrentCoordinates) else {return}
        
        let loc = CLLocation(latitude: locationCurrentCoordinates.latitude, longitude: locationCurrentCoordinates.longitude)
        viewModel.selectedLocation.value = loc
        
       
        self.locationMarker.isHidden = false
        let camera = GMSCameraPosition.camera(withTarget: locationCurrentCoordinates, zoom: cameraZoom)
        self.mapView?.camera = camera
        self.mapView?.delegate = self
        self.mapView?.settings.rotateGestures = false
        self.mapView?.settings.tiltGestures = false
        self.mapConfigured = true
        self.setBindings()
    }
    
    // MARK: Methods
    
    fileprivate func setBindings() {
        
        
        viewModel.isNeedToFindAddress.asObservable().observeOn(MainScheduler.instance)
            .bind { [unowned self] (isNeedToFindAddress) in
                if isNeedToFindAddress == false {
                    self.detectingLocationView.isHidden = true
                    self.lblAddress.text = ""
                    self.btnChangeAddress.setTitle("", for: UIControl.State())
                    self.lbl_chooselocation.text = ""
                } else {
                    self.btnChangeAddress.setTitle(localizedString("grocery_review_already_added_alert_confirm_button", comment: ""), for: UIControl.State())
                    self.lbl_chooselocation.text = localizedString("lbl_yourlocation", comment: "")
                }
            }.disposed(by: disposeBag)
        
        viewModel.isLocationFetching.asObservable().observeOn(MainScheduler.instance)
            .bind { [unowned self] (isLocationFetching) in
                self.detectingLocationView.isHidden = !(isLocationFetching ?? false)
                self.lblAddress.isHidden = (isLocationFetching ?? false)
            }.disposed(by: disposeBag)
        
        viewModel.selectedLocation.asObservable().observeOn(MainScheduler.instance)
            .bind { [unowned self] (location) in
                
                guard let location = location else {
                    self.confirmButton.enableWithAnimation(false)
                    return
                }
                
                self.confirmButton.enableWithAnimation(true)
                let cameraUpdate = GMSCameraUpdate.setTarget(location.coordinate)
                self.mapView?.moveCamera(cameraUpdate)
                
                if self.isPinUpdate {
                    self.lblAddress.text = ""
                    self.btnChangeAddress.isHidden = self.lblAddress.text?.count == 0
                    // self.addressTextField.text = ""
                    // self.addressTitleLabel.text = localizedString("lbl_use_current_location", comment: "")
                    //self.manualLbl.text  = localizedString("lbl_Manuall_Location", comment: "")
                }
                
                self.isNeedToUpdateManual = false
                self.isPinUpdate = false
                
                self.setupButtonsAppearance()
                self.isNeedToShowNoCoverage = false
                //self.viewHeight.constant = 280
                DispatchQueue.main.async {
                    self.lblError.text = ""
                    self.lblErrorTwo.text = ""
                    self.lblCurrentSearchView.layer.borderColor = AppSetting.theme.newBorderGreyColor.cgColor
                    self.maunalSearchView.layer.borderColor = AppSetting.theme.newBorderGreyColor.cgColor
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        self.view.layoutIfNeeded()
                        self.buttonsView.setNeedsLayout()
                    }, completion: nil)
                }
                
            }.disposed(by: disposeBag)
        
        
        viewModel.selectedAddress.asObservable().observeOn(MainScheduler.instance)
            .bind { [unowned self](address) in
                guard let address = address else {
                    self.detectingLocationView.isHidden = !(viewModel.isLocationFetching.value ?? false)
                    self.lblAddress.isHidden = (viewModel.isLocationFetching.value ?? false)
                    return
                }
                self.lblAddress.text  =  address.formattedAddress ?? "Unable to find location"
                self.btnChangeAddress.isHidden = self.lblAddress.text?.count == 0
            }.disposed(by: self.disposeBag)
        
        viewModel.userAddress.asObservable().observeOn(MainScheduler.instance)
            .bind { [unowned self](address) in
                guard let address = address else {
                    self.detectingLocationView.isHidden = !(viewModel.isLocationFetching.value ?? false)
                    self.lblAddress.isHidden = (viewModel.isLocationFetching.value ?? false)
                    return
                }
                var finalAddress = address
                let fetchedFormattedAddress = finalAddress
                self.viewModel.locationAddress.value = fetchedFormattedAddress
                let locationName = fetchedFormattedAddress.components(separatedBy: "-").dropLast().joined(separator: "-")
                self.viewModel.locationName.value = locationName
                self.lblAddress.text  =  fetchedFormattedAddress
                self.btnChangeAddress.isHidden = self.lblAddress.text?.count == 0
                
            }.disposed(by: disposeBag)
        
        
        // viewModel.locationName.asObservable().observeOn(MainScheduler.instance)
        // .bind { [unowned self](address) in
        //
        // guard address?.count ?? 0 > 0 else {return}
        // guard let location = self.viewModel.selectedLocation.value else {return}
        // self.checkCOnveredArea(location)
        //
        //
        // }.disposed(by: disposeBag)
    }
    
    fileprivate func showLocationDisableAlert(){
        
        ElGrocerAlertView.createAlert(localizedString("location_disable_alert_title", comment: ""),
                                      description:localizedString("location_disable_alert_message", comment: ""),
                                      positiveButton: localizedString("location_disable_alert_button", comment: ""),
                                      negativeButton: nil, buttonClickCallback: nil).show()
        
    }
    
    fileprivate func configureMapView() {
        
        guard mapConfigured == false else {return}
        
        if isConfirmAddress  {
            if let place = self.place {
                locationCurrentCoordinates = place.coordinate
            }
        } else if (CLLocationCoordinate2DIsValid(self.locationCurrentCoordinates) && (self.locationCurrentCoordinates.latitude != 0.0 && self.locationCurrentCoordinates.longitude != 0.0)) { } else if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .notDetermined, .restricted, .denied:
                print("No Access to Location services")
                //self.showLocationDisableAlert()
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Have Location services Access")
                LocationManager.sharedInstance.requestLocationAuthorization()
                LocationManager.sharedInstance.fetchCurrentLocation()
            }
            
            ElGrocerUtility.sharedInstance.delay(0.1) {
                if let location = self.viewModel.selectedLocation.value ?? LocationManager.sharedInstance.currentLocation.value {
                    if CLLocationCoordinate2DIsValid(location.coordinate) && (location.coordinate.latitude != 0 && location.coordinate.longitude != 0)  {
                        self.locationCurrentCoordinates  = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                        self.setCameraPosition(self.locationCurrentCoordinates)
                        return
                    }else {
                        self.locationCurrentCoordinates  = CLLocationCoordinate2D(latitude: 25.204955 , longitude: 55.270821) // dubai
                        self.setCameraPosition(self.locationCurrentCoordinates)
                    }
                    
                }else{
                    self.locationCurrentCoordinates  = CLLocationCoordinate2D(latitude: 25.204955 , longitude: 55.270821) // dubai
                    self.setCameraPosition(self.locationCurrentCoordinates)
                }
                
               
            }
            
            
        } else {
            if let location = self.viewModel.selectedLocation.value {
                locationCurrentCoordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            } else {
                self.locationCurrentCoordinates  = CLLocationCoordinate2D(latitude: 25.2048 , longitude: 55.2708) // dubai
                self.setCameraPosition(self.locationCurrentCoordinates)
            }
        }
        
        self.locationMarker.isHidden = false
        self.mapView?.delegate = self
//     self.mapView?.settings.rotateGestures = false
      //  self.mapView?.settings.tiltGestures = false
        self.mapConfigured = true
        if locationCurrentCoordinates.longitude != 0.0 &&  locationCurrentCoordinates.latitude != 0.0 {
            let camera = GMSCameraPosition.camera(withTarget: locationCurrentCoordinates, zoom: cameraZoom)
            self.mapView?.camera = camera
        }
       
    }
    
    fileprivate func setCameraPosition(_ coardinates : CLLocationCoordinate2D) {
        
        let camera = GMSCameraPosition.camera(withTarget: coardinates, zoom: cameraZoom)
        self.mapView?.camera = camera
    }
    
    fileprivate func configureAddressTextField() {
        
        self.addressTextField.rightViewMode = UITextField.ViewMode.always
        self.addressTitleLabel.text = localizedString("lbl_use_current_location", comment: "")
        self.addressTextField.text = ""

    }
    
    func locateButtonTouched() {
        
        guard let currentLocation = LocationManager.sharedInstance.currentLocation.value else {
            return
        }
        
        let cameraUpdate = GMSCameraUpdate.setTarget(currentLocation.coordinate)
        self.mapView?.moveCamera(cameraUpdate)
        
    }
    
    // MARK: Appearance
    
    func setUpBottomView() {
        //self.buttonsView.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
        self.buttonsView.layer.cornerRadius = 12.0
        
        if #available(iOS 11.0, *) {
            self.buttonsView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
            self.buttonsView.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
        }
        
        
        // shadow
        // self.buttonsView.layer.shadowColor = UIColor.black.cgColor
        // self.buttonsView.layer.shadowOffset = CGSize(width: 3, height: 3)
        // self.buttonsView.layer.shadowOpacity = 0.7
        // self.buttonsView.layer.shadowRadius = 4.0
    }
    
    
    func setLocationIconAppearence(){
        
        viewLocationIcon.layer.cornerRadius = 5
        viewLocationIcon.layer.shadowColor = UIColor.black.cgColor
        viewLocationIcon.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        viewLocationIcon.layer.shadowOpacity = 0.4
        viewLocationIcon.layer.shadowRadius = 3.0
    }
    
    func setupInitialControllerAppearance() {
        
        self.borderView.isHidden = true
        self.addressTitleLabel.isHidden = false
        self.addressTextField.isHidden = false
        
        if isConfirmAddress {
            self.setUpAddrressTitleLabelAppearence()
        }else{
            self.setupTextFieldsAppearance()
        }
        
        self.setupLabelsAppearance()
        self.setupButtonsAppearance()
    }
    
    func setupLabelsAppearance() {
        
        if isConfirmAddress {
            footerTitleLabel.text = localizedString("drag_pin_title", comment: "")
            self.addressLabel.text = self.place?.formattedAddress
        }else{
            footerTitleLabel.text = localizedString("location_map_label_title", comment: "")
        }
        
        footerTitleLabel.font = UIFont.bookFont(13.0)
        footerTitleLabel.textColor = UIColor.lightGray
        
        self.addressLabel.setBody3RegDarkStyle()
        self.addressLabel.sizeToFit()
        self.addressLabel.numberOfLines = 2
        self.addressLabel.isUserInteractionEnabled = true
        
        // let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        // if currentLang == "ar" {
        //// self.addressLabelLeading.constant = 5
        //// self.addressLabelTraling.constant = -45
        // }
        self.addressLableHeight.constant = .leastNormalMagnitude
        /*let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.confirmButtonHandler(_:)))
         tapGesture.numberOfTapsRequired = 1
         self.addressLabel.addGestureRecognizer(tapGesture)*/
    }
    
    func setUpAddrressTitleLabelAppearence(){
        
        self.addressTitleLabel.setBody3RegDarkStyle()
        //self.addressTitleLabel.textColor = UIColor.black
        self.addressTitleLabel.text = self.place?.formattedAddress
        self.addressTitleLabel.isHidden = false
        
        self.borderView.isHidden = false
        self.borderView.backgroundColor = UIColor.borderGrayColor()
    }
    
    func setupTextFieldsAppearance() {
        
        
        self.addressTextField.setBody3RegStyle()
        // self.addressTextField.textColor = UIColor.colorWithHexString(hexString: "333333")
        self.addressTextField.isHidden = false
    }
    
    func setupButtonsAppearance() {
        self.confirmButton.setTitle(localizedString("confirm_location_button_title", comment: ""), for: UIControl.State())
        self.confirmButton.setH4SemiBoldWhiteStyle()
        self.confirmButton.setBackgroundColor(ApplicationTheme.currentTheme.themeBasePrimaryColor, forState: UIControl.State())
        self.confirmButton.layer.cornerRadius = 28
        self.confirmButton.layer.masksToBounds = true
        
        self.cancelButton.setTitle(localizedString("account_setup_cancel", comment: ""), for: UIControl.State())
        self.cancelButton.setH4SemiBoldWhiteStyle()
        self.cancelButton.setBackgroundColor(UIColor.white, forState: UIControl.State())
        self.cancelButton.layer.cornerRadius = 28
        self.cancelButton.layer.borderWidth = 1.0
        self.cancelButton.layer.borderColor = AppSetting.theme.themeBasePrimaryColor.cgColor
        self.cancelButton.layer.masksToBounds = true
    }
    
    // MARK: Check Location Services
    
    func checkLocationService() -> Bool {
        
        var isCurrentLocationEnabled = false
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .notDetermined, .restricted, .denied:
                print("No Access to Location services")
                isCurrentLocationEnabled = false
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Have Location services Access")
                isCurrentLocationEnabled = true
            @unknown default:
                print("Have Location services Access")
            }
        }
        return isCurrentLocationEnabled
    }
    
    @objc func showLocationCustomPopUp() {
        
        if CLLocationManager.locationServicesEnabled(){
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined:
                LocationManager.sharedInstance.requestLocationAuthorization()
                NotificationCenter.default.addObserver(self, selector: #selector(self.locationUpdate(_:)), name:NSNotification.Name(rawValue: KLocationChange), object: nil)
            case .restricted , .denied:
                LocationManager.sharedInstance.requestLocationAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Have Location services Access")
                LocationManager.sharedInstance.requestLocationAuthorization()
                LocationManager.sharedInstance.fetchCurrentLocation()
                if LocationManager.sharedInstance.currentLocation.value != nil {
                    self.setCurrentAddress(LocationManager.sharedInstance.currentLocation.value!.coordinate)
                }else{
                    NotificationCenter.default.addObserver(self, selector: #selector(self.locationUpdate(_:)), name:NSNotification.Name(rawValue: KLocationChange), object: nil)
                }
            }
        }else{
            LocationManager.sharedInstance.requestLocationAuthorization()
            NotificationCenter.default.addObserver(self, selector: #selector(self.locationUpdate(_:)), name:NSNotification.Name(rawValue: KLocationChange), object: nil)
        }
        
    }
    
    @objc func locationUpdate(_ notification: NSNotification?)  {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: KLocationChange), object: nil);
        self.setCurrentAddress(LocationManager.sharedInstance.currentLocation.value!.coordinate)
    }
    
}

// MARK: GMSMapViewDelegate

extension LocationMapViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.mapPinToolTipText.isHidden = false
        self.viewModel.isNeedToFindAddress.value = position.zoom >= 18
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.shouldUpdatePinUpdate = true
        UIView.transition(with: self.mapToolTipBgView, duration: 0.2,
                          options: .curveEaseIn,
                          animations: {
                        self.mapToolTipBgView.isHidden = true
                      })
        
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("map Zoom level : \(position.zoom)")
        self.viewModel.isNeedToFindAddress.value = position.zoom >= 18
        
        
        
        self.mapPinToolTipText.text = position.zoom >= 18 ? localizedString("eg_label_drag_map", comment: "Drag the pin on the most accurate location") : localizedString("eg_label_zoom_map", comment: "Please zoom in to find your exact delivery location")
        UIView.transition(with: self.mapToolTipBgView, duration: 0.2,
                          options: .curveEaseOut,
                          animations: {
                        self.mapToolTipBgView.isHidden = false
                      })
    
        let location = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
        if CLLocationCoordinate2DIsValid(location.coordinate) && (location.coordinate.latitude != 0 && location.coordinate.longitude != 0){
            if self.shouldUpdatePinUpdate {
                self.isPinUpdate = true
                self.shouldUpdatePinUpdate = false
                viewModel.selectedLocation.value = location
            }
        }
    }
}

// MARK: UITextFieldDelegate

extension LocationMapViewController: UITextFieldDelegate {
    
    
    
    func setCurrentAddress(_ coordinate : CLLocationCoordinate2D) {
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.viewModel.selectedLocation.value = location
        // self.viewModel.locationName.value = localizedString("lbl_use_current_location", comment: "")
        let camera = GMSCameraPosition.camera(withTarget: location.coordinate , zoom: cameraZoom)
        self.mapView?.camera = camera
        
    }
    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField == self.addressTextField) {
            // if  (self.viewModel.locationName.value == localizedString("lbl_use_current_location", comment: "")  || self.viewModel.locationName.value == "") {
            // showLocationCustomPopUp()
            // }
            MixpanelEventLogger.trackCreateLocationSearchClick()
            showLocationCustomPopUp()
            return false
        }
        
        let isServiceEnabled = self.checkLocationService()
        MixpanelEventLogger.trackCreateLocationCurrentLocationClick()
        
        
        let searchController = GMSAutocompleteViewController()
        UINavigationBar.appearance().tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        searchController.delegate = self
        searchController.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        searchController.tableCellBackgroundColor = .white
        searchController.primaryTextHighlightColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        searchController.primaryTextColor = .black
        searchController.secondaryTextColor = .black
        searchController.modalPresentationStyle = .fullScreen
        
        if let nav = searchController.navigationController {
            nav.navigationBar.barTintColor = UIColor.navigationBarColor()
        }
        
        if isServiceEnabled{
            
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
                
                let bounds = GMSCoordinateBounds(coordinate: initialLocation, coordinate: otherLocation)
                
                // Set up the autocomplete filter.
                let filter = GMSAutocompleteFilter()
                //filter.type = .Geocode
                
                if (LocationManager.sharedInstance.countryCode != nil){
                    filter.country = LocationManager.sharedInstance.countryCode
                }
                filter.locationBias  = GMSPlaceRectangularLocationOption(bounds.northEast, bounds.southWest)
                
                searchController.autocompleteFilter = filter
                
                //searchController.autocompleteBounds = bounds
            }
        }
        
        self.present(searchController, animated: true, completion: nil)
        return false
    }
    
}

// MARK: GMSAutocompleteViewControllerDelegate

extension LocationMapViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.isNeedToUpdateManual = true
        self.fetchDeliveryAddressFromEntry = nil
        let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        self.viewModel.selectedLocation.value = location
        self.viewModel.locationName.value = place.name
        self.viewModel.locationAddress.value = place.formattedAddress
        self.viewModel.buildingName.value = ElGrocerUtility.sharedInstance.getPremiseFrom(place)
        FireBaseEventsLogger.trackSelectLocationEvents("" , params: ["selectedLocation" : place.formattedAddress ?? "" ])
        viewController.presentingViewController?.dismiss(animated: true, completion: {
            self.shouldUpdatePinUpdate = false
            let camera = GMSCameraPosition.camera(withTarget: location.coordinate , zoom: self.cameraZoom)
            self.mapView?.camera = camera
            ElGrocerUtility.sharedInstance.delay(0.1) {
                // self.manualLbl.text = ""
                //self.lblAddress.text = place.formattedAddress
                self.btnChangeAddress.isHidden = self.lblAddress.text?.count == 0
            }
        })
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        _ = ElGrocerAlertView.createAlert(error.localizedDescription, description: nil, positiveButton: localizedString("common_ok_button_title", comment: ""), negativeButton: nil) { (buttonIndex) in
            viewController.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

