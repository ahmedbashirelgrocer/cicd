//
//  RecipeDetailViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 16/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import NBBottomSheet
import SDWebImage

class RecipeDetailViewController: BasketBasicViewController   {
    
    var groceryController : GroceryFromBottomSheetViewController?
    lazy var dataHandler : RecipeDataHandler = {
        let dataH = RecipeDataHandler()
        dataH.delegate = self
        return dataH
    }()
    lazy var currentUser : UserProfile? = {
       return UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }()
    private (set) var recipeDetialHeader : RecipeDetailHeader?=nil
    private (set) var HowToMakeViewHeader : HowToMakeView?=nil
    var addToBasketMessageDisplayed: (()->Void)?
    
    @IBOutlet weak var btnAddToCart: UIButton!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            //tableView.contentInset = UIEdgeInsets(top: CGFloat(KRecipeDetailHeaderHeight), left: 0, bottom: 0, right: 0)
            //tableView.bounces = false
        }
    }
    var sectionZeroHeight : CGFloat = 60.0
    var recipe : Recipe?  {
        didSet{
            debugPrint("set recipe")
        }
    }
    //let headerView = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_WIDTH + 30))
    
    lazy var headerView : stetchyRecipeHeaderView = {
        let View = stetchyRecipeHeaderView.loadFromNib()
        return View!
    }()
    
    var shouldScroll : Bool = false
    
    //var cachedImageViewSize: CGRect!
    // var defaultOffSet = CGPoint.zero
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        self.setUpApearance()
        self.setProductNumber()
        self.initailCellRegistration()
        self.getRecipeDetialData()
        self.reloadData()
        
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
//            (self.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            //(self.navigationController as? ElGrocerNavigationController)?.setNavBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setBackgroundColorForBar(UIColor.clear)
            self.navigationController?.navigationBar.tintColor = UIColor.clear
            
            self.addCustomTitleViewWithTitleDarkShade(self.title ?? "" , true)
        }
        
    }

    override func backButtonClickedHandler() {
        self.backButtonClick()
    }
    
    func setUpApearance(){
        
        self.title = NSLocalizedString("title_recipe_list", comment: "")
        
        if (self.recipe?.recipeName?.isEmpty)! {
            _ = SpinnerView.showSpinnerViewInView(self.view)
              self.addBackButtonWithCrossIcon()
        }else{
            self.addBackButton(isGreen: false)
        }
        self.addShareButton()
  
        
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
      
        self.btnAddToCart.setBackgroundColor(UIColor.navigationBarColor(), forState: .normal)
        self.setAddCartButtonIntraction(false)
        
        self.btnAddToCart.setTitle(NSLocalizedString("btn_Recipe_Add_To_Cart_Title", comment: ""), for: .normal)
    
    }
    
    func addImageHeader () {
        
        //let headerView = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 260))
        //self.headerView.clipsToBounds = true
        //self.setHeaderImage(recipe?.recipeImageURL, inImageView: headerView.imageView)
        headerView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_WIDTH + 30)
        headerView.clipsToBounds = true
        self.view.addSubview(headerView)
        headerView.registerCell()
        //self.tableView.tableHeaderView = headerView
        
        tableView.contentInset = UIEdgeInsets(top: CGFloat(ScreenSize.SCREEN_WIDTH + 30), left: 0, bottom: 0, right: 0)
        
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
        
        self.btnAddToCart.isUserInteractionEnabled = isEnable
        
        if isEnable {
            self.btnAddToCart.alpha = 1.0
        }else{
            self.btnAddToCart.alpha = 0.5
        }
        
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
                
                let recipeTitle = (self.recipe?.recipeName)! + " " + NSLocalizedString("recipe_share_by", comment: "") + " " + (self.recipe?.recipeChef?.chefName)! + NSLocalizedString("recipe_share_onElgrocer", comment: "")
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

    func initailCellRegistration() {

        recipeDetialHeader = (Bundle.main.loadNibNamed("RecipeDetailHeader", owner: self, options: nil)![0] as? RecipeDetailHeader)!
        
        HowToMakeViewHeader = (Bundle.main.loadNibNamed("HowToMakeView", owner: self, options: nil)![0] as? HowToMakeView)!
        
        let recipeListCell = UINib(nibName: KRecipeTableViewCellIdentifier, bundle: Bundle(for: RecipeTableViewCell.self))
        self.tableView.register(recipeListCell, forCellReuseIdentifier: KRecipeTableViewCellIdentifier )
        self.tableView.backgroundColor = UIColor.lightGrayBGColor()
        self.tableView.estimatedRowHeight = CGFloat(KRecipeTableViewCellHeight)
        self.tableView.separatorStyle = .none

    }
    
    func setProductNumber(){
        
        self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
        self.basketIconOverlay?.grocery = self.grocery
       // self.refreshBasketIconStatus()
    }

    func addClouser() {
    }

    func getRecipeDetialData() {
        
        if self.recipe != nil {
            if  self.recipe?.recipeID != nil {
                if self.recipe?.recipeID != -1 {
                    dataHandler.getRecipDetail((self.recipe?.recipeID)!, retailerID: self.grocery?.dbID )
                    return;
                }else{
                    self.backButtonClick()
                }
            }else{
                self.backButtonClick()
            }
            
        }
        self.tableView.reloadData()
    }
    
    func reloadData() {
        if self.recipe != nil {
            self.recipeDetialHeader?.configuerData(self.recipe!)
            if let numberOfItem = self.recipe?.Ingredients?.count {
                let items = CGFloat(numberOfItem) / CGFloat(2)
               self.sectionZeroHeight = (items.rounded(.up) * kItemCellHeight) - 10
                if numberOfItem > 0 {
                    self.setAddCartButtonIntraction(true)
                }
            }
        }
       self.tableView.reloadData()
    }

    @IBAction func addToCartAction(_ sender: Any) {
    
        if let addToCartRecipe = self.recipe  {
            
            if (((self.grocery?.isShowRecipe) == nil) || self.grocery?.isShowRecipe == false) {
                self.showBottomSheet(self.recipe?.recipeName ?? "" , grocery: [] )
                self.getProductListFromIngrediats { [weak self](product) in
                    guard let self = self else { return }
                    self.fetchData(product)
                   // self.showGrocerySelectionController(product,true , self)
                }
     
            }else{
                
                if currentUser != nil {
                    _ = SpinnerView.showSpinnerViewInView(self.view)
                    dataHandler.addRecipeToCart(retailerID: self.grocery?.dbID , recipe: addToCartRecipe)
                }else{
                    self.addToCartCompleted()
                }
               // GoogleAnalyticsHelper.trackRecipeAddToCartClick()
               GoogleAnalyticsHelper.trackRecipeAddToCartClick(addToCartRecipe.recipeName! + " Add To Cart")
            }
        }
        
    }
    
    
    fileprivate func showBottomSheet (_ searchString : String , grocery : [Grocery] , isError : Bool = false) {
        if let topVc  = UIApplication.topViewController() {
            if topVc is GroceryFromBottomSheetViewController {
                let groc : GroceryFromBottomSheetViewController = topVc as! GroceryFromBottomSheetViewController
                if isError {
                    groc.showErrorMessage(searchString)
                }else{
                    groc.configureForRecipe(grocery, searchString: searchString)
                }
                return
            }
        }
        if self.groceryController == nil {
            self.groceryController  = ElGrocerViewControllers.getGroceryFromBottomSheetViewController()
        }
        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(500))
        configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
        let bottomSheetController = NBBottomSheetController(configuration: configuration)
        bottomSheetController.present(groceryController!, on: self)
        groceryController?.configureForRecipe(grocery, searchString: searchString)
        groceryController?.selectedGrocery = { [weak self] grocery in
            guard let self = self else {return}
        
            self.grocery = grocery
            ElGrocerUtility.sharedInstance.activeGrocery = grocery
            GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsRecipeDetailScreen)
            self.groceryController?.dismiss(animated: true, completion: nil)
            if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
                FireBaseEventsLogger.setScreenName(topControllerName, screenClass: String(describing: self.classForCoder))
            }
            if let addToCartRecipe = self.recipe  {
                if self.currentUser != nil {
                    _ = SpinnerView.showSpinnerViewInView(self.view)
                    self.dataHandler.addRecipeToCart(retailerID: self.grocery?.dbID , recipe: addToCartRecipe)
                    ElGrocerUtility.sharedInstance.delay(1.0) {
                        let msg = NSLocalizedString("product_added_to_basket", comment: "")
                        ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(named: "BasketAvailable") , -1 , false) { (sender , index , isUnDo) in  }
                    }
                }else{
                    self.addToCartCompleted()
                }
                
                GoogleAnalyticsHelper.trackRecipeAddToCartClick()
                GoogleAnalyticsHelper.trackRecipeAddToCartClick(addToCartRecipe.recipeName!)
            }
        }
    }
    
    
    
    func getProductListFromIngrediats(completion :  ([Product]) -> Void) {
        var productA = [Product]()
        if let data = self.recipe?.Ingredients {
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
            let msg = NSLocalizedString("product_added_to_basket", comment: "")
            ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(named: "BasketAvailable") , -1 , false) { (sender , index , isUnDo) in  }
        }
        
        self.AddToLocalDB()
        self.sendAddedMessageCall()
        self.backButtonClick()
       // self.navigationController?.popViewController(animated: true)
    
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
                dataHandler.addRecipeToCart(retailerID: self.grocery?.dbID , recipe: addToCartRecipe)
                ElGrocerUtility.sharedInstance.delay(1.0) {
                    let msg = NSLocalizedString("product_added_to_basket", comment: "")
                    ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(named: "BasketAvailable") , -1 , false) { (sender , index , isUnDo) in  }
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
        
        
      //  self.navigationController?.popViewController(animated: true)
        
        ElGrocerUtility.sharedInstance.delay(0.5) {
            controller.dismiss(animated: false, completion: { () -> Void in
                //self.navigationController?.popViewController(animated: true)
            })
        }
        return
        //dismiss grocery selection controller
        DispatchQueue.main.async {
            controller.dismiss(animated: true, completion: { () -> Void in
                /*  if !UserDefaults.isUserLoggedIn() {
                 
                 self.shouldShowBasket = .ShopByItemsBasket
                 self.shopByItemGrocery = grocery
                 self.notAvailableItems = notAvailableItems
                 self.availableProductsPrices = availableProductsPrices
                 (UIApplication.shared.delegate as! AppDelegate).showEntryView()
                 
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
                 } */
            })
        }
        
    }
    
  /*  func showGrocerySelectionController() {
        
        //show screen to choose grocery
        let groceriesController = ElGrocerViewControllers.grocerySelectionViewController()
        groceriesController.delegate = self
        
        //get products to check if available in grocery
        groceriesController.productsToCheck = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [groceriesController]
        navigationController.setLogoHidden(true)
        
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    } */
    
    
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

                context.performAndWait ({
                    let product = Product.createProductFromDictionary(productDict as NSDictionary, context: context)
                    
                    if let recipeName = self.recipe?.recipeName {
                        ElGrocerEventsLogger.sharedInstance.addToCart(product: product, recipeName, self.recipe?.recipeChef?.chefName, false, nil , "" , ingrediants.recipeIngredientsName!)
                    }
                
                    ShoppingBasketItem.addOrUpdateProductInBasketWithIncrement(product, grocery: grocery, brandName:nil, quantity: productQuantity , context: context)
                })
            }
