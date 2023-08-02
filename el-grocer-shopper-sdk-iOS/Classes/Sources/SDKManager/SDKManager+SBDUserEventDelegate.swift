//
//  SDKManager+Extension+SendbirdChatSDK.UserEventDelegate.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 20/06/2022.
//

import Foundation
import SendBirdDesk
import SendbirdChatSDK
import SendbirdUIKit
extension SDKManager : GroupChannelDelegate, BaseChannelDelegate, ConnectionDelegate, UserEventDelegate   {
    
    public func setSendbirdDelegate () {
        SendbirdChat.removeAllChannelDelegates()
        SendbirdChat.removeSessionDelegate()
        SendbirdChat.removeAllConnectionDelegates()
        SendbirdChat.removeAllUserEventDelegates()
        SendbirdChat.addChannelDelegate(SDKManager.shared, identifier: "UNIQUE_DELEGATE_ID")
        SendbirdChat.addConnectionDelegate(SDKManager.shared, identifier: "UNIQUE_DELEGATE_ID")
        SendbirdChat.addUserEventDelegate(SDKManager.shared, identifier: "UNIQUE_DELEGATE_ID")
    }
 
    func channel(_ sender: BaseChannel, didReceive message: BaseMessage) {
       
        elDebugPrint("\(message.requestId)")
        
        if UIApplication.shared.applicationState == .active {
            
            let dataDict = message._toDictionary()
            var isUserFound = false
            if let usersA = sender.dictionaryWithValues(forKeys: ["members"])["members"] as? [Member] {
                for user in usersA {
                    if let msgUserID = user.userId as? String {
                        if msgUserID == SendbirdChat.getCurrentUser()?.userId {
                            isUserFound = true
                            break;
                        }
                    }
                }
            }
            
            if let topVc = UIApplication.topViewController() {
                if topVc is SendBirdListViewController  || topVc is ElgrocerChannelController {
                    return
                }
            }
            
            guard isUserFound else {return}
            
            if let msgType = message.customType {
                if msgType.lowercased() == "SENDBIRD:AUTO_EVENT_MESSAGE".lowercased() {
                    return
                }
            }
            let nameDict = sender.dictionaryWithValues(forKeys: ["name"])
            let name = nameDict != nil ? nameDict["name"] : message.sender?.nickname
            var data  = [:] as [String : Any]
            var sendbirdData = [:] as [String : Any]
            sendbirdData["channel"] =  ["channel_url" : message.channelURL , "custom_type" : sender.customType ,  "name" : name]
            sendbirdData["message"] = message.message
            data["sendbird"] = sendbirdData
            SendBirdManager().didReciveRemoteNotification(userInfo: data)
            
            
        }
        
    }
    
//    func channel(_ sender: BaseChannel, didUpdate message: BaseMessage) {
//        elDebugPrint("")
//    }
//
//    func channel(_ sender: BaseChannel, messageWasDeleted messageId: Int64) {
//        elDebugPrint("")
//    }
//    
//    func channel(_ channel: BaseChannel, didReceiveMention message: BaseMessage) {
//        elDebugPrint("")
//    }
//
//    func channelWasChanged(_ sender: BaseChannel) {
//        elDebugPrint("")
//
//
//    }
//
//    func channelWasDeleted(_ channelUrl: String, channelType: ChannelType) {
//        elDebugPrint("")
//    }
//
//    func channelWasFrozen(_ sender: BaseChannel) {
//        elDebugPrint("")
//    }
//
//    func channelWasUnfrozen(_ sender: BaseChannel) {
//        elDebugPrint("")
//    }
//
//    func channel(_ sender: BaseChannel, createdMetaData: [String : String]?) {
//        elDebugPrint("")
//    }
//
//    func channel(_ sender: BaseChannel, updatedMetaData: [String : String]?) {
//        elDebugPrint("")
//    }
//
//    func channel(_ sender: BaseChannel, deletedMetaDataKeys: [String]?) {
//        elDebugPrint("")
//    }
//
//    func channel(_ sender: BaseChannel, createdMetaCounters: [String : NSNumber]?) {
//        elDebugPrint("")
//    }
//
//    func channel(_ sender: BaseChannel, updatedMetaCounters: [String : NSNumber]?) {
//        elDebugPrint("")
//    }
//
//    func channel(_ sender: BaseChannel, deletedMetaCountersKeys: [String]?) {
//        elDebugPrint("")
//    }
//
//    func channelWasHidden(_ sender: GroupChannel) {
//        elDebugPrint("")
//    }
//
//
//    func channel(_ sender: GroupChannel, didReceiveInvitation invitees: [SendbirdChatSDK.User]?, inviter: SendbirdChatSDK.User?) {
//    }
//
//    func channel(_ sender: GroupChannel, didDeclineInvitation invitee: SendbirdChatSDK.User?, inviter: SendbirdChatSDK.User?) {
//    }
//
//    func channel(_ sender: GroupChannel, userDidJoin user: SendbirdChatSDK.User) {
//    }
//
//    func channel(_ sender: GroupChannel, userDidLeave user: SendbirdChatSDK.User) {
//    }
//
//    func channelDidUpdateDeliveryReceipt(_ sender: GroupChannel) {
//    }
//
//    func channelDidUpdateReadReceipt(_ sender: GroupChannel) {
//    }
//
//    func channelDidUpdateTypingStatus(_ sender: GroupChannel) {
//
//        elDebugPrint("unreadMentionCount\(sender.unreadMentionCount)")
//    }
//
//    func channel(_ sender: OpenChannel, userDidEnter user: SendbirdChatSDK.User) {
//    }
//
//    func channel(_ sender: OpenChannel, userDidExit user: SendbirdChatSDK.User) {
//    }
//
//    func channel(_ sender: BaseChannel, userWasMuted user: SendbirdChatSDK.User) {
//    }
//
//    func channel(_ sender: BaseChannel, userWasUnmuted user: SendbirdChatSDK.User) {
//    }
//
//    func channel(_ sender: BaseChannel, userWasBanned user: SendbirdChatSDK.User) {
//    }
//
//    func channel(_ sender: BaseChannel, userWasUnbanned user: SendbirdChatSDK.User) {
//    }
//
//    func channelDidChangeMemberCount(_ channels: [GroupChannel]) {
//    }
//
//    func channelDidChangeParticipantCount(_ channels: [OpenChannel]) {
//    }
    
}

extension SDKManagerShopper : GroupChannelDelegate, BaseChannelDelegate, ConnectionDelegate, UserEventDelegate  {
    
    public func setSendbirdDelegate () {
        SendbirdChat.removeAllChannelDelegates()
        SendbirdChat.removeSessionDelegate()
        SendbirdChat.removeAllConnectionDelegates()
        SendbirdChat.removeAllUserEventDelegates()
        SendbirdChat.addChannelDelegate(SDKManager.shared, identifier: "UNIQUE_DELEGATE_ID")
        SendbirdChat.addConnectionDelegate(SDKManager.shared, identifier: "UNIQUE_DELEGATE_ID")
        SendbirdChat.addUserEventDelegate(SDKManager.shared, identifier: "UNIQUE_DELEGATE_ID")
    }

}


