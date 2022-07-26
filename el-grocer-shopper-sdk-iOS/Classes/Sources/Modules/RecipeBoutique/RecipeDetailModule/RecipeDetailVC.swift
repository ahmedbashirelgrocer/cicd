//
//  RecipeDetailVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 24/03/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import NBBottomSheet
import Storyly


class RecipeDetailVC: BasketBasicViewController {
    
    var source : String = "UnKnown"
    @IBOutlet weak var arrowImageView: UIImageView!{
        didSet{
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                arrowImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
        }
    }
    @IBOutlet var recipeDetailNavBar: UINavigationBar!{
        didSet{
            self.recipeDetailNavBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.recipeDetailNavBar.shadowImage = UIImage()
            self.recipeDetailNavBar.isTranslucent = true
            self.recipeDetailNavBar.backgroundColor = .clear
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                if let backImage = UIImage(name: "recipeBackArrow") {
                    recipeDetailNavBar.topItem?.leftBarButtonItem?.image? = backImage.withHorizontallyFlippedOrientation()
                }
            }
        }
    }
    var groceryController : GroceryFromBottomSheetViewController?
    
    lazy var currentUser : UserProfile? = {
        return UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }()
    
    private (set) var recipeDetialHeader : RecipeDetailHeader?=nil
    private (set) var HowToMakeViewHeader : HowToMakeView?=nil
    var addToBasketMessageDisplayed: (()->Void)?
    
    @IBOutlet var foorterView: AWView!{
        didSet{
            //MARK: For top shadow
            foorterView.layer.shadowOffset = CGSize(width: 0, height: -2)
            foorterView.layer.shadowOpacity = 0.16
            foorterView.layer.shadowRadius = 1
            foorterView.layer.cornerRadius = 8
            foorterView.layer.maskedCorners = [.layerMaxXMinYCorner , .layerMinXMinYCorner]
        }
    }
    @IBOutlet var cartButtonView: AWView!{
        didSet{
            cartButtonView.layer.backgroundColor = UIColor.navigationBarColor().cgColor
        }
    }
    @IBOutlet var lblItemsCount: UILabel!{
        didSet{
            lblItemsCount.setSubHead2RegWhiteStyle()
        }
    }
    @IBOutlet var lblGoToCart: UILabel!{
        didSet{
            lblGoToCart.setBody2BoldWhiteStyle()
            lblGoToCart.text = localizedString("lbl_go_to_cart_upperCase", comment: "")
        }
    }
    @IBOutlet var btnShare: UIButton!{
        didSet{
            btnShare.setTitle(localizedString("btn_share_title", comment: ""), for: UIControl.State())
            btnShare.setBody1BoldWhiteStyle()
        }
    }
    @IBOutlet var btnSave: UIButton!{
        didSet{
            btnSave.setTitle(localizedString("btn_save_title", comment: ""), for: UIControl.State())
            btnSave.setBody1BoldWhiteStyle()
        }
    }
    @IBOutlet var btnBack: UIButton!
    @IBOutlet weak var btnGoToCart: UIButton!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.bounces = false
            if headerView != nil{
                if headerView!.headerPageControl.numberOfPages > 1{
                    headerView?.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_WIDTH + 30)
                }else{
                    headerView?.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_WIDTH)
                }
            }
            //tableView.contentInset = UIEdgeInsets(top: CGFloat(ScreenSize.SCREEN_WIDTH + 30), left: 0, bottom: 0, right: 0)
        }
    }
    var sectionZeroHeight : CGFloat = 60.0
    var recipe : Recipe?  {
        didSet{
            elDebugPrint("set recipe")
        }
    }
    
    var groceryA : [Grocery]? = nil
    
    var headerView : stetchyRecipeHeaderView? =  stetchyRecipeHeaderView.loadFromNib()
    var shouldScroll : Bool = false
    
    var presenter = RecipePresenter()
    var itemsInCart : Int = 0
    
    var isCommingFromSignIn : Bool = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    let storylyView = StorylyView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad(view: self)
        
        //self.checkStolryStory()
        //self.setButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsRecipeDetailScreen)
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.setScreenName(topControllerName, screenClass: String(describing: self.classForCoder))
        }
        if self.navigationController is ElGrocerNavigationController {
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            if (self.navigationController as? ElGrocerNavigationController)?.navigationBar is ElGrocerNavigationBar{
                (self.navigationController as? ElGrocerNavigationController)?.setNavBarHidden(true)
            }else{
                self.navigationController?.navigationBar.isHidden = true
            }
            self.addCustomTitleViewWithTitleDarkShade(self.title ?? "" , true)
        }
        self.addBasketIcon()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.viewDidAppear(view: self)
        // self.tabBarController?.tabBar.isHidden = true
        //hide tabbar
        hideTabBar()
        if self.isCommingFromSignIn {
            self.isCommingFromSignIn = false
            presenter.loadRecipeDetailData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView?.headerCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc func addBasketIcon() {
        if ElGrocerUtility.sharedInstance.activeGrocery != nil {
            addBasketIconOverlay(self, grocery: ElGrocerUtility.sharedInstance.activeGrocery, shouldShowGroceryActiveBasket:  ElGrocerUtility.sharedInstance.activeGrocery != nil)
            self.basketIconOverlay?.grocery = ElGrocerUtility.sharedInstance.activeGrocery
//            self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
            self.refreshBasketIconStatus()
        }else{
            let barButton = self.tabBarController?.navigationItem.rightBarButtonItem as? BBBadgeBarButtonItem
            barButton?.badgeValue = "0"
            self.tabBarController?.tabBar.items?[4].badgeValue = nil
        }
    }
    
    
    override func backButtonClickedHandler() {
        self.backButtonClick()
    }
    
    func resetItemInCartCount(){
        self.itemsInCart = 0
    }
    func checkForItemsInCart(){
        if let ingrediants = recipe?.Ingredients{
            self.resetItemInCartCount()
            for ingrediant in ingrediants{
                getProductListFromIngrediats(ingrediant: [ingrediant]) { (products) in
                    if products.count > 0{
                        if let product = ShoppingBasketItem.checkIfProductIsInBasket(products[0], grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                            //productQuantity += product.count.intValue
                            self.itemsInCart = itemsInCart + 1
                            self.UpdateCartCount()
                        }
                    }
                    
                }
            }
        }
    }
    func UpdateCartCount(){
        if let ingrediants = recipe?.Ingredients{
            if itemsInCart <= ingrediants.count{
                if itemsInCart < 0{
                    itemsInCart = 0
                }
                if itemsInCart == 0{
                    self.lblItemsCount.text = "(" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(itemsInCart) ") + localizedString("lbl_item_multiple", comment: "") + ")"
                    setButtonState(enabled: false)
                }else{
                    if itemsInCart == 1{
                        self.lblItemsCount.text = "(" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(itemsInCart) ") + localizedString("lbl_item_singular", comment: "") + ")"
                    }else{
                        self.lblItemsCount.text = "(" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(itemsInCart) ") + localizedString("lbl_item_multiple", comment: "") + ")"
                    }
                    setButtonState(enabled: true)
                }
            }else{
                itemsInCart = ingrediants.count
            }
        }
    }
    
    func setButtonState(enabled : Bool = false){
        if enabled{
            self.cartButtonView.backgroundColor = UIColor.navigationBarColor()
            self.btnGoToCart.isEnabled = enabled
        }else{
            self.cartButtonView.backgroundColor = UIColor.disableButtonColor()
            self.btnGoToCart.isEnabled = enabled
        }
    }
    
    func checkStolryStory () {
        
        guard recipe?.recipeStorylySlug.count ?? 0 > 0 else {
            return
        }
        guard ElGrocerUtility.sharedInstance.appConfigData != nil else {return}
        guard ElGrocerUtility.sharedInstance.appConfigData.storlyInstanceId.count > 0 else {return}
        
        var someSet = Set<String>()
        someSet.insert(recipe?.recipeStorylySlug ?? "")
        
        let segment = StorylySegmentation.init(segments: someSet)
        let story = StorylyInit.init(storylyId: ElGrocerUtility.sharedInstance.appConfigData.storlyInstanceId , segmentation: segment)
        storylyView.translatesAutoresizingMaskIntoConstraints = false
        storylyView.languageCode = ElGrocerUtility.sharedInstance.isArabicSelected() ? "AR" : "EN"
        storylyView.storylyInit = story
        self.view.addSubview(storylyView)
        storylyView.delegate = self
        storylyView.rootViewController = self
        storylyView.storyItemIconBorderColor = [.navigationBarColor() , .navigationBarColor()]
        storylyView.storyGroupIconBorderColorNotSeen = [.navigationBarColor() , .navigationBarColor()]
        storylyView.storyGroupPinIconColor = .navigationBarColor()
      //  storylyView.storyGroupIconForegroundColors = [.navigationBarColor() , .navigationBarColor()]
        
        
        
    }
    
    func addImageHeader () {
        if headerView != nil{
            if headerView!.headerPageControl.numberOfPages > 1{
                headerView?.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_WIDTH + 30)
            }else{
                headerView?.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_WIDTH)
            }
        }

        
        headerView?.clipsToBounds = true
        
        headerView?.translatesAutoresizingMaskIntoConstraints = true
        
        if headerView != nil {
            self.view.addSubview(headerView!)
        }
        
        headerView?.registerCell()
        if headerView != nil{
            if headerView!.headerPageControl.numberOfPages > 1{
                tableView.contentInset = UIEdgeInsets(top: CGFloat(ScreenSize.SCREEN_WIDTH + 30), left: 0, bottom: 0, right: 0)
            }else{
                tableView.contentInset = UIEdgeInsets(top: CGFloat(ScreenSize.SCREEN_WIDTH), left: 0, bottom: 0, right: 0)
            }
        }
        
        
       
        if recipe?.recipeID != -1{
            if recipe!.isSaved{
                self.btnSave.setImage(UIImage(name: "saveFilled"), for: .normal)
            }else{
                self.btnSave.setImage(UIImage(name: "saveUnfilled"), for: .normal)
            }
        }
        
        
        self.view.bringSubviewToFront(self.recipeDetailNavBar)
        
    }
    
    fileprivate func setHeaderImage(_ urlString : String? , inImageView : UIImageView?=nil ) {
        
        guard urlString != nil && urlString!.range(of: "http") != nil && inImageView != nil else {
            return
        }
        inImageView?.clipsToBounds = true
        
        
        
        inImageView!.sd_setImage(with: URL(string: urlString! ), placeholderImage: productPlaceholderPhoto , options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            
            if cacheType == SDImageCacheType.none {
                UIView.transition(with: inImageView! , duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                    inImageView?.image = image
                }, completion: nil)
            }
            guard error == nil else {return}
            inImageView?.image = image
            
        })
        
    }
    
    fileprivate func setAddCartButtonIntraction (_ isEnable : Bool) {
        
        //        self.btnGoToCart.isUserInteractionEnabled = isEnable
        //
        //        if isEnable {
        //            self.btnGoToCart.alpha = 1.0
        //        }else{
        //            self.btnGoToCart.alpha = 0.5
        //        }
        
    }
    
    override func shareButtonClick() {
        
        if let recipeUse = self.recipe {
            if let currentChef = recipeUse.recipeChef {
                if let deeplink = recipeUse.recipeDeepLink {
                    if !deeplink.isEmpty {
                        if let recipeID = recipeUse.recipeID {
                            FireBaseEventsLogger.trackRecipeShare(recipeName: recipeUse.recipeName ?? "No Name", recipeID: "\(recipeID)")
                        }
                        self.showActivityViewWithShareLink(link: deeplink)
                        return
                    }
                }
                _ = SpinnerView.showSpinnerViewInView(self.view)
                DynamicLinksHelper.sharedInstance.createDynamicLinkWith(self.recipe?.recipeID , instaID : currentChef.chefInsta!) { [weak self ](shortURLString) in
                    SpinnerView.hideSpinnerView()
                    guard let self = self else {return}
                    GenericClass.print(shortURLString)
                    if shortURLString.isNotEmtpy() {
                        self.showActivityViewWithShareLink(link: shortURLString)
                    }
                }
            }
            GoogleAnalyticsHelper.trackRecipeShareClick(recipeUse.recipeName! + " Share")
            
        }
        
    }
    
    func showActivityViewWithShareLink(link : String) -> Void {
        
        if let recipeUse = self.recipe {
            if let _ = recipeUse.recipeChef {
                
                let recipeTitle = (self.recipe?.recipeName)! + " " + localizedString("recipe_share_by", comment: "") + " " + (self.recipe?.recipeChef?.chefName)! + localizedString("recipe_share_onElgrocer", comment: "")
                let items = [recipeTitle , URL(string: link)!] as [Any]
                let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                present(ac, animated: true)
            }
        }
    }
    
    override func backButtonClick() {
        
        
        for vc in  self.navigationController?.viewControllers ?? [] {
            if vc is ElgrocerParentTabbarController {
                (vc.navigationController as? ElgrocerGenericUIParentNavViewController)?.popToRootViewController(animated: true)
                (vc.navigationController as? ElgrocerGenericUIParentNavViewController)?.resetToWhite()
                (vc.navigationController as? ElgrocerGenericUIParentNavViewController)?.setBasketButtonHidden(false)
                (vc.navigationController as? ElgrocerGenericUIParentNavViewController)?.updateBadgeValue()
                
                // self.tabBarController?.navigationController?.setNavigationBarHidden(false, animated: false)
                return
            }
        }
        guard let navCount = self.navigationController else {
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        if  navCount.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    @objc func addIngrediantButtonClicked(sender : UIButton){
        let index = sender.tag
        if index > 0 && tableView.numberOfSections > 2{
            if let addToCartIngrediant = self.recipe?.Ingredients?[index - 1]{
                if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 1)) as? IngrediantsCell{
                    if let recipee = self.recipe{
                        cell.addIngrediantHandler(recipe: recipee, ingrediant: addToCartIngrediant, grocery: self.grocery , view: self)
                    }
                }
                
            }
            
        }
        
    }
    
    
    func getRetailersListForIngreadients(_ grocery : Grocery?) -> [Grocery] {
        
        if grocery != nil {
            
            let currentGrocery = grocery!
            
            var isGoWithCurrentGrocery = false
            if let isRetailIDAvailable = (self.recipe?.recipeRetailerIds?.contains(NSNumber(value: Int32(currentGrocery.dbID ) ?? -1))) {
                isGoWithCurrentGrocery = isRetailIDAvailable
            }
            
            if !isGoWithCurrentGrocery {
                if let isRetailIDAvailable = (self.recipe?.recipeStoreTypes?.contains(currentGrocery.retailerType )) {
                    isGoWithCurrentGrocery = isRetailIDAvailable
                }
            }
            if !isGoWithCurrentGrocery {
                if let retailerGroupAvailable = (self.recipe?.recipeRetailerGroups?.contains(currentGrocery.groupId)) {
                    isGoWithCurrentGrocery = retailerGroupAvailable
                }
            }
            if !isGoWithCurrentGrocery {
                let storeTypeA =  self.recipe?.recipeStoreTypes?.filter({ (data) -> Bool in
                    return (currentGrocery.storeType.contains(data) )
                })
                if storeTypeA?.count ?? 0 > 0 {
                    isGoWithCurrentGrocery = true
                }
            }
            
            if isGoWithCurrentGrocery {
                return [currentGrocery]
            }
            
        }
        
        
        
        
        
        let filterA = ElGrocerUtility.sharedInstance.groceries.filter { (currentGrocery) -> Bool in
            var isGoWithCurrentGrocery = false
            if let isRetailIDAvailable = (self.recipe?.recipeRetailerIds?.contains(NSNumber(value: Int32(currentGrocery.dbID ) ?? -1))) {
                isGoWithCurrentGrocery = isRetailIDAvailable
            }
            
            if !isGoWithCurrentGrocery {
                if let isRetailIDAvailable = (self.recipe?.recipeStoreTypes?.contains(currentGrocery.retailerType )) {
                    isGoWithCurrentGrocery = isRetailIDAvailable
                }
            }
            if !isGoWithCurrentGrocery {
                if let retailerGroupAvailable = (self.recipe?.recipeRetailerGroups?.contains(currentGrocery.groupId)) {
                    isGoWithCurrentGrocery = retailerGroupAvailable
                }
            }
            
            if !isGoWithCurrentGrocery {
                let storeTypeA =  self.recipe?.recipeStoreTypes?.filter({ (data) -> Bool in
                    return (currentGrocery.storeType.contains(data) )
                })
                if storeTypeA?.count ?? 0 > 0 {
                    isGoWithCurrentGrocery = true
                }
            }
            return isGoWithCurrentGrocery
        }
        
        return filterA
        
    }
    
    @objc func addAllIngrediantsButtonClicked(){
        
        if let addToCartRecipe = self.recipe{
            presenter.addAllIngrediantsToCartHandler(recipe: addToCartRecipe,ingrediants: addToCartRecipe.Ingredients , grocery: self.grocery)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.backButtonClick()
    }
    @IBAction func shareButonPressed(_ sender: Any) {
        shareButtonClick()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        presenter.saveButtonHandler()
    }
    
    
    @IBAction func goToCartAction(_ sender: Any) {
        
        //        self.navigationController?.dismiss(animated: true, completion: nil)
        
        
        if let vcA = self.navigationController?.viewControllers {
            
            
            
            var detailVc : UIViewController? = nil
            for vc in vcA {
                if vc is RecipeDetailVC {
                    detailVc = vc
                    break
                }
                
            }
            for vc in vcA {
                if vc is GenericStoresViewController {
                    detailVc = nil
                    break
                }
                
            }
            if detailVc != nil {
                self.navigationController?.dismiss(animated: true) {
                    if let topVc = UIApplication.topViewController() {
                        if topVc is GlobalSearchResultsViewController {
                            topVc.dismiss(animated: false) {
                                if let newTopVC = UIApplication.topViewController() {
                                    newTopVC.tabBarController?.selectedIndex = 4
                                }
                            }
                        }else{
                            
                            topVc.tabBarController?.tabBar.isHidden = false
                            topVc.tabBarController?.selectedIndex = 4
                        }
                        
                    }
                }
                return
                
            }
            
        }
        
        
        
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            let vc = self.navigationController?.viewControllers[0]
            if vc is RecipeBoutiqueListVC {
                self.navigationController?.dismiss(animated: true) {
                    if let topVc = UIApplication.topViewController() {
                        topVc.tabBarController?.selectedIndex = 4
                    }
                }
                return
            }
            self.tabBarController?.selectedIndex = 4
            self.navigationController?.popViewController(animated: false)
        }else{
            self.dismiss(animated: true) {
                if let topVc = UIApplication.topViewController() {
                    var finalVc = topVc
                    if let controllerA = (topVc.presentingViewController as? UINavigationController)?.viewControllers {
                        if controllerA.count > 0 {
                            let controller = controllerA[0]
                            if controller is GenericStoresViewController {
                                finalVc = controller
                            }
                        }
                    }
                    finalVc.tabBarController?.selectedIndex = 4
                }
            }
        }
        
        
    }
    func getProductListFromIngrediats(ingrediant : [RecipeIngredients]? , completion :  ([Product]) -> Void) {
        
        var isCurrentSelected = false
        let groceryA =  self.getRetailersListForIngreadients(self.grocery)
        if groceryA.count > 0 {
            let currentGrocey = self.grocery
            let selectGrocey = groceryA[0]
            if currentGrocey?.dbID == selectGrocey.dbID {
                isCurrentSelected = true
            }
            
        }
        guard isCurrentSelected else {
            completion([])
            return
        }
        
        
        var productA = [Product]()
        
        if let data = ingrediant{     //self.recipe?.Ingredients {
            for ingrediants : RecipeIngredients in data {
                
                
                var priceDict : [String:Any] = [:]
                if let priceData = ingrediants.recipeIngredientsPrice {
                    priceDict["price_full"]  = priceData
                    priceDict["price_currency"] = CurrencyManager.getCurrentCurrency()
                }
                
                var brandDict : [String:Any] = [:]
                brandDict["id"] = ingrediants.recipeIngredientsBrandID
                brandDict["name"] = ingrediants.recipeIngredientsBrandName
                brandDict["slug"] = ingrediants.recipeIngredientsBrandNameEn
                
                
                var categoriesA : [[String:Any]] = []
                var categoriesDict : [String:Any] = [:]
                categoriesDict["id"] = ingrediants.recipeIngredientsCategoryID
                categoriesDict["name"] = ingrediants.recipeIngredientsCategoryName
                categoriesDict["slug"] = ingrediants.recipeIngredientsCategoryNameEn
                categoriesA.append(categoriesDict)
                
                
                
                var subcategoriesA : [[String:Any]] = []
                var subcategoriesDict : [String:Any] = [:]
                subcategoriesDict["id"] = ingrediants.recipeIngredientsSubCategoryID
                subcategoriesDict["name"] = ingrediants.recipeIngredientsSubCategoryName
                subcategoriesDict["slug"] = ingrediants.recipeIngredientsSubCategoryNameEn
                subcategoriesA.append(subcategoriesDict)
                
                
                
                if let retailerID = self.grocery?.dbID {
                    
                    let productDict = ["id" : ingrediants.recipeIngredientsProductID!  , "retailer_id" : retailerID , "name" : ingrediants.recipeIngredientsName! , "image_url" : ingrediants.recipeIngredientsImageURL! , "price" : priceDict as NSDictionary , "brands" : brandDict as NSDictionary , "subcategories" : subcategoriesA , "categories" : subcategoriesA , "is_available" : ingrediants.recipeIngredientsIsAvailable! , "is_published" : ingrediants.recipeIngredientsIsPublished! ] as [String : Any]
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    context.performAndWait ({
                        let product = Product.createProductFromDictionary(productDict as NSDictionary, context: context)
                        productA.append(product)
                    })
                }
            }
        }
        completion(productA)
        // return productA
    }
    
    func addToCartCompleted() {
        
        
        ElGrocerUtility.sharedInstance.delay(1.0) {
            let msg = localizedString("product_added_to_cart", comment: "")
            ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
        }
        
        self.AddToLocalDB()
        self.sendAddedMessageCall()
        if tableView.numberOfSections > 2 {
            self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        }
        self.checkForItemsInCart()
        //presenter.updateItemsCount()
        
    }
    
    func goToBasket() {
        
        let basketController = ElGrocerViewControllers.myBasketViewController()
        basketController.showShoppingBasket(delegate: self, shouldShowGroceryActiveBasket: false, selectedGroceryForItems: grocery, notAvailableProducts: notAvailableItems, availableProductsPrices: availableProductsPrices)
        self.navigationController?.pushViewController(basketController, animated: true)
        
    }
    
    // MARK:- Grocery selection delegate
    
    override func updateDataWithNewGrocery(grocery: Grocery) {
        self.grocery = grocery
        ElGrocerUtility.sharedInstance.activeGrocery = grocery
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsRecipeDetailScreen)
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.setScreenName(topControllerName, screenClass: String(describing: self.classForCoder))
        }
        if let addToCartRecipe = self.recipe  {
            if currentUser != nil {
                _ = SpinnerView.showSpinnerViewInView(self.view)
                //sab
                presenter.interactor.dataHandler.addRecipeToCart(retailerID: self.grocery?.dbID , recipe: addToCartRecipe)
                ElGrocerUtility.sharedInstance.delay(1.0) {
                    let msg = localizedString("product_added_to_basket", comment: "")
                    ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "BasketAvailable") , -1 , false) { (sender , index , isUnDo) in  }
                }
            }else{
                self.addToCartCompleted()
            }
            
            GoogleAnalyticsHelper.trackRecipeAddToCartClick()
            GoogleAnalyticsHelper.trackRecipeAddToCartClick(addToCartRecipe.recipeName!)
        }
        
    }
    
    override func grocerySelectionController(_ controller: GrocerySelectionViewController, didSelectGrocery grocery: Grocery, notAvailableItems:[Int], availableProductsPrices:NSDictionary?) {
        
        ElGrocerUtility.sharedInstance.activeGrocery = grocery
        self.grocery = grocery
        
        ElGrocerUtility.sharedInstance.delay(0.5) {
            controller.dismiss(animated: false, completion: { () -> Void in
            })
        }
        return
        
    }
    
    func AddToLocalDB() {
        
        FireBaseEventsLogger.trackAddRecipe()
        
        let context = DatabaseHelper.sharedInstance.groceryManagedObjectContext
        // save record in recipe cart
        // let userProfile = UserProfile.getUserProfile(context)
        if let retailerID = self.grocery?.dbID {
            
            var ingredientIDsA = [NSNumber]()
            for ingrediants : RecipeIngredients in (self.recipe?.Ingredients)! {
                let productID = NSNumber(value: ingrediants.recipeIngredientsProductID ?? -1)
                ingredientIDsA.append(productID)
                let productQuantity = 1
                var priceDict : [String:Any] = [:]
                if let priceData = ingrediants.recipeIngredientsPrice {
                    priceDict["price_full"]  = priceData
                    priceDict["price_currency"] = CurrencyManager.getCurrentCurrency()
                }
                
                var brandData : [String:Any] = [:]
                if let brandID = ingrediants.recipeIngredientsBrandID {
                    brandData["id"]  = brandID
                    brandData["name"] = ingrediants.recipeIngredientsBrandName
                    brandData["slug"] = ingrediants.recipeIngredientsBrandNameEn
                }
                
                
                var categoriesA : [[String:Any]] = []
                var categoriesDict : [String:Any] = [:]
                categoriesDict["id"] = ingrediants.recipeIngredientsCategoryID
                categoriesDict["name"] = ingrediants.recipeIngredientsCategoryName
                categoriesDict["slug"] = ingrediants.recipeIngredientsCategoryNameEn
                categoriesA.append(categoriesDict)
                
                
                
                var subcategoriesA : [[String:Any]] = []
                var subcategoriesDict : [String:Any] = [:]
                subcategoriesDict["id"] = ingrediants.recipeIngredientsSubCategoryID
                subcategoriesDict["name"] = ingrediants.recipeIngredientsSubCategoryName
                subcategoriesDict["slug"] = ingrediants.recipeIngredientsSubCategoryNameEn
                subcategoriesA.append(subcategoriesDict)
                
                
                //                let sizeUnit = "\(ItemsCollectionViewCell.convertToHumanReadable(ingrediants.recipeIngredientsQuantity ?? 0.0)) \(String(describing: ingrediants.recipeIngredientsQuantityUnit ?? ""))"
                let sizeUnit = "\(ingrediants.recipeIngredientsQuantity) \(String(describing: ingrediants.recipeIngredientsQuantityUnit ?? ""))"
                
                let productDict = ["brand_id" : ingrediants.recipeIngredientsBrandID! , "subcategory_id" :  ingrediants.recipeIngredientsSubCategoryID!    ,  "id" : ingrediants.recipeIngredientsProductID!  , "retailer_id" : retailerID , "name" : ingrediants.recipeIngredientsName! , "image_url" : ingrediants.recipeIngredientsImageURL! , "price" : priceDict as NSDictionary , "brand" : brandData as NSDictionary , "subcategories" : subcategoriesA , "categories" : subcategoriesA  , "is_available" : ingrediants.recipeIngredientsIsAvailable! , "is_published" : ingrediants.recipeIngredientsIsPublished! , "is_p" : ingrediants.recipeIngredientsIsPromotion! , "size_unit" :  sizeUnit ] as [String : Any]
                
                let product = Product.createProductFromDictionary(productDict as NSDictionary, context: context)
                
                if let recipeName = self.recipe?.recipeName {
                    ElGrocerEventsLogger.sharedInstance.addToCart(product: product, recipeName, self.recipe?.recipeChef?.chefName, false, nil , "" , ingrediants.recipeIngredientsName!)
                }
                ShoppingBasketItem.addOrUpdateProductInBasketWithIncrement(product, grocery: grocery, brandName:nil, quantity: productQuantity , context: context)
            }
            //            if currentUser != nil {
            context.performAndWait ({
                
                let userDBID = currentUser != nil ? currentUser?.dbID as! Int64 : 0
                
                
                if let recipeObj =  RecipeCart.createOrUpdateRecipeCart(dbID: userDBID , retailerID: Int64(retailerID)! , recipeID: (self.recipe?.recipeID)!, ingredients: ingredientIDsA, recipeName: (self.recipe?.recipeName)! , context: context) {
                    
                    elDebugPrint("Object Created success ")
                    elDebugPrint(recipeObj.dbID)
                    elDebugPrint(recipeObj.recipeID)
                    elDebugPrint(recipeObj.retailerID)
                }else{
                    elDebugPrint("Failed")
                }
            })
            //}
            
        }
        
    }
    func sendAddedMessageCall(){
        if let clouser =  self.addToBasketMessageDisplayed {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
            clouser()
        }
    }
}


