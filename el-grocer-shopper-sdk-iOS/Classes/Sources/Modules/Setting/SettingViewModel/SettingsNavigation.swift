//
//  SettingsNavigation.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 13/05/2023.
//

import Foundation


enum SettingNavigationUseCase {
    case Login
    case SignUp
    case EditProfile
    case SignOut
}

class SettingsNavigation {
    
    var controller: SettingViewController!
    init(_ settingVc: SettingViewController) {
        self.controller = settingVc
    }
    
    func handleNavigation(with type: Any) {
        switch type as? SettingNavigationUseCase {
        case .SignUp:
            showRegistrationVC()
        case .Login:
            showRegistrationVC()
        case .EditProfile:
            if !UserDefaults.isUserLoggedIn() {
                showRegistrationVC()
            }else {
                self.editPressed()
            }
        case .SignOut:
            signOutUser()
        case .none:
            break
        }
        
        switch type as? SettingCellType {
        case .liveChat:
            showLiveChat()
        case .Recipes:
            showRecipeDetial()
        case .SaveCars:
            goToSavedCarsVC()
        case .Address:
            showDeliveryAddressVC()
        case .Orders:
            showOrderVC()
        case .PaymentMethods:
            goToAddNewCardVC()
        case .ElWallet:
            goToElWalletVC()
        case .Password:
            goToChangePasswordVC()
        case .DeleteAccount:
            showDeleteAccountVC()
        case .LanguageChange:
            showLanguageSelectionVC()
        case .TermsAndConditions:
            navigateToPrivacyPolicyViewControllerWithTermsEnable(true)
        case .PrivacyPolicy:
            navigateToPrivacyPolicyViewControllerWithTermsEnable(true)
        case .Faqs:
            showFAQs()
        case .none:
            break
        case .some(.UserNotLogin):
            showRegistrationVC()
        case .some(.UserLogin):
            break;
        case .some(.SignOut):
            signOutUser()
        case .some(.default):
            break
        }
    }
    
 
    private func showRecipeDetial() {
        
        let recipeStory = ElGrocerViewControllers.recipesListViewController()
        let navigationController = ElGrocerNavigationController.init(rootViewController: recipeStory)
        navigationController.modalPresentationStyle = .fullScreen
        self.controller.navigationController?.present(navigationController, animated: true, completion: { });
        
    }
    
    private func showLiveChat(){
        
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("LiveChat")
        let sendBirdManager = SendBirdDeskManager(controller: self.controller, orderId: "0", type: .agentSupport)
        sendBirdManager.setUpSenBirdDeskWithCurrentUser()
        
    }
    
    private func showRegistrationVC(){
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("CreateAccount")
        let signInVC = ElGrocerViewControllers.signInViewController()
        signInVC.isForLogIn = false
        signInVC.isCommingFrom = .cart
        signInVC.dismissMode = .dismissModal
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [signInVC]
        navController.modalPresentationStyle = .fullScreen
        self.controller.present(navController, animated: true, completion: nil)
    }
    
    private func showDeliveryAddressVC(){
        let locationVC = ElGrocerViewControllers.dashboardLocationViewController()
        self.controller.navigationController?.pushViewController(locationVC, animated: true)
    }
    
    private func showRequestsVC(){
        
        let requestsVC = ElGrocerViewControllers.requestsViewController()
        requestsVC.isNavigateToRequest = true
        requestsVC.modalPresentationStyle = .fullScreen
        self.controller.navigationController?.pushViewController(requestsVC, animated: true)
    }
    
    private func showFAQs(){
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("FAQ")
        let faqVC = ElGrocerViewControllers.faqViewController()
        self.controller.navigationController?.pushViewController(faqVC, animated: true)
    }
    
    private func showNotification(){
        // Notifications
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_notification")
        let sendBirdManager = SendBirdDeskManager(controller: self.controller, orderId: "0", type: .agentSupport)
        sendBirdManager.setUpSenBirdDeskWithCurrentUser()
    }
    
    private func showLanguageSelectionVC() {
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("ChangeLanguage")
        let languageController = ElGrocerViewControllers.languageViewController()
        languageController.isFromSetting = true
        self.controller.navigationController?.pushViewController(languageController, animated: true)
    }
    private func showDeleteAccountVC() {
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("DeleteAccount")
        let deleteAccountVC = ElGrocerViewControllers.getAccountDeletionReasonsVC()
        self.controller.navigationController?.pushViewController(deleteAccountVC, animated: true)
    }
    
    private func showOrderVC(){
        
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("MyOrders")
        let ordersController = ElGrocerViewControllers.ordersViewController()
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [ordersController]
        navigationController.modalPresentationStyle = .fullScreen
        MixpanelEventLogger.trackProfileMyOrders()
        self.controller.present(navigationController, animated: true, completion: { });
 
    }
    
