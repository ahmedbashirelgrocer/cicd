//
//  DynamicLinksHelper.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 26/09/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import Foundation
import FirebaseCore
import STPopup
import UIKit
import FirebaseDynamicLinks

let KresetToZero = "resetViewToZero"
let KChangeCurrentState = "CurrentStateModeSwitch"
let KRefreshBasketNumberNotifcation = "NotifcationFromBasketBasketNumber"
let KResetGenericStoreLocalChacheNotifcation = "ResetLocalChacheGenericStorePage"
let KGoToBasketFromNotifcation = "NotifcationFromBasket"
let KRefreshView = "KrefreshViewLoadNewHome"
let KReloadGenericView = "reloadGenericViewAllNotifcationObserver"
let KReloadProfileGenericView = "reloadProfileGenericViewAllNotifcationObserver"
let kRemoveAllNotifcationObserver = "RemoveAllNotifcationObserver"

let kDeepLinkNotificationKey = "HandleDeepLinkNotification"
let kOpenBrandNotificationKey = "BrandDeepLinkNotification"
let kDeepLinkErrorKey = "DeepLinkErrorKey"
let kChangeGroceryNotificationKey = "ChangeGrocery"
let kUpdateGroceryNotificationKey = "UpdateGroceryFromEdit"
let kMoveToOrdersNotificationKey = "NavigateUserToOrders"
let kMoveToRecipeNotificationKey = "NavigateUserToRecipeDetail"
let kMoveToRecipeDetialNotificationKey = "NavigateUserToRecipeDetailWithID"


private let SharedInstance = DynamicLinksHelper()

class DynamicLinksHelper {
   
    var serviceId = ""
    var parentIds = ""
    var parentId = ""
    var groceryId = ""
    var categoryId = ""
    var subcategoryId = ""
    var brandId = ""
    var recipeDetial = ""
    var recipeID = ""
    var chefID = ""
    var productBarcode = ""
    var productId = ""
    var isNewGroceryLoading = false
    var StoreDataSource : StoresDataHandler! {
        let StoreDataSource = StoresDataHandler()
        StoreDataSource.delegate = self
        return StoreDataSource
    }
    
   
    class var sharedInstance : DynamicLinksHelper {
        return SharedInstance
    }
    
    
    
    
    
    class func handleIncomingDynamicLinksWithUrl(_ dynamicLinkURL:String){
        print("Dynamic Link URL:%@",dynamicLinkURL)
        
        
        var delayTime = 1.0
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let dataAvailable = appDelegate.appStartTime {
                if dataAvailable.timeIntervalSinceNow > -5 {
                    delayTime = 2.0
                }
            }
        }
        if ElGrocerUtility.sharedInstance.groceries.count == 0 {
            ElGrocerUtility.sharedInstance.delay(2) {
                handleIncomingDynamicLinksWithUrl(dynamicLinkURL)
            }
            return
        }
        