extension RecipeDetailVC : UIScrollViewDelegate {
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if headerView is stetchyRecipeHeaderView{
            var y = -scrollView.contentOffset.y
            if shouldScroll{
                y = -scrollView.contentOffset.y
                let height = max(y, 60 + 30)
                if height < ScreenSize.SCREEN_WIDTH {
                    headerView?.headerPageControl.visibility = .gone
                    if let cell = headerView?.headerCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? recipeCustomHeaderCVC{
                        cell.btnPlay.isHidden = true
                    }
                }else{
                    if headerView != nil{
                        if headerView!.headerPageControl.numberOfPages > 1{
                            headerView?.headerPageControl.visibility = .visible
                        }else{
                            headerView?.headerPageControl.visibility = .gone
                        }
                    }
                    if let cell = headerView?.headerCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? recipeCustomHeaderCVC{
                        cell.btnPlay.isHidden = !(headerView?.storylyView != nil && headerView?.storyGroup != nil)
                    }
                }
                
                // self.headerView?.heightAnchor.constraint(equalTo: height  , multiplier: 1)
                if headerView != nil{
                    if headerView!.headerPageControl.numberOfPages > 1{
                        self.headerView?.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH + 30, height: height)
                    }else{
                        self.headerView?.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: height)
                    }
                }
                //self.headerView?.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH + 30, height: height)
                self.headerView?.headerCollectionView.performBatchUpdates({ () -> Void in
                    let ctx = UICollectionViewFlowLayoutInvalidationContext()
                    ctx.invalidateFlowLayoutDelegateMetrics = true
                    self.headerView?.headerCollectionView.collectionViewLayout.invalidateLayout(with: ctx)
                }) { (_: Bool) -> Void in
                    if  self.headerView?.headerPageControl.visibility == .gone {
                        if let cell = self.headerView?.headerCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? recipeCustomHeaderCVC{
                            //cell.btnPlay.isHidden = (self.headerView?.storylyView != nil && self.headerView?.storyGroup != nil)
                            if self.headerView != nil{
                                if  height >= ScreenSize.SCREEN_WIDTH {
                                    cell.btnPlay.isHidden = !(self.headerView?.storylyView != nil && self.headerView?.storyGroup != nil)
                                }else{
                                    cell.btnPlay.isHidden = true
                                }
                            }
                            
                        }
                    }else{
                        if let cell = self.headerView?.headerCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? recipeCustomHeaderCVC{
                            cell.btnPlay.isHidden = !(self.headerView?.storylyView == nil && self.headerView?.storyGroup == nil)
                        }
                    }
                    self.headerView?.headerCollectionView.invalidateIntrinsicContentSize()
                }
                // self.headerView?.headerCollectionView.collectionViewLayout.invalidateLayout()
                // self.headerView?.headerCollectionView.reloadData()
                
                
            }else{
                shouldScroll = true
                y = -scrollView.contentOffset.y
                let height = max(y, ScreenSize.SCREEN_WIDTH)
                scrollView.contentOffset.y = -height
                if headerView != nil{
                    if headerView!.headerPageControl.numberOfPages > 1{
                        self.headerView?.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH + 30, height: height)
                    }else{
                        self.headerView?.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: height)
                    }
                }
                self.headerView?.headerCollectionView.performBatchUpdates({ () -> Void in
                    let ctx = UICollectionViewFlowLayoutInvalidationContext()
                    ctx.invalidateFlowLayoutDelegateMetrics = true
                    self.headerView?.headerCollectionView.collectionViewLayout.invalidateLayout(with: ctx)
                }) { (_: Bool) -> Void in
                    if  self.headerView?.headerPageControl.visibility == .gone {
                        
                        if let cell = self.headerView?.headerCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? recipeCustomHeaderCVC{
                            //cell.btnPlay.isHidden = (self.headerView?.storylyView != nil && self.headerView?.storyGroup != nil)
                            if self.headerView != nil{
                                if height >= ScreenSize.SCREEN_WIDTH {
                                    cell.btnPlay.isHidden = !(self.headerView?.storylyView != nil && self.headerView?.storyGroup != nil)
                                }else{
                                    cell.btnPlay.isHidden = true
                                }
                            }
                        }
                        
                    } else {
                        
                        if let cell = self.headerView?.headerCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? recipeCustomHeaderCVC {
                            cell.btnPlay.isHidden = !(self.headerView?.storylyView == nil && self.headerView?.storyGroup == nil)
                        }
                        
                    }
                    self.headerView?.headerCollectionView.invalidateIntrinsicContentSize()
                }
            }
        }
        
    }
    
}

