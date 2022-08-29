//
//  SendBirdDeskManager.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 07/11/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
// ticketID: 7480421

import UIKit
import SendBirdDesk
import SendBirdSDK
import SendBirdUIKit
import CleverTapSDK
import IQKeyboardManagerSwift

enum SendBirdDeskType {
    case orderSupport
    case agentSupport
}

class SendBirdDeskManager{

    //let APP_ID = "F061BADA-1171-4478-8CFB-CBACC012301C"
    let shoperPrefix = "s_"
    let OrderUrlPrefix = "Order: "
    let SupportUrlPrefix = "Support: "
    
    var controller: UIViewController?
    var orderId: String?
    var groceryId: String?
    var deskType: SendBirdDeskType?
    var openOffset: Int = 0
    var closeOffset: Int = 0
    var openTickets: [SBDSKTicket]?
    var closeTickets: [SBDSKTicket]?
    
    init(type: SendBirdDeskType){
        self.openOffset = 0
        self.closeOffset = 0
        self.deskType = type
        initialise()
//        setUpSenBirdDeskWithCurrentUser(isWithChat: false)
    }
    
    init(controller: UIViewController, orderId: String?,type: SendBirdDeskType, _ groceryId : String? = nil) {
        
//        setUpSenBirdDeskWithCurrentUser()
        initialise()
        self.controller = controller
        self.orderId = orderId
        self.deskType = type
        self.openOffset = 0
        self.closeOffset = 0
        self.groceryId = groceryId
    }
    
    func getCurrentUser() -> UserProfile? {
        
        if UserDefaults.isUserLoggedIn(){
            let user = UserProfile.getOptionalUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            return user
        }else{
            return nil
        }
    }
    func initialise() {
        
         SBDMain.initWithApplicationId(SendBirdManager().APP_ID)
         SBDSKMain.initializeDesk()
       // SBDMain.setLogLevel([.error, .info])
    }
    func setUpSenBirdDeskWithCurrentUser(isWithChat:Bool = true){
        // Specify your Sendbird application ID.
        
        initialise()
        if isWithChat{
            self.logIn(isWithChat: isWithChat) {
               elDebugPrint("login called")
            }
        }else{
            SendBirdManager().setUpCurrentUserWithPlatform()
            return
        }
    }
    
    func loginSBUUserForChat(id: String, name: String){
        SBUGlobals.CurrentUser = SBUUser(userId: shoperPrefix + id, nickname: name, profileUrl: nil)
        SBUMain.connect { (user, error) in
            guard error == nil else {
                // Handle error.
               // error?.showSBDErrorAlert()
                return
            }
            if let obtainedUser = user{
                SBUGlobals.CurrentUser = SBUUser(user: obtainedUser)
            }
            if !(UserDefaults.isDevicePushTokenRegistered() ?? false){
                if let token = UserDefaults.getDevicePushTokenData(){
                    self.registerPushNotification(token) { (success) in
                        if success{
                           elDebugPrint("registered")
                        }
                    }
                }
            }
            
        }
    }
    