    private func showManageCard(){
        
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("ManageCards")
        
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let creditVC = CreditCardListViewController(nibName: "CreditCardListViewController", bundle: Bundle.resource)
        creditVC.userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        creditVC.isFromSetting = true
        let navigation = ElgrocerGenericUIParentNavViewController.init(rootViewController: creditVC)
        navigation.modalPresentationStyle = .fullScreen
        self.controller.present(navigation, animated: true, completion: nil)
   
    }
    
    fileprivate func signOutUser(){
        
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("signed_out")
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("SignOut")
        // Sign Out
        ElGrocerAlertView.createAlert(localizedString("sign_out_alert_title", comment: ""),
                                      description: localizedString("sign_out_alert_description", comment: ""),
                                      positiveButton: localizedString("sign_out_alert_yes", comment: ""),
                                      negativeButton: localizedString("sign_out_alert_no", comment: ""),
                                      buttonClickCallback: { (buttonIndex:Int) -> Void in
                                        if buttonIndex == 0 {
                                             let SDKManager = SDKManager.shared
                                            if UIApplication.topViewController() is GenericProfileViewController {
                                                SDKManager.currentTabBar?.dismiss(animated: false, completion: {
                                                    SDKManager.logoutAndShowEntryView()
                                                })
                                            }else {
                                                SDKManager.logoutAndShowEntryView()
                                            }
                                           
                                        }else{
                                             FireBaseEventsLogger.trackSignOut(false)
                                        }
        }).show()
    }
    
    
    private func navigateToPrivacyPolicyViewControllerWithTermsEnable(_ isTermsEnable:Bool = false){
        
        if isTermsEnable {
            ElGrocerEventsLogger.sharedInstance.trackSettingClicked("TermsConditions")
        }else{
            ElGrocerEventsLogger.sharedInstance.trackSettingClicked("PrivacyPolicy")
        }
        let ew = ElGrocerViewControllers.privacyPolicyViewController()
        ew.isTermsAndConditions = isTermsEnable
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [ew]
        navigationController.modalPresentationStyle = .fullScreen
        self.controller.navigationController?.present(navigationController, animated: true, completion: nil)

    }
    
    
    private func goToChangePasswordVC() {
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("ChangePassword")
        let passVC = ElGrocerViewControllers.changePasswordViewController()
        passVC.modalPresentationStyle = .fullScreen
        self.controller.navigationController?.pushViewController(passVC, animated: true)
    }
    
    private func goToSavedRecipesVC() {
        
        //ElGrocerEventsLogger.sharedInstance.trackSettingClicked(FireBaseScreenName.SavedRecipes.rawValue)
        ElGrocerEventsLogger.sharedInstance.trackRecipeViewAllClickedFromNewGeneric(source: FireBaseScreenName.SavedRecipes.rawValue)
        let passVC = ElGrocerViewControllers.savedRecipeViewController()
        passVC.modalPresentationStyle = .fullScreen
        //  passVC.hidesBottomBarWhenPushed = true
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [passVC]
        navigationController.modalPresentationStyle = .fullScreen
        self.controller.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    private func goToSavedCarsVC() {
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("saved recipes")
        let passVC = ElGrocerViewControllers.savedCarsViewController()
        passVC.modalPresentationStyle = .fullScreen
        //  passVC.hidesBottomBarWhenPushed = true
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [passVC]
        navigationController.modalPresentationStyle = .fullScreen
        //self.navigationController?.present(navigationController, animated: true, completion: nil)
        self.controller.navigationController?.pushViewController(passVC, animated: true)
    }
    
    private func editPressed(){
        if UserDefaults.isUserLoggedIn(){
            let editProfileVC = ElGrocerViewControllers.editProfileViewController()
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            editProfileVC.userProfile = userProfile
            self.controller.navigationController?.pushViewController(editProfileVC, animated: true)
            return
        
        }
    }

    
    
    private func goToElWalletVC() {
        
            //ElGrocerEventsLogger.sharedInstance.trackSettingClicked("saved recipes")
        let passVC = ElGrocerViewControllers.getElWalletHomeVC()
        passVC.modalPresentationStyle = .fullScreen
        
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [passVC]
        navigationController.modalPresentationStyle = .fullScreen
        self.controller.navigationController?.pushViewController(passVC, animated: true)
    }
    
    private func goToAddNewCardVC() {
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("saved recipes")
        let passVC = ElGrocerViewControllers.savedCarsViewController()
        passVC.modalPresentationStyle = .fullScreen
        passVC.saveType = .addNewCard
        //  passVC.hidesBottomBarWhenPushed = true
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [passVC]
        navigationController.modalPresentationStyle = .fullScreen
        //self.navigationController?.present(navigationController, animated: true, completion: nil)
        self.controller.navigationController?.pushViewController(passVC, animated: true)
    }
    
    
}
