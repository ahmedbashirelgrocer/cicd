//
//  SubtitutionBasketViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 21/09/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit
import WebKit
class SubtitutionBasketViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var substitutionSummaryTitle: UILabel!
    @IBOutlet weak var substitutionMessage: UILabel!
    
    @IBOutlet weak var substitutionTableView: UITableView!
    
    @IBOutlet weak var buttonsContainer: UIView!
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var sendButton_short: UIButton!
    @IBOutlet var cancelOrderButton: UIButton!
    
    @IBOutlet weak var viewStats: UIView!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    let child = SpinnerViewController()
    let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    var cardCvv = ""
    //var reference = String(format: "%.0f", Date.timeIntervalSinceReferenceDate)
    var reference : String   {
        get {
            let refValue = String(format: "%.0f", Date.timeIntervalSinceReferenceDate)
            //debugPrint("refGetcall: \(refValue)")
            return refValue  }
    }
    
    
    // MARK: Variables
    var order:Order!
    var orderItems:[ShoppingBasketItem]!
    var substitutionItems:[SubstitutionBasketItem]!

    var basketItems: Array<Product> = []
    var totalPrice : Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = localizedString("substitutions_title_new", comment: "")
        
        addBackButton()
        
        self.setSubstitutionSummaryViewAppearance()
        self.setupLabelAppearance()
        self.configureSubstitutionTableView()
        self.setButtonsContainerAppearance()
        
        self.orderItems = ShoppingBasketItem.getBasketItemsForOrder(self.order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        self.substitutionItems = SubstitutionBasketItem.getSubstitutionItemsForOrder(self.order, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
    
        let subtitutedProducts = OrderSubstitution.getSubtitutedProductsForOrderBasketWithCancelProduct(order, grocery: nil, context:DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        var addingIndex = 0
        
        var isHideCancelButton = true
        var isEnableSendButton = false
        
        for product in subtitutedProducts {
            
            let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            if basketItem!.isSubtituted == 1 {
                
                isEnableSendButton = true
                basketItems.insert(product, at: addingIndex)
                addingIndex += 1
                
            } else if basketItem!.isSubtituted == 2 {
                basketItems.append(product)
                isHideCancelButton = false
            }else{
                basketItems.append(product)
            }
        }
        
        let orderProducts = ShoppingBasketItem.getBasketProductsForOrder(self.order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        for product in orderProducts {
            
            let item = shoppingItemForProduct(product)
            if (item!.wasInShop.boolValue == true){
                isEnableSendButton = true
                break
            }
        }
        
        self.calculateOrderQuantityAndPrice()
        
        self.hideCancelOrderButton(isHideCancelButton)
        self.setSendButtonEnabled(isEnableSendButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        FireBaseEventsLogger.setScreenName( FireBaseScreenName.SubstitutionConfirmation.rawValue , screenClass: String(describing: self.classForCoder))
    }

    func calculateOrderQuantityAndPrice() {
        let subtitutedProducts = OrderSubstitution.getSubtitutedProductsForOrderBasket(order, grocery: nil, context:DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        var totalQuantity = 0
            totalPrice    = 0.0
        
        for product in subtitutedProducts {
            
            let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            if basketItem!.isSubtituted == 1 {
                
                let suggestedProduct = SubstitutionBasketItem.getSubstitutionBasketProductForSubtitutedProduct(self.order, subtitutedProduct: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                let basketItem = self.substitutionItemForProduct(suggestedProduct)
                
                totalQuantity   = totalQuantity + (basketItem?.count.intValue)!
                
                let price = (basketItem?.count.floatValue)! * suggestedProduct.price.floatValue
                totalPrice  = totalPrice + price
                
            }
        }
        
        if totalQuantity > 0 {
            self.substitutionTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
            self.viewStats.isHidden   = false
            
            let countLabel = totalQuantity == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")
            
            self.lblQuantity.text   = String(format: "%d %@",totalQuantity,countLabel)
            self.lblTotalPrice.text = String(format: "%@ %.2f",CurrencyManager.getCurrentCurrency() , totalPrice)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Appearance
    
    private func setSubstitutionSummaryViewAppearance() {
        
        self.substitutionSummaryTitle.font = UIFont.SFProDisplaySemiBoldFont(13.0)
        self.substitutionSummaryTitle.textColor = UIColor.black
        self.substitutionSummaryTitle.text = localizedString("choose_substitutions_title_new", comment: "")
        
        self.substitutionMessage.font = UIFont.bookFont(11.0)
        self.substitutionMessage.textColor = UIColor.black
        self.substitutionMessage.text = localizedString("products_out_of_stock_message_new", comment: "")
    }
    
    func setupLabelAppearance() {
        
        self.quantityLabel.font         = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.quantityLabel.text         = localizedString("substituted_items", comment: "")
        self.lblQuantity.font           = UIFont.SFProDisplaySemiBoldFont(14.0)
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            self.lblQuantity.textAlignment  = NSTextAlignment.left
        }else{
            self.lblQuantity.textAlignment  = NSTextAlignment.right
        }
        
        self.totalPriceLabel.font   = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.totalPriceLabel.text   = localizedString("total_price_:", comment: "")
        self.lblTotalPrice.font     = UIFont.SFProDisplaySemiBoldFont(17.0)
    }
    
    private func configureSubstitutionTableView() {
        
        self.substitutionTableView.separatorColor = UIColor.borderGrayColor()
        self.substitutionTableView.separatorInset = UIEdgeInsets.zero
        self.substitutionTableView.tableFooterView = UIView()
    }
    
    private func setButtonsContainerAppearance(){
        
        self.configureSendButtonAppearence()
        self.configureCancelOrderButtonApperence()
    }
    
    private func configureSendButtonAppearence(){
        
        self.sendButton.setTitle(localizedString("confirm_button_title_new", comment: "").uppercased(), for: UIControl.State())
        self.sendButton.titleLabel?.font = UIFont.SFProDisplayBoldFont(12.0)
        
        self.sendButton_short.setTitle(localizedString("confirm_button_title_new", comment: "").uppercased(), for: UIControl.State())
        self.sendButton_short.titleLabel?.font = UIFont.SFProDisplayBoldFont(12.0)
    }
    
    fileprivate func setSendButtonEnabled(_ enabled:Bool) {
        
        self.sendButton.isEnabled = enabled
        self.sendButton_short.isEnabled = enabled
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.sendButton.alpha = enabled ? 1 : 0.3
            self.sendButton_short.alpha = enabled ? 1 : 0.3
        })
    }
    
    
    private func configureCancelOrderButtonApperence(){
        
        self.cancelOrderButton.setTitle(localizedString("cancel_order_button_title", comment: ""), for: UIControl.State())
        self.cancelOrderButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(13.0)
    }
    
    private func hideCancelOrderButton(_ hidden:Bool){
        self.cancelOrderButton.isHidden   = hidden
        self.sendButton_short.isHidden    = hidden
        self.sendButton.isHidden          = !hidden
    }
    
     // MARK: UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.basketItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let product     		= self.basketItems[indexPath.row]
        let basketItem          = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if ((basketItem != nil) && (basketItem?.isSubtituted == 1)) {
            return kSubstitutionItemCellHeight_sub
        }else{
            return kSubstitutionItemCellHeight_cancel
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let product     		= self.basketItems[indexPath.row]
        let basketItem          = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if ((basketItem != nil) && (basketItem?.isSubtituted == 1)) {
            let product1    = product
            let basketItem1 = basketItem
            
            let product2 = SubstitutionBasketItem.getSubstitutionBasketProductForSubtitutedProduct(self.order, subtitutedProduct: product1, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            let basketItem2 = self.substitutionItemForProduct(product2)
            let subtitutionBasketCell = tableView.dequeueReusableCell(withIdentifier: kSubtitutionBasketCellIdentifier_Sub, for: indexPath) as! SubtitutionBasketCell
            subtitutionBasketCell.delegate  = self
            if basketItem1 != nil && basketItem2 != nil {
                 subtitutionBasketCell.configureWithSubstitutionBasketItem(product1, shoppingItem1: basketItem1!, product2: product2, shoppingItem2: basketItem2!, currentRow: indexPath.row)
            }else{
                subtitutionBasketCell.baseView.isHidden = true
            }
        
            return subtitutionBasketCell
        }else{
            
            let subtitutionBasketCell = tableView.dequeueReusableCell(withIdentifier: kSubtitutionBasketCellIdentifier_Cancel, for: indexPath) as! SubtitutionBasketCell
            subtitutionBasketCell.configureCancelledCellWithShoppingBasketItem(basketItem!, product: product, currentRow: indexPath.row)
            return subtitutionBasketCell
            
        }
    }
    
    // MARK: Helpers
    
    private func shoppingItemForProduct(_ product:Product) -> ShoppingBasketItem? {
        
        var productId = product.dbID
        
        let productIds = product.dbID.components(separatedBy: "_")
    
        if productIds.count > 3 {
            productId = String(format: "%@_%@_%@",productIds[0],productIds[1],productIds[2])
        }
        
        print("ProductId:%@",productId)
        
        for item in self.orderItems {
            
            if productId == item.productId {
                return item
            }
        }
        
        return nil
    }
    
    private func substitutionItemForProduct(_ product:Product) -> SubstitutionBasketItem? {
        
        for item in self.substitutionItems {
            
            if product.dbID == item.productId {
                return item
            }
        }
        
        return nil
    }
    
    // MARK: Actions
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func sendReplacmentHandler(_ sender: Any) {
        
        FireBaseEventsLogger.trackSubstitutionConfirmationEvents("SendReplacement")
        
        if let reftrans = self.order.refToken, let cardID = self.order.cardID {
            
            ElGrocerUtility.sharedInstance.getCvvFromUser(controller: self , self.order.cardLast ?? "" ) { (cvv, isSuccess) in

                if isSuccess {
                    self.gotoCvvAuth(cvv, cardID: cardID , authAmount:  self.finalAmmountWithSubItems() )
                }else{
                    let errorAlert = ElGrocerAlertView.createAlert(localizedString("sorry_title", comment: ""),description:localizedString("cvv_alert_msg", comment: "") ,positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
                    errorAlert.showPopUp()
                    // self.setSendButtonEnabled(true)
                }

            }
            return
                        
//             let userEmail = userProfile?.email ?? ""
//
//            let url = ElGrocerApi.sharedInstance.baseApiPath + "/online_payments/require_cvv" + "?" + "customer_email=\(String(describing: userEmail))" + "&" + "merchant_reference=\(ElGrocerUtility.sharedInstance.getRefernceFrom(isAddCard: false, orderID: self.order.dbID.stringValue, ammount: self.finalAmmountWithSubItems() , randomRef: self.reference, ""))" + "&" + "token=\(reftrans)"
//            let finalURL = url.replacingOccurrences(of: "/api/", with: "")
//            self.loadFiler3dURL(finalURL)
//            return
           
            
            /*
            let userID = userProfile?.dbID.stringValue ?? ""
            UserDefaults.setCardID(cardID: self.order.cardID ?? "" , userID: userID)
            let ammountHold = UserDefaults.getAmmountRef(userID: userID)
            let marchentRef = UserDefaults.getMarchentRef(userID: userID)
            if ammountHold == "" {
                self.callForAuth(tokenName: token)
                return;
            }else {
                
                if ammountHold ==  self.finalAmmountWithSubItems().description  {
                    self.callForReplacement(marchentRef , amountoHold: self.finalAmmountWithSubItems())
                    return
                }else{
                    debugPrint("diff")
                    voidAuthCall(marchentRef)
                    return
                }
            }
            */
        }
        
        self.setSendButtonEnabled(false)
        self.callForReplacement()
    }
    
    
    func gotoCvvAuth (_ cvv : String , cardID : String , authAmount : Double ) {
        
        let vc = ElGrocerViewControllers.getEmbededPaymentWebViewController()
        vc.isAddNewCard = false
        vc.isNeedToDismiss = false
        vc.isForCVVAuth = false
        vc.isForSub = true
        vc.order = order
        vc.cvv = cvv
        vc.cardID = cardID
        vc.authAmount = authAmount
        vc.finalOrderItems  = self.orderItems
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        vc.refreshCardApi = { [weak self] (isProceeCompleted) in
             self?.callForReplacement()
        }
        
    }
    
    
    
    func voidAuthCall(_ ref : String) {
        
        ElgrocerAPINonBase.sharedInstance.voidAuthorization(fortID: ref ) { (isSuccess, dict) in
            
            if isSuccess {
                UserDefaults.removeMerchantRef(userID: self.userProfile?.dbID.stringValue ?? "")
                UserDefaults.removeAmountRef(userID: self.userProfile?.dbID.stringValue ?? "")
            }else{  }
            self.sendReplacmentHandler("")
        }
        
        
    }
    
    func callForReplacement(_ ref : String? = "" , amountoHold : Double = 0.0) {
        
        //subtitute order
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        let subtitutedProducts = OrderSubstitution.getSubtitutedProductsForOrderBasket(order, grocery: nil, context:DatabaseHelper.sharedInstance.mainManagedObjectContext)
        ElGrocerApi.sharedInstance.sendSubstitutionForOrder(self.order, withProducts: subtitutedProducts , ref: ref ?? "" , amount: amountoHold  ,completionHandler: { (result) -> Void in
            
            switch result {
                case .success(let responseDict):
                    spinner?.removeFromSuperview()
                    print("Subtitution Response Dict:%@",responseDict)
                    
                    UserDefaults.removeMerchantRef(userID: self.userProfile?.dbID.stringValue ?? "")
                    UserDefaults.removeAmountRef(userID: self.userProfile?.dbID.stringValue ?? "")
                    
                    if(ElGrocerUtility.sharedInstance.isNavigationForSubstitution == true){
                        ElGrocerUtility.sharedInstance.isNavigationForSubstitution = false
                        self.navigationController?.popToRootViewController(animated: true)
                    }else{
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kOrderUpdateNotificationKey), object: nil)
                
                case .failure(let error):
                    spinner?.removeFromSuperview()
                    self.setSendButtonEnabled(true)
                    error.showErrorAlert()
            }
        })
        
        
    }
    
    
    func callForAuth(tokenName : String  ) {
        
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        guard let email = userProfile?.email else  {
            return
        }
        
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        
        var ip = DeviceIp.getWiFiAddress()
        if let publicAddress =  DeviceIp.getPublicAddress() {
            if publicAddress.count > 0 {
                ip = publicAddress
            }
        }
        
        ElGrocerUtility.sharedInstance.getCvvFromUser(controller: self , self.order.cardLast ?? "" ) { (cvv, isSuccess) in
            
            if isSuccess {
                
                ElgrocerAPINonBase.sharedInstance.authorization(cvv: cvv , token: tokenName, email: email , amountToHold: self.finalAmmountWithSubItems()  , ip: ip ?? "") { (isSuccess, dataDict) in
                    debugPrint(isSuccess)
                    SpinnerView.hideSpinnerView()
                    if isSuccess {
                        if let urlds = dataDict?["3ds_url"] as? String {
                            self.cardCvv = cvv
                            self.loadFiler3dURL(urlds)
                            return
                        }else {
                            UserDefaults.setMerchantRef(ref: dataDict?["merchant_reference"] as! String , userID: self.userProfile?.dbID.stringValue ?? "")
                            UserDefaults.setAmountRef(userID: self.userProfile?.dbID.stringValue ?? "" , ammount: self.finalAmmountWithSubItems().description )
                            let _ = UserDefaults.setSecureCVV(userID: self.userProfile?.dbID.stringValue ?? "" , cardID: self.order.cardID ?? "", cvv: cvv )
                            self.sendReplacmentHandler("")
                            return
                        }
                        
                    }
                    self.setSendButtonEnabled(true)
                }
                return
            }else {
                self.showErrorAlert()
            }
                                                                
        }
        
 
    }
    
    func finalAmmountWithSubItems () -> Double{
        
        let subtitutedProducts = OrderSubstitution.getSubtitutedProductsForOrderBasket(order, grocery: nil, context:DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        var nonSubsTotalPrice : Float = 0.0
        var substotalPrice : Float   = 0.0
        
        for product in subtitutedProducts {
            
            let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            if basketItem!.isSubtituted == 1 {
                
                let suggestedProduct = SubstitutionBasketItem.getSubstitutionBasketProductForSubtitutedProduct(self.order, subtitutedProduct: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                let basketItem = self.substitutionItemForProduct(suggestedProduct)
                let price = (basketItem?.count.floatValue)! * suggestedProduct.price.floatValue
                substotalPrice  = substotalPrice + price
                
            }
            
        }
        
        let orderProducts = ShoppingBasketItem.getBasketProductsForOrder(self.order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        for product in orderProducts {
            
            if let basketItem = shoppingItemForProduct(product) {
                if (basketItem.wasInShop.boolValue == true){
                    let price = (basketItem.count.floatValue) * product.price.floatValue
                    nonSubsTotalPrice = nonSubsTotalPrice + price
                }
            }
            
        }
        
        var serviceFee = ElGrocerUtility.sharedInstance.getFinalServiceFee(currentGrocery: self.order.grocery, totalPrice: Double(nonSubsTotalPrice + substotalPrice))
        return Double(nonSubsTotalPrice + substotalPrice + Float(serviceFee))
        
    }
    
    
    
    func loadFiler3dURL(_ urlStr : String) {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        let webView =  WKWebView(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width , height: view.frame.size.height) , configuration: configuration)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        //        self.view = webView
     //   let _ = SpinnerView.showSpinnerViewInView(webView)
        if let url = URL(string: urlStr) {
            let request = NSMutableURLRequest.init(url: url)  // URLRequest(url: url)
            request.httpMethod = "POST";
            var currentLang = LanguageManager.sharedInstance.getSelectedLocale()
            if currentLang == "Base" {
                currentLang = "en"
            }
            var final_Version = "1000000"
            if let version = Bundle.resource.infoDictionary?["CFBundleShortVersionString"] as? String {
                final_Version = version
            }
            request.allHTTPHeaderFields = ["Locale" : currentLang , "app_version" : final_Version ]
            webView.load(request as URLRequest)
        }
     //   createSpinnerView()
    }
    
    func createSpinnerView() {
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    
    func hideSpineer () {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    
    
    
    
    @IBAction func cancelButtonHandler(_ sender: Any) {
        //show confirmation alert
        
        
        let SDKManager = UIApplication.shared.delegate as! SDKManager
        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "NoCartPopUp") , header: "" , detail: localizedString("order_history_cancel_alert_message", comment: ""),localizedString("sign_out_alert_no", comment: "")  , localizedString("sign_out_alert_yes", comment: "") , withView: SDKManager.window!) { (buttonIndex) in
            
            if buttonIndex == 1 {
                FireBaseEventsLogger.trackSubstitutionConfirmationEvents("CancelOrder")
//                self.cancelOrder()
                self.cancelOrderHandler(self.order.dbID.stringValue)
            }
        }
        
        
        
        
        
//        ElGrocerAlertView.createAlert(localizedString("order_history_cancel_alert_title", comment: ""),
//                                      description: localizedString("order_history_cancel_alert_message", comment: ""),
//                                      positiveButton: localizedString("sign_out_alert_yes", comment: ""),
//                                      negativeButton: localizedString("sign_out_alert_no", comment: "")) { (buttonIndex:Int) -> Void in
//                                        
//                                        if buttonIndex == 0 {
//                                            FireBaseEventsLogger.trackSubstitutionConfirmationEvents("CancelOrder")
//                                            self.cancelOrder()
//                                            
//                                        }
//                                        
//            }.show()
    }
    func cancelOrderHandler(_ orderId : String){
        guard !orderId.isEmpty else {return}
        let cancelationHandler = OrderCancelationHandler.init { (isCancel) in
            debugPrint("")
            self.orderCancelled(isSuccess: isCancel)
        }
        cancelationHandler.startCancelationProcess(inVC: self, with: orderId)
    }
    func orderCancelled(isSuccess: Bool) {
        print(" OrderCancelationHandlerProtocol checkIfOrderCancelled fuction called")
         if isSuccess{
             self.perform(#selector(self.dismissView), with: nil, afterDelay: 3.0)
 
         }else{
             print("protocol fuction called Error")
         }
    }
    
    func cancelOrder(){
        
        
        
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        
        let orderId = String(describing: self.order.dbID)
        ElGrocerApi.sharedInstance.cancelOrder(orderId, completionHandler: { (result) -> Void in
            
            spinner?.removeFromSuperview()
            
            switch result {
            case .success(_):
                
//                let notification = ElGrocerAlertView.createAlert(localizedString("order_cancel_alert_title", comment: ""),description: localizedString("order_cancel_success_message", comment: ""),positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
//                notification.showPopUp()
                ElGrocerUtility.sharedInstance.showTopMessageView(localizedString("order_cancel_success_message", comment: "") , image: UIImage(name: "MyBasketOutOfStockStatusBar"), -1 , false) { (t1, t2, t3) in }
                
                self.perform(#selector(self.dismissView), with: nil, afterDelay: 3.0)
                
            case .failure(let error):
                error.showErrorAlert()
            }
        })
    }
    
    @objc func dismissView(){
        
        self.order.status = NSNumber(value: OrderStatus.canceled.rawValue as Int)
        DatabaseHelper.sharedInstance.saveDatabase()
        if(ElGrocerUtility.sharedInstance.isNavigationForSubstitution == true){
            ElGrocerUtility.sharedInstance.isNavigationForSubstitution = false
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: kOrderUpdateNotificationKey), object: nil)
    }
}

extension SubtitutionBasketViewController: SubtitutionBasketCellProtocol {
    
    func addProductInBasketWithProductIndex(_ index:NSInteger){
        
        let product     		= self.basketItems[index]
        let basketItem          = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        
        if ((basketItem != nil) && (basketItem?.isSubtituted == 1)) {
            let product1    = product
            
            let product2 = SubstitutionBasketItem.getSubstitutionBasketProductForSubtitutedProduct(self.order, subtitutedProduct: product1, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            let basketItem2 = self.substitutionItemForProduct(product2)

            let newCount            = (basketItem2?.count.intValue)! + 1
            basketItem2?.count       = NSNumber(value: newCount)
            
            //_ = [self.substitutionTableView .reloadRows(at: [NSIndexPath(forRow: index, inSection: 0) as IndexPath], with: UITableViewRowAnimation.none)]
            _ = [self.substitutionTableView .reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.none)]
            DatabaseHelper.sharedInstance.saveDatabase()
            self.calculateOrderQuantityAndPrice()
            
            ElGrocerEventsLogger.sharedInstance.addToCart(product: product2)           
//            GoogleAnalyticsHelper.trackAddToProduct(product: product2)
//            FireBaseEventsLogger.trackAddToProduct(product: product2)
        }
        
    }
    
    func discardProductInBasketWithProductIndex(_ index:NSInteger){
        
        let product     		= self.basketItems[index]
        let basketItem          = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        
        if ((basketItem != nil) && (basketItem?.isSubtituted == 1)) {
            let product1    = product
            
            let product2 = SubstitutionBasketItem.getSubstitutionBasketProductForSubtitutedProduct(self.order, subtitutedProduct: product1, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            let basketItem2 = self.substitutionItemForProduct(product2)
            
            if let tmpBasketItem = basketItem2 {
                
                if tmpBasketItem.count > 1 {
                    let newCount            = (tmpBasketItem.count.intValue) - 1
                    tmpBasketItem.count     = NSNumber(value: newCount)
                    
                    _ = [self.substitutionTableView .reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.none)]
                    DatabaseHelper.sharedInstance.saveDatabase()
                    self.calculateOrderQuantityAndPrice()
                }
            }
            FireBaseEventsLogger.trackDecrementAddToProduct(product: product2)
        }
    }
}
extension SubtitutionBasketViewController : WKNavigationDelegate {
    
    func showErrorAlert (_ message : String = "Error while adding card") {
        
        SpinnerView.hideSpinnerView()
        self.dismiss(animated: true) {
            let errorAlert = ElGrocerAlertView.createAlert(localizedString("sorry_title", comment: ""),description:message ,positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
            errorAlert.showPopUp()
        }
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint(error)
        hideSpineer()
        SpinnerView.hideSpinnerView()
        webView.willMove(toWindow: nil)
        webView.removeFromSuperview()
        let errorAlert = ElGrocerAlertView.createAlert(localizedString("sorry_title", comment: ""),description:error.localizedDescription ,positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
        errorAlert.showPopUp()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        debugPrint(webView)
        hideSpineer()
        
        
        SpinnerView.hideSpinnerView()
        hideSpineer()
        if let finalURl = webView.url {
            let  message = finalURl.getQueryItemValueForKey("message")
            if message != nil {
                if message == "success" {
                    webView.willMove(toWindow: nil)
                    webView.removeFromSuperview()
                    self.callForReplacement(self.reference , amountoHold: self.finalAmmountWithSubItems())
                }else{
                    
                    if let message = finalURl.getQueryItemValueForKey("error_message") {
                        self.showErrorAlert(message)
                    }else{
                          self.showErrorAlert()
                    }
                }
            }else{
                if finalURl.absoluteString.contains("FortAPI/paymentPage") {
                    createSpinnerView()
                }
            }
        }
        
        
        
        
        
        /*
        
        
        
        
        if let finalURl = webView.url {
            let responseCode = finalURl.getQueryItemValueForKey("response_code")
            if responseCode != nil {
                if  responseCode != "02000"   {
                    let responseMsg = finalURl.getQueryItemValueForKey("response_message")
                    if responseMsg!.count > 0 {
                        self.showErrorAlert(responseMsg ?? "Error while adding card")
                    }else{
                        self.showErrorAlert()
                    }
                } else {
                    if let _ = finalURl.getQueryItemValueForKey("token_name") {
                        if let ref = finalURl.getQueryItemValueForKey("merchant_reference") {
                            UserDefaults.setMarchentRef(ref: ref , userID: self.userProfile?.dbID.stringValue ?? "")
                            UserDefaults.setAmmountRef(userID: self.userProfile?.dbID.stringValue ?? "" , ammount: self.finalAmmountWithSubItems().description )
                            let _ = UserDefaults.setSecureCVV(userID: self.userProfile?.dbID.stringValue ?? "" , cardID: self.order.cardID ?? "", cvv: self.cardCvv )
                             self.sendReplacmentHandler("")
                        }
                        webView.willMove(toWindow: nil)
                        webView.removeFromSuperview()
                        
                    }else {
                        self.showErrorAlert()
                    }
                }
            }
            
        }
        
        */
    }
    
}
//extension SubtitutionBasketViewController : OrderCancelationHandlerProtocol{
//    func checkIfOrderCancelled(isSuccess: Bool) {
//        print(" OrderCancelationHandlerProtocol checkIfOrderCancelled fuction called")
//        if isSuccess{
//            self.perform(#selector(self.dismissView), with: nil, afterDelay: 3.0)
//            
//        }else{
//            print("protocol fuction called Error")
//        }
//    }
//}
