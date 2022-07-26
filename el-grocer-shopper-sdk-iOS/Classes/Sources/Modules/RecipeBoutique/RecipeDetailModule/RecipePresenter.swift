//
//  RecipePresenter.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 24/03/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import NBBottomSheet

class RecipePresenter: ViewToPresenterRecipeProtocol {
    
    // MARK: Properties
    var view : RecipeDetailVC!
    var interactor = RecipeInteractor()
    
    var recipe : Recipe?
    var groceryController : GroceryFromBottomSheetViewController?
//    var interactor: PresenterToInteractorRecipeProtocol?
//    var router: PresenterToRouterRecipeProtocol?

    //MARK: View
    func viewDidLoad(view : RecipeDetailVC){
        
        self.view = view
        if view.recipe != nil{
            self.recipe = view.recipe!
        }
        view.setUpApearance()
        view.setProductNumber()
        view.initailCellRegistration()
        self.loadRecipeDetailData()
    }
    
    
    func loadRecipeDetailData() {
        if view.recipe?.recipeID != -1{
            interactor.getRecipeDetialData(view.recipe!, grocery: ElGrocerUtility.sharedInstance.activeGrocery, presenter: self)
        }
        view.reloadData()
    }
    
    
    func viewDidAppear(view : RecipeDetailVC) {
        self.updateItemsCount()
    }
    
    func updateItemsCount() {
        
        let itemCount =  ElGrocerUtility.sharedInstance.getCurrentActionGroceryItemCount(grocery: self.view.grocery)
        var itemsString = localizedString("shopping_basket_items_count_singular", comment: "")
        if itemCount > 1 {
            itemsString = localizedString("shopping_basket_items_count_plural", comment: "")
        }
        self.view.setButtonState(enabled: (itemCount > 0))
        if itemCount == 0 {
            self.view.lblItemsCount.text = "("  + itemsString + ")"
        }else{
            self.view.lblItemsCount.text = "(\(itemCount) " + itemsString + ")"
        }
        
       
    }
    
    //MARK: button Handlers
    
    
    func saveButtonHandler(){
        
        
        guard UserDefaults.isUserLoggedIn() else {
            self.view.isCommingFromSignIn = true
            let signInVC = ElGrocerViewControllers.signInViewController()
            signInVC.isForLogIn = true
            signInVC.isCommingFrom = .saveRecipe
            signInVC.dismissMode = .dismissModal
            signInVC.recipeId =  recipe?.recipeID
            let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navController.viewControllers = [signInVC]
            navController.modalPresentationStyle = .fullScreen
            if let topVc = UIApplication.topViewController() {
                topVc.present(navController, animated: true, completion: nil)
                
            }
            return
        }
        
        
        
        
        if recipe?.recipeID != -1{
            if recipe!.isSaved{
                guard let id = recipe?.recipeID else {
                    return
                }
                interactor.apiCallSaveRecipe(recipeId: id, isSave: false)
            }else{
                guard let id = recipe?.recipeID else {
                    return
                }
                interactor.apiCallSaveRecipe(recipeId: id, isSave: true)
            }
        }
        
    }
    
    /*func addSingleIngrediantsToCartHandler(recipe : Recipe? , ingrediants : [RecipeIngredients]? , grocery : Grocery?){
        if let addToCartRecipe = recipe, let ingrediant = ingrediants{
            
            if (((grocery?.isShowRecipe) == nil) || grocery?.isShowRecipe == false) {
                self.showBottomSheet(self.recipe?.recipeName ?? "" , grocery: [] )
                
                view.getProductListFromIngrediats(ingrediant: ingrediant) { [weak self](product) in
                    //sab
                    guard let self = self else { return }
                    view.fetchData(product) { (groceryA) in
                        
                    }
                }
     
            }else{
                
                if currentUser != nil {
                    //sab
                    _ = SpinnerView.showSpinnerViewInView(view.view)
                    //sab
                    interactor.dataHandler.addRecipeToCart(retailerID: grocery?.dbID , recipe: addToCartRecipe)
                }else{
                    view.addToCartCompleted()
                }
               // GoogleAnalyticsHelper.trackRecipeAddToCartClick()
               GoogleAnalyticsHelper.trackRecipeAddToCartClick(addToCartRecipe.recipeName! + " Add To Cart")
            }
        }
    }*/
    