    func logIn(isWithChat: Bool = false,completionHandler: (() -> Void)?) {
        
        
        if isWithChat, let user = SBDMain.getCurrentUser() {
            
            if let topVc = UIApplication.topViewController() {
                let _ = SpinnerView.showSpinnerViewInView(topVc.view)
            }
          
            SBDSKMain.authenticate(withUserId: user.userId, accessToken: nil) { (error) in
                
                SpinnerView.hideSpinnerView()
                
                guard error == nil else {
                    FireBaseEventsLogger.trackCustomEvent(eventType: "Chat", action: "authenticate", ["user.id" : user.userId , "error" : error?.localizedDescription ?? ""], true)
                  //  error?.showSBDErrorAlert()
                    return
                }
                
                if !(UserDefaults.isDevicePushTokenRegistered() ?? false){
                    if let token = UserDefaults.getDevicePushTokenData(){
                        self.registerPushNotification(token) { (success) in
                            if success{
                               elDebugPrint("registered")
                            }
                        }
                    }
                }
                
                if isWithChat {
                    self.attachCustomFieldsWithCustomer()
                    self.setUpTicketConfigurationForCustomer()
                }
            }
            return
        }
        
        let group = DispatchGroup()
        group.enter()
        
        if let topVc = UIApplication.topViewController() {
            let _ = SpinnerView.showSpinnerViewInView(topVc.view)
        }
        
        if let user = self.getCurrentUser() {
            let id = shoperPrefix + user.dbID.stringValue
            var name = user.name ?? ""
            if name.isEmptyStr {
                name = user.phone ?? ""
            }
            if name.isEmptyStr {
                name = "NoName"
            }
            
            SBDMain.connect(withUserId: id, accessToken: nil) { (user, error) in
                guard error == nil else {
                    // Handle error.
                    error?.showSBDErrorAlert()
                    group.leave()
                    return
                }
                if user?.nickname == nil {
                    SBDMain.updateCurrentUserInfo(withNickname: name, profileUrl: nil) { (error) in
                        guard error == nil else{
                         
                            FireBaseEventsLogger.trackCustomEvent(eventType: "ChatUserName:\(name)", action: "updateCurrentUserInfo", [ "error" : error?.localizedDescription ?? ""], true)
                            return
                        }
                        SBDSKMain.authenticate(withUserId: user!.userId, accessToken: nil) { (error) in
                            guard error == nil else {
                                FireBaseEventsLogger.trackCustomEvent(eventType: "Chat", action: "authenticate", ["user.id" : user?.userId ?? "", "error" : error?.localizedDescription ?? ""], true)
                              //  error?.showSBDErrorAlert()
                                group.leave()
                                return
                            }
                            if !(UserDefaults.isDevicePushTokenRegistered() ?? false){
                                if let token = UserDefaults.getDevicePushTokenData(){
                                    self.registerPushNotification(token) { (success) in
                                        if success{
                                           elDebugPrint("registered")
                                        }
                                    }
                                }
                            }
                            if isWithChat{
                                self.attachCustomFieldsWithCustomer()
                                self.setUpTicketConfigurationForCustomer()
                            }
//                            group.leave()
                        }
                    }
                }else{
                    // Use the same user ID and access token used in the SBDMain.connect().
                    SBDSKMain.authenticate(withUserId: user!.userId, accessToken: nil) { (error) in
                        guard error == nil else {
                            // Handle error.
                            FireBaseEventsLogger.trackCustomEvent(eventType: "Chat", action: "authenticate", ["user.id" : user?.userId ?? "", "error" : error?.localizedDescription ?? ""], true)
                         //   error?.showSBDErrorAlert()
                            group.leave()
                            return
                        }
                        if !(UserDefaults.isDevicePushTokenRegistered() ?? false){
                            if let token = UserDefaults.getDevicePushTokenData(){
                                self.registerPushNotification(token) { (success) in
                                    if success{
                                       elDebugPrint("registered")
                                    }
                                }
                            }
                        }
                        if isWithChat{
                            self.attachCustomFieldsWithCustomer()
                            self.setUpTicketConfigurationForCustomer()
                        }
                        group.leave()
                    }
                }
            }
        }else{
            
           let anonymousUserId = CleverTapEventsLogger.getCTProfileId()
    
            if var id = anonymousUserId {
                
                if id.isEmptyStr {
                    id  =  UIDevice.current.identifierForVendor?.uuidString ?? "unknownIDs"
                }
                
                let name = "Anonymous"
                
                SBDMain.connect(withUserId: shoperPrefix + id, accessToken: nil) { (user, error) in
                    guard error == nil else {
                        // Handle error.
                        FireBaseEventsLogger.trackCustomEvent(eventType: "Chat", action: "connect", ["user.id" : self.shoperPrefix + id, "error" : error?.localizedDescription ?? ""], true)
                        error?.showSBDErrorAlert()
                        group.leave()
                        return
                    }
                    
                    self.loginSBUUserForChat(id: id, name: name)
                    
                    if user?.nickname == "" {
                        SBDMain.updateCurrentUserInfo(withNickname: name, profileUrl: nil) { (error) in
                            guard error == nil else{
                                FireBaseEventsLogger.trackCustomEvent(eventType: "ChatUserName:\(name)", action: "updateCurrentUserInfo", [ "error" : error?.localizedDescription ?? ""], true)
                                group.leave()
                                return
                            }
                            SBDSKMain.authenticate(withUserId: user!.userId, accessToken: nil) { (error) in
                                guard error == nil else {
                                    // Handle error.
                                    FireBaseEventsLogger.trackCustomEvent(eventType: "Chat", action: "connect", ["user.id" : self.shoperPrefix + id, "error" : error?.localizedDescription ?? ""], true)
                                 //   error?.showSBDErrorAlert()
                                    group.leave()
                                    return
                                }
                                if !(UserDefaults.isDevicePushTokenRegistered() ?? false){
                                    if let token = UserDefaults.getDevicePushTokenData(){
                                        self.registerPushNotification(token) { (success) in
                                            if success{
                                               elDebugPrint("registered")
                                            }
                                        }
                                    }
                                }
                                if isWithChat{
                                    self.attachCustomFieldsWithCustomer()
                                    self.setUpTicketConfigurationForCustomer()
                                }
                                group.leave()
                            }
                        }
                    }else{
                        // Use the same user ID and access token used in the SBDMain.connect().
                        SBDSKMain.authenticate(withUserId: user!.userId, accessToken: nil) { (error) in
                            guard error == nil else {
                                FireBaseEventsLogger.trackCustomEvent(eventType: "Chat", action: "connect", ["user.id" : self.shoperPrefix + id, "error" : error?.localizedDescription ?? ""], true)
                                //error?.showSBDErrorAlert()
                                group.leave()
                                return
                            }
                            if !(UserDefaults.isDevicePushTokenRegistered() ?? false){
                                if let token = UserDefaults.getDevicePushTokenData(){
                                    self.registerPushNotification(token) { (success) in
                                        if success{
                                           elDebugPrint("registered")
                                        }
                                    }
                                }
                            }
                            if isWithChat{
                                self.attachCustomFieldsWithCustomer()
                                self.setUpTicketConfigurationForCustomer()
                            }
                            group.leave()
                        }
                    }
                }
                
            }
//            group.leave()
        }
        
        group.notify(queue: DispatchQueue.global()) {
            SpinnerView.hideSpinnerView()
            completionHandler?()
            //The user has been successfully deauthenticated using this function.
        }
        
        
    }
    
