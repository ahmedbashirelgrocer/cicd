//
//  ZenDesk.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 31/01/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//




import Foundation
//import SupportSDK
//import ZendeskCoreSDK
//import AnswerBotSDK
//import AnswerBotProvidersSDK
//import ChatSDK
//import ChatProvidersSDK
//import MessagingSDK
//import Messages
//import CommonUISDK

private let ZenDeskSharedInstance = ZenDesk()

class ZenDesk : NSObject  { // ,  JWTAuthenticator
    
    
    private var currentUser : UserProfile? = nil
    private let clienID = "mobile_sdk_client_66423bf53f3281ddcdee"
    private let appId = "9ddd899ed6fbbdad03e2d1d36dee50ec8843f11b7f6328f1"
    private let appIdChat = "263997238697021441"
    private let zendeskUrl = "https://elgrocer2.zendesk.com"
    private let accountKey = "2Blc8b9vFfSTBvfQIxX5VOqnpr0i0xUy"
    private let sectionIDFaqs = NSNumber.init(value: 360005123859 as Int64)
//    private let sectionIDPrivacy = NSNumber(value: 360005081780 ) // 360018513800
//    private let sectionIDTerms = NSNumber(value: 360005081780 ) // 360018552059
//
    
    private let sectionIDPrivacy =  "360018513800" // 360018513800
    private let sectionIDTerms = "360018552059" // 360018552059
    
    private let platForm =   NSNumber.init(value: 360017101339 as Int64)
    private let orderIDNumber =   NSNumber.init(value: 360017037540 as Int64)
    private let shopperID =  NSNumber.init(value: 360019000499 as Int64)
    
    

    class var sharedInstance: ZenDesk {
        return ZenDeskSharedInstance
    }

    func initailized() {
        
        
//        
//        NotificationCenter.default.addObserver(forName:   Chat.NotificationAuthenticationFailed , object: nil , queue: OperationQueue.main) { (notifcation) in
//            elDebugPrint(notifcation)
//        }
//        
//        NotificationCenter.default.addObserver(forName:   Chat.NotificationMessageReceived , object: nil , queue: OperationQueue.main) { (notifcation) in
//            elDebugPrint(notifcation)
//        }
//        
//        NotificationCenter.default.addObserver(forName:   Chat.NotificationChatEnded , object: nil , queue: OperationQueue.main) { (notifcation) in
//            elDebugPrint(notifcation)
//        }
      
        
//        Zendesk.initialize(appId: appId, clientId: clienID, zendeskUrl: zendeskUrl)
//        Support.initialize(withZendesk: Zendesk.instance)
//        AnswerBot.initialize(withZendesk: Zendesk.instance, support: Support.instance!)
//        Chat.initialize(accountKey: accountKey , appId: appIdChat , queue: DispatchQueue.main)
        self.identifyUser()
      //  CommonTheme.currentTheme.primaryColor = UIColor.navigationBarColor()
        
      //  CoreLogger.enabled = Platform.isDebugBuild
      //  CoreLogger.logLevel = .debug
        
//        if let deviceToken = UserDefaults.getDevicePushToken() {
//            self.registerToken(deviceToken: deviceToken)
//
//        }
    
        //  Notification.Name("deviceToken")
//        NotificationCenter.default.addObserver(forName: Notification.Name("deviceToken") , object: nil , queue: OperationQueue.main) { (notifcation) in
//            let deviceTOken = notifcation.object
//            if deviceTOken is String {
//                self.registerToken(deviceToken: deviceTOken as! String)
//
//            }
//        }
    }
    
    func registerToken (deviceToken : String) {
//        if let instance = Zendesk.instance {
//            Chat.pushNotificationsProvider?.registerPushTokenString(deviceToken)
//            Chat.registerPushTokenString(deviceToken)
//            ZDKPushProvider(zendesk: instance).register(deviceIdentifier: deviceToken  , locale: ElGrocerUtility.sharedInstance.isArabicSelected() ? "ar" : "en") { (pushResponse, error) in
//              // elDebugPrint("Couldn't register device: \(deviceToken). Error: \(error)")
//                if error != nil {
//                    self.registerToken(deviceToken: deviceToken)
//                }
//            }
//        }
    }
    
    func presentRequest(with requestID: String) {
    //    let viewController = RequestUi.buildRequestUi(requestId: requestID)
       
        
//        DispatchQueue.main.async {
//            if let topVc = UIApplication.topViewController() {
//                topVc.navigationController?.pushViewController(viewController, animated: true)
//                //  topVc.present(chatController, animated: true)
//                topVc.navigationController?.navigationBar.tintColor = .navigationBarColor()
//                (viewController.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
//                (viewController.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
//                (viewController.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
//                (viewController.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
//                (viewController.navigationController as? ElGrocerNavigationController)?.setSearchBarText("")
//
//            }
//        }
        
        
    }
    
