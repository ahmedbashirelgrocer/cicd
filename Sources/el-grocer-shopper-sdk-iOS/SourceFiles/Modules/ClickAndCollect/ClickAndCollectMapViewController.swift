//
//  ClickAndCollectMapViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 17/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
//import GooglePlacePicker
//import NBBottomSheet
import SDWebImage

enum storeTypeViewHeight : CGFloat {
    case showTextOnly = 60.0
    case show = 110.0
    case dontShow = 0.01
}

class ClickAndCollectMapViewController: UIViewController {
    
    @IBOutlet var currentOrderCollectionView: UICollectionView!
    @IBOutlet var currentOrderCollectionViewHeightConstraint: NSLayoutConstraint!
    var openOrders : [NSDictionary] = []
    lazy var orderStatus : OrderStatusMedule = {
        return OrderStatusMedule()
    }()
    var orderItem : DispatchWorkItem?
    var defaultZoomLevel : Float = 12.0
    var storeDataSource : StoresDataHandler!
    var currentLocation : CLLocation = ElGrocerUtility.sharedInstance.dubaiCenterLocation
    var markerA : [GMSMarker] = []
    var storeTypeA : [StoreType] = []
    var selectStoreType : StoreType? = nil {
        willSet {
            if  newValue != nil && self.storeTypeA.count > 0 {
                let index = self.storeTypeA.firstIndex { (type) -> Bool in
                    type.storeTypeid == newValue?.storeTypeid
                }
                if index != nil , let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() {
                    FireBaseEventsLogger.trackStoreCategoryFilter(catID: String(describing: newValue?.storeTypeid ?? 0 ) , catName: newValue?.name ?? "" , possition: String(describing: (index ?? 0) + 1) , newLocation: address)
                }
            }
        }
    }
    
    var grocerA : [Grocery] = [] {
        didSet {
            self.setMapPins(grocerA)
            if storeTypeHeight != nil {
                self.storeTypeHeight.constant =  grocerA.count > 0 ? storeTypeViewHeight.showTextOnly.rawValue : storeTypeViewHeight.dontShow.rawValue
            }
        }
    }
    
    @IBOutlet var storeTypeHeight: NSLayoutConstraint!
    
    var filterdGrocerA : [Grocery] = []
    var groceryController : ElgrocerClickAndCollectGroceryDetailViewController?
    var orderId : NSNumber? = nil
    
    
    // properties iboutlet
    @IBOutlet var tableView: UITableView!
    @IBOutlet var mapView: GMSMapView! {
        didSet{
            mapView.delegate = self
        }
    }
    
    @IBOutlet var txtLocation: UITextField!
    
    @IBOutlet var orderInfoView: AWView!{
        didSet{
            orderInfoView.layer.cornerRadius = 8
            orderInfoView.layer.maskedCorners = [.layerMinXMinYCorner , .layerMaxXMinYCorner]
        }
    }
    @IBOutlet var imgCarOrderInfo: UIImageView!
    @IBOutlet var lblDetailOrderInfo: UILabel!
    @IBOutlet var btnViewOrderInfo: UIButton!{
        didSet{
            btnViewOrderInfo.setTitle(localizedString("btn_view_title_caps", comment: ""), for: UIControl.State())
        }
    }
    @IBOutlet var viewOrderHeight: NSLayoutConstraint!
    
