//
//  ElGrocerViewControllers.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 01.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

class ElGrocerViewControllers {
    
    fileprivate class func initializeControllerFromStoryboard<T: UIViewController>(_ storyboardId: String, storyboardControllerId: String) -> T {
        
        let storyboard = UIStoryboard(name: storyboardId, bundle: .resource)
        return storyboard.instantiateViewController(withIdentifier: storyboardControllerId) as! T
    }
    
    // MARK: Update location info
    
    class func updateLocationInfoController() -> UpdateLocationInfoViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("UpdateLocationInfo", storyboardControllerId: "UpdateLocationInfoViewController")
    }
    
    // MARK: Location Map
    
    class func locationMapViewController() -> LocationMapViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("LocationMap", storyboardControllerId: "LocationMapViewController")
    }
    
    
    // MARK: Force Update
    
    class func forceUpdateViewController() -> ForceUpdateViewController {
        
        return ElGrocerViewControllers.initializeControllerFromStoryboard("ForceUpdate", storyboardControllerId: "ForceUpdateViewController")
        
    }
    
    // MARK: Add Note
    
    class func addNoteController() -> AddNoteViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("AddNote", storyboardControllerId: "AddNoteViewController")
    }
    
    // MARK: Splash Animation Vc
    
    class func splashAnimationViewController() -> SplashAnimationViewController {
        
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Entry", storyboardControllerId: "SplashAnimationViewController")
        
    }
    
    // MARK: Entry
    
    class func entryViewController() -> EntryViewController {
        
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Entry", storyboardControllerId: "EntryViewController")
        
    }
    
    // MARK: Language
    
    class func languageViewController() -> LanguageViewController {
        
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Entry", storyboardControllerId: "LanguageVC")
    }
    
    // MARK: Login & Registration

    class func forgotPasswordViewController() -> ForgotPasswordViewController {
        
        let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
    }
    
    class func checkEmailViewController() -> CheckEmailViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("SignIn", storyboardControllerId: "CheckEmailViewController")
    }
    
    // MARK: Menu
    
    class func menuController() -> MenuViewController {
        
        let storyboard = UIStoryboard(name: "Menu", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
    }
    
    // MARK: Dashboard
    
    class func dashboardLocationViewController() -> DashboardLocationViewController {
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "DashboardLocationViewController") as! DashboardLocationViewController
    }
    
    class func SubCategoriesViewController( dataHandler : CateAndSubcategoryView?) -> SubCategoriesViewController {
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle(for: self))
        let subCate = storyboard.instantiateViewController(withIdentifier: "SubCategoriesVC") as! SubCategoriesViewController
        if let handler = dataHandler {
            subCate.viewHandler = handler
        }
        return subCate
        
    }
    class func SubCategoryProductListingViewController( dataHandler : CateAndSubcategoryView?) -> SubCategoryProductListingViewController {
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle(for: self))
        let subCate = storyboard.instantiateViewController(withIdentifier: "SubCategoryProductListingViewController") as! SubCategoryProductListingViewController
