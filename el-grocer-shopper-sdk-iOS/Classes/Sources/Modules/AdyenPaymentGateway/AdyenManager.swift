//
//  AdyenManager.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 20/12/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import Adyen
import UIKit
import PassKit
import SafariServices

public enum AppleMerchantIdentifier: String {
    
    case staging = "merchant.ElGrocer.com.adyen.ElGrocerUAE-online.test"
    case live = "merchant.com.adyen.ElGrocerUAE-online"
    case smileUAT = "merchant.ae.comtrust.ipg"
    case smileLive = "merchant.com.adyen.elgrocer.smiles"
   
    
    func description() -> String {
        return self.rawValue
    }
    
}


class AdyenManager {
    //
    //
    static let clientKey =  ElGrocerUtility.sharedInstance.isTesting() ? "test_JO6PTRP6TFECJGB2R5CR4OULHIAFIMKK" : "live_LHRGXT6PTFDYXGCKSI5O7BTMKASBBG6M"
    static let demoServerAPIKey = "AQEjhmfuXNWTK0Qc+iSVnkMqqOeeWlHG4AJIHfgzWu3BNmB/j5YQwV1bDb7kfNy1WIxIIkxgBw==-AuE4op/eIk1qEjZsmpvhv+oEJVU/j43SprCrTElnzvI=->q[?C7<>.tj}9w_H"
    
    //
    static let applePayMerchantIdentifier =  SDKManager.isSmileSDK ? (ElGrocerUtility.sharedInstance.isTesting() ? AppleMerchantIdentifier.smileUAT.description() : AppleMerchantIdentifier.smileLive.description()) : (ElGrocerUtility.sharedInstance.isTesting() ? AppleMerchantIdentifier.staging.description() : AppleMerchantIdentifier.live.description())
    
   
    
    static let merchantAccount = "ElGrocerUAE-online"
    static let KEY_SHOPPER_INTERACTION = "shopperInteraction"
    
    let apiContext = APIContext(environment: ElGrocerUtility.sharedInstance.isTesting() ? Environment.test : Environment.live , clientKey: clientKey)
    static let sharedInstance = AdyenManager()
    
    //for handling actions
    internal lazy var actionComponent: AdyenActionComponent = {
    let component = AdyenActionComponent(apiContext: apiContext)
    component.delegate = self
    component.presentationDelegate = self
    return component
    }()
    var cardComponent: CardComponent?
    var applePayComponent: ApplePayComponent?
    var adyendataObj: AdyenManagerObj?
    var adyenPrice : Amount?
    
    typealias paymentSuccess = (_ isError: Bool, _ response: NSDictionary, _ adyenObj: AdyenManagerObj) -> Void
    
    var isNewCardAdded: paymentSuccess?
    var isPaymentMade: paymentSuccess?
    var walletPaymentMade: paymentSuccess?

    func makePaymentWithCard(controller: UIViewController , amount: NSDecimalNumber, orderNum: String = "", method: AnyCardPaymentMethod, isForWallet: Bool = false) {
        
        self.adyenPrice =  AdyenManager.createAmount(amount: amount)
        self.adyendataObj = AdyenManagerObj(amount: amount, orderNumber: orderNum, isZeroAuth: false, isForWallet: isForWallet)
        self.settingPaymentComponent(paymentMethod: method, controller: controller, delegate: self,amount: amount, adyenObj: self.adyendataObj!)
        
    }
    
