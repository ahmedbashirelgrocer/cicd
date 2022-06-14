//
//  SmilesEventsLogger.swift
//  ElGrocerShopper
//
//  Created by Salman on 25/03/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics



enum SmilesEventsName : String {
    
    //case SmilesClicked = "SmilesClicked"//"Action_currentscreen"
    case SmilesPointsClicked = "SmilesPointsClicked"
    case SmilesSignUpClicked = "SmilesSignUpClicked"
    //case SmilesToggle = "SmilesToggle"
    case SmilesToggleOn = "SmilesToggleOn"
    case SmilesToggleOff = "SmilesToggleOff"
    case SmilesError = "SmilesError"
    case PurchaseOrder = "PurchaseOrder"
    case SmilesViewed = "SmilesViewed"

}

enum SmilesEventsParmName : String {
    
    case CurrentScreen = "CurrentScreen"//"Action_currentscreen"
    case IsSmilesLogin = "IsSmilesLogin"
    case Points = "Points"
    case IsSmile = "IsSmile"
    case OrderValue = "OrderValue"
    case newOrderValue = "NewOrderValue"
    case errorMessage = "ErrorMessage"
    case SmilesPointsEarned = "SmilesPointsEarned"
    case SmilesPointsSpent = "SmilesPointsSpent"

}

class SmilesEventsLogger  {
    