//        if let handler = dataHandler {
//            subCate.viewHandler = handler
//        }
        return subCate
    }
    
    
    
    
    
    
    class func groceriesViewController() -> GroceriesViewController {
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "GroceriesViewController") as! GroceriesViewController
    }
    
    class func mainCategoriesViewController() -> MainCategoriesViewController {
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "CategoriesVC") as! MainCategoriesViewController
    }
    
    class func groceryReviewsViewController() -> GroceryReviewsViewController {
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "GroceryReviewsViewController") as! GroceryReviewsViewController
    }
    
    class func newGroceryReviewViewController() -> NewGroceryReviewViewController {
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "NewGroceryReviewViewController") as! NewGroceryReviewViewController
    }
    
    class func editLocationViewController() -> EditLocationViewController {
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "EditLocationViewController") as! EditLocationViewController
    }
    
    class func browseViewController() -> BrowseViewController {
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "BrowseVC") as! BrowseViewController
    }
    
    class func productsViewController() -> ProductsViewController {
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "ProductsVC") as! ProductsViewController
    }
    
    class func groceryLoaderViewController() -> GroceryLoaderViewController {
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "GroceryLoaderVC") as! GroceryLoaderViewController
    }
    
    class func bannerDetailsViewController() -> BannerDetailsViewController {
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "BannerDetailsVC") as! BannerDetailsViewController
    }
    
    class func brandDetailsViewController() -> BrandDetailsViewController {
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "BrandDetailsViewController") as! BrandDetailsViewController
    }
    
    // MARK: Orders
    
    class func ordersViewController() -> OrdersViewController {
        
        let storyboard = UIStoryboard(name: "Orders", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "OrdersViewController") as! OrdersViewController
    }
    
    class func orderSummaryViewController() -> OrderSummaryViewController {
        
        let storyboard = UIStoryboard(name: "Orders", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "OrderSummaryViewController") as! OrderSummaryViewController
    }
    
    class func orderPaymentSelectionViewController() -> OrderPaymentSelectionViewController {
        
        let storyboard = UIStoryboard(name: "Orders", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "OrderPaymentSelectionViewController") as! OrderPaymentSelectionViewController
    }
    
    class func orderConfirmationViewController() -> OrderConfirmationViewController {
        
        let storyboard = UIStoryboard(name: "Orders", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "OrderConfirmationViewController") as! OrderConfirmationViewController
    }
    
    class func orderCanceledViewController(_ orderId: Int!, cancelMessage: String!) -> OrderCanceledViewController {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle(for: self))
        let controller = storyboard.instantiateViewController(withIdentifier: "OrderCanceledViewController") as! OrderCanceledViewController
        controller.setCanceledOrderId(orderId)
        controller.setCancelMessage(cancelMessage)
        
        return controller
    }
    
    //Hunain 8Jan17
    //MARK: My Basket
    
    class func myBasketViewController() -> MyBasketViewController {
        
        let storyboard = UIStoryboard(name: "Orders", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "MyBasketViewController") as! MyBasketViewController
    }
    
    // MARK: Favourites
    
    class func favouritesViewController() -> FavouritesViewController {
        
        let storyboard = UIStoryboard(name: "Favourites", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "FavouritesViewController") as! FavouritesViewController
    }
    
    // MARK: User Account
    
    class func userAccountViewController() -> UserAccountViewController {
        
        let storyboard = UIStoryboard(name: "UserAccount", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "UserAccountViewController") as! UserAccountViewController
    }
    
    class func editProfileViewController() -> EditProfileViewController {
        
        let storyboard = UIStoryboard(name: "UserAccount", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
    }
    
    class func contactInfoViewController() -> ContactInfoViewController {
        
        let storyboard = UIStoryboard(name: "UserAccount", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "ContactInfoVC") as! ContactInfoViewController
    }
    
    class func deliveryInfoViewController() -> DeliveryInfoViewController {
        
        let storyboard = UIStoryboard(name: "UserAccount", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "DeliveryInfoVC") as! DeliveryInfoViewController
    }
   
    // MARK: About
    
    class func aboutViewController() -> AboutViewController {
        
        let storyboard = UIStoryboard(name: "About", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
    }
    
    // MARK: Common
    
    class func searchViewController() -> SearchViewController {
        
        let storyboard = UIStoryboard(name: "Common", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
    }

    // MARK: Update location info

    class func shoppingListViewController() -> ShoppingListViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("MultipleSearch", storyboardControllerId: "ShoppingListViewController")
    }
    
    class func requestsViewController() -> RequestsViewController {
        
        let storyboard = UIStoryboard(name: "Common", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
    }
    
    class func getEmbededPaymentWebViewController() -> EmbededPaymentWebViewController {
        
        let storyboard = UIStoryboard(name: "Common", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "EmbededPaymentWebViewController") as! EmbededPaymentWebViewController
    }
    
    class func grocerySelectionViewController() -> GrocerySelectionViewController {
        
        let storyboard = UIStoryboard(name: "Common", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "GrocerySelectionViewController") as! GrocerySelectionViewController
    }
    
    class func noNetworkConnectionViewController() -> NoNetworkConnectionViewController {
        
        let storyboard = UIStoryboard(name: "Common", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "NoNetworkConnectionViewController") as!  NoNetworkConnectionViewController
    }
    
    class func replacementViewController() -> ReplacementViewController {
        
        let storyboard = UIStoryboard(name: "Common", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "ReplacementVC") as! ReplacementViewController
    }
    
    // MARK: Registration
    
    class func registrationPersonalViewController() -> RegistrationPersonalViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Registration", storyboardControllerId: "RegistrationPersonalViewController")
    }
    
    class func registrationAddressViewController() -> RegistrationAddressViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Registration", storyboardControllerId: "RegistrationAddressViewController")
    }
    
    class func registrationCodeVerifcationViewController() -> CodeVerificationViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Registration", storyboardControllerId: "CodeVerificationViewController")
    }
    
    // MARK: SignIn
    
    class func signInViewController() -> SignInViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("SignIn", storyboardControllerId: "SignInViewController")
    }
    
    // MARK: Setting
    
    class func settingViewController() -> SettingViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Setting", storyboardControllerId: "SettingViewController")
    }
    
    // MARK: FreeGroceries
    
    class func freeGroceriesViewController() -> FreeGroceriesViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("FreeGroceries", storyboardControllerId: "FreeGroceriesViewController")
    }
    
    
    // MARK: Wallet
    
    class func walletViewController() -> WalletViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Wallet", storyboardControllerId: "WalletViewController")
    }
    
    
    class func congratulationsViewController() -> CongratulationsViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Wallet", storyboardControllerId: "CongratulationsViewController")
    }
    
    // MARK: Substitutions
    
    class func substitutionsProductsViewController() -> SubstitutionsProductViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Substitutions", storyboardControllerId: "SubstitutionsProductVC")
    }
    
    class func substitutionsViewController() -> SubstitutionsViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Substitutions", storyboardControllerId: "SubstitutionsViewController")
    }
    
    class func substitutionsBasketViewController() -> SubtitutionBasketViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Substitutions", storyboardControllerId: "SubtitutionBasketVC")
    }
    
    // MARK: FAQ's
    
    class func faqViewController() -> FAQViewController {
        
        let storyboard = UIStoryboard(name: "About", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "FAQViewController") as! FAQViewController
    }
    
    class func questionViewController() -> QuestionViewController {
        
        let storyboard = UIStoryboard(name: "About", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "QuestionViewController") as! QuestionViewController
    }
    
    // MARK: Order Review
    
    class func orderReviewViewController() -> OrderReviewViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("OrderReview", storyboardControllerId: "OrderReviewVC")
    }
    
    // MARK: Order Tracking
    
    class func orderTrackingViewController() -> OrderTrackingViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Orders", storyboardControllerId: "OrderTrackingVC")
    }
    
    // MARK: Order Details
    class func orderDetailsViewController() -> OrderDetailsViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Orders", storyboardControllerId: "OrderDetailsViewController")
    }
    
    //MARK: order cancelation , account delete
    class func getOrderCancelationVC(_ delegate : OrderCancelationVCAction) -> OrderCancelationVC {
        
        let cancelVc : OrderCancelationVC =  ElGrocerViewControllers.initializeControllerFromStoryboard("SecondCheckOut", storyboardControllerId: "OrderCancelationVC")
        cancelVc.delegate = delegate
        return cancelVc
    }
    
    // MARK: Privacy Policy
    
    class func privacyPolicyViewController() -> PrivacyPolicyViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Setting", storyboardControllerId: "PrivacyPolicyVC")
    }
    
    class func changePasswordViewController() -> ChangePasswordViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Setting", storyboardControllerId: "ChangePasswordViewController")
    }
    class func savedRecipeViewController() -> savedRecipesVC {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("RecipeStory", storyboardControllerId: "savedRecipesVC")
    }
    
    class func savedCarsViewController() -> savedCarsVC {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Setting", storyboardControllerId: "savedCarsVC")
    }
    
    class func recipesListViewController() -> RecipesListViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("RecipeStory", storyboardControllerId: "RecipesListViewController")
    }
    class func recipesBoutiqueListVC() -> RecipeBoutiqueListVC {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("RecipeStory", storyboardControllerId: "RecipeBoutiqueListVC")
    }
    
    //recipe controllers
    
    class func failureReloadViewController() -> FailureViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("Failure", storyboardControllerId: "FailureViewController")
    }
    
    class func recipesDetailViewController() -> RecipeDetailViewController {
        let recipeDetail : RecipeDetailViewController  = ElGrocerViewControllers.initializeControllerFromStoryboard("RecipeStory", storyboardControllerId: "RecipeDetailViewController")
        recipeDetail.addToBasketMessageDisplayed = {
            let msg = NSLocalizedString("product_added_to_basket", comment: "")
            ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(named: "lbl_edit_Added") , -1 , false) { (sender , index , isUnDo) in  }
        }
        return recipeDetail
    }
    //
    class func recipeDetailViewController() -> RecipeDetailVC {
        let recipeDetail : RecipeDetailVC  = ElGrocerViewControllers.initializeControllerFromStoryboard("RecipeStory", storyboardControllerId: "RecipeDetailVC")
        recipeDetail.addToBasketMessageDisplayed = {
            let msg = NSLocalizedString("product_added_to_basket", comment: "")
            ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(named: "lbl_edit_Added") , -1 , false) { (sender , index , isUnDo) in  }
        }
        return recipeDetail
    }
    //
    class func recipeFilterViewController() -> FilteredRecipeViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("RecipeStory", storyboardControllerId: "FilteredRecipeViewController")
    }
    
    
    // advert
    
    class func getAdvertBrandViewController() -> AdvertBrandViewController {
        let storyboard = UIStoryboard(name: "AdvertBanners", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "AdvertBrandViewController") as! AdvertBrandViewController
    }
    
    
    // MARK: GenericView New UI 
    
    class func ElgrocerParentTabbarController() -> ElgrocerParentTabbarController {
        
        return ElGrocerViewControllers.initializeControllerFromStoryboard("GenericStoreView", storyboardControllerId: "ElgrocerParentTabbarController")
        
    }
    
   
    
    class func getGenericStoresViewController( _ homeHandler : HomePageData? = nil) -> GenericStoresViewController {
        
        let storyboard = UIStoryboard(name: "GenericStoreView", bundle: Bundle(for: self))
        let storeVc = storyboard.instantiateViewController(withIdentifier: "GenericStoresViewController") as! GenericStoresViewController
        if let handlerAvailable = homeHandler {
            storeVc.homeDataHandler = handlerAvailable
        }
        return storeVc
    }
    
    class func getClickAndCollectMapViewController() -> ClickAndCollectMapViewController {
        
        let storyboard = UIStoryboard(name: "GenericStoreView", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "ClickAndCollectMapViewController") as! ClickAndCollectMapViewController
    }
    
    
    
    
    class func getSearchListViewController() -> SearchListViewController {
        
        let storyboard = UIStoryboard(name: "GenericStoreView", bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "SearchListViewController") as! SearchListViewController
    }
    
    
    class func getUniversalSearchViewController() -> UniversalSearchViewController {
        
        let storyboard = UIStoryboard(name: "Common" , bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "UniversalSearchViewController") as! UniversalSearchViewController
    }
    
    class func getBrandDeepLinksVC() -> BrandDeepLinksVC {
        
        let storyboard = UIStoryboard(name: "Common" , bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "BrandDeepLinksVC") as! BrandDeepLinksVC
    }
    
    class func getGlobalSearchResultsViewController() -> GlobalSearchResultsViewController {
        
        let storyboard = UIStoryboard(name: "Common" , bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "GlobalSearchResultsViewController") as! GlobalSearchResultsViewController
    }
    
    
    
    class func getGroceryFromBottomSheetViewController() -> GroceryFromBottomSheetViewController {
        let storyboard = UIStoryboard(name: "Common" , bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "GroceryFromBottomSheetViewController") as! GroceryFromBottomSheetViewController
    }
    
    class func getElgrocerClickAndCollectGroceryDetailViewController() -> ElgrocerClickAndCollectGroceryDetailViewController {
        let storyboard = UIStoryboard(name: "Common" , bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "ElgrocerClickAndCollectGroceryDetailViewController") as! ElgrocerClickAndCollectGroceryDetailViewController
    }
    
    //MARK: DeepLink
    class func getDeepLinkBottomGroceryVC() -> DeepLinkBottomGroceryVC {
        let storyboard = UIStoryboard(name: "DeepLink" , bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "DeepLinkBottomGroceryVC") as! DeepLinkBottomGroceryVC
    }
    
    
    // MARK: SecondCheckout VC
    
    class func myBasketPlaceOrderVC() -> MyBasketPlaceOrderVC {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("SecondCheckOut", storyboardControllerId: "myBasketCheckoutVC")
    }
    
    //MARK: new home UI
    //hyperMarketVC
    class func getHyperMarketViewController() -> HyperMarketViewController {
        let storyboard = UIStoryboard(name: "GenericStoreView" , bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "HyperMarketViewController") as! HyperMarketViewController
    }
    class func getSpecialtyStoresGroceryViewController() -> SpecialtyStoresGroceryViewController {
        let storyboard = UIStoryboard(name: "GenericStoreView" , bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "SpecialtyStoresGroceryViewController") as! SpecialtyStoresGroceryViewController
    }

    class func getShopByCategoriesViewController() -> ShopByCategoriesViewController {
        let storyboard = UIStoryboard(name: "GenericStoreView" , bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: "ShopByCategoriesViewController") as! ShopByCategoriesViewController
    }

        // MARK: SendBirdListViewController
    
    class func getDeskListVc() -> SendBirdListViewController {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("SendBird", storyboardControllerId: "SendBirdListViewController")
    }

    // MARK: SmilePointsViewController
    class func getSmilePointsVC() -> SmilesHomeVC {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("SmilePoints", storyboardControllerId: "SmilesHomeVC")
    }
    
    class func getSmileLoginVC() -> SmilesLoginVC {
        return ElGrocerViewControllers.initializeControllerFromStoryboard("SmilePoints", storyboardControllerId: "SmilesLoginVC")
    }
    
}



