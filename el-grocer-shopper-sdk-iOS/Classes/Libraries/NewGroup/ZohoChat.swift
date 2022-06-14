//
//  ZohoChat.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 23/07/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import Foundation
//import Mobilisten

class ZohoChat{
    
    class func showChat(_ orderID : String? = nil) {
        
       // ZenDesk.sharedInstance.showLiveChat(orderID: orderID)
    }
    
    
    /*
    class func custimzedZohoView() {
        
        DispatchQueue.main.async {
            
            
            ZohoSalesIQ.Chat.setThemeColor(UIColor.navigationBarColor())
            ZohoSalesIQ.Chat.setBarColor(UIColor.white)
            ZohoSalesIQ.Chat.setBarTintColor(UIColor.newBlackColor())
            ZohoSalesIQ.Chat.setBarTitleColor(UIColor.newBlackColor())
            
            
            ZohoSalesIQ.Chat.setOutgoingMessageBackgroundColor(UIColor.navigationBarColor())
            
            if let name = currentUser?.name {
                ZohoSalesIQ.Visitor.setName(name)
            }

            ZohoSalesIQ.Chat.setTitle("el Grocer")
           // ZohoSalesIQ.Chat.setVisibility(.agent, visible: true)
            ZohoSalesIQ.Chat.setVisibility(.feedback, visible: true)
           // ZohoSalesIQ.Chat.setVisibility(.faq, visible: false)
            ZohoSalesIQ.Chat.setMessage(.chatCompleted, message: "Thank You for contacting us! Please leave us your valuable feedback.")
            
        }
        
    }
    
   
    class func loginZohoWith(_ userID : String ){
        DispatchQueue.main.async {
             ZohoSalesIQ.registerVisitor(userID)
        }
       
    }
    class func logOut(){
        DispatchQueue.main.async {
             ZohoSalesIQ.unregisterVisitor()
        }
       
    }
    */
}
/*
class ZohoChatHandler : ChatActivityHandler
{
    let sharedChat  = ZohoChatHandler()
    override func handleAgentsOnline()
    {
        
    }
}
*/