    func setUpTicketConfigurationForCustomer(){
        if let oId = self.orderId, let vc = self.controller,let type = self.deskType,let user = SBDMain.getCurrentUser() {
            
            self.getOpenedTicket { (isFound , openticket, ticketsCount) in
                
                self.handleOpenTicketResponse(isFound: isFound, openTicket: openticket, ticketCount: ticketsCount)
            }
        }
    }
    
    func createTicketWithCustomParams(orderId: String,user: String,controller: UIViewController){
        var customFields = [String: String]()
        var userToSend = user
        var prefixToSend = OrderUrlPrefix
        var orderIdToSend = orderId
        
        if let shopperUser = self.getCurrentUser(){
            customFields["shopperid"] = shopperUser.dbID.stringValue
        }
        
        
        if let type = self.deskType {
            if type == .orderSupport {
                customFields["orderid"] = orderId
                if let grocer = self.groceryId {
                    customFields["retailerid"] = grocer
                }
                prefixToSend = OrderUrlPrefix
                orderIdToSend = orderId  + "_shopper"
            }else if type == .agentSupport{
                customFields["orderid"] = "0"
                prefixToSend = SupportUrlPrefix
                if let user = SBDMain.getCurrentUser(){
                    orderIdToSend = user.userId
                }
            }
        }
        if let userSendBird = SBDMain.getCurrentUser(){
           userToSend = userSendBird.nickname ?? ""
        }
        
        if userToSend.isEmptyStr {
            if UserDefaults.isUserLoggedIn() {
                let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                userToSend = userProfile?.name ?? ""
                if userToSend.isEmptyStr {
                    userToSend = userProfile?.phone ?? ""
                }
            }
        }
        
        if userToSend.isEmptyStr {
            userToSend = "NoName"
        }
        
        SBDSKTicket.createTicket(withTitle: prefixToSend + orderIdToSend , userName: userToSend, groupKey: "", customFields: customFields,priority: SBDSKTicketPriority.medium , relatedChannels: [""]) { (ticket, error) in
            guard error == nil else {
                // Handle error.
                return
            }
            if let ticketChannel = ticket?.channel , let oid = self.orderId{
//                self.callSendBirdChat(orderId: oid, controller: controller, channelUrl: ticketChannelUrl)
                self.navigateTochannelViewController(channel: ticketChannel, controller: controller, orderId: orderId)
            }
        }
    }
    
