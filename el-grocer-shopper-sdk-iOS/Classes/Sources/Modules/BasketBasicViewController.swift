//
//  BasketBasicViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 13.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
// initial comit

import Foundation
import UIKit
import FBSDKCoreKit
import FirebaseAnalytics
import FirebaseCrashlytics
//import AppsFlyerLib
enum ShouldShowBasket : Int {
    case False = 0
    case ShopByItemsBasket = 1
    case ShopByStoreBasket = 2
}

enum PaymentOption : UInt32 {
    case none = 0
    case cash = 1
    case card = 2
    case creditCard = 3
    case smilePoints = 4
    case voucher = 5
    case PromoCode = 6
    case tabby = 7
    case applePay = 1000
    
}

extension PaymentOption {
    var paymentMethodName: String {
        switch self {
        case .none          : return ""
        case .cash          : return "Cash"
        case .card          : return "Payment by Card"
        case .creditCard    : return "Payment Online"
        case .smilePoints   : return "Smile Point"
        case .voucher       : return "Voucher"
        case .PromoCode     : return "Promo Code"
        case .applePay      : return "Apple Pay"
        case .tabby         : return "Tabby"
        }
    }
}


class BasketBasicViewController : UIViewController, BasketIconOverlayViewProtocol, ShoppingBasketViewProtocol, NavigationBarSearchProtocol, ProductCellProtocol, shoppingLisDelegate , GrocerySelectionProtocol, ProductDetailsViewProtocol,MyBasketViewProtocol , NavigationBarProtocol   {
    
    
    
    func navigationBarSearchViewDidChangeCharIn(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) {
        
    }
    
    
    @objc func backButtonClickedHandler(){
        
    }
    
    
    var grocery:Grocery?
    var shouldShowGroceryActiveBasket:Bool?
    var shouldShowBasket:ShouldShowBasket = .False
    
    var searchString:String = ""
    var searchedProducts:[Product] = [Product]()
    var searchTimer:Timer?
    
    var shoppingBasketView:ShoppingBasketView!
    
    var profileCompletionControllerShownForGroceryFlow:Bool = false
    
    var isReplacmentController:Bool = false
    
    //products search variables
    var currentSearchPage = 0
    var isLoadingProducts = false
    var moreProductsAvailable = true
    
    //empty view
    var emptyView:EmptyView?
    
