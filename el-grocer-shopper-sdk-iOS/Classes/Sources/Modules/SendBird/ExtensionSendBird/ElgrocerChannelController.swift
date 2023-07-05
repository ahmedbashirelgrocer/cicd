//
//  ElgrocerChannelController.swift
//  ElGrocerShopper
//
//  Created by saboor Khan on 07/09/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import SendBirdUIKit
import SendBirdDesk
import IQKeyboardManagerSwift
//MARK: to remove reactions , edit message and delete message option
class ElgrocerChannelController : SBUChannelViewController{
    
    lazy var ratingView : SendBirdCustomerFeedback = {
        let ratingView = SendBirdCustomerFeedback.loadFromNib()
        return ratingView!
    }()
    lazy var ratingDelegateView : CustomRatingViewDelegateHandler = {
        let ratingDelegateView = CustomRatingViewDelegateHandler()
        ratingDelegateView.delegate = self
        return ratingDelegateView
    }()
    
    var orderId : String = ""
    let shopperPrefixForSendBirdDesk = "s_"
    var isClosedTicket: Bool = false
    var shouldPop: Bool = false
    var ratingUserMessage: SBDUserMessage?
    var ticket : SBDSKTicket? = nil
    var rating: Float = 0
    var isAlertVisible: Bool = false
    
    override func setLongTapGestureHandler(_ cell: SBUBaseMessageCell, message: SBDBaseMessage, indexPath: IndexPath) {
        return
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialAppearence()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
         self.navigationController?.navigationBar.isTranslucent = true
        self.addBackButton(isGreen: true)
        self.readLastMessage()
        self.closeChatIfNeeded()
        self.handleArabicMode()
    }
    func handleArabicMode() {
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.messageInputView.sendButton?.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func closeChatIfNeeded() {
        guard let message = self.channel?.lastMessage else {
            return
        }
        if let msgData = message.data.data(using: .utf8) {
            let dataObject = try? JSONSerialization.jsonObject(with: msgData, options: []) as? [String: Any]
            if let dataObj = dataObject, let dataObj = dataObj, dataObj["type"] as? String == "NOTIFICATION_MANUAL_CLOSED" {
                self.messageInputView.showsSendButton = false
                for views in self.messageInputView.subviews {
                    views.isHidden = true
                }
            }
        }
    }
    
    func readLastMessage() {
        guard let message = self.channel?.lastMessage else {
            return
        }
        
        if let msgData = message.data.data(using: .utf8) {
            let dataObject = try? JSONSerialization.jsonObject(with: msgData, options: []) as? [String: Any]
            if let dataObj = dataObject, let dataObj = dataObj {
                handleMessageType(data: dataObj, message: message)
            }
        }
    }
    
    func setInitialAppearence(){
        
        self.useRightBarButtonItem = false
        setChannelName()
        IQKeyboardManager.shared.enableAutoToolbar = true
       // self.addBackButton()
    }
    override func backButtonClick() {
        if shouldPop {
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        elDebugPrint("")

    }
    
    func setOrderId(orderDbId : String) {
        self.orderId = orderDbId
        self.setChannelName()
    }
    
    func setChannelName() {
        let titleView = SBUNavigationTitleView()
        titleView.textAlignment = .center
        titleView.isHidden = false
        
        if UserDefaults.isUserLoggedIn(){
            if self.orderId == "0" {
                titleView.text = localizedString("support_sendBird_nav_title", comment: "")
            }else{
                titleView.text = localizedString("order_sendBird_nav_title", comment: "") + ": \(orderId)"
            }
        }else{
            titleView.text = localizedString("support_sendBird_nav_title", comment: "")
        }
        
        if let text = titleView.text{
            if text.count > 0{
                if text.lowercased().contains("proactive"){
                    titleView.text = localizedString("title_proactive", comment: "")
                }
            }
        }
        

        self.navigationItem.titleView = titleView
    }
    override func didSelectRetry() {
        self.dismiss(animated: true, completion: nil)

    }
    
    func submitTicketClosure(message: SBDUserMessage) {
        
        SBDSKTicket.confirmEndOfChat(with: message, confirm: true) { ticket, error in
            if error != nil {
               elDebugPrint(error)
                return
            }
        }
    }
    
    func submitCSATExperience(message: SBDUserMessage, rating: Int, comment: String) {
        SBDSKTicket.submitFeedback(with: message, score: rating, comment: comment) { ticketHandler, error in
            guard error == nil else {
               elDebugPrint(error?.code)
               elDebugPrint(error?.description)
               elDebugPrint(error?.debugDescription)
                return
            }
            Thread.OnMainThread {
                self.handleRatingView(isEnabled: false)
            }
        }
    }
    //over ride functions
    override func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        super.channel(sender, didReceive: message)
        if let msgData = message.data.data(using: .utf8) {
            let dataObject = try? JSONSerialization.jsonObject(with: msgData, options: []) as? [String: Any]
            if let dataObj = dataObject, let dataObj = dataObj {
                handleMessageType(data: dataObj, message: message)
            }
        }
    }
    
    override func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage) {
       elDebugPrint(message)
    }
    
    
    
    
       
    
    
    
}
extension ElgrocerChannelController {
   