    func addAllIngrediantsToCartHandler(recipe : Recipe? , ingrediants : [RecipeIngredients]? , grocery : Grocery?){
        
        
        func addCallProceed() {

            if let addToCartRecipe = recipe {
                if UserDefaults.isUserLoggedIn() {
                    _ = SpinnerView.showSpinnerViewInView(view.view)
                    interactor.dataHandler.addRecipeToCart(retailerID: grocery?.dbID , recipe: addToCartRecipe)
                }else{
                    view.addToCartCompleted()
                }
                GoogleAnalyticsHelper.trackRecipeAddToCartClick(addToCartRecipe.recipeName! + " Add To Cart")
                
            }
        }
        
        
        if let addToCartRecipe = recipe {
            let currentGrocery = grocery
            let filterA = self.view.getRetailersListForIngreadients(grocery)
            if filterA.count == 1 {
                let grocery = filterA[0]
                if grocery.dbID == currentGrocery?.dbID {
                    addCallProceed()
                    return
                }
            }
            
            if filterA.count > 0 {
                self.showBottomSheet(addToCartRecipe.recipeName ?? "" , grocery: filterA, ingredients: ingrediants)
                return
            }else{
                self.showBottomSheet( localizedString("No_Store_For_Recipe_title", comment: "") , grocery: [] , isError: true, ingredients: [])
                return
            }
            self.showBottomSheet(addToCartRecipe.recipeName ?? "" , grocery: [], ingredients: [] )
        }

    }
    
    //MARK: tableview functions
    
    func heightForFooter(section : Int) -> CGFloat{
       elDebugPrint("height for footer called from view")
        if section == 2{
            return 20
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func viewForFooter() -> UIView{
       elDebugPrint("view for footer called from view")
        let view = UIView()
        view.backgroundColor = .white
        return view
    }
    
    func heightForRowAtIndexPath(indexPath : IndexPath , tableView : UITableView) -> CGFloat{
       elDebugPrint("height for row called from view")
        if indexPath.section == 0{
           // return KRecipeDetailCellHeight
            if recipe != nil && recipe?.recipeDescription != nil{
                let height =  KRecipeDetailBottomCellHeight + dynamicHeight(text: recipe!.recipeDescription! , font: UIFont.SFProDisplayNormalFont(14)) + dynamicHeight(text: recipe!.recipeName! , font: UIFont.SFProDisplaySemiBoldFont(20))
                if height < KRecipeDetailMinCellHeight{
                    return KRecipeDetailMinCellHeight
                }
                return height
            }
            return 0.01
            
        }else if indexPath.section == 1{
            if indexPath.row == 0{
                return KGenericViewTitileTableViewCellHeight
            }
            if indexPath.row == tableView.numberOfRows(inSection: 1) - 1{
                return kAddallIngrediantsHeight
            }
            return kIngrediantCellHeight
        }else{
            if indexPath.section == 2 && indexPath.row == 0{
                return KGenericViewTitileTableViewCellHeight
            }
            //let steps = recipe?.Steps as? [RecipeSteps]
            //steps?[indexPath.row - 1].recipeStepDetail
            
            if recipe != nil && recipe?.Steps?[indexPath.row - 1].recipeStepDetail?.isEmpty == false{
                 let text = recipe?.Steps?[indexPath.row - 1].recipeStepDetail
                let height = dynamicHeight(text: text! , font: UIFont.SFProDisplayNormalFont(14)) //+ 24 //24 top bottom padding
                if height < kRecipePreparationMinHeight{
                  return  kRecipePreparationMinHeight
                }
                return height
            }
            
            return kRecipePreparationMinHeight
        }
    }
    
    func numberOfRowsInSection(section : Int) -> Int{
       elDebugPrint("number of rows called from view")
        if section == 0{
            return 1
        }else if section == 1{
            if recipe != nil{
                guard let ingrediantCount = recipe?.Ingredients?.count else {
                    return 2
                }
                return ingrediantCount + 2
            }
            return 2
        }else if section == 2{
            guard let stepsCount = recipe?.Steps?.count else {
                return 0
            }
            return stepsCount + 1 // +1 for heading
        }
        return 0
    }
    
    
    //MARK: Other Functions
    
    func showBottomSheet (_ searchString : String , grocery : [Grocery] , isError : Bool = false , ingredients : [RecipeIngredients]?) {
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
        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(550))
        configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
        let bottomSheetController = NBBottomSheetController(configuration: configuration)
        bottomSheetController.present(groceryController!, on: view)
        groceryController?.configureForRecipe(grocery, searchString: searchString)
        groceryController?.selectedGrocery = { [weak self] grocery in
            guard let self = self else {return}
            func processGroceryChange() {
                self.view.grocery = grocery
                ElGrocerUtility.sharedInstance.activeGrocery = grocery
                GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsRecipeDetailScreen)
                if let topVc = UIApplication.topViewController() {
                    if let tabbar = topVc.tabBarController {
                        ElGrocerUtility.sharedInstance.resetTabbar(tabbar)
                    }
                }
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
                self.groceryController?.dismiss(animated: true, completion: nil)
                if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
                    FireBaseEventsLogger.setScreenName(topControllerName, screenClass: String(describing: self.view.classForCoder))
                }
                
                self.addAllIngrediantsToCartHandler(recipe: self.recipe, ingrediants: ingredients, grocery: grocery)
                
                /*
                if let addToCartRecipe = self.recipe  {
                    if self.view.currentUser != nil {
                        _ = SpinnerView.showSpinnerViewInView(self.view.view)
                        self.interactor.dataHandler.addRecipeToCart(retailerID: self.view.grocery?.dbID , recipe: addToCartRecipe)
                        ElGrocerUtility.sharedInstance.delay(1.0) {
                            let msg = localizedString("product_added_to_basket", comment: "")
                            ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "BasketAvailable") , -1 , false) { (sender , index , isUnDo) in  }
                        }
                        self.view.addToCartCompleted()
                    }else{
                        self.view.addToCartCompleted()
                    }
                    
                    GoogleAnalyticsHelper.trackRecipeAddToCartClick()
                    GoogleAnalyticsHelper.trackRecipeAddToCartClick(addToCartRecipe.recipeName!)
                }*/
            }
            ElGrocerUtility.sharedInstance.checkActiveGroceryNeedsToClear(grocery) { (isUserApproved) in
                if isUserApproved {
                    processGroceryChange()
                }
            }
        }
    }
    
    func dynamicHeight(text : String , font : UIFont) -> CGFloat{
        let string = text
        let textSize = string.heightOfString(withConstrainedWidth: ScreenSize.SCREEN_WIDTH - 100 , font: font)
        return textSize + 14
    }
    func dynamicHeightPrep() -> CGFloat{
        let string = "Prep the chicken thighs by trimming any excess fat and gristle. I think it’s easiest to use kitchen shears, as opposed to a knife. (Note that there’s a fair amount of waste with the thighs — that’s why the recipe calls for 2-1/2 pounds of dark meat versus 2 pounds of white meat.)"
        let textSize = string.heightOfString(withConstrainedWidth: ScreenSize.SCREEN_WIDTH - 100 , font: UIFont.SFProDisplayNormalFont(14))
        return textSize + 14
    }
    
}