    var controllerTitle: String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setVeriableAllocationAndDelgation()
        self.registerTableViewObject()
        self.setNavigationBarAppearance()
        if ElGrocerUtility.sharedInstance.cAndcAvailabitlyRetailerList.count > 0 {
                let data = ElGrocerUtility.sharedInstance.cAndcAvailabitlyRetailerList
                let responseData = Grocery.insertOrReplaceGroceriesFromDictionary(data, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , false)
                ElGrocerUtility.sharedInstance.cAndcRetailerList = responseData
            ElGrocerUtility.sharedInstance.cAndcAvailabitlyRetailerList = [:]
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        elDebugPrint(#function)
        self.setViewOrderHeight(false)
        self.getData(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        elDebugPrint(#function)
//        if let item = self.orderItem{
//            item.cancel()
//        }
//        self.orderItem = DispatchWorkItem {
//            self.getOpenOrder()
//        }
      //  DispatchQueue.global(qos: .utility).async(execute: self.orderItem!)
        if ElGrocerUtility.sharedInstance.appConfigData == nil {
            ElGrocerUtility.sharedInstance.delay(8) {
                self.getOpenOrders()
            }
        }else{
            self.getOpenOrders()
        }
        
    }
    
    func getOpenOrders() {
        
        orderStatus.orderWorkItem  = DispatchWorkItem {
            self.orderStatus.getOpenOrders { (data) in
                switch data {
                    case .success(let response):
                        if let dataA = response["data"] as? [NSDictionary]{
                            self.openOrders = dataA
                            DispatchQueue.main.async {
                                self.currentOrderCollectionView.reloadData()
                            }
                        }
                    case .failure(let error):
                        elDebugPrint(error.localizedMessage)
                }
            }
        }
        DispatchQueue.global(qos: .utility).async(execute: orderStatus.orderWorkItem!)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        elDebugPrint(#function)
        self.orderId = nil
        ElGrocerUtility.sharedInstance.delay(1) {
            if let topVc = UIApplication.topViewController() {
                if topVc is GenericStoresViewController {
                    ElGrocerUtility.sharedInstance.isDeliveryMode = true
                    if let grocery = HomePageData.shared.groceryA {
                        ElGrocerUtility.sharedInstance.groceries = grocery
                    } else {
                        ElGrocerUtility.sharedInstance.groceries  = []
                    }
                   
                    let SDKManager: SDKManagerType! = sdkManager
                    if let tab = sdkManager.currentTabBar  {
                        ElGrocerUtility.sharedInstance.resetTabbar(tab)
                    }
                }
            }
        }
    }
    
    func setNavigationBarAppearance() {
        
        if self.navigationController is ElGrocerNavigationController {
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLocationHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setNavBarHidden(false)
            (self.navigationController as? ElGrocerNavigationController)?.setWhiteTitleColor()
            
            self.navigationItem.hidesBackButton = true
            self.title = self.controllerTitle ?? localizedString("lbl_CAndC", comment: "")
            self.addRightCrossButton(true)
        }
    }
    
    @objc override func rightBackButtonClicked() {
        self.dismiss(animated: true)
        MixpanelEventLogger.trackClickAndCollectClose()
    }
    
    func setViewOrderHeight (_ isNeedToShow : Bool = false) {
        self.orderInfoView.isHidden = !isNeedToShow
        self.viewOrderHeight.constant = isNeedToShow ? 62 : 0
        DispatchQueue.main.async {
            if isNeedToShow{
                UIView.animate(withDuration: 0.45) {
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                }
            }else{
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    func setVeriableAllocationAndDelgation() {
        self.storeDataSource = StoresDataHandler()
        self.storeDataSource.delegate = self
        self.txtLocation.placeholder = localizedString("lbl_collectionNear", comment: "")
        self.txtLocation.setBody3RegStyle()
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.txtLocation.textAlignment = .right
        }
        self.imgCarOrderInfo.image = UIImage(name: "orderInfoCar")
        self.lblDetailOrderInfo.setBody3RegSecondaryWhiteStyle()
        self.btnViewOrderInfo.setCaption1BoldWhiteStyle()
    }
    
    func registerTableViewObject() {
        
        self.tableView.backgroundColor = .white
        let ElgrocerCategorySelectTableViewCell = UINib(nibName: KElgrocerCategorySelectTableViewCell , bundle: Bundle.resource)
        self.tableView.register(ElgrocerCategorySelectTableViewCell, forCellReuseIdentifier: KElgrocerCategorySelectTableViewCell)
        
        
        let CurrentOrderCollectionCell = UINib(nibName: "CurrentOrderCollectionCell", bundle: Bundle.resource)
        self.currentOrderCollectionView.register(CurrentOrderCollectionCell, forCellWithReuseIdentifier: "CurrentOrderCollectionCell")
        
        let recipeCategoryDataCell = UINib(nibName: "CarBrandCollectionCell" , bundle: Bundle.resource)
        self.currentOrderCollectionView.register(recipeCategoryDataCell, forCellWithReuseIdentifier: "CarBrandCollectionCell")
        
        self.currentOrderCollectionView.delegate = self
        self.currentOrderCollectionView.dataSource = self
        self.currentOrderCollectionView.isPagingEnabled = true
        self.currentOrderCollectionView.showsHorizontalScrollIndicator = false
        self.currentOrderCollectionView.showsVerticalScrollIndicator = false
        self.currentOrderCollectionView.backgroundColor = .clear
        
    }
    
    func getData(_ isNeedToShowSpinner : Bool = true) {
        if isNeedToShowSpinner { let _  = SpinnerView.showSpinnerViewInView(self.view) }
        self.storeDataSource.getClickAndCollectionRetailerData(for: currentLocation.coordinate.latitude , and: currentLocation.coordinate.longitude)
        self.resetMapCamera()
    }
    
    func getOpenOrder() {
        guard UserDefaults.isUserLoggedIn() else {return}
        // let _ = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.getOpenOrderDetails { (result) in
            switch result {
                case .success(let response):
                    elDebugPrint(response)
                    if let orderA = response["data"] as? [NSDictionary] {
                        if orderA.count > 0 {
                            let orderDict = orderA[0]
                            if let orderID = orderDict["order_id"] as? NSNumber {
                                self.orderId = orderID
                                if let retailer_name = orderDict["retailer_name"] as? String {
                                    self.lblDetailOrderInfo.text = localizedString("lbl_Order_From_Info", comment: "") + " " + retailer_name
                                }
                                self.setViewOrderHeight(true)
                            }
                        }
                    }
                case .failure(let error):
                    elDebugPrint("Failure: \(error)")
            }
        }
    }
    
    
    fileprivate func showGroceryFromBottomSheet ( grocery : Grocery?) {
        
        if let topVc  = UIApplication.topViewController() {
            
            if topVc is ElgrocerClickAndCollectGroceryDetailViewController {
                let detailVc : ElgrocerClickAndCollectGroceryDetailViewController = topVc as! ElgrocerClickAndCollectGroceryDetailViewController
                let storeTypes = grocery?.getStoreTypes() ?? []
                let selectType = self.storeTypeA.filter({ (type) -> Bool in
                                                            return (storeTypes.contains(NSNumber(value: type.storeTypeid)) ?? false)   })
                detailVc.storeType = selectType.count > 0 ? selectType[0] : nil
                detailVc.grocery = grocery
                return
            }
            
        }
        
        if self.groceryController == nil {
            self.groceryController  = ElGrocerViewControllers.getElgrocerClickAndCollectGroceryDetailViewController()
        }else{
            self.groceryController?.grocery = nil
        }
        
        
        self.groceryController?.shopClicked = {  grocery in
            
            UserDefaults.setCurrentSelectedDeliverySlotId(0)
            UserDefaults.setPromoCodeValue(nil)
            
            if (grocery!.isOpen.boolValue && Int(grocery!.deliveryTypeId!) != 1) || (grocery!.isSchedule.boolValue && Int(grocery!.deliveryTypeId!) != 0){
                let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                if currentAddress != nil  {
                    UserDefaults.setGroceryId(grocery!.dbID , WithLocationId: (currentAddress!.dbID))
                }
            }
            ElGrocerUtility.sharedInstance.activeGrocery = grocery
            
            let dataA = ElGrocerUtility.sharedInstance.cAndcRetailerList.filter({ (grocery) -> Bool in
                return grocery.dbID == ElGrocerUtility.sharedInstance.activeGrocery?.dbID
            })
            
            if dataA.count == 0 {
                ElGrocerUtility.sharedInstance.cAndcRetailerList.append(ElGrocerUtility.sharedInstance.activeGrocery!)
            }
            ElGrocerUtility.sharedInstance.groceries = ElGrocerUtility.sharedInstance.cAndcRetailerList
            ElGrocerUtility.sharedInstance.isDeliveryMode = false
            DispatchQueue.main.async {
                
                self.dismiss(animated: false)
                
                // if let SDKManager: SDKManagerType! = sdkManager {
                    if let navtabbar = sdkManager.rootViewController as? UINavigationController  {
                        if !(sdkManager.rootViewController is ElgrocerGenericUIParentNavViewController) {
                            if let tabbar = navtabbar.viewControllers[0] as? UITabBarController {
                                if ((tabbar.viewControllers?[1] as? UINavigationController) != nil) {
                                    let nav = tabbar.viewControllers?[1] as! UINavigationController
                                    nav.setViewControllers([nav.viewControllers[0]], animated: false)
                                    if nav.viewControllers[0] is MainCategoriesViewController {
                                        let main : MainCategoriesViewController = nav.viewControllers[0] as! MainCategoriesViewController
                                        main.grocery = nil
                                    }
                                }
                                if ((tabbar.viewControllers?[2] as? UINavigationController) != nil) {
                                    let nav = tabbar.viewControllers?[1] as! UINavigationController
                                    nav.setViewControllers([nav.viewControllers[0]], animated: false)
                                }
                                if ((tabbar.viewControllers?[3] as? UINavigationController) != nil) {
                                    let nav = tabbar.viewControllers?[1] as! UINavigationController
                                    nav.setViewControllers([nav.viewControllers[0]], animated: false)
                                }
                                if ((tabbar.viewControllers?[4] as? UINavigationController) != nil) {
                                    let nav = tabbar.viewControllers?[1] as! UINavigationController
                                    nav.setViewControllers([nav.viewControllers[0]], animated: false)
                                }
                                tabbar.selectedIndex = 1
                            }
                        }
                    }else{
                        // elDebugPrint(self.grocerA[12312321])
                        FireBaseEventsLogger.trackCustomEvent(eventType: "Error", action: "generic grocery controller found failed.Force crash")
                    }
                //}

            }
       
            
        }
        
        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(180))
        configuration.backgroundViewColor = UIColor.bottomSheetShadowColor()
        let bottomSheetController = NBBottomSheetController(configuration: configuration)
        bottomSheetController.present(groceryController!, on: self)
        
        if grocery != nil {
            let storeTypes = grocery?.getStoreTypes() ?? []
            let selectType = self.storeTypeA.filter({ (type) -> Bool in
                                                        return (storeTypes.contains(NSNumber(value: type.storeTypeid)) ?? false)   })
            self.groceryController?.storeType = selectType.count > 0 ? selectType[0] : nil
            self.groceryController?.grocery = grocery
        }
        
        
    }
    
    
    
    @IBAction func changeLocationHandler(_ sender: Any) {
        
        
        let isServiceEnabled = LocationManager.sharedInstance.checkLocationService()
        
        let searchController = GMSAutocompleteViewController()
        UINavigationBar.appearance().tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        searchController.delegate = self
        searchController.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        searchController.tableCellBackgroundColor = .white
        searchController.primaryTextHighlightColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
        searchController.primaryTextColor = .black
        searchController.secondaryTextColor = .black
        searchController.modalPresentationStyle = .fullScreen
        
        if let nav = searchController.navigationController {
            nav.navigationBar.barTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        }
        MixpanelEventLogger.trackClickAndCollectSearch()
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
                filter.type = .noFilter
                //filter.type = .Geocode
                filter.locationBias  = GMSPlaceRectangularLocationOption(bounds.northEast, bounds.southWest)
                if (LocationManager.sharedInstance.countryCode != nil){
                    filter.country = LocationManager.sharedInstance.countryCode
                }
                
                searchController.autocompleteFilter = filter
                //searchController.autocompleteBounds = bounds
            }
        }
        
        self.present(searchController, animated: true, completion: nil)
        
    }

    @IBAction func viewOrderHandler(_ sender: Any) {
        self.getOrderDetail()
    }

    fileprivate func getOrderDetail() {
        guard self.orderId?.stringValue.count ?? 0 > 0 else {return}
        guard UserDefaults.isUserLoggedIn() else {return}
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.getorderDetails(orderId: self.orderId!.stringValue ) { (result) in
            SpinnerView.hideSpinnerView()
            switch result {
                case .success(let response):
                    elDebugPrint(response)
                    if let orderDict = (response["data"] as? NSDictionary)?["order"] as? NSDictionary {
                        let latestOrderObj = Order.insertOrReplaceOrderFromDictionary(orderDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        let controller = ElGrocerViewControllers.orderDetailsViewController()
                        controller.order = latestOrderObj
                        controller.isCommingFromOrderConfirmationScreen = false
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                case .failure(let error):
                    elDebugPrint("error : \(error.localizedMessage)")
            }
        }
    }
}

extension ClickAndCollectMapViewController : GMSAutocompleteViewControllerDelegate {
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        self.currentLocation = location
        self.txtLocation.text = place.formattedAddress
        FireBaseEventsLogger.trackSelectLocationEvents("" , params: ["selectedLocation" : place.formattedAddress ?? "" ])
        viewController.presentingViewController?.dismiss(animated: true, completion: {
            self.getData()
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

extension ClickAndCollectMapViewController : GMSMapViewDelegate {
    
    func resetMapCamera() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            let camera = GMSCameraPosition.camera(withTarget: self.currentLocation.coordinate , zoom: self.defaultZoomLevel)
            self.mapView.camera = camera
        }
    }
    
    func setMapPins (_ groceryA : [Grocery] , _ isNeedToReset : Bool = true) {
        
        
        
        let groceryFilterd = groceryA.filter { (grocery) -> Bool in
            if self.selectStoreType?.storeTypeid == 0 {
                return true
            }
            let storeTypes = grocery.getStoreTypes() ?? []
            return storeTypes.contains(NSNumber(value: self.selectStoreType?.storeTypeid ?? 0))
        }
        
        if self.filterdGrocerA != groceryFilterd {
            self.filterdGrocerA = groceryFilterd
        }
        
        if isNeedToReset {
            for data in markerA {
                data.map = nil
            }
            markerA = []
        }
        for groceryObj in self.filterdGrocerA {
            let groceryPossition = CLLocationCoordinate2D(latitude: groceryObj.latitude, longitude: groceryObj.longitude)
            let groceryMarker = GMSMarker(position: groceryPossition)
            //groceryMarker.isFlat = true
            groceryMarker.userData = groceryObj
            markerA.append(groceryMarker)
        }
        for marker in markerA {
            
            //let customPinView = ElgrocerStorePin.loadFromNib()
            let imageview = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 64, height: 64))
            imageview.backgroundColor = .white
            imageview.layer.cornerRadius = imageview.frame.size.height / 2
            imageview.clipsToBounds = true
            let url = (marker.userData as? Grocery)?.smallImageUrl
            imageview.sd_setImage(with: URL(string: url!), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0) , completed: {[weak self] (image, error, cacheType, imageURL) in
                guard image != nil else {return}
                if cacheType == .memory {
                    imageview.image = image
                }
                imageview.layer.cornerRadius = imageview.frame.size.height / 2
            })
            marker.iconView = imageview
            marker.map = self.mapView
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
       elDebugPrint(position.target)
        self.currentLocation = CLLocation.init(latitude: position.target.latitude, longitude: position.target.longitude)
        self.defaultZoomLevel = mapView.camera.zoom
        self.getData(false)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let selectedGrocery = marker.userData as? Grocery {
            self.showGroceryFromBottomSheet(grocery: selectedGrocery)
            MixpanelEventLogger.trackClickAndCollectStoreSelected(storeId: selectedGrocery.dbID, storeName: selectedGrocery.name ?? "")
           // self.getGroceryDeliverySlots(selectedGrocery)
             self.storeDataSource.getClickAndCollectionRetailerDetail(for: selectedGrocery.latitude, and: selectedGrocery.longitude, dbID: selectedGrocery.dbID, parentId: selectedGrocery.parentID.stringValue)
        }
        return true
    }
    
    
    func getGroceryDeliverySlots(_ grocery : Grocery?){
        
        ElGrocerApi.sharedInstance.getGroceryDeliverySlotsWithGroceryId(grocery?.dbID , andWithDeliveryZoneId: grocery?.deliveryZoneId, false, completionHandler: { (result) -> Void in
            
            switch result {
                
                case .success(let response):
                   elDebugPrint("SERVER Response:%@",response)
                    self.saveResponseData(response, grocery: grocery)
                    
                case .failure(let error):
                   elDebugPrint("Error while getting Delivery Slots from SERVER:%@",error.localizedMessage)
            }
        })
    }
    
    // MARK: Data
    func saveResponseData(_ responseObject:NSDictionary , grocery : Grocery?) {
        
        let spiner = SpinnerView.showSpinnerViewInView(self.view)
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        if  let groceryDict = responseObject["data"] as? NSDictionary {
            if let deliverySlotA = groceryDict["delivery_slots"] as? [NSDictionary] {
                if let groceryID = grocery?.dbID {
                    grocery?.clearDeliverySlotsTable(context: context)
                    for responseDict in deliverySlotA {
                        let deliverySlot = DeliverySlot.createDeliverySlotsFromDictionary(responseDict, groceryID: groceryID, context: context)
                              grocery?.addDeliverySlot(deliverySlot) // change here
                    }
                }
            }
            DatabaseHelper.sharedInstance.saveDatabase()
        }
        spiner?.removeFromSuperview()
        if grocery != nil {
            ElGrocerUtility.sharedInstance.delay(0.01) {
                self.showGroceryFromBottomSheet(grocery: grocery)
            }
        }
        
    }

}

extension ClickAndCollectMapViewController :  UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let final =  60//singleTypeRowHeight + 5
        return CGFloat(final)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ElgrocerCategorySelectTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "ElgrocerCategorySelectTableViewCell", for: indexPath) as! ElgrocerCategorySelectTableViewCell
        //cell.configuredData(storeTypeA: self.storeTypeA , selectedType: self.selectStoreType , grocerA: self.grocerA)
        cell.configuredDataToShowTextOnly(storeTypeA: self.storeTypeA , selectedType: self.selectStoreType , grocerA: self.grocerA)
        cell.selectedStoreType  = { [weak self] (selectedStoreType) in
            
            guard let self = self else {return}
            
            self.selectStoreType = selectedStoreType
            let groceryFilterd = self.grocerA.filter { (grocery) -> Bool in
                if self.selectStoreType?.storeTypeid == 0 {
                    return true
                }
                let storeTypes = grocery.getStoreTypes() ?? []
                return storeTypes.contains(NSNumber(value: self.selectStoreType?.storeTypeid ?? 0))
            }
            if self.filterdGrocerA != groceryFilterd {
                self.filterdGrocerA = groceryFilterd
            }
            self.setMapPins( self.filterdGrocerA , true)
            self.tableView.reloadData()
            MixpanelEventLogger.trackClickAndCollectCategoryFilter(filterId: "\(selectedStoreType?.storeTypeid ?? -1)", filterName: selectedStoreType?.name ?? "")
        }
        return cell
    }
    
}