extension RecipeDetailVC : UITableViewDelegate , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.presenter.heightForFooter(section: section)
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.presenter.viewForFooter()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.presenter.heightForRowAtIndexPath(indexPath: indexPath, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.numberOfRowsInSection(section: section)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //sab
        if indexPath.section == 0{
            let cell : recipeDetailCell = tableView.dequeueReusableCell(withIdentifier: "recipeDetailCell", for: indexPath) as! recipeDetailCell
            if recipe != nil{
                cell.configureCell(recipe!)
            }
            cell.chefClickedSelected = { [weak self] (chef) in
                guard self != nil else {return}
                guard let chefToPass = chef else {
                    return
                }
                let recipeFilter : FilteredRecipeViewController = ElGrocerViewControllers.recipeFilterViewController()
                recipeFilter.dataHandler.setFilterChef(chef)
                recipeFilter.dataHandler.setFilterRecipeCategory(nil)
                var groceryArr = ElGrocerUtility.sharedInstance.groceries
                if let dataGroceryA = self?.groceryA {
                    groceryArr = dataGroceryA
                }
                recipeFilter.groceryA = groceryArr
                recipeFilter.chef = chefToPass
                recipeFilter.vcTitile = chef?.chefName ?? ""
                recipeFilter.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(recipeFilter, animated: true)
            }
            return cell
        }else if indexPath.section == 1{
            if indexPath.row == 0{
                let cell : GenericViewTitileTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
                cell.configureCell(title: localizedString("lbl_ingrediants_title", comment: ""))
                return cell
            }
            
            if indexPath.row == tableView.numberOfRows(inSection: 1) - 1{
                let cell : AddAllIngrediantsCell = tableView.dequeueReusableCell(withIdentifier: "AddAllIngrediantsCell", for: indexPath) as! AddAllIngrediantsCell
                cell.btnAddAllIngrediants.addTarget(self, action: #selector(addAllIngrediantsButtonClicked), for: .touchUpInside)
                return cell
            }
            
            let cell : IngrediantsCell = tableView.dequeueReusableCell(withIdentifier: "IngrediantsCell", for: indexPath) as! IngrediantsCell
            if let ingrediants = recipe?.Ingredients{
                cell.btnAddRemoveIngrediant.tag = indexPath.row
                cell.configureCell(ingrediant: ingrediants[indexPath.row - 1] , grocery : self.grocery , view: self) //-1 for heading
                cell.btnAddRemoveIngrediant.addTarget(self, action: #selector(addIngrediantButtonClicked(sender:)), for: .touchUpInside)
            }
            return cell
        }
        
        
        if  indexPath.section == 2 && indexPath.row == 0{
            let cell : GenericViewTitileTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
            cell.configureCell(title: localizedString("lbl_preparation_title", comment: ""))
            return cell
        }
        
        let cell : RecipePreparationCell = tableView.dequeueReusableCell(withIdentifier: "RecipePreparationCell", for: indexPath) as! RecipePreparationCell
        if recipe != nil && recipe?.Steps?[indexPath.row - 1].recipeStepDetail?.isEmpty == false{
            cell.configureCell(step: (recipe?.Steps?[indexPath.row - 1])!, count: indexPath.row) //-1 beacause index 0 is heading
        }
        
        return cell
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}
extension RecipeDetailVC : UIGestureRecognizerDelegate {}
extension RecipeDetailVC {
    
    func fetchData(_ productsToCheck : [Product] , isSingleProduct : Bool = false , completetion : @escaping ([Grocery]) -> Void) {
        ElGrocerApi.sharedInstance.getAllGroceries(DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)! , completionHandler: { (result) in
            switch result {
                case .success(let response):
                    let responseData = Grocery.insertGroceriesWithNotAvailableProducts(response, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    let groceries = responseData.groceries
                    if groceries.count == 0 {
                        self.presenter.showBottomSheet(localizedString("No_Store_For_Recipe_title", comment: "") , grocery: [], isError: true, ingredients: [])
                    }else{
                        if isSingleProduct{
                            completetion(responseData.groceries)
                        }else{
                            self.presenter.showBottomSheet(self.recipe?.recipeName ?? "" , grocery: responseData.groceries, ingredients: [] )
                        }
                        
                    }
                case .failure(let error):
                    self.groceryController?.dismiss(animated: true, completion: nil)
                    error.showErrorAlert()
            }
        })
    }
    
}
extension RecipeDetailVC: PresenterToViewRecipeProtocol{
    
    func setUpApearance(){
        
        
        self.btnSave.contentHorizontalAlignment = .trailing
        
        
        self.title = localizedString("title_recipe_list", comment: "")
        
        if ((self.recipe?.recipeName) != nil) {
            _ = SpinnerView.showSpinnerViewInView(self.view)
            self.addBackButtonWithCrossIcon()
        }else{
            self.addBackButton()
        }
        self.addShareButton()
        
        self.view.backgroundColor = .white
        self.tableView.backgroundColor = .white
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        self.setAddCartButtonIntraction(false)
        
        self.edgesForExtendedLayout = UIRectEdge.all
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            if self.btnBack != nil {
                self.btnBack.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.btnBack.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            }
        }
    }
    func setProductNumber(){
        
//        self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
        self.basketIconOverlay?.grocery = self.grocery
    }
    
    func reloadData() {
        if self.recipe != nil {
            self.headerView?.configureHeader(recipe : self.recipe!)
        }
        self.tableView.reloadData()
    }
    
    func initailCellRegistration() {
        self.tableView.register(UINib(nibName: "recipeDetailCell", bundle: Bundle.resource), forCellReuseIdentifier: "recipeDetailCell")
        self.tableView.register(UINib(nibName: "IngrediantsCell", bundle: Bundle.resource), forCellReuseIdentifier: "IngrediantsCell")
        self.tableView.register(UINib(nibName: "AddAllIngrediantsCell", bundle: Bundle.resource), forCellReuseIdentifier: "AddAllIngrediantsCell")
        self.tableView.register(UINib(nibName: "RecipePreparationCell", bundle: Bundle.resource), forCellReuseIdentifier: "RecipePreparationCell")
        self.tableView.register(UINib(nibName: KGenericViewTitileTableViewCell, bundle: Bundle.resource), forCellReuseIdentifier: KGenericViewTitileTableViewCell)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.separatorStyle = .none
        
    }
    
}
extension RecipeDetailVC : StorylyDelegate {
    
  
    
    func storylyLoaded(_ storylyView: StorylyView, storyGroupList: [StoryGroup], dataSource: StorylyDataSource) {
        elDebugPrint("")
        
        
        headerView?.storyGroup = nil
        headerView?.storylyView = nil
        if storyGroupList.count > 0 {
            let grocerp = storyGroupList[0]
            if headerView is stetchyRecipeHeaderView{
                headerView?.storyGroup = grocerp
                headerView?.storylyView = storylyView
                
                elDebugPrint("grocerp.title : \(grocerp.title)")
                elDebugPrint(recipe?.recipeStorylySlug)
            }
        }
    }
    
    func storylyLoadFailed(_ storylyView: StorylyView, errorMessage: String) {
        elDebugPrint("")
    }
    
    
    
    
}