    var authToken: String = "" {
        didSet {
            guard !authToken.isEmpty else {
               // resetVisitorIdentity()
                return
            }
           // Chat.instance?.setIdentity(authenticator: self)
        }
    }
    
    
    func resetVisitorIdentity() {
       // Chat.instance?.resetIdentity(nil)
    }
    
    func getToken(_ completion: @escaping (String?, Error?) -> Void) {
       // completion(authToken, nil)
    }
    
    
    @discardableResult func reloadCurrentUser () -> UserProfile? {
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
        currentUser = userProfile
        return userProfile
    }
    
    
    func identifyUser() {
        self.reloadCurrentUser ()
       // var ident = Identity.createAnonymous()
//        if currentUser != nil {
//            if let email = currentUser?.email {
//                ident = Identity.createAnonymous(name: currentUser?.name ?? "" , email: email)
//            }
//        }
//        Zendesk.instance?.setIdentity(ident)
//        getToken { (token, error) in
//            elDebugPrint("token: \(String(describing: token))")
//        }
    }
    /*
    
    func getchatConfiguration(_ orderID : String? = nil , _ currentUser : UserProfile? = nil , _ visitor :  VisitorInfo? = nil) -> ChatConfiguration {
        
        
        defer {
            Chat.instance?.clearCache()
            let chatAPIConfiguration = ChatAPIConfiguration()
            chatAPIConfiguration.department = "Shopper"
            chatAPIConfiguration.visitorInfo = visitor
            let sid = "sid:\(currentUser?.dbID.stringValue ?? "")"
            let oid = "oid:\(orderID ?? "")"
            chatAPIConfiguration.tags = [sid , oid  , "IOS", "Shopper" ]
           
            Chat.instance?.profileProvider.addTags( [sid , oid  , "IOS", "Shopper" ] )
            Chat.instance?.profileProvider.setNote([sid , oid  , "IOS", "Shopper" ].joined(separator: ","))
        }
    
        


        let chatConfiguration =  ChatConfiguration()
        let preChatConfig = ChatFormConfiguration.init(name: .required, email: .required, phoneNumber: .optional , department: .hidden)
        chatConfiguration.isPreChatFormEnabled = false
        chatConfiguration.isAgentAvailabilityEnabled = true
        chatConfiguration.preChatFormConfiguration = preChatConfig
        chatConfiguration.chatMenuActions = [ChatMenuAction.endChat , ChatMenuAction.emailTranscript]
        return chatConfiguration
        
        
    }
    
    
    func buildUI(_ orderID : String? = nil) throws -> UIViewController {
        
        self.reloadCurrentUser()
        self.identifyUser()
        
        var visInfo : VisitorInfo? = nil
        if currentUser != nil {
            visInfo = VisitorInfo(name: currentUser?.name ?? "", email: currentUser?.email ?? "", phoneNumber: currentUser?.phone ?? "")
        }
        CommonTheme.currentTheme.primaryColor = .navigationBarColor()
        let customFieldPlatForm = CustomField.init(dictionary: ["id": platForm, "value": "IOS"])
        let customFieldOrderID = CustomField.init(dictionary: ["id": orderIDNumber, "value": orderID == nil ? "" : orderID ?? "" ])
        let customFieldShopperID = CustomField.init(dictionary: ["id": shopperID , "value": currentUser?.dbID.stringValue ?? ""])
        let config = RequestUiConfiguration.init()
        config.subject = "IOS Shopper Support"
        config.tags = ["IOS", "Shopper"  ]
        config.customFields = [customFieldPlatForm , customFieldOrderID , customFieldShopperID ]
        
        let apiConfigration = self.getchatConfiguration(orderID, currentUser, visInfo)
        let requestUI =  RequestUi.buildRequestList(with: [config , apiConfigration ])
        return requestUI
    }
    
    
    func showChatWithReplacingCurrentNavigation( orderID : String? = nil , inNavigation : UINavigationController?)  {
        
        guard inNavigation != nil else {
            self.showChat(orderID: orderID)
            return
        }
        self.identifyUser()
        let chatScreen : UIViewController?
        do {
            chatScreen = try buildUI(orderID)
        }catch {
            self.showChat(orderID: orderID)
            return
        }
        if chatScreen != nil {
            var vcArray = inNavigation!.viewControllers
            vcArray.removeLast()
            vcArray.append(chatScreen!)
            inNavigation?.setViewControllers(vcArray, animated: false)
            DispatchQueue.main.async {
                chatScreen?.navigationController?.navigationBar.tintColor = .navigationBarColor()
                (chatScreen?.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
                (chatScreen?.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
                (chatScreen?.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
                (chatScreen?.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
                (chatScreen?.navigationController as? ElGrocerNavigationController)?.setSearchBarText("")
            }
        }else{
            self.showChat(orderID: orderID)
        }
        
    }
    
 
    func showChat( orderID : String? = nil)  {
        do {
            try self.buildChatController(orderID)
            
        }catch {
            elDebugPrint("Faileur chat")
        }
        
    }
    
    
    
    
    func buildLiveChatUI(_ orderID : String? = nil) throws -> UIViewController {
        
        self.reloadCurrentUser()
        self.identifyUser()
        var visInfo : VisitorInfo? = nil
        if currentUser != nil {
             visInfo = VisitorInfo(name: currentUser?.name ?? "", email: currentUser?.email ?? "", phoneNumber: currentUser?.phone ?? "")
        }
        CommonTheme.currentTheme.primaryColor = .navigationBarColor()
        let customFieldPlatForm = CustomField.init(dictionary: ["id": platForm, "value": "IOS"])
        let customFieldOrderID = CustomField.init(dictionary: ["id": orderIDNumber, "value": orderID == nil ? "" : orderID ?? "" ])
        let customFieldShopperID = CustomField.init(dictionary: ["id": shopperID , "value": currentUser?.dbID.stringValue ?? ""])
        let config = RequestUiConfiguration.init()
        let sid = "sid:\(currentUser?.dbID.stringValue ?? "")"
        let oid = "oid:\(orderID ?? "")"
        config.tags = ["IOS", "Shopper" , sid , oid  ]
        config.customFields = [customFieldPlatForm , customFieldOrderID , customFieldShopperID ]
        let messagingConfiguration = MessagingConfiguration()
        messagingConfiguration.name = "elGrocer Support"
        let answerBotEngine = try AnswerBotEngine.engine()
        let supportEngine = try SupportEngine.engine()
        let chatEngine = try ChatEngine.engine()
        let apiConfiguration = self.getchatConfiguration(orderID, currentUser, visInfo)
        return try Messaging.instance.buildUI(engines: [answerBotEngine, supportEngine, chatEngine],
                                                            configs: [config ,messagingConfiguration , apiConfiguration ])
    }
    
    
    func showLiveChat(orderID : String? = nil) {
        do {
            let viewController = try self.buildLiveChatUI(orderID)
            viewController.hidesBottomBarWhenPushed  = true
            self.goToChatCOntroller(viewController: viewController)
        }catch {
            return
        }
    }
    
    func showLiveChatWithReplacingCurrentNavigation( orderID : String? = nil , inNavigation : UINavigationController?)  {
        
        guard inNavigation != nil else {
            self.showLiveChat(orderID: orderID)
            NotificationCenter.default.post(name: KChatNotifcation, object: false)
            return
        }
        self.identifyUser()
        let chatScreen : UIViewController?
        do {
            chatScreen = try buildLiveChatUI(orderID)
        }catch {
            self.showLiveChat(orderID: orderID)
            NotificationCenter.default.post(name: KChatNotifcation, object: false)
            return
        }
        if chatScreen != nil {
            var vcArray = inNavigation!.viewControllers
            vcArray.removeLast()
            vcArray.append(chatScreen!)
            inNavigation?.setViewControllers(vcArray, animated: false)
            DispatchQueue.main.async {
                chatScreen?.navigationController?.navigationBar.tintColor = .navigationBarColor()
                (chatScreen?.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
                (chatScreen?.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
                (chatScreen?.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
                (chatScreen?.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
                (chatScreen?.navigationController as? ElGrocerNavigationController)?.setSearchBarText("")
                NotificationCenter.default.post(name: KChatNotifcation, object: false)
            }
        }else{
            self.showLiveChat(orderID: orderID)
        }
        
    }
   
   func buildChatController(_ orderID : String? = nil) throws {
        self.identifyUser()
        let viewController = try buildUI(orderID)
        
            self.goToChatCOntroller(viewController: viewController)
      
    }
    
    func goToChatCOntroller (viewController : UIViewController) {
        DispatchQueue.main.async {
            if let topVc = UIApplication.topViewController() {
                topVc.navigationController?.pushViewController(viewController, animated: true)
                //  topVc.present(chatController, animated: true)
                topVc.navigationController?.navigationBar.tintColor = .navigationBarColor()
                (viewController.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
                (viewController.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
                (viewController.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
                (viewController.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
                (viewController.navigationController as? ElGrocerNavigationController)?.setSearchBarText("")
                (viewController.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
                NotificationCenter.default.post(name: KChatNotifcation, object: false)
            }
        }
        
        
        
    }
    
    
    @objc private func dismiss() {
        if let topVc = UIApplication.topViewController() {
           //  topVc.dismiss(animated: true, completion: nil)
            //topVc.present(helpCenter, animated: true, completion: nil)
            topVc.navigationController?.popViewController(animated: true)
        }
    }
  
    func presentFaQsHelpCenter() {
        
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("FAQ")
        
        do {
            
            self.identifyUser()
          //  let answerBotEngine = try AnswerBotEngine.engine()
            let helpCenterUiConfig = HelpCenterUiConfiguration()
            helpCenterUiConfig.showContactOptions = false
           // helpCenterUiConfig.engines = [answerBotEngine]
            helpCenterUiConfig.groupType = .section
            helpCenterUiConfig.groupIds = [sectionIDFaqs]
        
            let articleUiConfig = ArticleUiConfiguration()
            //articleUiConfig.engines = [answerBotEngine]
            let helpCenterViewController = HelpCenterUi.buildHelpCenterOverviewUi(withConfigs: [helpCenterUiConfig, articleUiConfig])
            DispatchQueue.main.async {
                if let topVc = UIApplication.topViewController() {
                    topVc.navigationController?.navigationBar.tintColor = .navigationBarColor()
                    topVc.navigationController?.pushViewController(helpCenterViewController, animated: true)
                }
                
                (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
                (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
                (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
                (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
                (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setSearchBarText("")
                
            }
       
        } catch {
            self.showFAQs()
            // do something with error
        }
    }

    
    func presentPrivacyHelpCenter() {
        
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("PrivacyPolicy")
        do {
            self.identifyUser()
            let articleUiConfig = ArticleUiConfiguration()
            articleUiConfig.showContactOptions = false
            let helpCenterViewController = HelpCenterUi.buildHelpCenterArticleUi(withArticleId: sectionIDPrivacy , andConfigs: [articleUiConfig])
            DispatchQueue.main.async {
                if let topVc = UIApplication.topViewController() {
                    topVc.navigationController?.navigationBar.tintColor = .navigationBarColor()
                    topVc.navigationController?.pushViewController(helpCenterViewController, animated: true)
                    (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
                    (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
                    (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
                    (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
                    (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setSearchBarText("")
                }
            }
            
        } catch {
            self.navigateToPrivacyPolicyViewControllerWithTermsEnable(false)
        }
    }
    
    
    func presentTermAndConditionsHelpCenter() {
        
            ElGrocerEventsLogger.sharedInstance.trackSettingClicked("TermsConditions")
  
        do {
            self.identifyUser()
            let articleUiConfig = ArticleUiConfiguration()
            articleUiConfig.showContactOptions = false
            let helpCenterViewController = HelpCenterUi.buildHelpCenterArticleUi(withArticleId: sectionIDTerms , andConfigs: [articleUiConfig])
            DispatchQueue.main.async {
                if let topVc = UIApplication.topViewController() {
                    topVc.navigationController?.navigationBar.tintColor = .navigationBarColor()
                    topVc.navigationController?.pushViewController(helpCenterViewController, animated: true)
                    (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
                    (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
                    (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
                    (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
                    (helpCenterViewController.navigationController as? ElGrocerNavigationController)?.setSearchBarText("")
                }
            }
      
        } catch {
            self.navigateToPrivacyPolicyViewControllerWithTermsEnable(true)
        }
    }
    
    
    private func navigateToPrivacyPolicyViewControllerWithTermsEnable(_ isTermsEnable:Bool = false){
        
       
        let ew = ElGrocerViewControllers.privacyPolicyViewController()
        ew.isTermsAndConditions = isTermsEnable
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [ew]
        navigationController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async { [weak self] in
            if let topVc = UIApplication.topViewController() {
                topVc.navigationController?.present(navigationController, animated: true, completion: nil)
                
                
            }
        }
    }
    
    
    fileprivate func showFAQs(){
       
        let faqVC = ElGrocerViewControllers.faqViewController()
        DispatchQueue.main.async {
            if let topVc = UIApplication.topViewController() {
                topVc.navigationController?.present(faqVC, animated: true, completion: nil)
            }
        }
    }

    */
    
    
}
