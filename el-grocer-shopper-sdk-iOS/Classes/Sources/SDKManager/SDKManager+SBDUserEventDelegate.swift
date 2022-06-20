//
//  SDKManager+Extension+SBDUserEventDelegate.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 20/06/2022.
//

import Foundation
import SendBirdUIKit

extension SDKManager : SBDConnectionDelegate, SBDUserEventDelegate, SBDChannelDelegate {
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        debugPrint("\(message.requestId)")
        
        if UIApplication.shared.applicationState == .active {
            
            let dataDict = message._toDictionary()
            var isUserFound = false
            if let usersA = sender.dictionaryWithValues(forKeys: ["_members"])["_members"] as? [SBDMember] {
                for user in usersA {
                    if let msgUserID = user.userId as? String {
                        if msgUserID == SBDMain.getCurrentUser()?.userId {
                            isUserFound = true
                            break;
                        }
                    }
                }
            }
            
            if let topVc = UIApplication.topViewController() {
                if topVc is SBUChannelListViewController  || topVc is ElgrocerChannelController {
                    return
                }
            }
            
            guard isUserFound else {return}
            
            if let msgType = message.customType {
                if msgType.lowercased() == "SENDBIRD:AUTO_EVENT_MESSAGE".lowercased() {
                    return
                }
            }
            let nameDict = sender.dictionaryWithValues(forKeys: ["_name"])
            let name = nameDict != nil ? nameDict["_name"] : message.sender?.nickname
            var data  = [:] as [String : Any]
            var sendbirdData = [:] as [String : Any]
            sendbirdData["channel"] =  ["channel_url" : message.channelUrl , "custom_type" : sender.customType ,  "name" : name]
            sendbirdData["message"] = message.message
            data["sendbird"] = sendbirdData
            SendBirdManager().didReciveRemoteNotification(userInfo: data)
            
            
        }
        
    }
    
    func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage) {
        debugPrint("")
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        debugPrint("")
    }
    
    func channel(_ channel: SBDBaseChannel, didReceiveMention message: SBDBaseMessage) {
        debugPrint("")
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        debugPrint("")
        
        
    }
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        debugPrint("")
    }
    
    func channelWasFrozen(_ sender: SBDBaseChannel) {
        debugPrint("")
    }
    
    func channelWasUnfrozen(_ sender: SBDBaseChannel) {
        debugPrint("")
    }
    
    func channel(_ sender: SBDBaseChannel, createdMetaData: [String : String]?) {
        debugPrint("")
    }
    
    func channel(_ sender: SBDBaseChannel, updatedMetaData: [String : String]?) {
        debugPrint("")
    }
    
    func channel(_ sender: SBDBaseChannel, deletedMetaDataKeys: [String]?) {
        debugPrint("")
    }
    
    func channel(_ sender: SBDBaseChannel, createdMetaCounters: [String : NSNumber]?) {
        debugPrint("")
    }
    
    func channel(_ sender: SBDBaseChannel, updatedMetaCounters: [String : NSNumber]?) {
        debugPrint("")
    }
    
    func channel(_ sender: SBDBaseChannel, deletedMetaCountersKeys: [String]?) {
        debugPrint("")
    }
    
    func channelWasHidden(_ sender: SBDGroupChannel) {
        debugPrint("")
    }
    
    func channel(_ sender: SBDGroupChannel, didReceiveInvitation invitees: [SBDUser]?, inviter: SBDUser?) {
    }
    
    func channel(_ sender: SBDGroupChannel, didDeclineInvitation invitee: SBDUser?, inviter: SBDUser?) {
    }
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
    }
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
    }
    
    func channelDidUpdateDeliveryReceipt(_ sender: SBDGroupChannel) {
    }
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        
        debugPrint("unreadMentionCount\(sender.unreadMentionCount)")
    }
    
    func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
    }
    
    func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
    }
    
    func channel(_ sender: SBDBaseChannel, userWasMuted user: SBDUser) {
    }
    
    func channel(_ sender: SBDBaseChannel, userWasUnmuted user: SBDUser) {
    }
    
    func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {
    }
    
    func channel(_ sender: SBDBaseChannel, userWasUnbanned user: SBDUser) {
    }
    
    func channelDidChangeMemberCount(_ channels: [SBDGroupChannel]) {
    }
    
    func channelDidChangeParticipantCount(_ channels: [SBDOpenChannel]) {
    }
    
}