// MARK: - Outputs to view
extension RecipePresenter: InteractorToPresenterRecipeProtocol {
    
    func noNewDataSuccess() {
       elDebugPrint("Presenter receives the result from Interactor after it's done its job.")
        view.reloadData()
        
    }
    
    func fetchResponceSuccess(recipe : Recipe) {
       elDebugPrint("Presenter receives the result from Interactor after it's done its job.")
        FireBaseEventsLogger.trackRecipeView(recipe: recipe , source: self.view.source)
        self.recipe = recipe
        view.recipe = recipe
        view.addImageHeader()
        view.setUpApearance()
        view.reloadData()
        view.checkStolryStory()
        SpinnerView.hideSpinnerView()
        
    }
//    
    func fetchResponceFailure() {
       elDebugPrint("Presenter receives the result from Interactor after it's done its job.")
        
        view.backButtonClick()
    }
    
    func saveResponce(sucess : Bool){
        
        if recipe!.isSaved{
            if sucess{
                view.btnSave.setImage(UIImage(name: "saveUnfilled"), for: .normal)
                recipe?.isSaved = false
            }else{
                //cell.saveRecipeImageView.image = UIImage(name: "saveUnfilled")
                view.btnSave.setImage(UIImage(name: "saveFilled"), for: .normal)
            }
        }else{
            if sucess{
                view.btnSave.setImage(UIImage(name: "saveFilled"), for: .normal)
                recipe?.isSaved = true
                //cell.saveRecipeImageView.image = UIImage(name: "saveFilled")
                let msg = localizedString("recipe_save_success", comment: "")
                ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "saveFilled") , -1 , false) { (sender , index , isUnDo) in  }
            }else{
                //cell.saveRecipeImageView.image = UIImage(name: "saveUnfilled")
                view.btnSave.setImage(UIImage(name: "saveUnfilled"), for: .normal)
            }
        }
        
    }
    
    
}