    func makePaymentWithApple(controller: UIViewController , amount: NSDecimalNumber, orderNum: String = "", method: ApplePayPaymentMethod,isForWallet: Bool = false) {
        
        
        let amountDecimal = amount
        FireBaseEventsLogger.trackCustomEvent(eventType: "payment", action: "makePaymentWithApple", ["amount": amount, "amountDecimalValue" : amountDecimal.decimalValue])
        self.adyendataObj = AdyenManagerObj(amount: amountDecimal, orderNumber: orderNum, isZeroAuth: false, isForWallet: isForWallet)
        
        let amountAdyen = AdyenManager.createAmount(amount: amountDecimal)
        let payment = Payment(amount: amountAdyen, countryCode: "AE")
        let summary = PKPaymentSummaryItem(label: applicationNameForApple, amount: amountDecimal, type: .final)
        let config = ApplePayComponent.Configuration(summaryItems: [summary], merchantIdentifier: AdyenManager.applePayMerchantIdentifier)
        
        self.adyendataObj = AdyenManagerObj(amount: amount, orderNumber: orderNum, isZeroAuth: false, isForWallet: isForWallet)
        self.adyenPrice = amountAdyen
        self.setApplePayComponent(applePaymentMethod: method, payment: payment, configuration: config, controller: controller)
    }
    
    
    func performZeroTokenization(controller: UIViewController,_ isForWallet: Bool = false) {
        
        let amount = AdyenManager.createAmount(amount: 0.0)
        self.adyenPrice = amount
        self.adyendataObj = AdyenManagerObj(amount: 0.0, orderNumber: "", isZeroAuth: true, isForWallet: isForWallet)
        let _ = SpinnerView.showSpinnerViewInView(controller.view)
        AdyenApiManager().getPaymentMethods(amount: amount) { error, paymentMethods in
            SpinnerView.hideSpinnerView()
            if let error = error {
                error.showErrorAlert()
                return
            }
            Thread.OnMainThread {
                if let paymentMethod = paymentMethods {
                    print(paymentMethods)
                    for method in paymentMethod.regular{
                        if method.type.elementsEqual("scheme") {
                            
                            self.settingPaymentComponent(paymentMethod: method as! CardPaymentMethod, controller: controller, delegate: self,amount: 0.0, adyenObj: self.adyendataObj!)
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    func settingPaymentComponent(paymentMethod: AnyCardPaymentMethod, controller: UIViewController, delegate: PaymentComponentDelegate?, amount: NSDecimalNumber,adyenObj: AdyenManagerObj){

        var configurations = CardComponent.Configuration()
        configurations.showsStorePaymentMethodField = false
        configurations.showsHolderNameField = true
        var stored = StoredCardConfiguration.init()
        stored.showsSecurityCodeField = false
        configurations.stored = stored
     
        let style = FormComponentStyle(tintColor: .navigationBarColor())
     
        
        self.cardComponent = CardComponent(paymentMethod: paymentMethod, apiContext: self.apiContext, configuration: configurations, style: style)
     
        if let component = self.cardComponent{
            component.delegate = self
            component.cardComponentDelegate = self
            component.localizationParameters =  ElGrocerUtility.sharedInstance.isArabicSelected() ? LocalizationParameters.init(tableName: "adyenAr") : LocalizationParameters.init(tableName: "adyenEn")
            component.payment = Payment(amount: Amount(value: amount.decimalValue,currencyCode: "AED"), countryCode: "AE")
            if adyenObj.isZeroAuth {
                //if zero auth component is presented in full screen as there are no pre filled card details
                component.viewController.title = localizedString("Add_New_Card_Title", comment: "")
                let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                navigationController.hideSeparationLine()
                navigationController.viewControllers = [component.viewController]
                
                navigationController.setGreenBackgroundColor()
                navigationController.setLogoHidden(true)
                navigationController.actiondelegate = self
                
                component.viewController.modalPresentationStyle = .fullScreen
                navigationController.modalPresentationStyle = .fullScreen
                controller.present(navigationController, animated: true, completion: {  })
            }else {
                //if not zero auth component will be presented in pop up
                controller.present(component.viewController, animated: true)
            }
        }
    }
    
 
    
    func setActionComponent(actionData: Data){
        do{
            let action = try JSONDecoder().decode(Action.self, from: actionData)
            actionComponent.handle(action)
            
        }catch let error{
            SpinnerView.hideSpinnerView()
           elDebugPrint(error.localizedDescription)
            let error = ElGrocerError.genericError()
            error.showErrorAlert()
        }
        
    }
    
    func setApplePayComponent(applePaymentMethod: ApplePayPaymentMethod, payment: Payment,configuration: ApplePayComponent.Configuration, controller: UIViewController){
        
        do{
            self.applePayComponent = try ApplePayComponent(paymentMethod: applePaymentMethod, apiContext: apiContext, payment: payment, configuration: configuration)
            if let component = applePayComponent {
                component.delegate = self
                component.didFinalize(with: true)
                component.viewController.modalPresentationStyle = .fullScreen
                controller.present(component.viewController, animated: true)
            }
        }catch (let error) {
           elDebugPrint(error.localizedDescription)
           // let error = ElGrocerError.genericError()
           // error.showErrorAlert()
            SpinnerView.hideSpinnerView()
            let cancelButtonTitle = localizedString("ok_button_title", comment: "")
            let message = localizedString("error_NoCard_ApplePay", comment: "")
            let errorAlert = ElGrocerAlertView.createAlert(localizedString("sorry_title", comment: ""), description:message ,positiveButton:localizedString("title_SetUp_with_apple_pay", comment: "") ,negativeButton:cancelButtonTitle,buttonClickCallback: { buttonIndex in
                if buttonIndex == 0 {
                let passLibrary = PKPassLibrary()
                passLibrary.openPaymentSetup()
                }
            } )
            errorAlert.show()
        }
        
        
    }
    
    
    func handleActionResponse(data: ActionComponentData, component: ActionComponent){
        AdyenApiManager().handlePaymentAction(data: data) { error, response in
            self.cardComponent?.viewController.dismiss(animated: true, completion: nil)
            self.applePayComponent?.viewController.dismiss(animated: true, completion: nil)
            self.removeSafariChild()
            if let error = error {
                
                SpinnerView.hideSpinnerView()
                if response != nil {
                    let resultCode = response?["resultCode"] as? String ?? ""
                    print(resultCode)
                    let refusalReason = response?["refusalReason"] as? String ?? ""
                    AdyenManager.showErrorAlert(title: resultCode, descr: refusalReason)
                }else {
                    error.showErrorAlert()
                }
                
                
            }else{
                if let adyenObjData = self.adyendataObj, let response = response {
                    if adyenObjData.isZeroAuth {
                        if let closure = self.isNewCardAdded {
                            closure(false,response, adyenObjData)
                        }
                    }else {
                        if let closure = self.isPaymentMade {
                            closure(false,response, adyenObjData)
                        }
                    }
                }
            }
            
            self.cardComponent?.viewController.dismiss(animated: true, completion: nil)
            self.applePayComponent?.viewController.dismiss(animated: true, completion: nil)
            self.removeSafariChild()
            
        }
    }
    
    func handleCardResponseAndPay(data: PaymentComponentData, component: PaymentComponent){
        
        
        guard let paymentMethodDict = data.paymentMethod.dictionary, let adyenObjData = self.adyendataObj else {return }
        let browserInfo = data.browserInfo
        
        var value = AdyenManager.createAmount(amount: adyenObjData.amount)
        if let data = self.adyenPrice {
            value = data
        }
        let _ = SpinnerView.showSpinnerView()
        AdyenApiManager().makePayment(amount: value, orderNum: adyenObjData.orderNumber, paymentMethodDict: paymentMethodDict, isForZeroAuth: adyenObjData.isZeroAuth, isForWallet: adyenObjData.isForWallet, browserInfo: browserInfo) { error, response in
       //     print(error)
            SpinnerView.hideSpinnerView()

            if let error = error {
                
                SpinnerView.hideSpinnerView()
                guard response != nil else {
                    if adyenObjData.isForWallet {
                        self.cardComponent?.viewController.dismiss(animated: true, completion: nil)
                        self.applePayComponent?.viewController.dismiss(animated: true, completion: nil)
                        if let closure = self.walletPaymentMade {
                            closure(true,[:], adyenObjData)
                        }
                    }else {
                        error.showErrorAlert()
                    }
                    
                    return
                }
                let resultCode = response?["resultCode"] as? String ?? ""
                let refusalReason = response?["refusalReason"] as? String ?? ""
                
                if component.paymentMethod.type.elementsEqual("scheme") {
                    self.cardComponent?.viewController.dismiss(animated: true, completion: nil)
                    if adyenObjData.isZeroAuth {
                        if let closure = self.isNewCardAdded {
                            closure(false,response!, adyenObjData)
                        }
                    }else {
                        if let closure = self.isPaymentMade  {
                            closure(refusalReason.count == 0 ? false : true,response!, adyenObjData)
                            
                        }
                    }
                }else{
                    self.applePayComponent?.viewController.dismiss(animated: true, completion: nil)
                    if let closure = self.isPaymentMade {
                        closure(refusalReason.count == 0 ? false : true,response!, adyenObjData)
                    }
                }
                
            }else{
                guard response != nil else {
                    print("something went Wrong")
                    SpinnerView.hideSpinnerView()
                    let error = ElGrocerError()
                    error.showErrorAlert()
                    return
                }
                
                if let action = response?["action"] as? NSDictionary {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: action, options: [])
                        self.setActionComponent(actionData: jsonData)
                        
                    } catch let error {
                        print(error.localizedDescription)
                        let errorGrocer = ElGrocerError.parsingError()
                        errorGrocer.showErrorAlert()
                    }
                }else {
                    
                    if component.paymentMethod.type.elementsEqual("scheme") {
                        self.cardComponent?.viewController.dismiss(animated: true, completion: nil)
                        if adyenObjData.isZeroAuth {
                            if let closure = self.isNewCardAdded {
                                closure(false,response!, adyenObjData)
                            }
                        }else {
                            if let closure = self.isPaymentMade {
                                closure(false,response!, adyenObjData)
                            }
                        }
                    }else{
                        self.applePayComponent?.viewController.dismiss(animated: true, completion: nil)
                        if let closure = self.isPaymentMade {
                            closure(false,response!, adyenObjData)
                        }
                    }
                }
            }
        }
    }
    
        
 
    //End class bracket below
}

//MARK: Adyen Utility Functions
extension AdyenManager {
    
    class func createAmount(amount: NSDecimalNumber, currencyCode: String = "AED")-> Amount{
        
        let amount = Amount(value: amount.decimalValue, currencyCode: currencyCode, localeIdentifier: nil)
        return amount
    }
    
    class func showErrorAlert(title: String = localizedString("alert_error_title", comment: ""), descr: String) {
        
        SpinnerView.hideSpinnerView()
        
        let errorTitle = title
        let okButtonTitle = localizedString("ok_button_title", comment: "")
        
        let alert = ElGrocerAlertView.createAlert(errorTitle, description: descr, positiveButton: okButtonTitle, negativeButton: nil, buttonClickCallback: nil)
        
        alert.show()
    }
    
}

//MARK: delegates
extension AdyenManager: PaymentComponentDelegate{
    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
       elDebugPrint(data)
        handleCardResponseAndPay(data: data, component: component)
        
    }
    
    func didFail(with error: Error, from component: PaymentComponent) {
       elDebugPrint(error)
        
        SpinnerView.hideSpinnerView()
        
        if let error = error as? Adyen.ComponentError {
            if error == Adyen.ComponentError.cancelled {
                return
            }
        }
       
        
        let error = ElGrocerError(error: error as NSError)
        error.showErrorAlert()

        self.cardComponent?.viewController.dismiss(animated: true, completion: nil)
        self.applePayComponent?.viewController.dismiss(animated: true, completion: nil)
        self.removeSafariChild()
        
    }
    
}
extension AdyenManager: ActionComponentDelegate , PresentationDelegate{
    
    func didComplete(from component: ActionComponent) {
       elDebugPrint("success")
    }
    
    func didFail(with error: Error, from component: ActionComponent) {
       elDebugPrint(error.localizedDescription)
        
        SpinnerView.hideSpinnerView()
        
        let error = ElGrocerError(error: error as NSError)
        error.showErrorAlert()
        self.cardComponent?.viewController.dismiss(animated: true, completion: nil)
        self.applePayComponent?.viewController.dismiss(animated: true, completion: nil)
    }
    
    func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
       elDebugPrint(data)
        self.handleActionResponse(data: data, component: component)
        
    }
    
    //PresentationDelegate
    func present(component: PresentableComponent) {
       elDebugPrint(component.viewController)
         
        if component.viewController is SFSafariViewController {
            let child = component.viewController
                        if let topvc = UIApplication.topViewController() {
                            topvc.addChild(child)
                            child.view.frame = CGRect.init(x: 0, y: 0, width: topvc.view.frame.size.width, height: topvc.view.frame.size.height)
                            topvc.view.addSubview(child.view)
                            child.didMove(toParent: topvc)
//
//                            topvc.present(component.viewController, animated: true) {
//                                elDebugPrint("preeseenteed")
//                            }
                        }
        }else{
            component.viewController.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func removeSafariChild() {
        
        if let topVc = UIApplication.topViewController()?.children {
            for vc in topVc {
                if vc is SFSafariViewController {
                    self.hideContentController(content: vc)
                }
            }
        }
    }
    
    func hideContentController(content: UIViewController) {
        content.willMove(toParent: nil)
        content.view.removeFromSuperview()
        content.removeFromParent()
    }
}
extension AdyenManager: CardComponentDelegate{
    func didChangeBIN(_ value: String, component: CardComponent) {
       elDebugPrint(value)
    }
    
    func didChangeCardBrand(_ value: [CardBrand]?, component: CardComponent) {
       elDebugPrint(value)
    }
    
    func didSubmit(lastFour value: String, component: CardComponent) {
       elDebugPrint("last 4 " + value)
    }
    
}

extension AdyenManager: NavigationBarProtocol {
    func backButtonClickedHandler() {
        self.cardComponent?.viewController.dismiss(animated: true, completion: nil)
    }
}
