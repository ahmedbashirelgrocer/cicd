//
//  Constants.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 20/06/2022.
//

import Foundation

// MARK: Constants

//private enum BackendSuggestedAction: Int {
//    case Continue = 0
//    case ForceUpdate = 1
//}

let KUpdateBasketToServer = "update To server"
let kHelpShiftApiKey = "f4b06efaf1612c5925da8888702aeea3"
let kHelpShiftDomainName = "elgrocer.helpshift.com"
let kHelpShiftAppId = "elgrocer_platform_20150806182025195-893afc8050f1f9f"

let kHelpshiftChatResponseNotificationKey = "HelpshiftChatResponseNOtification"
let KRefreshActiveBasketData = "NewBasketRetreiveFromServer"
let kProductUpdateNotificationKey = "UpdateProductsNotification"
let kBasketUpdateNotificationKey = "UpdateBasketNotification"
let kReOrderNotificationKey = "ReOrderNotification"
let KSlotsUpdate = "slotRefreshCalled"
let KUpdateGenericSlotView = "slotRefreshView"
let KCheckPhoneNumber = "slotRefreshCalled"
let KRefreshGroceries = "Refresh Grocery Called"
let KGoToMayBasket = "LoadMyBasketVC"
let KGoBackToOrderScreen = "PendingStageReactiveted"
let kBasketUpdateForEditNotificationKey = "UpdateBasketForEditNotification"
let kStartCheckOutProcessKey = "allDataDonenPleaseStartCheckoutProcessFromMYBasketScreen"

let kGoogleMapsApiKey   =  Bundle.main.bundleIdentifier == "elgrocer.com.ElGrocerShopper.SDK" ?  "AIzaSyCqtepDQi1zQc-k5FF0z6I84h5raUuBy2U" : "" // AIzaSyDYXdoLYTAByiN7tc1wDIL_D7hqe01dJG0 forlive

let KGoToBasket = "gotoBackFromTabBar"
let KCancelOldAllCalls = "CancelDataCalls"