        ElGrocerUtility.sharedInstance.delay(delayTime) {
         DynamicLinksHelper.sharedInstance.parseDynamicLinkUrl(dynamicLinkURL)
        }
    }
    
    @discardableResult
    func setNewGroceryAccordingToLink(_ locationID : String) -> Bool {
        if (ElGrocerUtility.sharedInstance.deepLinkURL.isEmpty == false) {
            if let dynamicUrl = getUrlFromDynamicString(ElGrocerUtility.sharedInstance.deepLinkURL) {
                let tmpGroceryId = dynamicUrl.getQueryItemValueForKey("StoreID")
                let tmpParentID = dynamicUrl.getQueryItemValueForKey("parentID")
                let tmpParentIDs = dynamicUrl.getQueryItemValueForKey("parentIDs")
                
                
                if tmpGroceryId != nil || tmpParentID != nil || tmpParentIDs != nil {
                    var filteredArray : [Grocery] = []
                    if tmpParentID != nil {
                        filteredArray =  ElGrocerUtility.sharedInstance.groceries.filter(){$0.parentID.stringValue == tmpParentID }
                    }
                    if tmpGroceryId != nil {
                        filteredArray =  ElGrocerUtility.sharedInstance.groceries.filter(){$0.dbID == tmpGroceryId }
                    }
                    
                    if tmpParentIDs != nil {
                        let dataA = tmpParentIDs?.split(separator: ",")
                        for data in dataA ?? [] {
                            filteredArray =  ElGrocerUtility.sharedInstance.groceries.filter(){$0.parentID.stringValue == data }
                        }
                    }
                    if filteredArray.count > 0 {
                        UserDefaults.setGroceryId(filteredArray[0].dbID , WithLocationId: locationID)
                         let CategoryID = dynamicUrl.getQueryItemValueForKey("CategoryID")
                        let SubcategoryID = dynamicUrl.getQueryItemValueForKey("SubcategoryID")
                         let BrandID = dynamicUrl.getQueryItemValueForKey("BrandID")
                        if CategoryID == nil && SubcategoryID == nil && BrandID == nil {
                            ElGrocerUtility.sharedInstance.deepLinkURL = ""
                        }
                        return true
                    }
                }
            }
            let filteredArray = ElGrocerUtility.sharedInstance.groceries.filter(){$0.retailerType.intValue == 1}
            if filteredArray.count > 0 {
                UserDefaults.setGroceryId(filteredArray[0].dbID , WithLocationId: locationID)
                return true
            }
        }
        return false
    }
    
    func getUrlFromDynamicString(_ dynamicLinkURL : String) -> URL? {
        
        var dUrl = URL.init(string: dynamicLinkURL)
        
        if let encoded = dynamicLinkURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let finalUrl = URL(string: encoded) {
            dUrl = finalUrl
        }
        
        return dUrl
        
    }

    func gotoProductZoomController(){
        
        guard self.productBarcode != "" || self.productId != "" else {
            return
        }
        
        let popupViewController = PopImageViwerViewController(nibName: "PopImageViwerViewController", bundle: nil)
        popupViewController.view.frame = UIScreen.main.bounds
        
        let popupController = STPopupController(rootViewController: popupViewController)
        if NSClassFromString("UIBlurEffect") != nil {
            let blurEffect = UIBlurEffect(style: .dark)
            popupController.backgroundView = UIVisualEffectView(effect: blurEffect)
        }
        
        popupController.transitionStyle = .slideVertical
        if let topController = UIApplication.topViewController() {
            
            popupViewController.didDissmiss = { (didDissmiss,products,grocery,brandId) in
                if didDissmiss{
                    
                    self.callBrandDeepLinkVCForPopImage(brandId: brandId, products: products, grocery: grocery,topController: topController)
                }
            }
            
            popupController.backgroundView?.alpha = 1
            popupController.navigationBarHidden = true
            popupViewController.controllerType = .productDeepLink
            popupViewController.barcodeString = self.productBarcode
            popupViewController.productId = self.productId
            popupController.containerView.layer.cornerRadius = 5
            popupController.present(in: topController)
            
            
        }
    }
    
    
    func goToSubVC (_ substituteOrderID : String? ) {
        if let topvc = UIApplication.topViewController() {
            if topvc is GroceryLoaderViewController {
                ElGrocerUtility.sharedInstance.delay(2) {
                    self.goToSubVC(substituteOrderID)
                }
            }else{
                let ordersController = ElGrocerViewControllers.ordersViewController()
//                let navigationController = ElGrocerNavigationController.init(rootViewController: ordersController)
//                navigationController.modalPresentationStyle = .fullScreen
//
                let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                navigationController.hideSeparationLine()
                navigationController.viewControllers = [ordersController]
                navigationController.modalPresentationStyle = .fullScreen
            
                topvc.present(navigationController, animated: false, completion: {
                    let substitutionsProductsVC = ElGrocerViewControllers.substitutionsProductsViewController()
                    substitutionsProductsVC.orderId = substituteOrderID!
                    ElGrocerUtility.sharedInstance.isNavigationForSubstitution = true
                    if let topvc = UIApplication.topViewController() {
                        if topvc is SubstitutionsProductViewController {}else{
                            topvc.navigationController?.pushViewController(substitutionsProductsVC, animated: false)
                        }
                    }
                });
            }
        }
    }
    
    
    func parseDynamicLinkUrl(_ dynamicLinkURL:String){
        
        
        defer {
            ElGrocerUtility.sharedInstance.deepLinkURL = ""
        }
        
        debugPrint("dynamicLinkURL:\(dynamicLinkURL)")
        
        
        /*
        BaseURL == https://elgrocer.com.ElGrocerShopper.app.goo.gl/?
        1- For Brand
            StoreID=12&CategoryID=13&SubcategoryID=14&BrandID=15
        2- For SubCategory
            StoreID=12&CategoryID=13&SubcategoryID=14
        3- For Category ---
            StoreID=12&CategoryID=13
        4- For Grocery
            StoreID=12
        5- If StoreID is not present in url we can use our current loaded grocery Id for category, subcategory and brand
        FullURL: "https://elgrocer.com.ElGrocerShopper.app.goo.gl/?StoreID=12&CategoryID=13&SubcategoryID=14&BrandID=15"
        */
        
        var dUrl = URL.init(string: dynamicLinkURL)
        
        if let encoded = dynamicLinkURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let finalUrl = URL(string: encoded) {
            dUrl = finalUrl
        }
        
       
        
        self.groceryId = ""
        self.brandId = ""
        self.parentIds = ""
        self.serviceId = ""
        self.productBarcode = ""
        self.productId = ""
        
        let serviceID = dUrl?.getQueryItemValueForKey("serviceID")
        // print("tmpParent  is:%@", serviceID ?? "nil")
        if serviceID != nil {
            self.serviceId = serviceID!
        }
        let tmpParentId = dUrl?.getQueryItemValueForKey("parentID")
        // print("tmpParent  is:%@",tmpParentId ?? "nil")
        if tmpParentId != nil {
            self.parentId = tmpParentId!
        }
        let tmpParentIds = dUrl?.getQueryItemValueForKey("parentIDs")
        // print("tmpParent  is:%@",tmpParentId ?? "nil")
        if tmpParentIds != nil {
            self.parentIds = tmpParentIds!
        }
        
        let tmpGroceryId = dUrl?.getQueryItemValueForKey("StoreID")
        // print("Grocery Id is:%@",tmpGroceryId ?? "nil")
        if tmpGroceryId != nil {
            self.groceryId = tmpGroceryId!
        }
        
        let tempProductId = dUrl?.getQueryItemValueForKey("productId")
        // print("tmpParent  is:%@", tempProductBarCode ?? "nil")
        if tempProductId != nil {
            self.productId = tempProductId!
            self.gotoProductZoomController()
            return
        }
        let tempProductBarCode = dUrl?.getQueryItemValueForKey("barcode")
        // print("tmpParent  is:%@", tempProductBarCode ?? "nil")
        if tempProductBarCode != nil {
            self.productBarcode = tempProductBarCode!
            self.gotoProductZoomController()
            return
        }
        self.brandId = ""
        let tmpBrandId = dUrl?.getQueryItemValueForKey("BrandID")
        // print("Brand Id is:%@",tmpBrandId ?? "nil")
        if tmpBrandId != nil {
            self.brandId = tmpBrandId!
            self.navigateToScreen( isBrand: true , isSubCatogryOrCategory: false)
            return
        }
        self.categoryId = ""
        let tmpCategoryId = dUrl?.getQueryItemValueForKey("CategoryID")
        if tmpCategoryId != nil {
            self.categoryId = tmpCategoryId!
        }else if let tmpCategoryId = dUrl?.getQueryItemValueForKey("categoryID") {
            self.categoryId = tmpCategoryId
        }
        self.subcategoryId = ""
        let tmpSubcategoryId = dUrl?.getQueryItemValueForKey("SubcategoryID")
        if tmpSubcategoryId != nil {
            self.subcategoryId = tmpSubcategoryId!
        }else if let tmpSubcategoryId = dUrl?.getQueryItemValueForKey("subcategoryID") {
            self.subcategoryId = tmpSubcategoryId
        }else if let tmpSubcategoryId = dUrl?.getQueryItemValueForKey("subCategoryID") {
            self.subcategoryId = tmpSubcategoryId
        }
        if ( self.categoryId.isEmpty == false ) {
            self.navigateToScreen( isBrand: false , isSubCatogryOrCategory: true)
            return
        }
        let substituteOrderID = dUrl?.getQueryItemValueForKey("substituteOrderID")
        if substituteOrderID != nil {
            if UserDefaults.isUserLoggedIn() {
                self.goToSubVC(substituteOrderID)
            }
            return
        }
        let tmpPage = dUrl?.getQueryItemValueForKey("page")
        print("Page is:%@",tmpPage ?? "nil")
        if tmpPage != nil && tmpPage == "orders"{
            self.goToOrders()
            return
        }
        
        self.recipeDetial = ""
        let recipe = dUrl?.getQueryItemValueForKey("recipeDetail")
        if recipe != nil {
            self.recipeDetial = recipe!
            self.loadDeliveryStore { (isLoaded) in
                if isLoaded {
                    self.naviagteToRecipe(self.recipeDetial)
                }
            }
            
            return
        }
        self.recipeID = ""
        let recipeiD = dUrl?.getQueryItemValueForKey("recipeID")
        if let recipeid = recipeiD {
            if !recipeid.isEmpty {
                self.recipeID = recipeid
                self.loadDeliveryStore { (isLoaded) in
                    if isLoaded {
                        self.naviagteToRecipeDetial()
                    }
                }
                
                return
            }
        }
        self.chefID = ""
        let chefID = dUrl?.getQueryItemValueForKey("chefID")
        if let chefid = chefID {
            if !chefid.isEmpty {
                self.chefID = chefid
                self.loadDeliveryStore { (isLoaded) in
                    if isLoaded {
                        
                        self.naviagteToChef(chefName: dUrl?.getQueryItemValueForKey("chefName") ?? "", chefID: self.chefID)
                    }
                }
                return
            }
        }
        
        let recipeBoutique = dUrl?.absoluteString.contains("recipeBoutique") ?? false
        if recipeBoutique {
            self.loadDeliveryStore { (isLoaded) in
                if isLoaded {
                   // ElGrocerEventsLogger.sharedInstance.trackRecipeViewAllClickedFromNewGeneric(source: "DeepLink")
                    let recipeStory = ElGrocerViewControllers.recipesBoutiqueListVC()
                    recipeStory.isNeedToShowCrossIcon = true
                    recipeStory.isCommingFromDeepLink  = true
                    recipeStory.groceryA = ElGrocerUtility.sharedInstance.groceries
                    
                    let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                    navigationController.hideSeparationLine()
                    navigationController.viewControllers = [recipeStory]
                    navigationController.modalPresentationStyle = .fullScreen
                    if let topVc = UIApplication.topViewController() {
                        topVc.present(navigationController, animated: true, completion: { });
                    }
                }
            }
            
            return
        }
     
        let retailer_id = dUrl?.getQueryItemValueForKey("retailer_id")
        if retailer_id != nil {
            if let topvc = UIApplication.topViewController() {
               
                let dataA =  ElGrocerUtility.sharedInstance.groceries.filter { (grocery) -> Bool in
                    return Int(grocery.dbID) == Int(retailer_id ?? "-11")
                }
                if dataA.count > 0 {
                    ElGrocerUtility.sharedInstance.activeGrocery = dataA[0]
                    topvc.tabBarController?.selectedIndex = 1
                }else{
                    // SpinnerView.hideSpinnerView()
                }
            }
            return
        }
       
        if !self.groceryId.isEmpty ||  self.parentId.count > 0 || self.parentIds.count > 0 {
            self.navigateToScreen()
            return
        }
        
        /*
        if self.parentId.count > 0  {
            self.navigateToScreen()
            return
        }
        if self.parentIds.count > 0 {
            var filteredArray : [Grocery] = []
            let dataA = self.parentIds.split(separator: ",")
            for data in dataA {
                filteredArray =  ElGrocerUtility.sharedInstance.groceries.filter(){$0.parentID.stringValue == data }
            }
            if filteredArray.count > 0 {
                ElGrocerUtility.sharedInstance.activeGrocery = filteredArray[0]
                if let topvc = UIApplication.topViewController() {
                    topvc.tabBarController?.selectedIndex = 1
                }
            }
            return
        }*/
    }
    
    func loadGroceryAlreadySelected() {
                    if let topvc = UIApplication.topViewController() {
                        if topvc is MainCategoriesViewController {
                            topvc.viewDidAppear(true)
                        }else{
                            topvc.tabBarController?.selectedIndex = 1
                        }
                        
                    }
    }
    
    
    func loadDeliveryStore( completionHandler:@escaping (_ result:Bool) -> Void) {
        
        var currentGroceryID = ElGrocerUtility.sharedInstance.activeGrocery?.dbID ?? ""
        if !ElGrocerUtility.sharedInstance.isDeliveryMode {
            currentGroceryID = ""
        }
        if let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()  {
            self.StoreDataSource.apiHandler.getAllretailers(latitude: currentAddress.latitude, longitude: currentAddress.longitude, success: { (task, responseObj) in
                if  responseObj is NSDictionary {
                    let data: NSDictionary = responseObj as? NSDictionary ?? [:]
                    if let dataDict : NSDictionary = data["data"] as? NSDictionary {
                        if let _ = dataDict["retailers"] as? [NSDictionary] {
                            let responseData = Grocery.insertOrReplaceGroceriesFromDictionary(data, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , false)
                            let filteredArray =  ElGrocerUtility.sharedInstance.makeFilterOneSlotBasis(storeTypeA:  responseData )
                            guard filteredArray.count > 0 else {
                                completionHandler(false)
                                return
                            }
                            ElGrocerUtility.sharedInstance.groceries = filteredArray
                            let isActiveAvailable =  ElGrocerUtility.sharedInstance.groceries.filter { (grocery) -> Bool in
                                return grocery.dbID == currentGroceryID
                            }
                            
                            if isActiveAvailable.count > 0 {
                                ElGrocerUtility.sharedInstance.activeGrocery = isActiveAvailable[0]
                                ElGrocerUtility.sharedInstance.isDeliveryMode = true
                                completionHandler(true)
                                return
                            }else{
                                ElGrocerUtility.sharedInstance.activeGrocery =  ElGrocerUtility.sharedInstance.groceries[0]
                                ElGrocerUtility.sharedInstance.isDeliveryMode = true
                                completionHandler(true)
                                return
                            }
                           
                        }
                        
                    }
                }
                completionHandler(false)
            }) { (task, error) in
                debugPrint(error.localizedDescription)
                completionHandler(false)
            }
        }else{
            completionHandler(false)
        }
       
    }
    
    
    @objc func naviagteToChef(chefName : String = "" , chefID : String){
        
        
        
        func gotoChefScreen(_ chefSelected : CHEF) {
            if let topController = UIApplication.topViewController() {
                if topController is GroceryLoaderViewController {
                    ElGrocerUtility.sharedInstance.delay(1) {
                        [weak self] in
                        guard let self = self else {return}
                        self.naviagteToChef(chefName: chefName, chefID: chefID)
                    }
                }else{
                    
                    FireBaseEventsLogger.trackRecipeFilterClick(chef: chefSelected, source: "DeepLink")
                    ElGrocerUtility.sharedInstance.isDeliveryMode = true
                    let recipeFilter : FilteredRecipeViewController = ElGrocerViewControllers.recipeFilterViewController()
                    recipeFilter.groceryA = ElGrocerUtility.sharedInstance.groceries
                    recipeFilter.dataHandler.setFilterChef(chefSelected)
                    recipeFilter.vcTitile = chefSelected.chefName
                    let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                    navigationController.viewControllers = [recipeFilter]
                    navigationController.modalPresentationStyle = .fullScreen
                    topController.navigationController?.pushViewController(recipeFilter, animated: true)
                }
            }
        }
        
        
        let retailerString = ElGrocerUtility.sharedInstance.GenerateRetailerIdString(groceryA: ElGrocerUtility.sharedInstance.groceries)
        let startingIndex  = "0"
        ELGrocerRecipeMeduleAPI().getChefList(offset: startingIndex , Limit: "1000", chefID: chefID , retailerIDs: retailerString) { [weak self](result) in
            guard self != nil else {return}
            switch result {
                case .success(let response):
                    guard (response["status"] as? String) == "success" else {
                        return
                    }
                    if let arrayData = response["data"] {
                        let chefData : [NSDictionary] = arrayData as! [NSDictionary]
                        if (chefData.count) > 0 {
                            for data:NSDictionary in chefData {
                                let chef : CHEF   =   CHEF.init(chefDict: data as! Dictionary<String, Any>)
                                if chef.chefID == Int(chefID) ?? 0 {
                                    gotoChefScreen(chef)
                                }
                            }
                        }
                    }
                case .failure(let error):
                    error.showErrorAlert()
            }
            
        }
        
          
    }
    
    @objc func naviagteToRecipe(_ recipeDetail : String = ""){
        
        if let topController = UIApplication.topViewController() {
            if topController is GroceryLoaderViewController {
                ElGrocerUtility.sharedInstance.delay(1) {
                    [weak self] in
                    guard let self = self else {return}
                    self.naviagteToRecipe()
                }
            }else{
                ElGrocerUtility.sharedInstance.isDeliveryMode = true
                let recipeStory = ElGrocerViewControllers.recipesListViewController()
                recipeStory.isNeedToShowCrossIcon = true
                let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                navigationController.viewControllers = [recipeStory]
                navigationController.modalPresentationStyle = .fullScreen
                topController.navigationController?.present(navigationController, animated: true, completion: {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    if let tab = appDelegate.currentTabBar  {
                        ElGrocerUtility.sharedInstance.resetTabbar(tab)
                        tab.selectedIndex = 1
                    }
                });
            }
        }
    }
    @objc func naviagteToRecipeDetial(){
        
        
        ElGrocerUtility.sharedInstance.delay(0.5) {[weak self] in
            guard let self = self else {return}
            if  self.recipeID == "0"  || self.recipeID.isEmpty {
                self.naviagteToRecipe()
            }else{
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    if let topController = UIApplication.topViewController() {
                        if topController is GroceryLoaderViewController {
                            ElGrocerUtility.sharedInstance.delay(1) {
                                [weak self] in
                                guard let self = self else {return}
                                self.naviagteToRecipeDetial()
                            }
                        }else{
                            ElGrocerUtility.sharedInstance.isDeliveryMode = true
                            let recipeDetail : RecipeDetailVC = ElGrocerViewControllers.recipeDetailViewController()
                            recipeDetail.source = "DeepLink"
                            var recipeData : Recipe = Recipe()
                            recipeData.recipeID = Int64(self.recipeID)
                            recipeDetail.recipe = recipeData
                            GoogleAnalyticsHelper.trackRecipeClick()
                            
                            let navRecipeDetailController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                            navRecipeDetailController.viewControllers = [recipeDetail]
                            navRecipeDetailController.modalPresentationStyle = .fullScreen
                            if let topVC = UIApplication.topViewController() {
                                topVC.present(navRecipeDetailController, animated: true, completion: {
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    if let tab = appDelegate.currentTabBar  {
                                        ElGrocerUtility.sharedInstance.resetTabbar(tab)
                                        tab.selectedIndex = 1
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }
   
    func goToOrders () {
        
        if let topVc = UIApplication.topViewController() {
            if topVc is GroceryLoaderViewController {
                ElGrocerUtility.sharedInstance.delay(2) {
                    self.goToOrders()
                }
            }else{
                let ordersController = ElGrocerViewControllers.ordersViewController()
                let navigationController = ElGrocerNavigationController.init(rootViewController: ordersController)
                navigationController.modalPresentationStyle = .fullScreen
                if let topVc = UIApplication.topViewController() {
                    topVc.present(navigationController, animated: true, completion: { });
                }
            }
        }
    }
    
    func callBrandDeepLinkVC(brandId: String){
        let vc = ElGrocerViewControllers.getBrandDeepLinksVC()
        vc.brandID = brandId
//        vc.retailers = self.deliveryGroceryList
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [vc]
        navController.modalPresentationStyle = .fullScreen

        if let topVc = UIApplication.topViewController() {
            topVc.present(navController, animated: true, completion: { });
        }
    }
    
    func callBrandDeepLinkVCForPopImage(brandId: String,products: [Product], grocery: Grocery, topController: UIViewController){
        let vc = ElGrocerViewControllers.getBrandDeepLinksVC()
        vc.type = .generic
        vc.brandID = brandId
        vc.grocery = grocery
        vc.filteredProductsArray = products
        
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [vc]
        navController.modalPresentationStyle = .fullScreen

        topController.present(navController, animated: false, completion: { });
        
    }
    
    
    func navigateToScreen( isBrand : Bool = false , isSubCatogryOrCategory : Bool = false){
        
        debugPrint("self.parentId")
        debugPrint(self.parentId)
        debugPrint("self.parentIds")
        debugPrint(self.parentIds)
        debugPrint("self.parentIds")
        debugPrint(self.parentIds)
        debugPrint("self.groceryId")
        debugPrint(self.groceryId)
        debugPrint("self.categoryId")
        debugPrint(self.categoryId)
        debugPrint("self.subcategoryId")
        debugPrint(self.subcategoryId)
        
        if isBrand {
            
            let brand = GroceryBrand.init()
            brand.brandId = Int(self.brandId) ?? -1
            guard brand.brandId > 0 else {
                MeterialProgress.completeAndHideProgressView()
                return
            }
            self.callBrandDeepLinkVC(brandId: self.brandId)
            return
        }
        
        var isNeedToCheckAllMode = true
        if  self.serviceId.count > 0 {
            isNeedToCheckAllMode = false
        }
        
        func callToChangeStoreAfterAllDataSet() {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                if let currentTabBar = appDelegate.currentTabBar {
                    ElGrocerUtility.sharedInstance.resetTabbar(currentTabBar)
                    currentTabBar.selectedIndex = 1
                }
            }
            
        }
        
        // brand Navigation work
        func moveToBrandPage(_ grocery : Grocery , brand : GroceryBrand) {
            
            // SpinnerView.hideSpinnerView()
            
            if let topController = UIApplication.topViewController() {
                if topController is GroceryLoaderViewController {
                    ElGrocerUtility.sharedInstance.delay(2) {
                        moveToBrandPage(grocery, brand: brand)
                    }
                }else{
                    MeterialProgress.completeAndHideProgressView()
                    guard brand.brandId > 0 else{  return }
                    let brandDetailsVC = ElGrocerViewControllers.brandDetailsViewController()
                    brandDetailsVC.hidesBottomBarWhenPushed = false
                    brandDetailsVC.brand = brand
                    brandDetailsVC.isFromDynamicLink = true
                    brandDetailsVC.brandID = String(describing: brand.brandId )
                    brandDetailsVC.grocery = grocery
                    topController.navigationController?.pushViewController(brandDetailsVC, animated: true)
                   
                }
            }
        }
        func checkForBrand() {
            
            let brand = GroceryBrand.init()
            brand.brandId = Int(self.brandId) ?? -1
            guard brand.brandId > 0 else {
                MeterialProgress.completeAndHideProgressView()
                return
            }
            self.callBrandDeepLinkVC(brandId: self.brandId)
        }
        ///
        
        /// category navigation work
        func checkForCategories(lat : Double , lng : Double) {
                guard let activeGrocery = ElGrocerUtility.sharedInstance.activeGrocery else {
                    MeterialProgress.completeAndHideProgressView()
                    return
                    
                }
                callToChangeStoreAfterAllDataSet()
                ElGrocerApi.sharedInstance.getAllCategories(nil , parentCategory: nil, forGrocery: activeGrocery , lat, lng) { (result) in
                    switch result {
                        case .success(let response):
                            self.saveAllCategories(responseDict: response, grocery: activeGrocery , lat: lat, lng: lng)
                        case .failure(_):
                            MeterialProgress.completeAndHideProgressView()
                    }
                }
        }
        
        func checkGrocery (_ checkBoth : Bool = false , lat : Double , lng : Double , dbID : String = "" ) {
            
            var deliveryGroceryList : [Grocery] = []
            var cncGroceryList : [Grocery] = []
            func checkForCandC(lat : Double , lng : Double) {
                
                ElGrocerApi.sharedInstance.checkCandCavailability( lat , lng: lng ) { (result) in
                    switch result {
                        case .success(let responseObj):
                            var data: NSDictionary = responseObj
                            data = data["data"] as? NSDictionary ?? [:]
                            if let retailerslist = data["retailers"] as? [NSDictionary] {
                                ElGrocerUtility.sharedInstance.cAndcRetailerList = []
                                let responseData = Grocery.insertOrReplaceGroceriesFromDictionary(data, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , false)
                                ElGrocerUtility.sharedInstance.cAndcRetailerList = responseData
                                if retailerslist.count > 0 {
                                    checkForcncGroceryDetail()
                                }
                                return
                            }
                            MeterialProgress.completeAndHideProgressView()
                        case .failure( _):
                            MeterialProgress.completeAndHideProgressView()
                    }
                }

                func checkForcncGroceryDetail() {
                    
                    if !parentIds.isEmpty {
                        let parentA = self.parentIds.split(separator: ",")
                        for parentId in parentA {
                            if let grocery = deliveryGroceryList.first(where: { (grocery) -> Bool in
                                return parentId == grocery.parentID.stringValue
                            }){
                                self.groceryId = grocery.dbID
                                self.parentId = grocery.parentID.stringValue
                                break
                            }
                        }
                    }else if self.groceryId.isEmpty && self.parentId.isEmpty  {
                        if deliveryGroceryList.count > 0 {
                            self.groceryId = ElGrocerUtility.sharedInstance.cAndcRetailerList[0].dbID
                        }
                    }
                    ElGrocerApi.sharedInstance.getcAndcRetailerDetail(lat, lng: lng, dbID: self.groceryId , parentID: self.parentId) { (result) in
                        switch result {
                            case.success(let data):
                                let responseData = Grocery.insertOrReplaceGroceriesFromDictionary(data, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , false)
                                if responseData.count > 0 {
                                    ElGrocerUtility.sharedInstance.cAndcRetailerList.append(responseData[0])
                                    ElGrocerUtility.sharedInstance.activeGrocery = responseData[0]
                                    UserDefaults.setGroceryId(ElGrocerUtility.sharedInstance.activeGrocery?.dbID , WithLocationId: dbID)
                                    ElGrocerUtility.sharedInstance.isDeliveryMode = false
                                    ElGrocerUtility.sharedInstance.groceries = ElGrocerUtility.sharedInstance.cAndcRetailerList
                                    self.getGroceryDeliverySlots(ElGrocerUtility.sharedInstance.activeGrocery)
                                    if isBrand {
                                        checkForBrand()
                                        return
                                    }else if isSubCatogryOrCategory{
                                        checkForCategories(lat: lat, lng: lng)
                                        return
                                    }else{
                                        self.loadGroceryAlreadySelected()
                                    }
                                }
                                MeterialProgress.completeAndHideProgressView()
                            case.failure(let error):
                                MeterialProgress.completeAndHideProgressView()
                        }
                    }
                    
                    
                }
                
                
            }
            if checkBoth || self.serviceId == OrderType.delivery.rawValue {
    
                let apiCall = GenericStoreMeduleAPI()
                apiCall.getAllretailers(latitude: lat, longitude: lng) { (task, responseObj) in
                    if  responseObj is NSDictionary {
                        let data: NSDictionary = responseObj as? NSDictionary ?? [:]
                        if let dataDict : NSDictionary = data["data"] as? NSDictionary {
                            if let _ = dataDict["retailers"] as? [NSDictionary] {
                                let responseData = Grocery.insertOrReplaceGroceriesFromDictionary(data, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , false)
                                deliveryGroceryList = responseData
                                callForGroceryDetail()
                                return
                            }
                        }
                    }
                    // SpinnerView.hideSpinnerView()
                } failure: { (task, Error) in
                    // SpinnerView.hideSpinnerView()
                }

                func callForGroceryDetail() {
                    
                    if !parentIds.isEmpty {
                        let parentA = self.parentIds.split(separator: ",")
                        for parentId in parentA {
                            if let grocery = deliveryGroceryList.first(where: { (grocery) -> Bool in
                                return parentId == grocery.parentID.stringValue
                            }){
                                self.groceryId = grocery.dbID
                                self.parentId = grocery.parentID.stringValue
                                break
                            }
                        }
                    }else if self.groceryId.isEmpty && self.parentId.isEmpty  {
                        if deliveryGroceryList.count > 0 {
                            self.groceryId = deliveryGroceryList[0].dbID
                        }
                    }
                    ElGrocerApi.sharedInstance.getGroceryFrom(lat: lat, lng: lng, storeID: self.groceryId , parentID: self.parentId) { (result) in
                        switch result {
                            case.success(let data):
                                let responseData = Grocery.insertOrReplaceGroceriesFromDictionary(data, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , false)
                                if responseData.count > 0 {
                                    ElGrocerUtility.sharedInstance.activeGrocery = responseData[0]
                                    UserDefaults.setGroceryId(ElGrocerUtility.sharedInstance.activeGrocery?.dbID , WithLocationId: dbID)
                                    ElGrocerUtility.sharedInstance.isDeliveryMode = true
                                    ElGrocerUtility.sharedInstance.groceries = deliveryGroceryList
                                    self.getGroceryDeliverySlots(ElGrocerUtility.sharedInstance.activeGrocery)
                                    if isBrand {
                                        checkForBrand()
                                    }else if isSubCatogryOrCategory{
                                        checkForCategories(lat: lat, lng: lng)
                                    }else{
                                        self.loadGroceryAlreadySelected()
                                    }
                                }else if checkBoth {
                                    checkForCandC(lat: lat, lng: lng)
                                }
                                // SpinnerView.hideSpinnerView()
                            case.failure(let error):
                                debugPrint(error.localizedMessage)
                                // SpinnerView.hideSpinnerView()
                        }
                    }
                    
                    
                }
                  
            }else if self.serviceId == OrderType.CandC.rawValue {
                checkForCandC(lat: lat, lng: lng)
            }
        }
        
        
        func callWithCurrentAddress() {
            if let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()  {
                checkGrocery(isNeedToCheckAllMode , lat: currentAddress.latitude , lng:  currentAddress.longitude , dbID: currentAddress.dbID)
            } else {
                // SpinnerView.hideSpinnerView()
            }
        }
        
        
        
        if self.serviceId == OrderType.CandC.rawValue {
            LocationManager.sharedInstance.locationWithStatus = { (location , state) in
                guard state != nil else {
                    return
                }
                switch state! {
                    case LocationManager.State.fetchingLocation:
                        debugPrint("")
                    case LocationManager.State.initial:
                        debugPrint("")
                    default:
                        LocationManager.sharedInstance.stopUpdatingCurrentLocation()
                        if LocationManager.sharedInstance.currentLocation.value != nil {
                            var lati = ElGrocerUtility.sharedInstance.dubaiCenterLocation.coordinate.latitude
                            var lngi = ElGrocerUtility.sharedInstance.dubaiCenterLocation.coordinate.longitude
                            if LocationManager.sharedInstance.currentLocation.value != nil {
                                lati = LocationManager.sharedInstance.currentLocation.value?.coordinate.latitude ?? ElGrocerUtility.sharedInstance.dubaiCenterLocation.coordinate.latitude
                                lngi = LocationManager.sharedInstance.currentLocation.value?.coordinate.longitude ?? ElGrocerUtility.sharedInstance.dubaiCenterLocation.coordinate.longitude
                            }else{
                                if let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() {
                                    lati = currentAddress.latitude
                                    lngi = currentAddress.longitude
                                }else{
                                    LocationManager.sharedInstance.locationWithStatus = nil
                                    return
                                }
                            }
                            checkGrocery(isNeedToCheckAllMode, lat: lati , lng: lngi, dbID: "")
                            LocationManager.sharedInstance.locationWithStatus = nil
                        }else{
                            callWithCurrentAddress()
                            LocationManager.sharedInstance.locationWithStatus = nil
                        }
                }
            }
            LocationManager.sharedInstance.fetchCurrentLocation()
            
        }else{
            callWithCurrentAddress()
        }
        self.showHudOfTopScreen()
    }
    
    private func showHudOfTopScreen() {
        
        if let topVc = UIApplication.topViewController() {
            if topVc is GroceryLoaderViewController {
                ElGrocerUtility.sharedInstance.delay(0.1) {
                    self.showHudOfTopScreen()
                }
                return
            }
                // let _ =  SpinnerView.showSpinnerViewInView(topVc.view)
        }
    }
    
    func saveAllCategories(responseDict : NSDictionary , grocery : Grocery  , lat : Double , lng : Double ) {
        
        
      //  if let data = responseDict["data"] as? NSDictionary {
            if let categoryArray = responseDict["data"] as? [NSDictionary] {
                let groceryBgContext = DatabaseHelper.sharedInstance.getEntityWithName(GroceryEntity, entityDbId: grocery.dbID as AnyObject, keyId: "dbID", context: DatabaseHelper.sharedInstance.mainManagedObjectContext) as! Grocery
                Category.insertOrUpdateCategoriesForGrocery(groceryBgContext, categoriesArray: categoryArray, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                DatabaseHelper.sharedInstance.saveDatabase()
            }
      //  }
        if let updateGrocery = Grocery.getGroceryById(grocery.dbID, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            var categories = updateGrocery.categories.allObjects as! [Category]
            categories.sort { $0.sortID < $1.sortID}
            
            let selectedCategoryA = categories.filter { (cate) -> Bool in
                return cate.dbID.stringValue == self.categoryId
            }
            
            if selectedCategoryA.count > 0 {
                let cateSelect = selectedCategoryA[0]
                if self.subcategoryId.isEmpty {
                    // SpinnerView.hideSpinnerView() ;
                    let controller = ElGrocerViewControllers.SubCategoriesViewController(dataHandler: CateAndSubcategoryView()) as SubCategoriesViewController
                    controller.viewHandler.setGrocery(updateGrocery)
                    controller.viewHandler.setParentCategory(cateSelect)
                    controller.viewHandler.setParentSubCategory(nil)
                    controller.viewHandler.setLastScreenName(UIApplication.gettopViewControllerName() ?? "")
                    controller.grocery = updateGrocery
                    controller.hidesBottomBarWhenPushed = false
                    self.gotToController(controller)
                    MeterialProgress.completeAndHideProgressView()
                    
                }else{
                    
                    ElGrocerApi.sharedInstance.getAllCategories(nil , parentCategory: cateSelect, forGrocery: updateGrocery , lat, lng) { (result) -> Void in
                        // SpinnerView.hideSpinnerView() ;
                        switch result {
                            case .success(let response):
                                let newSubCategories = SubCategory.getAllSubCategoriesFromResponse(response)
                                
                                let subSelectedCategoryA = newSubCategories.filter { (cate) -> Bool in
                                    return cate.subCategoryId.stringValue == self.subcategoryId
                                }
                                if subSelectedCategoryA.count > 0 {
                                    let subC = subSelectedCategoryA[0]
                                    if let controller = ElGrocerViewControllers.SubCategoriesViewController(dataHandler: CateAndSubcategoryView()) as? SubCategoriesViewController {
                                        controller.viewHandler.setLastScreenName(UIApplication.gettopViewControllerName() ?? "")
                                        controller.grocery = updateGrocery
                                        controller.viewHandler.setGrocery(updateGrocery)
                                        controller.viewHandler.setParentCategory(cateSelect)
                                        controller.viewHandler.setParentSubCategory(subC)
                                        controller.hidesBottomBarWhenPushed = false
                                        self.gotToController(controller)
                                    }
                                }
                                MeterialProgress.completeAndHideProgressView()
                            case .failure(let _):
                                MeterialProgress.completeAndHideProgressView()
                        }
                    }
                }
            }
        }
        // SpinnerView.hideSpinnerView() ;
    }
    
    
    func gotToController (_ controller : SubCategoriesViewController) {
        if let topVc = UIApplication.topViewController() {
            if topVc is GroceryLoaderViewController {
                ElGrocerUtility.sharedInstance.delay(2) {
                    self.gotToController(controller)
                }
            }else{
                topVc.navigationController?.pushViewController(controller, animated: true)
                MeterialProgress.completeAndHideProgressView()
            }
        }
    }
    
    
    
    func getGroceryDeliverySlots(_ grocery : Grocery?){
        
        ElGrocerApi.sharedInstance.getGroceryDeliverySlotsWithGroceryId(grocery?.dbID , andWithDeliveryZoneId: grocery?.deliveryZoneId, false, completionHandler: { (result) -> Void in
            
            switch result {
                
                case .success(let response):
                    print("SERVER Response:%@",response)
                    self.saveResponseData(response)
                    
                case .failure(let error):
                    print("Error while getting Delivery Slots from SERVER:%@",error.localizedMessage)
            }
        })
    }
    
    // MARK: Data
    func saveResponseData(_ responseObject:NSDictionary) {
        
      
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        Grocery.updateActiveGroceryDeliverySlots(with: responseObject, context: context)
        let _ =  DeliverySlot.insertOrReplaceDeliverySlotsFromDictionary(responseObject, context: context)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: KUpdateGenericSlotView), object: nil)
        }
     //   spiner?.removeFromSuperview()
    }
    
    
    
    func createDynamicLinkWith (_ recipeID : Int64? , instaID : String , completetion : @escaping (String) -> Void)  {

        let returnString : String = String(describing: recipeID ?? 0)
       // let instagramURL = "https://itunes.apple.com/ae/app/grocer-online-grocery-delivery/id1040399641?mt=8"
        var instagramURL = "https://www.instagram.com/" + instaID + "/?hl=en"
        if instaID.isEmpty {
            instagramURL = "https://itunes.apple.com/ae/app/grocer-online-grocery-delivery/id1040399641?mt=8"
        }else if instaID.contains("instagram.com") {
            instagramURL = instaID
        }
        if Platform.isDebugBuild {
             instagramURL = "https://www.instagram.com/" + "tamarafarra" + "/?hl=en"
        }
        
        let iosAppLink : String = "https://e6rqa.app.goo.gl/?&recipeID=\(returnString)"
        guard let link = URL(string: iosAppLink ) else {  completetion("") ; return  }
        let dynamicLinksDomainURIPrefix = "elgrocershopper.page.link"
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        let iOSParams = DynamicLinkIOSParameters(bundleID: "elgrocer.com.ElGrocerShopper")
        iOSParams.customScheme = "elgrocer.com.ElGrocerShopper"
        linkBuilder?.iOSParameters = iOSParams
        linkBuilder?.iOSParameters?.fallbackURL = (NSURL(string: instagramURL)! as URL)
        linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.el_grocer.shopper")
        linkBuilder?.androidParameters?.fallbackURL = (NSURL(string: instagramURL)! as URL)
        guard let longDynamicLink = linkBuilder?.url else { completetion("") ; return  }
        print("The long URL is: \(longDynamicLink)")
        guard linkBuilder?.url != nil else {  completetion("") ; return }
        debugPrint(longDynamicLink)
        let options = DynamicLinkComponentsOptions()
        options.pathLength = .short
        linkBuilder?.options = options
        linkBuilder?.shorten { (url, warning, error) in
            guard let url = url, error == nil else {
                 completetion("")
                return
            }
            print("The short URL is: \(url)")
            completetion(url.absoluteString)
        }
    }
}


extension DynamicLinksHelper : StoresDataHandlerDelegate { }

let kMeterialProgress = -102011
import MaterialComponents.MaterialActivityIndicator
class MeterialProgress {
    
    
    class func showProgress() {
        
        
       
        
        let progressView : UIActivityIndicatorView?
        
        if let topVc = UIApplication.shared.keyWindow {
            
            if let view = topVc.viewWithTag(kMeterialProgress) as? UIActivityIndicatorView {
                progressView = view
            } else {
                progressView = UIActivityIndicatorView(frame: CGRect(x: (topVc.bounds.width / 2) - 25 , y: topVc.bounds.height / 2, width: 50, height: 50))
            }
          
            progressView?.color = UIColor.secondaryDarkGreenColor()
            
          
            if #available(iOS 13.0, *)  {
                progressView?.style = .large
            }else{
                progressView?.style = .whiteLarge
            }
            
           
            progressView?.hidesWhenStopped = false
            progressView?.tag = kMeterialProgress
            progressView?.hidesWhenStopped = true
            guard progressView != nil else { return }
            
            UIApplication.shared.keyWindow?.addSubview(progressView!)
            startAndShowProgressView(progressView!)
            
        }
    
    }
    
    class private func startAndShowProgressView(_ progressView : UIActivityIndicatorView) {
        progressView.startAnimating()
    }
    
    class func completeAndHideProgressView() {
        
        if let topVc = UIApplication.shared.keyWindow {
            if let view = topVc.viewWithTag(kMeterialProgress) as? UIActivityIndicatorView {
                view.stopAnimating()
            }
        }
    }
    
}