    func getOpenedTicket(completion:@escaping (Bool, SBDSKTicket?, Int)-> Void){
        
        var found: Bool = false
        var customFieldFilter = [String: String]()
        
        if let shopperUser = self.getCurrentUser(){
         //   customFieldFilter = ["shopperid": shopperUser.dbID.stringValue]
        }
        if let type = self.deskType{
            if type == .orderSupport{
                customFieldFilter["orderid"] = self.orderId
            }else if type == .agentSupport{
               // customFieldFilter["orderid"] = "0"
            }
        }
        SBDSKTicket.getOpenedList(withOffset: self.openOffset, customFieldFilter: customFieldFilter) { (tickets, hasNext, error) in
            guard error == nil else {
                completion(found, nil, 0)
                return
            }
            if let ticketsRecived = tickets {
                if ticketsRecived.count > 0 {
                    if self.openOffset == 0 {
                        self.openTickets = ticketsRecived
                    }else{
                        for tickets in ticketsRecived {
                            self.openTickets?.append(tickets)
                        }
                    }
                    if let openedTickets = self.openTickets, let oid = self.orderId {
                        for ticket in openedTickets{
                            found = true
                            completion(found,ticket, openedTickets.count)
                            break
                            
                        }
                    }
                    if hasNext && !found{
                        self.openOffset = self.openTickets?.count ?? 0
                        self.getOpenedTicket(completion: completion)
                    }
                }else{
                    completion(found,nil, 0)
                }
            }else{
                completion(found,nil, 0)
            }
            
        }
    }
    
    func getCloseTickets(completion:@escaping (Bool,SBDSKTicket?,Int)-> Void){
        
        var found: Bool = false
        var customFieldFilter = [String: String]()
        
        if let shopperUser = self.getCurrentUser(){
            customFieldFilter = ["shopperid": shopperUser.dbID.stringValue]
        }
        if let type = self.deskType{
            if type == .orderSupport{
                customFieldFilter["orderid"] = self.orderId
            }else if type == .agentSupport{
                customFieldFilter["orderid"] = "0"
            }
        }
        
        SBDSKTicket.getClosedList(withOffset: self.closeOffset, customFieldFilter: customFieldFilter) { (tickets, hasNext, error) in
            guard error == nil else {
                // Handle error.
               elDebugPrint(error)
                completion(found, nil,0)
                return
            }
           elDebugPrint("closed Tickets: \(tickets?.count)")
            if let ticketsRecived = tickets{
                if ticketsRecived.count > 0{
                    if self.closeOffset == 0{
                        self.closeTickets = ticketsRecived
                    }else{
                        for tickets in ticketsRecived{
                            self.closeTickets?.append(tickets)
                        }
                    }
                    if let closeTickets = self.closeTickets, let oid = self.orderId{
                        for ticket in closeTickets{
                            found = true
                            completion(found,ticket,closeTickets.count)
                            break
                        }
                    }
                    if hasNext && !found{
                        self.closeOffset = self.openTickets?.count ?? 0
                        self.getCloseTickets(completion: completion)
                    }
                }else{
                    completion(found,nil,0)
                }
            }else{
                completion(found,nil,0)
            }
        }
    }
    
    func closeTicket(ticket: SBDSKTicket){
        ticket.close(withComment: "") { (ticket, error) in
            guard error == nil else {
                // Handle error.
               elDebugPrint(error)
                return
            }

            // Implement your code to close a ticket.
        }
    }
    
    func reOpenTicket(ticket: SBDSKTicket,completion:@escaping (SBDSKTicket?)->Void){
        ticket.reopen { (ticket, error) in
            guard error == nil else {
                // Handle error.
               elDebugPrint(error)
                completion(nil)
                return
            }
            completion(ticket)
        }
    }
    
    func attachCustomFieldsWithCustomer(){
        var customFields = [String: String]()
        customFields["app"] = "Shopper"
        customFields["platform"] = "iOS"
        customFields["smilesdk"] = SDKManager.isSmileSDK ? "true" : "false"
        if let shopperUser = self.getCurrentUser(){
        customFields["shopperid"] =  shopperUser.dbID.stringValue
        } else {
            if let id = CleverTapEventsLogger.getCTProfileId(){
                customFields["shopperid"] = id
            }
        }

        SBDSKMain.setCustomerCustomFields(customFields) { (error) in
            guard error == nil else {
                // Handle error.
               elDebugPrint(error)
                return
            }
        }
    }
    