    var shopByItemGrocery: Grocery?
    var notAvailableItems:[Int] = []
    var availableProductsPrices:NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(BasketBasicViewController.keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BasketBasicViewController.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        addBasketIconOverlay(self, grocery: self.grocery, shouldShowGroceryActiveBasket: self.shouldShowGroceryActiveBasket)
   
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BasketBasicViewController.dismissKeyboard))
        self.emptyView?.addGestureRecognizer(tapGesture)
        self.emptyView?.isUserInteractionEnabled = true
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldShowBasket != .False{
            self.showBasketAfterLogin()
            shouldShowBasket = .False
        }
        
       // refreshBasketIconStatus() -- Comment this line
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyboard()
    }
    
    // MARK: Keyboard
    
    @objc func dismissKeyboard() {
        
        self.navigationController?.navigationBar.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
    }
    
    // MARK: Empty view
    
    func addEmptyView() {
        
        self.emptyView?.removeFromSuperview()
        
        self.emptyView = EmptyView.createAndAddEmptyView(localizedString("empty_view_products_search_title", comment: ""), description: localizedString("empty_view_products_search_description", comment: ""), addToView: self.view)
        self.emptyView?.isHidden = true
        if let emptyView = self.emptyView {
            self.view.sendSubviewToBack(emptyView)
        }
    }
    
    func showBasketAfterLogin() {
        if UserDefaults.isUserLoggedIn() {
            if shouldShowBasket == .ShopByStoreBasket {
                self.shoppingBasketView = ShoppingBasketView.showShoppingBasket(self, shouldShowGroceryActiveBasket: (self.grocery != nil || self.shouldShowGroceryActiveBasket != nil), selectedGroceryForItems: nil, notAvailableProducts: nil, availableProductsPrices: nil)
            } else if shouldShowBasket == .ShopByItemsBasket {
                self.shoppingBasketView = ShoppingBasketView.showShoppingBasket(self, shouldShowGroceryActiveBasket: false, selectedGroceryForItems: self.shopByItemGrocery, notAvailableProducts: self.notAvailableItems, availableProductsPrices: self.availableProductsPrices)
                
                //tutorial
                /*if !UserDefaults.wasTutorialImageShown(TutorialView.TutorialImage.Basket) {
                    
                    TutorialView.showTutorialView(withImage: TutorialView.TutorialImage.Basket)
                    UserDefaults.setTutorialImageAsShown(TutorialView.TutorialImage.Basket)
                }*/
            }
        }
    }
    
    // MARK: Basket Button Clicked
    
    override func basketButtonClick() {
        
        ElGrocerEventsLogger.sharedInstance.trackMyBasketClick()
  
        let basketController = ElGrocerViewControllers.myBasketViewController()
        basketController.showShoppingBasket(delegate: self, shouldShowGroceryActiveBasket: (self.grocery != nil || self.shouldShowGroceryActiveBasket != nil), selectedGroceryForItems: nil, notAvailableProducts: nil, availableProductsPrices: nil)
        self.navigationController?.pushViewController(basketController, animated: true)
    }

    // MARK: BasketIconOverlayViewProtocol
    func basketIconOverlayViewDidTouchBasket(_ basketIconOverlayView: BasketIconOverlayView) {
        
     /* if (self.grocery != nil || self.shouldShowGroceryActiveBasket != nil) && !UserDefaults.isUserLoggedIn() {
            
            self.shouldShowBasket = .ShopByStoreBasket
            
            self.shoppingBasketView = ShoppingBasketView.showShoppingBasket(self, shouldShowGroceryActiveBasket: (self.grocery != nil || self.shouldShowGroceryActiveBasket != nil), selectedGroceryForItems: nil, notAvailableProducts: nil, availableProductsPrices: nil)
            
        } else if UserDefaults.isUserLoggedIn() {
            
            self.shoppingBasketView = ShoppingBasketView.showShoppingBasket(self, shouldShowGroceryActiveBasket: (self.grocery != nil || self.shouldShowGroceryActiveBasket != nil), selectedGroceryForItems: nil, notAvailableProducts: nil, availableProductsPrices: nil)
        } else {
            
            self.shoppingBasketView = ShoppingBasketView.showShoppingBasket(self, shouldShowGroceryActiveBasket: (self.grocery != nil || self.shouldShowGroceryActiveBasket != nil), selectedGroceryForItems: nil, notAvailableProducts: nil, availableProductsPrices: nil)
        }*/
        
       let basketController = ElGrocerViewControllers.myBasketViewController()
        basketController.showShoppingBasket(delegate: self, shouldShowGroceryActiveBasket: (self.grocery != nil || self.shouldShowGroceryActiveBasket != nil), selectedGroceryForItems: nil, notAvailableProducts: nil, availableProductsPrices: nil)
        self.navigationController?.pushViewController(basketController, animated: true)
    }
    
    
    // MARK: MyBasketViewProtocol
    func shoppingBasketViewCheckOutTapped(_ isGroceryBasket:Bool, grocery:Grocery?, notAvailableItems:[Int]?, availableProductsPrices:NSDictionary?){
        
        guard UserDefaults.isUserLoggedIn() else {
            // The user is not logged in. Lets show him the registration controller
            
            self.shouldShowBasket = .False

            let registrationProfileController = ElGrocerViewControllers.registrationPersonalViewController()
            registrationProfileController.delegate = self
            let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navController.viewControllers = [registrationProfileController]
            navController.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                 self.present(navController, animated: true, completion: nil)
            }
           
            
            
            ElGrocerUtility.sharedInstance.isFromCheckout = true
            ElGrocerUtility.sharedInstance.isSummaryForGroceryBasket = isGroceryBasket
            ElGrocerUtility.sharedInstance.notAvailableItems = notAvailableItems
            ElGrocerUtility.sharedInstance.availableProductsPrices = availableProductsPrices
            return
        }
     
      if grocery == nil {
            //we are checking out basket from items flow without selected grocery
            self.showGrocerySelectionController()
        } else {
            //we are checking out basket for either items flow with grocery selected or grocery flow
           // self.showSummaryController(grocery!, isBasketForGroceryFlow: isGroceryBasket, notAvailableItems: notAvailableItems, availableProductsPrices: availableProductsPrices)
        }
    }
    
    // MARK: ShoppingBasketViewProtocol
    
    func shoppingBasketViewDidTouchProduct(_ shoppingBasketView: ShoppingBasketView, product: Product, shoppingItem: ShoppingBasketItem) {
        
        let grocery = (self.grocery != nil || self.shouldShowGroceryActiveBasket != nil) ? Grocery.getGroceryById(product.groceryId, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) : nil
        
        ProductDetailsView.showWithProduct(product, shoppingItem:shoppingItem, grocery: grocery, delegate: self)
    }
    
    func shoppingBasketViewDidDeleteProduct(_ shoppingBasketView: ShoppingBasketView, product: Product, grocery: Grocery?, shoppingBasketItem: ShoppingBasketItem) {
        
        ShoppingBasketItem.removeProductFromBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        self.shoppingBasketView?.refreshView()
        refreshBasketIconStatus()
        self.checkBasketAndManageAbandonedBasketNotification()
    }
    
    func shoppingBasketViewDidTouchCheckOut(_ shoppingBasketView: ShoppingBasketView, isGroceryBasket:Bool, grocery: Grocery?, notAvailableItems:[Int]?, availableProductsPrices:NSDictionary?) {
        
        guard UserDefaults.isUserLoggedIn() else {
            // The user is not logged in. Lets show him the registration controller
            self.shouldShowBasket = .False
            let registrationProfileController = ElGrocerViewControllers.registrationPersonalViewController()
            registrationProfileController.delegate = self
            registrationProfileController.dismissMode = .dismissModal
            let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navController.viewControllers = [registrationProfileController]
            navController.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        if grocery == nil {
            //we are checking out basket from items flow without selected grocery
            self.showGrocerySelectionController()
        } else {
            //Hunain 20Dec2016
            //Remove all checks in all cases controll moves at Checkout Profile Screen
            //hide basket
            hideShoppingBasket()
            
            //get user profile and address to check for profile completion
            //let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)!
            //let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            //check if user has phone number and valid delivery address
            //if userProfile.phone == nil || userProfile.phone!.isEmpty {
                
                /*self.profileCompletionControllerShownForGroceryFlow = isGroceryBasket
                self.showProfileCompletionController(userProfile, deliveryAddress: deliveryAddress, grocery: grocery!, notAvailableItems: notAvailableItems, availableProductsPrices: availableProductsPrices)*/
                
            //} else {
                
                //we are checking out basket for either items flow with grocery selected or grocery flow
           // self.showSummaryController(grocery!, isBasketForGroceryFlow: isGroceryBasket, notAvailableItems: notAvailableItems, availableProductsPrices: availableProductsPrices)
            //}
        }
    }
    func reloadCellIndexForBanner(_ currentIndex: Int , cell : ShoppingListCellTableViewCell) {  }
    func addBannerFor(_ currentIndex: Int, searchResultString: String, homeFeed: Any?) {}
    
    
    // MARK: ProductDetailsViewProtocol
    
    func productDetailsViewProtocolDidTouchDoneButton(_ productDetailsView: ProductDetailsView, product:Product, quantity: Int) {
        
        if !self.searchString.isEmpty && ElGrocerUtility.sharedInstance.searchBarShakeHintCount > 0 {
            // Analytics.logEvent("Hint_Search_Product_Add", parameters:nil)
            ElGrocerUtility.sharedInstance.isShoppingAfterSearchHint = true
        }
        
        if self.shoppingBasketView != nil {
            
            self.shoppingBasketView.refreshView()
        }
        
        self.checkBasketAndManageAbandonedBasketNotification()
    }
    
    func productDetailsViewProtocolDidTouchFavourite(_ productDetailsView: ProductDetailsView, product: Product) {
        if UserDefaults.isUserLoggedIn() {
            Product.markSimilarProductsAsFavourite(product, markAsFavourite: product.isFavourite.boolValue, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            if product.isFavourite.boolValue {
                
                ElGrocerApi.sharedInstance.addProductToFavourite(product, completionHandler: { (result) -> Void in
                    
                })
                // IntercomeHelper.updateIntercomFavouritesDetails()
                // PushWooshTracking.updateFavouritesDetails()
            } else {
                
                ElGrocerApi.sharedInstance.deleteProductFromFavourites(product, completionHandler: { (result) -> Void in
                    
                })
                // IntercomeHelper.updateIntercomFavouritesDetails()
                // PushWooshTracking.updateFavouritesDetails()
            }
        } else {
            (sdkManager).showEntryView()
        }
    }
    
    // MARK: GrocerySelectionProtocol
    
    func grocerySelectionController(_ controller: GrocerySelectionViewController, didSelectGrocery grocery: Grocery, notAvailableItems:[Int], availableProductsPrices:NSDictionary?) {
                
        //dismiss grocery selection controller
        controller.presentingViewController?.dismiss(animated: true, completion: { () -> Void in
            
            if !UserDefaults.isUserLoggedIn() {
                
                self.shouldShowBasket = .ShopByItemsBasket
                self.shopByItemGrocery = grocery
                self.notAvailableItems = notAvailableItems
                self.availableProductsPrices = availableProductsPrices
                (sdkManager).showEntryView()
                
            } else {
                
                //show basket with selected grocery and prices, with items markes as unavailable
                let basketController = ElGrocerViewControllers.myBasketViewController()
                basketController.showShoppingBasket(delegate: self, shouldShowGroceryActiveBasket: false, selectedGroceryForItems: grocery, notAvailableProducts: notAvailableItems, availableProductsPrices: availableProductsPrices)
                self.navigationController?.pushViewController(basketController, animated: true)
                
                /* ---------- Hide below code because now we are not showing old basket view ---------- */
               /* self.shoppingBasketView = ShoppingBasketView.showShoppingBasket(self, shouldShowGroceryActiveBasket: false, selectedGroceryForItems: grocery, notAvailableProducts: notAvailableItems, availableProductsPrices: availableProductsPrices)*/
                
                //tutorial
               /* if !UserDefaults.wasTutorialImageShown(TutorialView.TutorialImage.Basket) {
                    
                    TutorialView.showTutorialView(withImage: TutorialView.TutorialImage.Basket)
                    UserDefaults.setTutorialImageAsShown(TutorialView.TutorialImage.Basket)
                }*/
            }
        })
    }
    
    func updateDataWithNewGrocery(grocery: Grocery) {} /* implement in recipe items controller*/
    
    // MARK: Helpers
    
    func showGrocerySelectionController(_ productsToCheck : [Product]?=nil , _ isFromRecipe : Bool=false , _ recipeController : RecipeDetailViewController? = nil) {
        
        //show screen to choose grocery
        let groceriesController = ElGrocerViewControllers.grocerySelectionViewController()
        if let cont = recipeController {
            groceriesController.delegate = cont
        }else{
            groceriesController.delegate = self
        }
    
        groceriesController.isRecipeItems = isFromRecipe
        if let data = productsToCheck {
             groceriesController.productsToCheck = data
        }else{
            //get products to check if available in grocery
            groceriesController.productsToCheck = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [groceriesController]
        navigationController.setLogoHidden(true)
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    
    
    
    
    func showLoginGrocerySelectionController() {
        
        //show screen to choose grocery
        let groceriesController = ElGrocerViewControllers.grocerySelectionViewController()
        groceriesController.delegate = self
        
        //get products to check if available in grocery
        groceriesController.productsToCheck = ShoppingBasketItem.getBasketProductsForActiveItemsBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        

        (sdkManager).showEntryView()
        
    }
    
    func showProfileCompletionController(_ userProfile:UserProfile, deliveryAddress:DeliveryAddress, grocery:Grocery, notAvailableItems:[Int]?, availableProductsPrices:NSDictionary?) {
        
        //Hunain 20Dec2016
        //go to screen when user have to complete missing data
        //New checkout Profile screen is designed
        
        let registrationProfileController = ElGrocerViewControllers.registrationPersonalViewController()
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [registrationProfileController]
        present(navController, animated: true, completion: nil)
    }
    
    private func validateUserProfile(_ userProfile: UserProfile?, andUserDefaultLocation deliveryAddress:DeliveryAddress?) -> Bool {
        
        var isValidationSuccessed = false
        
        guard let profile = userProfile, let address = deliveryAddress  else {
            return isValidationSuccessed
        }
        
        if address.addressType == "1" {
            
            isValidationSuccessed = profile.name != nil && !profile.name!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty && profile.phone != nil
                && !userProfile!.phone!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                
                && address.houseNumber != nil && !address.houseNumber!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && address.street != nil && !address.street!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        }else{
            
            isValidationSuccessed = profile.name != nil && !profile.name!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty && profile.phone != nil
                && !userProfile!.phone!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                
                && address.building != nil && !address.building!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && address.floor != nil && !address.floor!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && address.apartment != nil && !address.apartment!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && address.street != nil && !address.street!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        }
        
        return isValidationSuccessed
    }
    
    func hideShoppingBasket() {
        
        //UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        self.shoppingBasketView.removeFromSuperview()
    }
    
    // MARK: NavigationBarSearchProtocol
    
    @objc 
    func navigationBarSearchTapped() {
       elDebugPrint("Implement in controller")
        
        let searchController = ElGrocerViewControllers.getUniversalSearchViewController()
        ElGrocerEventsLogger.sharedInstance.trackScreenNav( ["clickedEvent" : "Search" , "isUniversal" : "0" ,  FireBaseParmName.CurrentScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName() ?? "") , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Search.rawValue ])
        searchController.navigationFromControllerName = FireBaseEventsLogger.gettopViewControllerName() ?? ""
        searchController.searchFor = .isForStoreSearch
        self.navigationController?.modalTransitionStyle = .crossDissolve
        self.navigationController?.modalPresentationStyle = .formSheet
        self.navigationController?.pushViewController(searchController, animated: true)
        ElGrocerUtility.sharedInstance.delay(1.0) {
            if searchController.txtSearch != nil {
                searchController.txtSearch.becomeFirstResponder()
            }
        }
        
    }
    
    
    func navigationBarSearchViewDidChangeText(_ navigationBarSearch: NavigationBarSearchView, searchString: String) {
        
        self.searchString = searchString
        //performSearch(searchString)
        self.performSearch(searchString, withSearchSuggestion: nil)
    }
    
    
    // MARK: Search
    func performSearch(_ searchString:String, withSearchSuggestion seachSuggestion:SearchSuggestion?) {
        
        //check if user paused search
        if self.searchTimer != nil {
            self.searchTimer?.invalidate()
            self.searchTimer = nil
        }
        
    //    self.searchTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(BasketBasicViewController.userPerformedSearch), userInfo: nil, repeats: false)
        
        if !searchString.isEmpty {
    
           // let _ = SpinnerView.showSpinnerViewInView(self.view)
            //self.searchProducts(true)
             self.searchProducts(true, withSearchSuggestion: seachSuggestion)
        
        } else {
            
            self.refreshData()
            self.emptyView?.isHidden = true
           // SpinnerView.hideSpinnerView()
        }
    }
    
    @objc func userPerformedSearch() {
        
        if !self.searchString.isEmpty {
     
            GoogleAnalyticsHelper.trackProductsSearchPhrase(self.searchString)
            
            ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("search")
            
            if let searchVC : SearchViewController = UIApplication.topViewController() as? SearchViewController {
                FireBaseEventsLogger.trackSearch(self.searchString, topControllerName: searchVC.navigationFromControllerName)
            }
            
            /* ---------- Facebook Search Event ----------*/
            //MARK:- Fix fix it later with sdk version
            //AppEvents.logEvent(AppEvents.Name.searched, parameters: [AppEvents.Name.searched.rawValue:self.searchString])
            /* ---------- AppsFlyer Search Event ----------*/
                // MARK:- TODO fixappsflyer
           // AppsFlyerLib.shared().logEvent(name: AFEventSearch, values: [AFEventParamSearchString:self.searchString], completionHandler: nil)
            //AppsFlyerLib.shared().trackEvent(AFEventSearch, withValues:[AFEventParamSearchString:self.searchString])
            /* ---------- Fabric Search Event ----------*/
            // Answers.Search(withQuery: self.searchString,customAttributes: nil)
            
           elDebugPrint("search call : \(self.searchString)")
        }
    }
    
    func searchProducts(_ shouldClearProductsArray:Bool, withSearchSuggestion seachSuggestion:SearchSuggestion?) {
        
        self.isLoadingProducts = true
        self.currentSearchPage = shouldClearProductsArray ? 0 : self.currentSearchPage + 1
        
        var location:DeliveryAddress? = nil
        if (self.grocery != nil || self.shouldShowGroceryActiveBasket != nil) {
            location = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
       
        var dbToSend = ""
        if let dbID = ElGrocerUtility.sharedInstance.activeGrocery?.dbID {
            dbToSend = dbID
        }
        
        if let dbID = self.grocery?.dbID {
            dbToSend = dbID
        }
        
        AlgoliaApi.sharedInstance.searchQueryWithCurrentStoreItems(self.searchString, storeID: dbToSend, pageNumber: self.currentSearchPage , seachSuggestion: seachSuggestion, searchType: "alternate" ) { (content, error) in
            
            if error != nil {
                elDebugPrint("==============")
                elDebugPrint(error as Any)
            
            }else if  content != nil{
                
                //  elDebugPrint(content as Any)
                
                if shouldClearProductsArray {
                    self.searchedProducts = [Product]()
                }
                
                Thread.OnMainThread {
                    
                    //, searchString: self.searchString
                    let newProducts = Product.insertOrReplaceProductsFromDictionary(content! as NSDictionary , context: DatabaseHelper.sharedInstance.mainManagedObjectContext , searchString: self.searchString  )
                    self.moreProductsAvailable = newProducts.algoliaCount ?? newProducts.products.count > 0
                    
                    self.searchedProducts += newProducts.products
                    DatabaseHelper.sharedInstance.saveDatabase()
                    
                    for product in self.searchedProducts {
                        
                        if product.brandId == nil {
                            let removedObjectIndex = self.searchedProducts.firstIndex(of: product)!
                            // elDebugPrint("Object Remove Index:%@",removedObjectIndex)
                            self.searchedProducts.remove(at: removedObjectIndex)
                        }
                    }
                    if (self.grocery == nil && self.shouldShowGroceryActiveBasket == nil) {
                        
                        //filter search results and remove duplicates
                        var filteredIds = [Int : Bool]()
                        var filteredResults = [Product]()
                        
                        for product in self.searchedProducts {
                            
                            if filteredIds[product.productId.intValue] == nil {
                                
                                filteredIds[product.productId.intValue] = true
                                filteredResults.append(product)
                            }
                        }
                        self.searchedProducts = filteredResults
                        //  elDebugPrint("searched Products Array After Filtering Product ID:%@",self.searchedProducts.count)
                    }
                    
                    
                }
                
               
            }
            
            Thread.OnMainThread {
                self.isLoadingProducts = false
                self.refreshData()
                SpinnerView.hideSpinnerView()
            }
          
        }
        
            return
        

    }
    
    func refreshData() {
    }
   
    
    // MARK: ProductCellProtocol
    
    func productCellOnFavouriteClick(_ productCell: ProductCell, product: Product) {
        
    }
    
    func productCellOnProductQuickAddButtonClick(_ productCell: ProductCell, product: Product) {
        
        GoogleAnalyticsHelper.trackProductQuickAddAction()
       // GoogleAnalyticsHelper.trackProductQuickAddAction("", productName: product.name ?? "", brandName: product.brandName ?? "" , categoryName: "", subcategoryName: "")
        
        if self.grocery != nil {
            
            let isActive = self.checkIfOtherGroceryBasketIsActive(product)
            
            if isActive {
                if UserDefaults.isUserLoggedIn() {
                    //clear active basket and add product
                    ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    ElGrocerUtility.sharedInstance.resetBasketPresistence()
                    self.addProductToBasketFromQuickAdd(product)
                }else{
                    
                    
                    let SDKManager: SDKManagerType! = sdkManager
                    let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "NoCartPopUp") , header: localizedString("products_adding_different_grocery_alert_title", comment: ""), detail: localizedString("products_adding_different_grocery_alert_message", comment: ""),localizedString("grocery_review_already_added_alert_cancel_button", comment: ""),localizedString("select_alternate_button_title_new", comment: "") , withView: SDKManager.window!) { (buttonIndex) in
                        
                        if buttonIndex == 1 {
                            
                            //clear active basket and add product
                            ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                            ElGrocerUtility.sharedInstance.resetBasketPresistence()
                            self.addProductToBasketFromQuickAdd(product)
                        }
                    }

                }
            }else{
                self.addProductToBasketFromQuickAdd(product)
            }
            
        } else {
            self.addProductToBasketFromQuickAdd(product)
        }
    }
    
    func productCellOnProductQuickRemoveButtonClick(_ productCell:ProductCell, product:Product) {
        
        if self.grocery != nil {
            
            let isActive = self.checkIfOtherGroceryBasketIsActive(product)
            
            if isActive {
                
                if UserDefaults.isUserLoggedIn() {
                    //clear active basket and add product
                    ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    ElGrocerUtility.sharedInstance.resetBasketPresistence()
                   // self.addProductToBasketFromQuickAdd(product)
                }else{
                    ElGrocerAlertView.createAlert(localizedString("products_adding_different_grocery_alert_title", comment: ""),description: localizedString("products_adding_different_grocery_alert_message", comment: ""),positiveButton: localizedString("products_adding_different_grocery_alert_confirm_button", comment: ""),
                                                  negativeButton: localizedString("products_adding_different_grocery_alert_cancel_button", comment: ""),buttonClickCallback: { (buttonIndex:Int) -> Void in
                                                    if buttonIndex == 0 {
                                                        
                                                        //clear active basket and add product
                                                        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                                        ElGrocerUtility.sharedInstance.resetBasketPresistence()
                                                        self.addProductToBasketFromQuickAdd(product)
                                                    }
                                                  }).show()
                    
                }
                

            }else{
                self.removeProductToBasketFromQuickRemove(product)
            }
            
        } else {
            self.removeProductToBasketFromQuickRemove(product)
        }
    }
    
    func checkIfOtherGroceryBasketIsActive(_ selectedProduct:Product) -> Bool{
        
        //check if other grocery basket is active
        let isOtherGroceryBasketActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive(self.grocery!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let activeBasketGrocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if isOtherGroceryBasketActive && activeBasketGrocery != nil && activeBasketGrocery!.dbID != selectedProduct.groceryId {
              return true
        } else {
             return false
        }
    }
    
    func addProductToBasketFromQuickAdd(_ product:Product) {
         //implement in controller
    }
    
    func removeProductToBasketFromQuickRemove(_ product:Product){
        //implement in controller
    }
    
    func chooseReplacementWithProduct(_ product: Product) {
        
        let replacementVC = ElGrocerViewControllers.replacementViewController()
        replacementVC.currentAlternativeProduct = product
        replacementVC.cartGrocery = self.grocery
        self.navigationController?.pushViewController(replacementVC, animated: true)
    }
}

extension BasketBasicViewController: RegistrationControllerDelegate {
    //Hunain 19Dec2016
    // Old controller was RegistrationAddressViewController
    func registrationControllerDidRegisterUser(_ controller: RegistrationPersonalViewController) {
        
        controller.dismiss(animated: true, completion: nil)
        self.shoppingBasketView?.onCheckOutButtonClick(self.shoppingBasketView.checkoutButton)
    }
    
}

