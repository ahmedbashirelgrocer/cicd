//
//  sendBirdManager.swift
//  ElGrocerShopper
//
//  Created by saboor Khan on 02/09/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import SendBirdUIKit
// import AFNetworking
import CloudKit

enum sendBirdApiEndPoint: String{
    case viewUser = "/users/"
    case createUser = "/users"
    case removeDeviceToken = "/push/device_tokens/"
}
enum sendBirdDeskEndPoints: String{
    case viewCustomer = "customers/"
    case createCustomer = "customers"
    case ticketCustomFieldUpdate = "/custom_fields"
}

class SendBirdManager {

    let APP_ID = "F061BADA-1171-4478-8CFB-CBACC012301C"
    //test APP id below
//    let APP_ID = "094AAAA9-E52B-439B-A7C2-8BC8D7292550"
    let OrderUrlPrefix = "order-"
    let shoperPrefix = "s_"
    let pickerPrefix = "p_"
    let baseUrl = "https://api-F061BADA-1171-4478-8CFB-CBACC012301C.sendbird.com/v3"
    let deskBaseUrl = "https://desk-api-F061BADA-1171-4478-8CFB-CBACC012301C.sendbird.com/platform/v1/"
    let baseUrlEndPoint = ".sendbird.com/v3"
    let ApiToken = "b0418e8bb20c5c9b992e21283511e1d1a2bcafcb"
    let contentType = "application/json; charset=utf8"
    let deskApiToken = "e236272bf75a7cdd1b0050fcc6a6a05730b3b70b"
    init() {
        
       // setUpSenBirdWithCurrentUser()
        setSendBirdAppearence()
    }
    
    
    func getCurrentUser() -> UserProfile? {
        
        if UserDefaults.isUserLoggedIn(){
            let user = UserProfile.getOptionalUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            return user
        }else{
            return nil
        }
        
    }
    
    class func getCurrentSendBirdUser() -> SBDUser? {
        guard let user = SBDMain.getCurrentUser() else{
            return nil
        }
        return user
    }
    
    func setUpSenBirdWithCurrentUser(){
        // Specify your Sendbird application ID.
        SBUMain.initialize(applicationId: APP_ID)
        self.logIn {
            elDebugPrint("Login called")
        }
    }
    