    func navigateTochannelViewController(channel : SBDGroupChannel , controller : UIViewController , orderId : String){
        
        ElGrocerEventsLogger.sharedInstance.chatWithSupportClicked(orderId: orderId)
        
        if let user = SBDMain.getCurrentUser() {
            let userID = user.userId
            SBUGlobals.CurrentUser = SBUUser(userId: userID, nickname: user.nickname, profileUrl: nil)
        } else {

            if let id = CleverTapEventsLogger.getCTProfileId(){
                let name = "Anonymous"
                SBUGlobals.CurrentUser = SBUUser(userId: shoperPrefix + id, nickname: name, profileUrl: nil)
                
            }
        }
        
        guard let userToAuth = SBUGlobals.CurrentUser else {return}
        
        SBDSKMain.authenticate(withUserId: userToAuth.userId , accessToken: nil) { (error) in
           
            guard error == nil else {
                FireBaseEventsLogger.trackCustomEvent(eventType: "Chat", action: "authenticate", ["user.id" : userToAuth.userId , "error" : error?.localizedDescription ?? ""], true)
                return
            }
            self.attachCustomFieldsWithCustomer()
            
            Thread.OnMainThread {
                
                IQKeyboardManager.shared.enableAutoToolbar = true
                IQKeyboardManager.shared.enable = true
                
                let channelController = ElgrocerChannelController(channel: channel)
                channelController.setOrderId(orderDbId: orderId)
                
                let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                navigationController.viewControllers = [channelController]
                navigationController.modalPresentationStyle = .fullScreen
                
                controller.present(navigationController, animated: true)
            }
            
        }
       
    }
    
    func navigateToChannelList(controller : UIViewController) {
        
        
        guard let user = SBDMain.getCurrentUser() else {return}
        
        Thread.OnMainThread {
            
            let userID = user.userId
            SBUGlobals.CurrentUser = SBUUser(userId: userID, nickname: user.nickname, profileUrl: nil)
            
            let vc = ElGrocerViewControllers.getDeskListVc()
            vc.orderId = self.orderId ?? "0"
            let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navigationController.viewControllers = [vc]
            navigationController.modalPresentationStyle = .fullScreen
            controller.present(navigationController, animated: true)
            
        }

    }
    
    
    func  setUserUpdatedLanguage()  {
        let preferredLanguages =  ElGrocerUtility.sharedInstance.isArabicSelected() ?  ["ar"] : ["en"] // French, German, Spanish, and Korean
        SBDMain.updateCurrentUserInfo(withPreferredLanguages: preferredLanguages, completionHandler: { error in
        })
    }
    
    func callSendBirdChat(orderId: String, controller: UIViewController, channelUrl: String){
        

        self.setUserUpdatedLanguage()
        
        self.checkIfChannelExist(channelUrl: channelUrl) { doesExist, channel in
            if doesExist{
                if let userSendBird = SendBirdManager().getCurrentUser() {
                    let id = self.shoperPrefix + userSendBird.dbID.stringValue
                    if channel.hasMember(id){
                        if self.deskType == .agentSupport {
                            self.navigateTochannelViewController(channel: channel, controller: controller, orderId: "0")
                        } else {
                            self.navigateTochannelViewController(channel: channel, controller: controller, orderId: orderId)
                        }
                    }
                }else{
                    if let anonymousId = CleverTapEventsLogger.getCTProfileId(){
                        let id = self.shoperPrefix + anonymousId
                        if channel.hasMember(id){
                            if self.deskType == .agentSupport {
                                self.navigateTochannelViewController(channel: channel, controller: controller, orderId: "0")
                            } else {
                                self.navigateTochannelViewController(channel: channel, controller: controller, orderId: orderId)
                            }
                        }
                        
                    }
                }
            }else{
                return
            }
        }
    }
    
    func checkIfChannelExist(channelUrl : String , completion: @escaping (Bool , SBDGroupChannel) ->()){
        
        SBDGroupChannel.getWithUrl(channelUrl) { SBDchannel, error in
            guard let channel = SBDchannel , error == nil else{
                completion(false , SBDGroupChannel(dictionary: ["" : ""]))
                return
            }
            completion(true , channel)
        }
    }
    