    func showTicketClosureAlert(message: SBDUserMessage?) {
        
        guard message != nil else{
            return
        }
        
        for  view in (UIApplication.shared.keyWindow?.subviews ?? []) {
            if view is ElGrocerAlertView {
                view.removeFromSuperview()
            }
        }

        let alert = ElGrocerAlertView.createAlert("", description: message!.message, positiveButton: localizedString("store_favourite_alert_yes", comment: ""), negativeButton: localizedString("sign_out_alert_no", comment: "")) { index in
            self.isAlertVisible = false
            if index == 0 {
//               elDebugPrint("yes")
                self.submitTicketClosure(message: message!)
            }
        }
        alert.show()
    }
    
    func handleMessageType(data: [String: Any], message: SBDBaseMessage) {
        
        
        
        guard let messageType = data["type"] as? String else {
            return
        }
        
        if messageType == "SENDBIRD_DESK_CUSTOMER_SATISFACTION" {
            let closureInquiry = data["body"] as? [String: Any]
            let state = closureInquiry?["state"] as? String
            self.view.endEditing(true)
            switch state {
                case "CONFIRMED":
                // Implement your code for the UI when there is a response from a customer.
               elDebugPrint("survey is already submitted")
                let rating = closureInquiry?["customerSatisfactionScore"] as? Int ?? 0
                let comment = closureInquiry?["customerSatisfactionComment"] as? String ?? ""
                self.showRatingView(title: message.message)
                self.assignSubmittedValues(rating: Float(rating), comment: comment)
                self.handleRatingView(isEnabled: false)
                
                case "WAITING":
                // Implement your code for the UI when there is no response from a customer.
               elDebugPrint("survey needs to be submitted")
                if let message = message as? SBDUserMessage {
                    self.ratingUserMessage = message
                }
                self.showRatingView(title: message.message)
                self.handleRatingView(isEnabled: true)
                
                default: break
            }
        }else if messageType == "SENDBIRD_DESK_INQUIRE_TICKET_CLOSURE" {
            let closureInquiry = data["body"] as? [String: Any]
            let state = closureInquiry?["state"] as? String
            self.view.endEditing(true)
            switch state {
                case "CONFIRMED":
                // Implement your code for the UI when a customer confirms to close a ticket.
                   elDebugPrint("confirmed")
                isAlertVisible = false
                case "DECLINED":
                // Implement your code for the UI when a customer declines to close a ticket.
                   elDebugPrint("DECLINED")
                isAlertVisible = false
                case "WAITING":
                // Implement your code for the UI when there is no response from a customer.
                   elDebugPrint("WAITING")
                guard let message = message as? SBDUserMessage else {
                        return
                }
                    self.isAlertVisible = true
                self.showTicketClosureAlert(message: message)
                
                default: break
            }
                        
        }
    }
    
    func handleRatingView(isEnabled: Bool = false) {
        self.view.endEditing(true)
        self.ratingView.starRatingView.isUserInteractionEnabled = isEnabled
        self.ratingView.growingTextView.isUserInteractionEnabled = isEnabled
        self.ratingView.btnSubmitFeedback.isUserInteractionEnabled = isEnabled
        self.ratingView.btnSubmitFeedback.backgroundColor = isEnabled ? ApplicationTheme.currentTheme.buttonEnableBGColor : ApplicationTheme.currentTheme.buttonDisableBGColor
    }
    func assignSubmittedValues(rating: Float, comment: String) {
        self.ratingView.starRatingView.rating = rating
        self.ratingView.growingTextView.text = comment
    }
    
}
extension ElgrocerChannelController {
    func showRatingView(title: String) {
        ratingView.backgroundColor = .navigationBarWhiteColor()
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        self.messageInputView.addSubview(ratingView)
        self.messageInputView.bringSubviewToFront(ratingView)
        self.ratingView.setNeedsLayout()
        self.ratingView.layoutIfNeeded()
        ratingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 0).isActive = true
        ratingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: 0).isActive = true
//        ratingView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        ratingView.topAnchor.constraint(equalTo: self.messageInputView.topAnchor).isActive = true
        ratingView.bottomAnchor.constraint(equalTo: self.messageInputView.bottomAnchor).isActive = true
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            ratingView.starRatingView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        roundWithCustomShadow()
        setRatingViewData(title: title)
        handleRatingViewClosure()
    }
    func handleRatingViewClosure() {
        
        self.ratingView.btnSubmitPressed = {
            if let message = self.ratingUserMessage, self.rating > 0 {
                self.submitCSATExperience(message: message, rating: Int(self.rating), comment: self.ratingView.growingTextView.text ?? "")
            }
        }
        
    }
    
    func setRatingViewData(title: String) {
        self.ratingView.lblHeading.text = title
        self.ratingView.setRatingViewDelegate(delegate: ratingDelegateView)
    }
    
    func roundWithCustomShadow() {
        self.ratingView.layer.shadowOffset = CGSize(width: -6, height: 6)
        self.ratingView.layer.shadowOpacity = 0.16
        self.ratingView.layer.shadowRadius = 10
        
        self.ratingView.layer.cornerRadius = 16
        self.ratingView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

}
extension ElgrocerChannelController: customRatingViewHandlerProtocol {
    
    func didUpdateRating(rating: Float) {
       elDebugPrint("rating: \(rating)")
        self.rating = rating
        
    }
}