    func logIn(connectAnnonymousUser: Bool = false,completionHandler: (() -> Void)?) {
        
//        if let _ = SBDMain.getCurrentUser() {
//            self.logout { (success) in
//                if success{
//                }
//            }
//            return
//        }
        
        let group = DispatchGroup()
        
        group.enter()
        
        if let user = self.getCurrentUser() {
            
            let id = user.dbID
            var name = user.name ?? ""
            
            if name.isEmptyStr {
                name = user.phone ?? ""
            }
            if name.isEmptyStr {
                name = "NoName"
            }
            
            SBUGlobals.CurrentUser = SBUUser(userId: shoperPrefix + id.stringValue, nickname: name, profileUrl: nil)
            SBUMain.connect { (user, error) in
                guard error == nil else {
                    // Handle error.
                    group.leave()
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
                group.leave()
            }
        }else{
            if connectAnnonymousUser {
                
                if let id = CleverTapEventsLogger.getCTProfileId(){
                
                    let name = "Anonymous"
                    SBUGlobals.CurrentUser = SBUUser(userId: shoperPrefix + id, nickname: name, profileUrl: nil)
                    SBUMain.connect { (user, error) in
                        guard error == nil else {
                            // Handle error.
                            group.leave()
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
                        group.leave()
                    }
                }
            }
//            group.leave()
            
        }
        
        group.notify(queue: DispatchQueue.global()) {
            completionHandler?()
        }
        
        
    }
    
    func setSendBirdAppearence(){
        
        
        
        var channelTheme = SBUChannelTheme()
        channelTheme = .light
        channelTheme.leftBarButtonTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        channelTheme.rightBarButtonTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        channelTheme.menuItemTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        
        var channelSettingsTheme = SBUChannelSettingsTheme()
        channelSettingsTheme = .light
        channelSettingsTheme.cellSwitchColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        channelSettingsTheme.leftBarButtonTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        channelSettingsTheme.rightBarButtonTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        channelSettingsTheme.cellArrowIconTintColor =
        ApplicationTheme.currentTheme.themeBasePrimaryColor
        channelSettingsTheme.cellTypeIconTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        
        
        
        var userListTheme = SBUUserListTheme()
        userListTheme = .light
        userListTheme.rightBarButtonTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        userListTheme.leftBarButtonTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        
        var componentTheme = SBUComponentTheme()
        componentTheme = .light
        componentTheme.buttonTextColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        componentTheme.actionSheetItemColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        componentTheme.loadingSpinnerColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        componentTheme.broadcastIconTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        componentTheme.channelTypeSelectorItemTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        componentTheme.addReactionTintColor = ApplicationTheme.currentTheme.unselectedPageControl
        componentTheme.reactionBoxSelectedEmojiBackgroundColor = ApplicationTheme.currentTheme.unselectedPageControl
        componentTheme.newMessageButtonTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        componentTheme.newMessageTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        componentTheme.scrollBottomButtonIconColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        componentTheme.emptyViewRetryButtonTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        componentTheme.loadingSpinnerColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        
        var messageCellTheme = SBUMessageCellTheme()
        messageCellTheme = .light
        messageCellTheme.rightBackgroundColor = ApplicationTheme.currentTheme.unselectedPageControl
        messageCellTheme.rightPressedBackgroundColor = ApplicationTheme.currentTheme.unselectedPageControl
        messageCellTheme.userMessageRightTextColor = ApplicationTheme.currentTheme.labelHeadingTextColor
        messageCellTheme.pressedContentBackgroundColor = ApplicationTheme.currentTheme.unselectedPageControl
        messageCellTheme.pendingStateColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        
        
        
        
        var messageInputTheme = SBUMessageInputTheme()
        messageInputTheme = .light
        messageInputTheme.buttonTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        messageInputTheme.textFieldTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        
        
        var channelListCellTheme = SBUChannelCellTheme()
        channelListCellTheme.unreadCountBackgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        channelListCellTheme.memberCountTextColor = UIColor.clear
        
        let newTheme = SBUTheme(channelListTheme: .light,
                                channelCellTheme: channelListCellTheme,
                                channelTheme: channelTheme,
                                messageInputTheme: messageInputTheme,
                                messageCellTheme: messageCellTheme,
                                userListTheme: userListTheme,
                                userCellTheme: .light,
                                channelSettingsTheme: channelSettingsTheme,
                                componentTheme: componentTheme)
        
        SBUTheme.set(theme: newTheme)
    }
    
    func navigateTochannelViewController(channel : SBDGroupChannel , controller : UIViewController , orderId : String){
        let channelController = ElgrocerChannelController(channel: channel)
        channelController.setOrderId(orderDbId: orderId)
        let naviVC = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        naviVC.viewControllers = [channelController]
       // let naviVC = ElGrocerNavigationController(rootViewController: channelController)
        naviVC.modalPresentationStyle = .fullScreen
        controller.present(naviVC, animated: true)
    }
    
    
    func callSendBirdChat(pickerID : String , orderId : String , controller : UIViewController ,  user : UserProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext) ){
        
        guard UserDefaults.isUserLoggedIn() else {
            return
        }
        
        
        func startPickerChat() {
            
            self.setUserUpdatedLanguage()
            let pickerIdWithPrefix = pickerPrefix + pickerID
            let groupChannelParams = SBDGroupChannelParams()
            groupChannelParams.channelUrl = OrderUrlPrefix + orderId
            groupChannelParams.addUserIds([pickerIdWithPrefix])
            groupChannelParams.isPublic = true
            groupChannelParams.name = localizedString("order_sendBird_nav_title", comment: "") + ":" + orderId
            groupChannelParams.customType = orderId
            self.checkIfChannelExist(channelUrl: OrderUrlPrefix + orderId) { doesExist, channel in
                if doesExist{
                    if channel.isPublic {
                        channel.join(completionHandler: { (error) in
                            guard error == nil else {
                                    // Handle error.
                               elDebugPrint(error?.localizedDescription ?? "")
                                return
                            }
                            self.navigateTochannelViewController(channel: channel, controller: controller, orderId: orderId)
                        })
                    }
                    
                }else{
                    SBDGroupChannel.createChannel(with: groupChannelParams) { groupChannel, error in
                        guard error == nil else {
                                // Handle error.
                           elDebugPrint(error?.localizedDescription ?? "")
                            return
                        }
                        DispatchQueue.main.async {
                            if let channelUrl = groupChannel{
                                self.navigateTochannelViewController(channel: channelUrl, controller: controller, orderId: orderId)
                            }
                        }
                    }
                }
            }
        }
        
        self.logIn {
            startPickerChat()
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
    
    
    func  setUserUpdatedLanguage()  {
        let preferredLanguages =  ElGrocerUtility.sharedInstance.isArabicSelected() ?  ["ar"] : ["en"] // French, German, Spanish, and Korean
        SBDMain.updateCurrentUserInfo(withPreferredLanguages: preferredLanguages, completionHandler: { error in
        })
    }
    
    //MARK: push notification
    func registerPushNotification(_ deviceToken : Data, completion : @escaping(Bool) -> ()){

        self.setPushNotification(enable: true) { (success) in
            if success{
                completion(true)
                UserDefaults.setIsDevicePushTokenRegistered(true)
            }else{
                completion(false)
                UserDefaults.setIsDevicePushTokenRegistered(false)
            }
        }
        
//        guard SBDMain.getCurrentUser() != nil else { return }
//        SBDMain.registerDevicePushToken(deviceToken, unique: true, completionHandler: { (status, error) in
//            if error == nil {
//                completion(true)
//                UserDefaults.setIsDevicePushTokenRegistered(true)
//            }
//            else {
//                if status == SBDPushTokenRegistrationStatus.pending {
//                    self.setPushNotification(enable: false) { }
//                    UserDefaults.setIsDevicePushTokenRegistered(false)
//
//                } else {
//                    // Handle registration failure.
//                    completion(false)
//                    UserDefaults.setIsDevicePushTokenRegistered(false)
//                }
//            }
//        })
    }
    
    func setPushNotification(enable: Bool , completionHandler: @escaping ((Bool) -> Void)) {
        
        if enable {
            
            if let user = self.getCurrentUser(){
                let id = shoperPrefix + user.dbID.stringValue
                var name = user.name ?? ""
                if name.isEmptyStr {
                    name = user.phone ?? ""
                }
                if name.isEmptyStr {
                    name = "NoName"
                }
                
                self.registerDeviceToken(userId: id) { (userId) in
                    if userId != nil{
                        UserDefaults.setIsDevicePushTokenRegistered(true)
                        completionHandler(true)
                    }else{
                        completionHandler(false)
                    }
                }
            }else{
                guard let anonymousUserId = CleverTapEventsLogger.getCTProfileId() else{return}
                let id = shoperPrefix + anonymousUserId
                let name = "Anonymous"
                
                self.registerDeviceToken(userId: id) { (userId) in
                    if userId != nil{
                        UserDefaults.setIsDevicePushTokenRegistered(true)
                        completionHandler(true)
                    }else{
                        completionHandler(false)
                    }
                }
            }
        }else{
            if let user = self.getCurrentUser(){
                let id = shoperPrefix + user.dbID.stringValue
                var name = user.name ?? ""
                if name.isEmptyStr {
                    name = user.phone ?? ""
                }
                if name.isEmptyStr {
                    name = "NoName"
                }
                self.deleteRegisterDeviceToken(userId: id) { (userId) in
                    if userId != nil{
                        UserDefaults.setIsDevicePushTokenRegistered(false)
                        completionHandler(true)
                    }else{
                        completionHandler(false)
                    }
                }
            }else{
                guard let anonymousUserId = CleverTapEventsLogger.getCTProfileId() else{return}
                let id = shoperPrefix + anonymousUserId
                let name = "Anonymous"
                self.deleteRegisterDeviceToken(userId: id) { (userId) in
                    if userId != nil{
                        UserDefaults.setIsDevicePushTokenRegistered(false)
                        completionHandler(true)
                    }else{
                        completionHandler(false)
                    }
                }
            }
        }
        
       /* if enable {
            if let token = UserDefaults.getDevicePushTokenData() {
                SBDMain.registerDevicePushToken(token, unique: true, completionHandler: { (status, error) in
                    if let handler = completionHandler {
                        handler()
                    }
                })
            }  else {
                if let handler = completionHandler {
                    handler()
                }
            }
        }
        else {
            if let token = UserDefaults.getDevicePushTokenData() {
                // If you want to unregister the current device only, invoke this method.
                SBDMain.unregisterPushToken(token, completionHandler: { (response, error) in
                    guard error == nil else{
                       elDebugPrint(error)
                        if let handler = completionHandler {
                            handler()
                        }
                        return
                    }
                    UserDefaults.setIsDevicePushTokenRegistered(false)
                    if let handler = completionHandler {
                        handler()
                    }
                })
                SBUMain.unregisterAllPushToken { (isCompleted) in
                    elDebugPrint(isCompleted)
                    if isCompleted{
                        UserDefaults.setIsDevicePushTokenRegistered(false)
                    }
                }
               
            }else {
                if let handler = completionHandler {
                    handler()
                }
            }
        }
        */
    }
    
    // SendBirdHelper.swift
    func logout(completionHandler:@escaping ((Bool) -> Void)) {
        
        self.setPushNotification(enable: false) { success in
            if success{
                completionHandler(true)
            }else{
                completionHandler(false)
            }
        }
        SBDMain.disconnect { }
        SBUMain.disconnect { }
    }
    
    func didReciveRemoteNotification(userInfo : [AnyHashable : Any]) {
    
        guard let sendBirdData = userInfo["sendbird"] as? NSDictionary else{
           elDebugPrint("no channel present")
            return
        }
        
        if let channel = sendBirdData["channel"] as? NSDictionary{
            
            var isAppStart = false
            // if let SDKManager = SDKManager.shared {
                if let dataAvailable = SDKManager.shared.sdkStartTime {
                    if dataAvailable.timeIntervalSinceNow > -10 {
                        isAppStart = true
                    }
                }
            //}
            
            
            
            if let channel_url = channel["channel_url"] as? String {
                
                //MARK: shoper and agent chat
                if let customeType = channel["custom_type"] as? String{
                    if customeType == "SENDBIRD_DESK_CHANNEL_CUSTOM_TYPE" {
                        
                        let name = channel["name"] as? String ?? ""
                        var orderId = name
                        var type: SendBirdDeskType = .orderSupport
                        if name.contains(localizedString("order_sendBird_nav_title", comment: "") + ":"){
                           orderId = orderId.replacingOccurrences(of: localizedString("order_sendBird_nav_title", comment: "") + ": ", with: "")
                            type = .orderSupport
                        }else if name.contains(localizedString("support_sendBird_nav_title", comment: "") + ":"){
                            
                           orderId = orderId.replacingOccurrences(of: localizedString("support_sendBird_nav_title", comment: "") + ": ", with: "")
                            type = .agentSupport
                        }
                        
                       
                        
                        if let controller = UIApplication.topViewController(){
                            if controller is ElgrocerChannelController{
                                let channelController = controller as! ElgrocerChannelController
                                
                                if channelController.channelUrl == channel_url {
                                    
                                }else{
                                    
                                    if UIApplication.shared.applicationState == .active && !isAppStart {
                                        
                                        if let message = sendBirdData["message"] as? String{
                                            
                                            
                                            ElGrocerUtility.sharedInstance.showTopMessageView(message, "", image: UIImage(name: "chat-White"), -1, false) { data, index, viewTap in
                                                
                                                guard SBDMain.getCurrentUser() != nil else {
                                                    SendBirdDeskManager(type: type).logIn(isWithChat: false) {
                                                        SendBirdDeskManager(type: type).callSendBirdChat(orderId: orderId, controller: controller, channelUrl: channel_url)
                                                    }
                                                    return
                                                }
                                                
                                                SendBirdDeskManager(type: type).callSendBirdChat(orderId: orderId, controller: controller, channelUrl: channel_url)
                                            }
                                        }
                                    }else{
                                        
                                        
                                        guard SBDMain.getCurrentUser() != nil else{
                                            SendBirdDeskManager(type: type).logIn(isWithChat: false) {
                                                SendBirdDeskManager(type: type).callSendBirdChat(orderId: orderId, controller: controller, channelUrl: channel_url)
                                            }
                                            return
                                        }
                                        
                                        
                                        SendBirdDeskManager(type: type).callSendBirdChat(orderId: orderId, controller: controller, channelUrl: channel_url)
                                    }
                                }
                            }else{
                                if UIApplication.shared.applicationState == .active && !isAppStart  {
                                    
                                    if let message = sendBirdData["message"] as? String{
                                        DispatchQueue.main.async {
                                            ElGrocerUtility.sharedInstance.showTopMessageView(message, "", image: UIImage(name: "chat-White"), -1, false) { data, index, viewTap in
                                                
                                                guard SBDMain.getCurrentUser() != nil else{
                                                    SendBirdDeskManager(type: type).logIn(isWithChat: false) {
                                                        SendBirdDeskManager(type: type).callSendBirdChat(orderId: orderId, controller: controller, channelUrl: channel_url)
                                                    }
                                                    return
                                                }
                                                
                                                SendBirdDeskManager(type: type).callSendBirdChat(orderId: orderId, controller: controller, channelUrl: channel_url)
                                            }
                                        }
                                        
                                    }
                                }else{
                                    
                                    
                                    guard SBDMain.getCurrentUser() != nil else{
                                        SendBirdDeskManager(type: type).logIn(isWithChat: false) {
                                            SendBirdDeskManager(type: type).callSendBirdChat(orderId: orderId, controller: controller, channelUrl: channel_url)
                                        }
                                        return
                                    }
                                    
                                    SendBirdDeskManager(type: type).callSendBirdChat(orderId: orderId, controller: controller, channelUrl: channel_url)
                                }
                            }
                        }
                    }else{
                        
                        
                        //MARK: picker and shoper chat
                        let pickerData = sendBirdData["sender"] as? NSDictionary
                        let orderId = channel_url.replacingOccurrences(of: OrderUrlPrefix, with: "")
                       elDebugPrint(orderId)
                        if orderId.count > 0 {
                            if !UserDefaults.isUserLoggedIn() {
                                return
                            }
                        }
                        
                        if let controller = UIApplication.topViewController(){
                            if controller is ElgrocerChannelController{
                                let channelController = controller as! ElgrocerChannelController
                                if channelController.channelUrl == channel_url{
                                    
                                }else{
                                    
                                    if let pickerID = pickerData?["id"] as? String{
                                        if UIApplication.shared.applicationState == .active && !isAppStart {
                                            
                                            if let message = sendBirdData["message"] as? String{
                                                
                                                
                                                guard SBDMain.getCurrentUser() != nil else {
                                                    self.logIn(connectAnnonymousUser: true) {
                                                        ElGrocerUtility.sharedInstance.showTopMessageView(message, "", image: UIImage(name: "chat-White"), -1, false) { data, index, viewTap in
                                                            SendBirdManager().callSendBirdChat(pickerID: pickerID, orderId: orderId, controller: controller)
                                                        }
                                                    }
                                                    return
                                                }
                                                
                                                ElGrocerUtility.sharedInstance.showTopMessageView(message, "", image: UIImage(name: "chat-White"), -1, false) { data, index, viewTap in
                                                    SendBirdManager().callSendBirdChat(pickerID: pickerID, orderId: orderId, controller: controller)
                                                }
                                            }
                                        }else{
                                            SendBirdManager().callSendBirdChat(pickerID: pickerID, orderId: orderId, controller: controller)
                                        }
                                    }
                                }
                                
                            }else{
                                if let pickerID = pickerData?["id"] as? String{
                                    if UIApplication.shared.applicationState == .active && !isAppStart  {
                                        if let message = sendBirdData["message"] as? String{
                                            
                                            ElGrocerUtility.sharedInstance.showTopMessageView(message, "", image: UIImage(name: "chat-White"), -1, false) { data, index, viewTap in
                                                SendBirdManager().callSendBirdChat(pickerID: pickerID, orderId: orderId, controller: controller)
                                            }
                                        }
                                    }else{
                                        SendBirdManager().callSendBirdChat(pickerID: pickerID, orderId: orderId, controller: controller)
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
    }
    
}

extension SendBirdManager {
    
    
    func createNewUserAndDeActivateOld() {
        
        if let anonymousUserId = CleverTapEventsLogger.getCTProfileId() {
            let id = self.shoperPrefix + anonymousUserId
            
            self.deleteRegisterDeviceToken(userId: id) { user in
                if user != nil {
                   elDebugPrint("anonymous user logged out")
                }
            }
        }
        
        SBDMain.disconnect {}
        SendBirdDeskManager(type: .agentSupport).setUpSenBirdDeskWithCurrentUser(isWithChat: false)
       
        
    }
    
    
    
}

extension SendBirdManager{
    //Api calling on platForm Api for sendBird
    
    func setUpCurrentUserWithPlatform() {
        if let user = self.getCurrentUser() {
            let id = shoperPrefix + user.dbID.stringValue
            var name = user.name ?? ""
            if name.isEmptyStr {
                name = user.phone ?? ""
            }
            if name.isEmptyStr {
                name = "NoName"
            }
//            self.startCustomerPlatformProcess(idToSend: id, nmaeToSend: name)
            self.startPlatformRegistation(userIdToCheck: id, nameToCheck: name)
        }else{
            guard let anonymousUserId = CleverTapEventsLogger.getCTProfileId() else{return}
            let id = shoperPrefix + anonymousUserId
            let name = "Anonymous"
//            self.startCustomerPlatformProcess(idToSend: id, nmaeToSend: name)
            self.startPlatformRegistation(userIdToCheck: id, nameToCheck: name)
        }
    }
    
    func startCustomerPlatformProcess(idToSend: String, nmaeToSend: String){

        self.createCustomer(userId: idToSend) { (createdUser) in
            if let id = createdUser {
                self.registerDeviceToken(userId: id) { (user) in
                    if user != nil{
                        return
                    }else{
                       elDebugPrint("platform error")
                    }
                }
                
              
                
            }else{
//                self.startPlatformRegistation(userIdToCheck: idToSend, nameToCheck: nmaeToSend)
            }
        }
    }
    
    func startPlatformRegistation(userIdToCheck: String, nameToCheck: String){
    
        viewUser(userId: userIdToCheck, name: nameToCheck) { [weak self] (viewUserId, viewUsername) in
            let manager = SendBirdManager()
            if let _ = viewUserId {
                manager.startCustomerPlatformProcess(idToSend: userIdToCheck, nmaeToSend: nameToCheck)
                manager.updateUser(userIdToUpdate: userIdToCheck, nameToUpdate: nameToCheck) { (updatedUser) in }
            }else{
                //no user exists create user
                manager.createUser(userId: userIdToCheck, name: nameToCheck) { [weak self](cretedUserId) in
                    if cretedUserId != nil {
                        manager.startCustomerPlatformProcess(idToSend: userIdToCheck, nmaeToSend: nameToCheck)
                    }else{
                        //user cannot be created
                       elDebugPrint("platform error")
                    }
                }
                
            }
        }
        
    }

    func viewUser(userId: String,name: String, completion: @escaping (String?,String?)-> Void) {
        let url = baseUrl + sendBirdApiEndPoint.viewUser.rawValue
        
        let configuration = URLSessionConfiguration.default
        
        
        
        let headerToSend = ["Content-Type": contentType, "Api-Token": ApiToken]
        let manager = AFHTTPSessionManagerCustom.init()
        
        manager.get(
            url + userId,
            parameters: nil,headers: headerToSend, progress: nil,
            success: { [weak self] (operation, responseObject) in

                 if let dic = responseObject as? [String: Any]{
                     elDebugPrint(dic)
                     if let userId = dic["user_id"] as? String, let name = dic["nickname"] as? String{
                         completion(userId,name)
                     }
                     
                 }else{
                     completion(nil,nil)
                 }
                
            }, failure: { (operation, error) in
                elDebugPrint("Error: " + error.localizedDescription)
                completion(nil,nil)
        })
        
    }
    
    func createUser(userId: String, name: String , completion: @escaping(String?)-> Void){
        let url = baseUrl + sendBirdApiEndPoint.createUser.rawValue
        let params = ["user_id" : userId, "nickname": name,"profile_url": ""]
        let manager = AFHTTPSessionManagerCustom.init()
        manager.requestSerializer = AFJSONRequestSerializerCustom()
        manager.requestSerializer.setValue(contentType, forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue(ApiToken, forHTTPHeaderField: "Api-Token")

        manager.post(url, parameters: params, headers: manager.requestSerializer.httpRequestHeaders, progress: nil, success: { [weak self] (task: URLSessionDataTask, responseObject: Any?) in
            if var jsonResponse = responseObject as? [String: AnyObject] {
                // here read response
               elDebugPrint(jsonResponse)
                if let userId = jsonResponse["user_id"] as? String{
                    completion(userId)
                }else{
                    completion(nil)
                }
            }
        }) { (task: URLSessionDataTask?, error: Error) in
           elDebugPrint("POST fails with error \(error)")
            completion(nil)
        }
    }
    
    func updateUser(userIdToUpdate: String, nameToUpdate: String, completion: @escaping(String?)-> Void){
        let url = baseUrl + sendBirdApiEndPoint.viewUser.rawValue + userIdToUpdate
        let params = ["nickname": nameToUpdate,"profile_url": ""]
        let manager = AFHTTPSessionManagerCustom.init()
        manager.requestSerializer = AFJSONRequestSerializerCustom()
        manager.requestSerializer.setValue(contentType, forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue(ApiToken, forHTTPHeaderField: "Api-Token")
        
        manager.put(url, parameters: params, headers: manager.requestSerializer.httpRequestHeaders, success: { [weak self] (task: URLSessionDataTask, responseObject: Any?) in
            if var jsonResponse = responseObject as? [String: AnyObject] {
                // here read response
               elDebugPrint(jsonResponse)
                if let userId = jsonResponse["user_id"] as? String{
                    completion(userId)
                }else{
                    completion(nil)
                }
            }else{
                completion(nil)
            }
        }) { (task: URLSessionDataTask?, error: Error) in
           elDebugPrint("Put fails with error \(error)")
            completion(nil)
        }
    }
    
    func registerDeviceToken(userId: String,completion: @escaping (String?)-> Void){
        let tokenType = "apns"
        let url = baseUrl + sendBirdApiEndPoint.viewUser.rawValue + userId + "/push/" + tokenType
        let params = ["apns_device_token" : UserDefaults.getDevicePushToken() ?? ""]
        let manager = AFHTTPSessionManagerCustom.init()
        manager.requestSerializer = AFJSONRequestSerializerCustom()
        manager.requestSerializer.setValue(contentType, forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue(ApiToken, forHTTPHeaderField: "Api-Token")
        
        guard  UserDefaults.getDevicePushToken() != nil else {
            completion(nil)
            return
        }
        
        manager.post(url, parameters: params, headers: manager.requestSerializer.httpRequestHeaders, progress: nil, success: { [weak self] (task: URLSessionDataTask, responseObject: Any?) in
            
            if let jsonResponse = responseObject as? [String: AnyObject] {
                // here read response
               elDebugPrint(jsonResponse)
                if let user = jsonResponse["user"] as? [String: Any]{
                    if let id = user["user_id"] as? String{
                        completion(id)
                    }
                }else{
                    completion(nil)
                }
                
            }else{
                completion(nil)
            }
        }) { (task: URLSessionDataTask?, error: Error) in
           elDebugPrint("POST fails with error \(error)")
            completion(nil)
        }
        
        if Platform.isDebugBuild {
            self.getRegisterDeviceTokenList(userId: userId) { data in
                elDebugPrint("APNS-SendBirdData: \(data)")
            }
        }
        
    }
    
    func deleteRegisterDeviceToken(userId: String,completion: @escaping (String?)-> Void){
        
        //let tokenType = "apns"
        
        guard let _ = UserDefaults.getDevicePushToken() else{
            return
        }
        //to revoke all token against user
        let url = baseUrl + "/users/" + userId + "/push"
        

        
        //to revoke all users against token
//        let url = baseUrl + sendBirdApiEndPoint.removeDeviceToken.rawValue + tokenType + "/" + token
        let params = ["":""]


        let manager = AFHTTPSessionManagerCustom.init()
        manager.requestSerializer = AFJSONRequestSerializerCustom()
        manager.requestSerializer.setValue(contentType, forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue(ApiToken, forHTTPHeaderField: "Api-Token")

        manager.delete(url, parameters: params, headers: manager.requestSerializer.httpRequestHeaders, success: { [weak self] (task: URLSessionDataTask, responseObject: Any?) in
            if let jsonResponse = responseObject as? [String: AnyObject] {
                // here read response
               elDebugPrint(jsonResponse)
                if let userId = jsonResponse["user_id"] as? String{
                    completion(userId)
                }else{
                    if let user = jsonResponse["user"] as? [String: Any]{
                        if let userId = user["user_id"] as? String {
                            completion(userId)
                        }else{
                            completion(nil)
                        }
                        
                    }else{
                        completion(nil)
                    }
                }
            }else{
                completion(nil)
            }
        }) { (task: URLSessionDataTask?, error: Error) in
           elDebugPrint("Delete fails with error \(error)")
            completion(nil)
        }
    }
    
    func getRegisterDeviceTokenList(userId: String,completion: @escaping (String?)-> Void){
        
            //let tokenType = "apns"
        
        guard let _ = UserDefaults.getDevicePushToken() else{
            return
        }
            //to revoke all token against user
        let url = baseUrl + "/users/" + userId + "/push/apns"
        
     
        let manager = AFHTTPSessionManagerCustom.init()
        manager.requestSerializer = AFJSONRequestSerializerCustom()
        manager.requestSerializer.setValue(contentType, forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue(ApiToken, forHTTPHeaderField: "Api-Token")
        
        manager.get(url, parameters: nil , headers: manager.requestSerializer.httpRequestHeaders, progress: nil) { [weak self] (task: URLSessionDataTask, responseObject: Any?) in
            if let jsonResponse = responseObject as? [String: AnyObject] {
                elDebugPrint(jsonResponse)
            }
            completion(nil)
        } failure: { (task: URLSessionDataTask?, error: Error) in
           elDebugPrint("Delete fails with error \(error)")
            completion(nil)
        }

    }

    func getDeviceTokenUser(completion: @escaping (String?)-> Void){
        let tokenType = "apns"
        guard let token = UserDefaults.getDevicePushToken() else{
            return
        }
        let url = baseUrl + sendBirdApiEndPoint.removeDeviceToken.rawValue + tokenType + "/" + token
        let configuration = URLSessionConfiguration.default
        
        
    
        
        let headerToSend = ["Content-Type": contentType, "Api-Token": ApiToken]
        let manager = AFHTTPSessionManagerCustom.init()
        
        manager.get(
            url,
            parameters: nil,headers: headerToSend, progress: nil,
            success: { [weak self] (operation, responseObject) in

                 if let dic = responseObject as? [[String: Any]]{
                     elDebugPrint(dic)
                     if let userId = dic[0]["user_id"] as? String{
                         completion(userId)
                     }
                 }else{
                     completion(nil)
                 }
                 DispatchQueue.main.async {
                     
                 }
            },
            failure:
            {
                (operation, error) in
                elDebugPrint("Error: " + error.localizedDescription)
                completion(nil)
        })
    }
    
    //MARK: sendBird desk platform api
    
    func viewCustomer(userId: String, completion: @escaping (String?)-> Void){
        let url = deskBaseUrl + sendBirdDeskEndPoints.viewCustomer.rawValue
        
        let configuration = URLSessionConfiguration.default
        

        let manager = AFHTTPSessionManagerCustom.init()
        manager.requestSerializer = AFJSONRequestSerializerCustom()
        manager.requestSerializer.setValue(contentType, forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue(deskApiToken, forHTTPHeaderField: "SENDBIRDDESKAPITOKEN")
        
        manager.get(
            url + userId,
            parameters: nil,headers: manager.requestSerializer.httpRequestHeaders, progress: nil,
            success:
            {
               [weak self] (operation, responseObject) in

                 if let dic = responseObject as? [String: Any]{
                     elDebugPrint(dic)
                     if let userId = dic["user_id"] as? String{
                         completion(userId)
                     }
                     
                 }else{
                     completion(nil)
                 }
                 DispatchQueue.main.async {
                     
                 }
            },
            failure:
            {
                (operation, error) in
                elDebugPrint("Error: " + error.localizedDescription)
                completion(nil)
        })
        
    }
    
   
    
    func createCustomer(userId: String,completion: @escaping(String?)-> Void){
        
        let url = deskBaseUrl + sendBirdDeskEndPoints.createCustomer.rawValue
        let semaphore = DispatchSemaphore (value: 0)
        
        var parameters = "{\n    \"sendbirdId\": \"\(userId)\"\n}"
        
        let dic = ["sendbirdId": userId , "customFields" : ["smilesdk" : SDKManager.isSmileSDK ? "true" : "false" , "app" : "Shopper" , "platform" : "iOS"]] as [String : Any]
        
       
        if let jsonData = try? JSONSerialization.data(withJSONObject:dic) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
               elDebugPrint(jsonString)
                parameters = jsonString
            }
        }
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(deskApiToken, forHTTPHeaderField: "SENDBIRDDESKAPITOKEN")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
          guard let data = data else {
           elDebugPrint(String(describing: error))
            completion(nil)
            semaphore.signal()
            return
          }
            guard let stringData = String(data: data, encoding: .utf8) else {return}
            if let response = self?.convertToDictionary(text: stringData){
                if let id = response["sendbirdId"] as? String{
                    completion(id)
                }else{
                    completion(userId)
                }
            }else{
                completion(nil)
            }
          semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
    
    func updateFieldForTicket(ticketId: String , userId : String, completion: @escaping (String?)-> Void){
        
        let tickedUrlId = "tickets/\(ticketId)"
        let url = deskBaseUrl + tickedUrlId  + sendBirdDeskEndPoints.ticketCustomFieldUpdate.rawValue
        
        let semaphore = DispatchSemaphore (value: 0)
        
        var parameters = "{\n    \"sendbirdId\": \"\(userId)\"\n}"
        let dic = ["sendbirdId": shoperPrefix + userId , "customFields" : [ "smilesdk" : SDKManager.isSmileSDK ? "true" : "false" ,"app" : "Shopper" , "platform" : "iOS", "shopperid" : userId]] as [String : Any]
        
        
        if let jsonData = try? JSONSerialization.data(withJSONObject:dic) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
               elDebugPrint(jsonString)
                parameters = jsonString
            }
        }
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(deskApiToken, forHTTPHeaderField: "SENDBIRDDESKAPITOKEN")
        request.httpMethod = "PATCH"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else {
               elDebugPrint(String(describing: error))
                completion(nil)
                semaphore.signal()
                return
            }
            guard let stringData = String(data: data, encoding: .utf8) else {return}
            if let response = self?.convertToDictionary(text: stringData){
                if let id = response["sendbirdId"] as? String{
                    completion(id)
                }else{
                    completion(userId)
                }
            }else{
                completion(nil)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        
        
    }
    
    
    
    // MARK: - Helper
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
               elDebugPrint(error.localizedDescription)
            }
        }
        return nil
    }
    
}