//            if currentUser != nil {
                context.performAndWait ({

                    let userDBID = currentUser != nil ? currentUser?.dbID as! Int64 : 0
                    
                    
                    if let recipeObj =  RecipeCart.createOrUpdateRecipeCart(dbID: userDBID , retailerID: Int64(retailerID)! , recipeID: (self.recipe?.recipeID)!, ingredients: ingredientIDsA, recipeName: (self.recipe?.recipeName)! , context: context) {
                        
                        debugPrint("Object Created success ")
                        debugPrint(recipeObj.dbID)
                        debugPrint(recipeObj.recipeID)
                        debugPrint(recipeObj.retailerID)
                    }else{
                        debugPrint("Failed")
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

extension RecipeDetailViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let headerView = self.tableView.tableHeaderView as?  StretchyTableHeaderView {
            //headerView.scrollViewDidScroll(scrollView: scrollView)
        }else{
            var y = -scrollView.contentOffset.y
            if shouldScroll{
                 y = -scrollView.contentOffset.y
                let height = max(y, 60 + 20)
                print(height)
                print("y : \(y)")
                //imageView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: height)
                if height < ScreenSize.SCREEN_WIDTH{
                    headerView.headerPageControl.visibility = .gone
                }else{
                    headerView.headerPageControl.visibility = .visible
                }
                headerView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH + 30, height: height)
            }else{
                shouldScroll = true
                 y = -scrollView.contentOffset.y
                print("Screen width :\(ScreenSize.SCREEN_WIDTH)")
                print("offset y :\(y)")
                
                let height = max(y, ScreenSize.SCREEN_WIDTH + 30)
                print(height)
                scrollView.contentOffset.y = -height
                //imageView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: height)
                headerView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH + 30, height: height)
            }
            
            
        }
    }
           
}