extension ClickAndCollectMapViewController :  StoresDataHandlerDelegate {
    func storeCategoryData(storeTypeA : [StoreType]) -> Void  {
        elDebugPrint(storeTypeA)
        self.storeTypeA = storeTypeA
        if self.storeTypeA.count > 0 {
            if  self.selectStoreType == nil {
                self.selectStoreType = self.storeTypeA[0]
            }else{
                let isAvailable = self.storeTypeA.filter { (type) -> Bool in
                    return type.storeTypeid == self.selectStoreType!.storeTypeid
                }
                if isAvailable.count > 0 {
                    self.selectStoreType = isAvailable[0]
                }
            }
        }
        
        self.tableView.reloadData()
    }
    func allRetailerData(groceryA : [Grocery]) -> Void {
        self.grocerA = groceryA
      //  ElGrocerUtility.sharedInstance.groceries = self.grocerA
        // self.grocerA += groceryA
        //self.grocerA = self.grocerA.uniqued()
        SpinnerView.hideSpinnerView()
    }
    
    func getDetailGrocery(grocery: Grocery?) {
        if let selectGrocery = grocery {
            ElGrocerUtility.sharedInstance.delay(0.01) {
                self.showGroceryFromBottomSheet(grocery: selectGrocery)
            }
            
        }
    }
    
}

