//
//  IngrediantsCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 26/03/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import NBBottomSheet

let kIngrediantCellHeight : CGFloat = 55 + 24 // 24 for padding

class IngrediantsCell: UITableViewCell {

   
    @IBOutlet var ingrediantImage: UIImageView!
    @IBOutlet var lblIngredantName: UILabel!{
        didSet{
            lblIngredantName.setBody2RegDarkStyle()
        }
    }
    @IBOutlet var lblIngrediantQuantity: UILabel!{
        didSet{
            lblIngrediantQuantity.setCaptionOneRegSecondaryDarkStyle()
        }
    }
    @IBOutlet var lblTotalQuantity: UILabel!{
        didSet{
            lblTotalQuantity.setCaptionOneRegSecondaryDarkStyle()
        }
    }
    @IBOutlet var btnAddRemoveIngrediant: UIButton!
    
    
    var groceryController : GroceryFromBottomSheetViewController?
    //var recipeController : RecipeDetailVC!
//    lazy var recipeController : RecipeDetailVC = {
//        let recipeController = RecipeDetailVC()
//        return recipeController
//    }()
    
    lazy var dataHandler : RecipeDataHandler = {
        let dataH = RecipeDataHandler()
        dataH.delegate = self
        return dataH
    }()
    lazy var currentUser : UserProfile? = {
       return UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }()
    var view : RecipeDetailVC!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setInitailAppearence()
    }
    
    func setInitailAppearence(){
        self.backgroundColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(ingrediant : RecipeIngredients , grocery : Grocery? , view : RecipeDetailVC){
        self.view = view
        if ingrediant.recipeIngredientsID != -1{
            getProductListFromIngrediats(ingrediant: [ingrediant], grocery: grocery) { (products) in
                if products.count > 0{
                    if let product = ShoppingBasketItem.checkIfProductIsInBasket(products[0], grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                        //productQuantity += product.count.intValue
                        self.addIngrediant(true)
                    }else{
                        
                        self.addIngrediant(false)
                    }
                }else{
                    self.addIngrediant(false)
                }
                
            }
            lblIngredantName.text = ingrediant.recipeIngredientsName
            guard let ingrediantQuantity = ingrediant.recipeIngredientsQuantity else {return}
            guard let ingrediantQuantityUnit = ingrediant.recipeIngredientsQuantityUnit else{return}
            guard let ingrediantSizeUnit = ingrediant.recipeIngredientsTotalQuantity else{return}
            lblTotalQuantity.text = "\(ingrediantQuantity)" + ingrediantQuantityUnit
            lblIngrediantQuantity.text = ingrediantSizeUnit

            if let url = ingrediant.recipeIngredientsImageURL{
                setImage(url, inImageView: self.ingrediantImage)
            }

            

        }
    }

    fileprivate func setImage(_ urlString : String? , inImageView : UIImageView?=nil ) {

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

    func addIngrediant(_ added : Bool = false){
        if added{
            self.btnAddRemoveIngrediant.setImage(UIImage(named: "removeIngrediant"), for: UIControl.State())
        }else{
            self.btnAddRemoveIngrediant.setImage(UIImage(named: "addIngrediant"), for: UIControl.State())
        }
    }

    func addIngrediantHandler(recipe: Recipe, ingrediant : RecipeIngredients , grocery : Grocery? , view : RecipeDetailVC){
        
        getProductListFromIngrediats(ingrediant: [ingrediant], grocery: grocery) { (products) in
            
            if products.count > 0{
                if let product = ShoppingBasketItem.checkIfProductIsInBasket(products[0], grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                    self.removeProductToBasketFromQuickRemove(products[0], grocery: grocery)
                }else{
                    addProductInShoppingBasketFromQuickAdd(products[0], grocery: grocery)
                }
            }else{
                //sab new
//                view.fetchData(products , isSingleProduct: true) { (groceryA) in
//                        self.showBottomSheet(recipe.recipeName ?? "", grocery: groceryA, ingrediants: [ingrediant], recipe: recipe , view : view)
//                }
                 ///let addToCartRecipe = recipe
                    let currentGrocery = grocery
                    let filterA = self.view.getRetailersListForIngreadients(grocery)
                    if filterA.count == 1 {
                        let grocery = filterA[0]
                        if grocery.dbID == currentGrocery?.dbID {
                            return
                        }
                    }
                    showBottomSheet(recipe.recipeName ?? "", grocery: [], ingrediants: [ingrediant], recipe: recipe , view : view)
                if filterA.count > 0 {
                    showBottomSheet(recipe.recipeName ?? "", grocery: filterA , ingrediants: [ingrediant], recipe: recipe , view : view)
                    }else{
                        showBottomSheet(NSLocalizedString("No_Store_For_Recipe_title", comment: "") , grocery: [], ingrediants: [ingrediant], recipe: recipe , view : view , isError: true)
                    }
            }
            
        }
    }
    
    
    
    func showBottomSheet (_ searchString : String , grocery : [Grocery] , ingrediants : [RecipeIngredients]? ,recipe : Recipe ,view : RecipeDetailVC, isError : Bool = false) {
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
        bottomSheetController.present(groceryController!, on: view)
        groceryController?.configureForRecipe(grocery, searchString: searchString)
        groceryController?.selectedGrocery = { [weak self] grocery in
            guard let self = self else {return}
            func processGroceryChange() {
                
                view.grocery = grocery
                ElGrocerUtility.sharedInstance.activeGrocery = grocery
                view.grocery = grocery
                UserDefaults.setCurrentSelectedDeliverySlotId(0)
                UserDefaults.setPromoCodeValue(nil)
                if (grocery.isOpen.boolValue && Int(grocery.deliveryTypeId!) != 1) || (grocery.isSchedule.boolValue && Int(grocery.deliveryTypeId!) != 0){
                    let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    if currentAddress != nil  {
                        UserDefaults.setGroceryId(grocery.dbID , WithLocationId: (currentAddress?.dbID)!)
                    }
                }
                
                let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                context.performAndWait {
                    ShoppingBasketItem.clearActiveGroceryShoppingBasket(context)
                }
                
                GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsRecipeDetailScreen)
                self.groceryController?.dismiss(animated: true, completion: nil)
                if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
                    FireBaseEventsLogger.setScreenName(topControllerName, screenClass: String(describing: self.classForCoder))
                }
                
                if ingrediants?.count ?? 0 > 0 {
                    if let ingre = ingrediants?[0] {
                        self.addIngrediantHandler(recipe: recipe, ingrediant: ingre , grocery: grocery , view: view)
                    }
                   
                }
                
              
                
                /*
                if let addToCartRecipe = ingrediants  {
                    if self.currentUser != nil {
                        if addToCartRecipe.count > 0 {
                            self.dataHandler.addRecipeProductToCart(retailerID: grocery.dbID, recipeIngrediants: addToCartRecipe)
                        }
                    }else{
                        if addToCartRecipe.count > 0{
                            self.addIngrediantHandler(recipe: recipe, ingrediant: addToCartRecipe[0] , grocery: grocery, view: view)
                        }
                    }
                    
                }
                */
                
                
            }
            ElGrocerUtility.sharedInstance.checkActiveGroceryNeedsToClear(grocery) { (isUserApproved) in
                if isUserApproved {
                    processGroceryChange()
                }
            }
 
        }
    }
    
    func getProductListFromIngrediats(ingrediant : [RecipeIngredients]? , grocery : Grocery?, completion :  ([Product]) -> Void) {
        
        
        var isCurrentSelected = false
         let groceryA =  self.view.getRetailersListForIngreadients(grocery)
            if groceryA.count > 0 {
                let currentGrocey = self.view.grocery
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
        if let data = ingrediant {     //self.recipe?.Ingredients {
            
            
            var ingredientIDsA = [NSNumber]()
         
            
            
            for ingrediants : RecipeIngredients in data {
                
                let productID = NSNumber(value: ingrediants.recipeIngredientsProductID ?? -1)
                ingredientIDsA.append(productID)
                
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
                
                if let retailerID = grocery?.dbID {
                    let productDict = ["id" : ingrediants.recipeIngredientsProductID!  , "retailer_id" : retailerID , "name" : ingrediants.recipeIngredientsName! , "image_url" : ingrediants.recipeIngredientsImageURL! , "price" : priceDict as NSDictionary , "brands" : brandDict as NSDictionary , "subcategories" : subcategoriesA , "categories" : subcategoriesA , "is_available" : ingrediants.recipeIngredientsIsAvailable! , "is_published" : ingrediants.recipeIngredientsIsPublished! ] as [String : Any]
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    let product = Product.createProductFromDictionary(productDict as NSDictionary, context: context)
                    productA.append(product)
                  
                }
            }
        }
        completion(productA)
       // return productA
    }
    
    func addProductInShoppingBasketFromQuickAdd(_ selectedProduct: Product, grocery : Grocery?){

        let productQuantity = 1
        self.updateProductsQuantity(productQuantity, selectedProduct: selectedProduct,grocery: grocery)
    }

    func removeProductToBasketFromQuickRemove(_ selectedProduct: Product,grocery : Grocery?){

        guard grocery != nil else {return}
        let productQuantity = 0
        self.updateProductsQuantity(productQuantity, selectedProduct: selectedProduct,grocery: grocery)
    }

    func updateProductsQuantity(_ quantity: Int, selectedProduct: Product , grocery : Grocery?) {

        if quantity == 0 {
            
            //remove product from basket
            ShoppingBasketItem.removeProductFromBasket(selectedProduct, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            self.addIngrediant(false)
            view.itemsInCart = view.itemsInCart - 1
            view.UpdateCartCount()
    
        } else {

            //Add or update item in basket
            ShoppingBasketItem.addOrUpdateProductInBasket(selectedProduct, grocery: grocery, brandName: selectedProduct.brandNameEn , quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            ElGrocerEventsLogger.sharedInstance.addToCart(product: selectedProduct, "\(self.view.recipe?.recipeID ?? -1)", "\(self.view.recipe?.recipeChef?.chefID ?? -1)", false, nil , "", selectedProduct.nameEn ?? "")
           // ElGrocerEventsLogger.sharedInstance.addToCart(product: selectedProduct , "", nil, false , -1 )
            
            ElGrocerUtility.sharedInstance.delay(1.0) {
                let msg = NSLocalizedString("product_added_to_cart", comment: "")
                ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(named: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
            }
            self.addIngrediant(true)
            view.itemsInCart = view.itemsInCart + 1
            view.UpdateCartCount()
            //self.view.checkForItemsInCart()
           
        }
        DatabaseHelper.sharedInstance.saveDatabase()
        //self.view.checkForItemsInCart()
    
    }
}
extension IngrediantsCell : RecipeDataHandlerDelegate{
    func addToCartCompleted() {
        ElGrocerUtility.sharedInstance.delay(1.0) {
            
            let msg = NSLocalizedString("product_added_to_cart", comment: "")
            ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(named: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
        }
        self.addIngrediant(true)
        view.itemsInCart = view.itemsInCart + 1
        view.UpdateCartCount()
        //self.view.checkForItemsInCart()
        
    }
}