extension RecipeDetailViewController : UITableViewDelegate , UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return CGFloat(KRecipeDetailHeaderHeight)
        }else if section == 1 {
            return CGFloat(KHowToMakeHeaderHeight)
        }else{
            return CGFloat.leastNormalMagnitude
        }
    
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
          //  self.cachedImageViewSize = recipeDetialHeader?.ImageRecipe.frame
            return recipeDetialHeader
        }else  if section == 1 {
            return HowToMakeViewHeader
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return sectionZeroHeight
        }else if indexPath.section == 1 {
            var height = 105.0
            if let steps = self.recipe?.Steps {
                let step = steps[indexPath.row]
                let font = UIFont.SFProDisplayNormalFont(12)
                height = Double(Int(font.sizeOfString(step.recipeStepDetail!, constrainedToWidth: Double(self.view.frame.size.width * 0.5)).height))
                height = height + 10.0
                if height < 50 {
                    height = 50
                }
            }
            return CGFloat(height)
        }else{
            return UITableView.automaticDimension
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return  self.recipe?.Steps?.count ?? 0
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let itemCell : RecipeItemsTableViewCell = tableView.dequeueReusableCell(withIdentifier: KRecipeItemsTableViewCellIdentifier , for: indexPath) as! RecipeItemsTableViewCell
            if let ingredents = self.recipe?.Ingredients {
                 itemCell.setIngrediantsData(ingredents)
            }
            return itemCell
        }
        
        let howToMake = tableView.dequeueReusableCell(withIdentifier: KHowToMakeTableViewCellIdentifier ) as! HowToMakeTableViewCell
        if let steps = self.recipe?.Steps {
            howToMake.configureCell(steps[indexPath.row], indexPath: indexPath, totalCount: steps.count)
        }
       
        return howToMake
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }

}
extension RecipeDetailViewController : UIGestureRecognizerDelegate {}
extension RecipeDetailViewController : RecipeDataHandlerDelegate {
    
    func recipeDetial(_ recipe: Recipe) {
        self.recipe = recipe
        self.addImageHeader()
        self.setUpApearance()
        self.reloadData()
        SpinnerView.hideSpinnerView()
    }
    
}


extension RecipeDetailViewController {
    
    fileprivate func fetchData(_ productsToCheck : [Product] ) {
        ElGrocerApi.sharedInstance.getAllGroceries(DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)! , completionHandler: { (result) in
            switch result {
                case .success(let response):
                    let responseData = Grocery.insertGroceriesWithNotAvailableProducts(response, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    let groceries = responseData.groceries
                    if groceries.count == 0 {
                        self.showBottomSheet(NSLocalizedString("No_Store_For_Recipe_title", comment: "") , grocery: [], isError: true)
                    }else{
                        self.showBottomSheet(self.recipe?.recipeName ?? "" , grocery: responseData.groceries )
                    }
                case .failure(let error):
                    self.groceryController?.dismiss(animated: true, completion: nil)
                    error.showErrorAlert()
            }
        })
    }
    
}