extension ClickAndCollectMapViewController : UICollectionViewDelegate , UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return openOrders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentOrderCollectionCell", for: indexPath) as! CurrentOrderCollectionCell
        cell.ordersPageControl.numberOfPages = collectionView.numberOfItems(inSection: 0)
        cell.loadOrderStatusLabel(status: indexPath.row  , orderDict: openOrders[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        ElGrocerUtility.sharedInstance.groceries = ElGrocerUtility.sharedInstance.cAndcRetailerList
        let order = openOrders[indexPath.row]
        let key = DynamicOrderStatus.getKeyFrom(status_id: order["status_id"] as? NSNumber ?? -1000, service_id: order["retailer_service_id"]  as? NSNumber ?? -1000 , delivery_type: order["delivery_type_id"]  as? NSNumber ?? -1000)
        if let orderNumber = order["id"] as? NSNumber {
            let statusId = order["status_id"] as? NSNumber ?? -1000
            ElGrocerEventsLogger.OrderStatusCardClick(orderId: orderNumber.stringValue, statusID: statusId.stringValue)
        }
        let status_id : DynamicOrderStatus? = ElGrocerUtility.sharedInstance.appConfigData.orderStatus[key]
        if status_id?.getStatusKeyLogic().status_id.intValue == OrderStatus.inEdit.rawValue {
            let navigator = OrderNavigationHandler.init(orderId: order["id"] as! NSNumber, topVc: self, processType: .editWithOutPopUp)
            navigator.startEditNavigationProcess { (isNavigationDone) in
                elDebugPrint("Navigation Completed")
            }
            return
        }
        
        
        //let order = openOrders[indexPath.row]
        let orderConfirmationController = ElGrocerViewControllers.orderConfirmationViewController()
        orderConfirmationController.isNeedToRemoveActiveBasket = false
        orderConfirmationController.orderDict = order
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [orderConfirmationController]
        orderConfirmationController.modalPresentationStyle = .fullScreen
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: { })
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let currentCell = cell as? CurrentOrderCollectionCell {
            currentCell.ordersPageControl.currentPage = indexPath.row
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let order = openOrders[indexPath.row]
        if let orderNumber = order["id"] as? NSNumber {
            let statusId = order["status_id"] as? NSNumber ?? -1000
            ElGrocerEventsLogger.trackOrderStatusCardView(orderId: orderNumber.stringValue, statusID: statusId.stringValue)
        }
    }
    
}
extension ClickAndCollectMapViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.size.width, height: collectionView.bounds.height)
        
    }
    
}