    //MARK:- SmilesClickedEvents
    class fileprivate func trackSmilesClickedEvent(_ eventName : String , params :  [String : Any]? = nil) {
        var finalParms = params
        finalParms?[FireBaseParmName.CurrentScreen.rawValue] = (FireBaseEventsLogger.gettopViewControllerName() ?? "")
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix  +  eventName  , parameter:  finalParms  )
    }
    
    //MARK:- SmilesToggle
    class fileprivate func trackSmilesToggleEvent(_ eventName : String , params :  [String : Any]? = nil) {
        var finalParms = params
        //finalParms?[SmilesEventsParmName.CurrentScreen.rawValue] = FireBaseScreenName.SubstitutionConfirmation.rawValue
        finalParms?[FireBaseParmName.CurrentScreen.rawValue] = (FireBaseEventsLogger.gettopViewControllerName() ?? "")
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix  +  eventName  , parameter:  finalParms  )
    }
    
    //MARK:- SmilesError
    class fileprivate func trackSmilesErrorEvent(_ eventName : String , params :  [String : Any]? = nil) {
        var finalParms = params
        //finalParms?[SmilesEventsParmName.CurrentScreen.rawValue] = FireBaseScreenName.SubstitutionConfirmation.rawValue
        finalParms?[FireBaseParmName.CurrentScreen.rawValue] = (FireBaseEventsLogger.gettopViewControllerName() ?? "")
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix  +  eventName  , parameter:  finalParms  )
    }
    

    //MARK:- PurchaseOrder
    class fileprivate func trackPurchaseOrderEvent(_ eventName : String , params :  [String : Any]? = nil) {
        var finalParms = params
        //finalParms?[SmilesEventsParmName.CurrentScreen.rawValue] = FireBaseScreenName.SubstitutionConfirmation.rawValue
        finalParms?[FireBaseParmName.CurrentScreen.rawValue] = (FireBaseEventsLogger.gettopViewControllerName() ?? "")
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix  +  eventName  , parameter:  finalParms  )
    }
    
    //MARK:- SmilesViewed
    class fileprivate func trackSmilesViewedEvent(_ eventName : String , params :  [String : Any]? = nil) {
        
        var finalParms = params
        
        //finalParms?[SmilesEventsParmName.CurrentScreen.rawValue] = FireBaseScreenName.SubstitutionConfirmation.rawValue
        finalParms?[FireBaseParmName.CurrentScreen.rawValue] = (FireBaseEventsLogger.gettopViewControllerName() ?? "")
        
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix  +  eventName  , parameter:  finalParms  )
    }
    
    
    
    
    class func smilesSignUpClickedEvent( isSmileslogin:Bool=false, smilePoints:Any=0) {
        
        let params: [String : Any]? = [
            "clickedEvent": SmilesEventsName.SmilesSignUpClicked.rawValue,
            SmilesEventsParmName.IsSmilesLogin.rawValue: isSmileslogin,
            SmilesEventsParmName.Points.rawValue: smilePoints
            ]
        
        SmilesEventsLogger.trackSmilesClickedEvent(SmilesEventsName.SmilesSignUpClicked.rawValue, params: params)
    }
    
    class func smilePointsClickedEvent( isSmileslogin:Bool=true, smilePoints:Any=0) {
        
        let params: [String : Any]? = [
            "clickedEvent": SmilesEventsName.SmilesPointsClicked.rawValue,
            SmilesEventsParmName.IsSmilesLogin.rawValue: isSmileslogin,
            SmilesEventsParmName.Points.rawValue: smilePoints
            ]
        
        SmilesEventsLogger.trackSmilesClickedEvent(SmilesEventsName.SmilesPointsClicked.rawValue, params: params)
    }
    
    class func smilesToggleEvent( orderValue:Any, isSmilesCheck:Bool, smilePoints:Any ) {
        
        let eventName: String = isSmilesCheck ? SmilesEventsName.SmilesToggleOn.rawValue : SmilesEventsName.SmilesToggleOff.rawValue
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            SmilesEventsParmName.IsSmile.rawValue: isSmilesCheck,
            SmilesEventsParmName.OrderValue.rawValue: orderValue,
            SmilesEventsParmName.Points.rawValue: smilePoints
            ]
        
        SmilesEventsLogger.trackSmilesToggleEvent(eventName, params: params)
    }
    
    //TODO: use this function is response for checkout api when updated
    class func smilesToggleErrorEvent( orderValue:Any, isSmilesCheck:Bool=false, smilePoints:Any, message:Any ) {
        
        var eventName: String = isSmilesCheck ? SmilesEventsName.SmilesToggleOn.rawValue : SmilesEventsName.SmilesToggleOff.rawValue
        
        let params: [String : Any]? = [
            //"clickedEvent": SmilesEventsName.SmilesToggle.rawValue,
            "clickedEvent": eventName,
            SmilesEventsParmName.IsSmile.rawValue: isSmilesCheck,
            SmilesEventsParmName.OrderValue.rawValue: orderValue,
            SmilesEventsParmName.Points.rawValue: smilePoints,
            SmilesEventsParmName.errorMessage.rawValue: message
            ]
        
        
        if !isSmilesCheck {
            eventName = SmilesEventsName.SmilesError.rawValue
            SmilesEventsLogger.trackSmilesErrorEvent(eventName, params: params)
        } else {
            SmilesEventsLogger.trackSmilesErrorEvent(eventName, params: params)
        }
    }
    
    class func smilesPurchaseOrderEvent( orderValue:Int, pointsEarned:Int, pointsBurned:Int, isSmilesCheck:Bool, smilePoints:Int ) {

        let params: [String : Any]? = [
            "clickedEvent": SmilesEventsName.PurchaseOrder.rawValue,
            SmilesEventsParmName.IsSmile.rawValue: isSmilesCheck,
            SmilesEventsParmName.OrderValue.rawValue: orderValue,
            SmilesEventsParmName.Points.rawValue: smilePoints,
            SmilesEventsParmName.SmilesPointsEarned.rawValue: pointsEarned,
            SmilesEventsParmName.SmilesPointsSpent.rawValue: pointsBurned,
            ]

        SmilesEventsLogger.trackPurchaseOrderEvent(SmilesEventsName.PurchaseOrder.rawValue, params: params)
    }
    
    class func smilesImpressionEvent( isSmileslogin:Bool, smilePoints:Any) {
        
        //disabled as per instructed on 25may
        return
        let params: [String : Any]? = [
            "clickedEvent": SmilesEventsName.SmilesViewed.rawValue,
            SmilesEventsParmName.IsSmile.rawValue: isSmileslogin,
            SmilesEventsParmName.Points.rawValue: smilePoints
            ]
        
        SmilesEventsLogger.trackSmilesViewedEvent(SmilesEventsName.SmilesViewed.rawValue, params: params)
    }
    
}