    //MARK: push notification
    func registerPushNotification(_ deviceToken : Data, completion : @escaping(Bool) -> ()){

        SBDMain.registerDevicePushToken(deviceToken, unique: true, completionHandler: { (status, error) in
            if error == nil {
                completion(true)
                UserDefaults.setIsDevicePushTokenRegistered(true)
            }
            else {
                if status == SBDPushTokenRegistrationStatus.pending {
                    self.setPushNotification(enable: false)
                    UserDefaults.setIsDevicePushTokenRegistered(false)
                } else {
                    // Handle registration failure.
                    completion(false)
                    UserDefaults.setIsDevicePushTokenRegistered(false)
                }
            }
        })
    }

    func setPushNotification(enable: Bool) {
        if enable {
            if let token = SBDMain.getPendingPushToken() {
                SBDMain.registerDevicePushToken(token, unique: true, completionHandler: { (status, error) in
                })
            }
        }
        else {
            if let token = SBDMain.getPendingPushToken() {
                // If you want to unregister the current device only, invoke this method.
                SBDMain.unregisterPushToken(token, completionHandler: { (response, error) in
                    guard error == nil else{
                       elDebugPrint(error)
                        return
                    }
                    UserDefaults.setIsDevicePushTokenRegistered(false)
                })
            }
        }
    }
    
    
//
//    // SendBirdHelper.swift
//    func logout(completionHandler: (() -> Void)?) {
//
//        self.setPushNotification(enable: false)
//        SBDMain.disconnect { }
//    }
}

extension SBDError {
    
    
    func showSBDErrorAlert() {
        return
        
        let errorTitle = localizedString("alert_error_title", comment: "")
        let okButtonTitle = localizedString("ok_button_title", comment: "")
        let errorMsg = localizedString("registration_error_alert", comment: "")
        let alert = ElGrocerAlertView.createAlert(errorTitle, description: errorMsg, positiveButton: okButtonTitle, negativeButton: nil, buttonClickCallback: nil)
        alert.show()
        
    }
    
    
}
//MARK: sendBird Desk Helper
extension SendBirdDeskManager {
    
    func handleOpenTicketResponse(isFound: Bool, openTicket: SBDSKTicket?, ticketCount: Int) {
        if let oId = self.orderId, let vc = self.controller {
            if ticketCount > 1 {
                self.navigateToChannelList(controller: vc)
                return
            }else {
                checkCloseTickets(openTicket: openTicket, openCount: ticketCount)
            }
        }
    }
    
    func checkCloseTickets(openTicket: SBDSKTicket?, openCount: Int) {
        self.getCloseTickets { (isFound , closeticket, closeCount) in
            self.handleCloseTicketResponse(openTicket: openTicket, openTicketCount: openCount, closeTicket: closeticket, closeTicketCount: closeCount)
        }
    }
    
    func handleCloseTicketResponse(openTicket: SBDSKTicket?, openTicketCount: Int, closeTicket: SBDSKTicket?, closeTicketCount: Int ) {
        guard let oId = self.orderId, let vc = self.controller,let type = self.deskType,let user = SBDMain.getCurrentUser() else {
            return
        }

        if openTicketCount > 1 || (closeTicketCount > 0 && type != .orderSupport) {
            self.navigateToChannelList(controller: vc)
            return
        }
        
        if let openTicketUrl = openTicket?.channel?.channelUrl {
            self.callSendBirdChat(orderId: oId, controller: vc, channelUrl: openTicketUrl)
            return
        }
        self.createTicketWithCustomParams(orderId: oId, user: user.nickname!, controller: vc)
        //commenting because no ticket will be reopened now
//        if type == .agentSupport {
//            self.createTicketWithCustomParams(orderId: oId, user: user.nickname!, controller: vc)
//            return
//        }else {
//            if let closeTicket = closeTicket {
//                self.reOpenTicket(ticket: closeTicket) { (reOpenedticket) in
//                   if let opened = reOpenedticket, let url = closeTicket.channel?.channelUrl {
//                       self.callSendBirdChat(orderId: oId, controller: vc, channelUrl: url)
//                   }
//               }
//            }else {
//                self.createTicketWithCustomParams(orderId: oId, user: user.nickname!, controller: vc)
//            }
//        }
    }
}
