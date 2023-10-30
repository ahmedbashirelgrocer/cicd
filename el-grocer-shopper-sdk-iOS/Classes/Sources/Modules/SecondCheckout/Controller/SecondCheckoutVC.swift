//
//  SecondCheckoutVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 23/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import RxSwift
import NBBottomSheet
import SwiftMessages
import Adyen
import CoreLocation


// Problem Statements:
// - Fetch Delivery Slots from API
// - if selected slot id is not nil [in checkout model] then filter delivery slots to get the selected slot

class SecondCheckoutVC: UIViewController {

    @IBOutlet var checkoutScrollView: UIScrollView!
    @IBOutlet var checkoutStackView: UIStackView!
    @IBOutlet var checkoutDeliverySlotView: CheckoutDeliverySlotView!
    @IBOutlet var checkoutDeliveryAddressView: CheckoutDeliveryAddressView!
    @IBOutlet var additionalInstructionsView: AdditionalInstructionsView!
    @IBOutlet var paymentMethodView: PaymentMethodView!
    @IBOutlet var promocodeView: PromocodeView!
    @IBOutlet weak var checkoutButtonView: CheckoutButtonView!
    @IBOutlet var viewCollector: CollectorsView!
    @IBOutlet var viewCollectorCar: CollectorsCarView!
    @IBOutlet var viewWarning: WarningView!
    @IBOutlet var pinView: MapPinView! {
        didSet{
            pinView.delegate = self
        }
    }
    @IBOutlet var tabbyView: TabbyView!
    private var billView = BillView()
    private lazy var secondaryPaymentView: SecondaryPaymentView = SecondaryPaymentView()
    private lazy var mapDelegate: LocationMapDelegation = {
        let delegate = LocationMapDelegation.init(self, type: .basket)
        return delegate
    }()
   
    
    var viewModel: SecondaryViewModel!
    
    var activeAddressObj : DeliveryAddress?
    var selectedPaymentOption: PaymentOption?
    var selectedSlot: DeliverySlot?
    var selectedCardID: String?
    var selectedCollector : collector?
    var selectedCar : Car?
    var pickUpLocation : PickUpLocation?
    var selectedReason: Int?
    var additionalText: String?
    var orderID: String?
    var grocery: Grocery? = ElGrocerUtility.sharedInstance.activeGrocery
    var shopingItems: [ShoppingBasketItem]?
    var products: [Product]?
    var price: Double?
    var orderPlacement: PlaceOrderHandler!
    private var disposeBag = DisposeBag()
    
    var secondCheckOutDataHandler : MyBasket?
    
    var userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)    
    override func viewDidLoad() {
        super.viewDidLoad()

        IQKeyboardManager.shared.enable = true
        // show hide click and collect views based on delivery mode.
        self.viewWarning.isHidden = ElGrocerUtility.sharedInstance.isDeliveryMode
        self.viewCollector.isHidden = ElGrocerUtility.sharedInstance.isDeliveryMode
        self.viewCollectorCar.isHidden = ElGrocerUtility.sharedInstance.isDeliveryMode
        
        // adding subviews
        self.addSubViews()
            
        // setting delegates of subviews
        self.paymentMethodView.delegate = self
        self.promocodeView.delegate = self
        self.viewCollector.delegate = self
        self.viewCollectorCar.delegate = self
        self.additionalInstructionsView.delegate = self
        self.secondaryPaymentView.delegate = self
        self.tabbyView.delegate = self
        
        // Hides tabby view by default
        self.tabbyView.isHidden = true
        
        self.checkoutDeliverySlotView.changeSlot = { [weak self] (slot) in
            guard let self = self, let slot = slot else {return}
            self.viewModel.setSelectedSlotId(slot.dbID.intValue)
            self.viewModel.setDeliverySlot(slot)
            self.viewModel.updateSlotToBackEnd()
            self.checkoutDeliverySlotView.configure(slots: self.viewModel.deliverySlots, selectedSlotId: self.viewModel.getCurrentDeliverySlotId())
        }
        // subscribe the delivery slots subject
        viewModel.deliverySlotsSubject.subscribe(onNext: { [weak self] deliverySlots in
            guard let self = self else { return }
            self.checkoutDeliverySlotView.configure(slots: deliverySlots, selectedSlotId: self.viewModel.getCurrentDeliverySlotId())
        }).disposed(by: disposeBag)
        
        if let _ = self.viewModel.getOrderId() {
            self.additionalInstructionsView.tfAdditionalNote.text = self.viewModel.getEditOrderInitialDetail()?.orderNote ?? ""
        }else {
            self.additionalInstructionsView.tfAdditionalNote.text = UserDefaults.getAdditionalInstructionsNote() ?? ""
        }
        
        self.checkoutButtonView.checkOutClicked = { [weak self] in
            guard let self = self else { return }
            guard self.viewModel.getGrocery()?.deliveryZoneId != nil, self.viewModel.getSelectedPaymentOption() != PaymentOption.none, self.viewModel.getCurrentDeliverySlotId() != nil, let grocery = self.viewModel.getGrocery() else {
                return
            }
            
            let _ = SpinnerView.showSpinnerViewInView(self.view)

            self.orderPlacement = PlaceOrderHandler.init(finalOrderItems: self.viewModel.getShoppingItems() ?? [], activeGrocery: grocery , finalProducts: self.viewModel.getFinalisedProducts() ?? [], orderID: self.viewModel.getOrderId(), finalOrderAmount: self.viewModel.basketDataValue?.finalAmount ?? 0.00, orderPlaceOrEditApiParams: self.viewModel.getOrderPlaceApiParams())
            if let _ = self.viewModel.getOrderId() {
                self.orderPlacement.isForNewOrder = false
                // orderPlacement.editedOrder()
            } else {
                MixpanelEventLogger.trackCheckoutConfirmOrderClicked(value: String(self.viewModel.basketDataValue?.finalAmount ?? 0.00))
                self.orderPlacement.isForNewOrder = true
                // orderPlacement.placeOrder()
            }
            if self.viewModel.getSelectedPaymentOption() == .creditCard, let card = self.viewModel.getCreditCard()?.adyenPaymentMethod {
                self.paymentWithCard(card, amount: self.viewModel.basketDataValue?.finalAmount ?? 0.00)
            } else if self.viewModel.getSelectedPaymentOption() == .applePay, let card = self.viewModel.getApplePay(){
                self.payWithApplePay(selctedApplePayMethod: card, amount: self.viewModel.basketDataValue?.finalAmount ?? 0.00)
            } else {
                if self.orderPlacement.isForNewOrder == true {
                    self.orderPlacement.generateOrderAndProcessPayment()
                } else {
                    self.orderPlacement.generateEditOrderAndProcessPayment()
                }
            }
            
            self.orderPlacement.orderPlaced = { [weak self] order, error, apiResponse in
                 
                SpinnerView.hideSpinnerView()
                if error != nil {
                    MixpanelEventLogger.trackCheckoutOrderError(error: error?.localizedMessage ?? "", value: String(self?.viewModel.basketDataValue?.finalAmount ?? 0.00))
                    return
                }
            
                guard order != nil else { return }
                
                func logPurchaseEvents() {
                    self?.viewModel.setRecipeCartAnalyticsAndRemoveRecipe()
                    ElGrocerUtility.sharedInstance.delay(0.5) { 
                        
                        ElGrocerEventsLogger.sharedInstance.recordPurchaseAnalytics(
                            finalOrderItems:self?.viewModel.getShoppingItems() ?? []
                            , finalProducts:self?.viewModel.getFinalisedProducts() ?? []
                            , finalOrder: order!
                            , availableProductsPrices:[:]
                            , priceSum : self?.viewModel.basketDataValue?.finalAmount! ?? 0.0
                            , discountedPrice : self?.viewModel.basketDataValue?.productsSaving! ?? 0.0
                            , grocery : self?.viewModel.getGrocery() 
                            , deliveryAddress : self?.viewModel.getDeliveryAddressObj()
                            , carouselproductsArray : self?.viewModel.getCarouselProductsArray() ?? []
                            , promoCode : self?.viewModel.basketDataValue?.promoCode?.code ?? ""
                            , serviceFee : self?.viewModel.basketDataValue?.serviceFee ?? 0.0
                            , payment : self?.viewModel.getSelectedPaymentOption() ?? PaymentOption.none
                            , discount: self?.viewModel.basketDataValue?.totalDiscount ?? 0.0
                            , IsSmiles: self?.viewModel.getIsSmileTrue() ?? false
                            , smilePoints: Int(self?.viewModel.basketDataValue?.smilesPoints ?? 0)
                            , pointsEarned:Int(self?.viewModel.basketDataValue?.smilesEarn ?? 0)
                            , pointsBurned:Int(self?.viewModel.basketDataValue?.smilesRedeem ?? 0),
                            self?.viewModel.getIsWalletTrue() ?? false,
                            self?.viewModel.basketDataValue?.elWalletRedeem ?? 0.0
                        )
                    }
                }
                
                if self?.viewModel.getSelectedPaymentOption() == .creditCard, let card = self?.viewModel.getCreditCard()?.adyenPaymentMethod {
                    // Credit card flow
                    if self?.orderPlacement.isForNewOrder == false, let oldOrderCard = self?.viewModel.getEditOrderInitialDetail()?.cardID,oldOrderCard.elementsEqual(card.identifier){
                        // Edit order flow when payment method is not changed
                        self?.showConfirmationView(order!)
                        logPurchaseEvents()
                        // Logging segment event for for edit order completed or order purchased
                        self?.logOrderEditedOrCompletedEvent(order: order)
                        return
                    }else {
                        // Due to: new order flow
                        //  self?.paymentWithCard(card, order: order!, amount: self?.viewModel.basketDataValue?.finalAmount ?? 0.00)
                        self?.processPaymentResponse(apiResponse, order: order!)
                    }
                }else if self?.viewModel.getSelectedPaymentOption() == .applePay {
                    // Apple pay flow
                    // self?.payWithApplePay(selctedApplePayMethod: card, order: order!, amount: self?.viewModel.basketDataValue?.finalAmount ?? 0.00)
                    self?.processPaymentResponse(apiResponse, order: order!)
                } else {
                    self?.showConfirmationView(order!)
                    
                    // Logging segment event for for edit order completed or order purchased
                    self?.logOrderEditedOrCompletedEvent(order: order)
                }
                
                logPurchaseEvents()
            }
        }
        
        viewModel.apiCall.subscribe(onNext: { [weak self] isNeedToShow in
            if isNeedToShow {
                guard self == self, let view = self?.view else { return }
                let _ = SpinnerView.showSpinnerViewInView(view)
            }else{
                SpinnerView.hideSpinnerView()
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.basketData.subscribe(onNext: { [weak self] data in
            guard let self = self, let data = data else { return }
            self.viewModel.setSelectedSlotId(data.selectedDeliverySlot ?? 0)
            self.updateViewAccordingToData(data: data)
//            self.viewModel.fetchDeliverySlots()
        })
        .disposed(by: disposeBag)
        
        viewModel.getBasketData.subscribe(onNext: { [weak self] data in
            guard let self = self, let data = data else { return }
            
//            self.viewModel.fetchDeliverySlots()
        })
        .disposed(by: disposeBag)
     
        // Logging segment screen event and checkout started
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .checkoutScreen))
        SegmentAnalyticsEngine.instance.logEvent(event: CheckoutStartedEvent())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setupNavigationBar()
        self.setDeliveryAddress()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func setDeliveryAddress() {
        self.checkoutDeliveryAddressView.configure(address: viewModel.getDeliveryAddress())
        let address = viewModel.getDeliveryAddressObj()
        let addressString = viewModel.getDeliveryAddress()
        self.pinView.configureWith(detail: UserMapPinAdress.init(nickName: address?.nickName ?? "",address: addressString, addressImageUrl: address?.addressImageUrl, addressLat: address?.latitude ?? 0.0, addressLng: address?.longitude ?? 0.0))
    }
    
    func updateViewAccordingToData(data: BasketDataClass) {
        
        
        Thread.OnMainThread {
        // configure bill view
            self.billView.configure(productTotal: data.productsTotal ?? 0.00, serviceFee: data.serviceFee ?? 0.00, total: data.totalValue ?? 0.00, productSaving: data.totalDiscount ?? 0.00, finalTotal: data.finalAmount ?? 0.00, elWalletRedemed: data.elWalletRedeem ?? 0.00, smilesRedemed: data.smilesRedeem ?? 0.00, promocode: data.promoCode, quantity: data.quantity ?? 0, smilesSubscriber: data.smilesSubscriber ?? false, tabbyRedeem: data.tabbyRedeem)

            self.checkoutDeliverySlotView.configure(slots: self.viewModel.deliverySlots, selectedSlotId: self.viewModel.getCurrentDeliverySlotId())
        
        self.checkoutDeliveryAddressView.configure(address: self.viewModel.getDeliveryAddress())

//        self.promocodeView.isHidden = data.promoCodes ?? false
        self.promocodeView.configure(promocode: data.promoCode?.code ?? "")
        
        
        self.paymentMethodView.configure(paymentTypes: data.paymentTypes ?? [], selectedPaymentId: self.viewModel.getSelectedPaymentMethodId(),creditCard: self.viewModel.getCreditCard())
        
        let secondaryPaymentTypes = self.viewModel.getShouldShowSecondaryPayments(paymentMethods: data.paymentTypes ?? [])
        if secondaryPaymentTypes == .none {
            self.secondaryPaymentView.isHidden = true
        }else {

            self.secondaryPaymentView.configure(smilesBalance: data.smilesBalance ?? 0.00, elWalletBalance: data.elWalletBalance ?? 0.00, smilesRedeem: data.smilesRedeem ?? 0.00, elWalletRedeem: data.elWalletRedeem ?? 0.00, smilesPoint: data.smilesPoints ?? 0, paymentTypes: secondaryPaymentTypes)
        }
        let paymentOption = self.viewModel.createPaymentOptionFromString(paymentTypeId: data.primaryPaymentTypeID ?? 0)
        
            self.checkoutButtonView.configure(paymentOption: paymentOption, points: self.viewModel.getBurnPointsFromAed(), amount: data.finalAmount ?? 0.00, aedSaved: data.productsSaving ?? 0.00, earnSmilePoints: data.smilesEarn ?? 0, promoCode: data.promoCode, isSmileOn: self.viewModel.getIsSmileTrue() )
        }
        
        
        if sdkManager.isShopperApp {
            let isTabbyAvailable = data.paymentTypes?.contains(where: { type in type.id == PaymentOption.tabby.rawValue }) ?? true
            self.tabbyView.isHidden = !isTabbyAvailable
            
            if let tabbyRedeem = data.tabbyRedeem, tabbyRedeem > 0 {
                self.tabbyView.enableTabbyPayment(status: true)
            } else {
                self.tabbyView.enableTabbyPayment(status: false)
                
                if let message = data.tabbyThresholdMessage, message.isNotEmpty {
                    ElGrocerUtility.sharedInstance.showTopMessageView(message, image: nil, -1, false, backButtonClicked: { sender, index, inUndo in
                    }, buttonIcon: UIImage(named: "crossWhite"))
                }
            }
        }
    }
    
    func paymentWithCard(_ selectedMethod: StoredCardPaymentMethod, amount: Double) {
        let configAuthAmount = ElGrocerUtility.sharedInstance.appConfigData.initialAuthAmount
        var authValue: NSDecimalNumber = NSDecimalNumber.init(floatLiteral: 0.00)
        
        if configAuthAmount < 0 {
            authValue = NSDecimalNumber.init(floatLiteral: amount)
        }else {
            authValue = NSDecimalNumber.init(floatLiteral: configAuthAmount)
        }
        
        AdyenManager.sharedInstance.isPaymentApprovedByUser = { [weak self] initiatePaymentParams in
            // generate order and payment now
            self?.orderPlacement.initiatePaymentParams = initiatePaymentParams as? [String: Any] ?? [:]
            if self?.orderPlacement.isForNewOrder == true {
                self?.orderPlacement.generateOrderAndProcessPayment()
            } else {
                self?.orderPlacement.generateEditOrderAndProcessPayment()
            }
        }
        
        Thread.OnMainThread { [weak self ] in
            guard let self = self else { return }
            AdyenManager.sharedInstance.makePaymentWithCard(controller: self, amount: authValue, method: selectedMethod)
        }
        
    }
    
    func processPaymentResponse(_ results: Either<NSDictionary>, order: Order) {
        
        var error: ElGrocerError?
        var result: NSDictionary?
        
        defer {
            AdyenManager.sharedInstance.processAdyenAPIResponse(error, result)
        }
        
        switch results {
            case .success(let data):
            
            if let dataDict = data["data"] as? NSDictionary,
               let paymentData = dataDict["online_payment_response"] as? NSDictionary,
                let response = paymentData["response"] as? NSDictionary {
                    if let code = response["errorCode"] as? String {
                        (error, result) = (ElGrocerError(forAdyen: response), nil)
                    } else if let action = response["action"] as? NSDictionary {
                        (error, result) = (nil, response)
                    } else {
                        let resultCode = response["resultCode"] as? String ?? ""
                        if resultCode.elementsEqual("Authorised") || resultCode.elementsEqual("Received") || resultCode.elementsEqual("Pending") {
                            (error, result) = (nil, response)
                        } else {
                            (error, result) = (ElGrocerError.genericError(), response)
                        }
                    }
            } else {
                (error, result) = (ElGrocerError.parsingError(), nil)
            }
            
            case .failure(let err):
                (error, result) = (err, nil)
            
        }
        
            AdyenManager.sharedInstance.isPaymentMade = { [order, weak self] (error, response,adyenObj) in
                SpinnerView.hideSpinnerView()
                if error {
                    if let resultCode = response["resultCode"] as? String,  resultCode.count > 0 {
                        // print(resultCode)
                        let refusalReason =  (response["refusalReason"] as? String) ?? resultCode
                        AdyenManager.showErrorAlert(descr: refusalReason)
                        MixpanelEventLogger.trackCheckoutPaymentMethodError(error: refusalReason)
                    }
                }else {
                    self?.showConfirmationView(order)
                    
                    // Logging segment event for for edit order completed or order purchased
                    self?.logOrderEditedOrCompletedEvent(order: order)
                }
            }
    }
    
    func payWithApplePay(selctedApplePayMethod: ApplePayPaymentMethod, amount: Double) {
        
        let configAuthAmount = ElGrocerUtility.sharedInstance.appConfigData != nil ? ElGrocerUtility.sharedInstance.appConfigData.initialAuthAmount : 0.00
        var authValue: NSDecimalNumber = NSDecimalNumber.init(floatLiteral: 1.00)
        
        if configAuthAmount < 0 {
            authValue = NSDecimalNumber.init(floatLiteral: amount)
        }else {
            authValue = NSDecimalNumber.init(floatLiteral: configAuthAmount)
        }
        
        AdyenManager.sharedInstance.isPaymentApprovedByUser = { [weak self] initiatePaymentParams in
            // generate order and payment now
            self?.orderPlacement.initiatePaymentParams = initiatePaymentParams as? [String: Any] ?? [:]
            if self?.orderPlacement.isForNewOrder == true {
                self?.orderPlacement.generateOrderAndProcessPayment()
            } else {
                self?.orderPlacement.generateEditOrderAndProcessPayment()
            }
        }
            
        AdyenManager.sharedInstance.makePaymentWithApple(controller: self, amount: authValue, method: selctedApplePayMethod)
        
    }
    
    
    func showConfirmationView(_ order : Order) {
        
        defer {
            
            UserDefaults.setLeaveUsNote(nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "resetBasketObjData"), object: nil)
            
        }
        
        UserDefaults.resetEditOrder()
    
        self.resetLocalDBData(order)
       
        let viewModel = OrderConfirmationViewModel(OrderStatusMedule(), orderId: order.dbID.stringValue, true)
        let orderConfirmationController = OrderConfirmationViewController.make(viewModel: viewModel)
        self.navigationController?.pushViewController(orderConfirmationController, animated: true)
        
    }
    
    private func resetLocalDBData(_ order: Order) {
        ElGrocerUtility.sharedInstance.resetBasketPresistence()
        ElGrocerApi.sharedInstance.deleteBasketFromServerWithGrocery(order.grocery) { (result) in
            debugPrint(result)
        }
    }
    
    func updateAddressInOrder( address: DeliveryAddress) {
        if let order =  self.viewModel.getEditOrderInitialDetail() {
            order.deliveryAddress = address
            DatabaseHelper.sharedInstance.saveDatabase()
        }
    }
    
    
}

// MARK: - Helpers Methods
private extension SecondCheckoutVC {
    func addSubViews() {
        
        checkoutStackView.addArrangedSubview(checkoutDeliverySlotView)
        checkoutStackView.addArrangedSubview(pinView)
        checkoutStackView.addArrangedSubview(viewWarning)
       // checkoutStackView.addArrangedSubview(checkoutDeliveryAddressView)
        checkoutStackView.addArrangedSubview(additionalInstructionsView)
        checkoutStackView.addArrangedSubview(viewCollectorCar)
        checkoutStackView.addArrangedSubview(viewCollector)
        checkoutStackView.addArrangedSubview(viewCollector)
        checkoutStackView.addArrangedSubview(paymentMethodView)
        checkoutStackView.addArrangedSubview(promocodeView)
        checkoutStackView.addArrangedSubview(tabbyView)
        checkoutStackView.addArrangedSubview(secondaryPaymentView)
        checkoutStackView.addArrangedSubview(billView)
        
    }
    
    func setupNavigationBar() {
        
        if let nav = self.navigationController as? ElGrocerNavigationController {
            nav.setGreenBackgroundColor()
            nav.setLogoHidden(true)
            nav.setSearchBarHidden(true)
            nav.setBackButtonHidden(false)
        }
        
        self.navigationItem.hidesBackButton = true
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        self.title = localizedString("order_CheckOut_label", comment: "")
    }
    
    func logOrderEditedOrCompletedEvent(order: Order?) {
        if (self.viewModel.getOrderId() != nil) {
            // Edit Completed Event
            SegmentAnalyticsEngine.instance.logEvent(event: EditOrderCompletedEvent(order: order, grocery: self.grocery))
            
            logPurchaseEventOnTopSort(orderID: order?.dbID.stringValue ?? UUID().uuidString)
        } else {
            let orderCompletedEvent = OrderPurchaseEvent(
                products: self.viewModel.getFinalisedProducts() ?? [],
                grocery: self.grocery,
                order: order,
                isWalletEnabled: viewModel.isElWalletEnabled(),
                isSmilesEnabled: viewModel.isSmilesEnabled(),
                isPromoCodeApplied: viewModel.isPromoApplied(),
                smilesPointsEarned: viewModel.basketDataValue?.smilesEarn ?? 0,
                smilesPointsBurnt: viewModel.basketDataValue?.smilesRedeem ?? 0,
                realizationId: viewModel.basketDataValue?.promoCode?.promotionCodeRealizationID,
                isTabbyEnabled: viewModel.getTabbyEnabled(),
                amoutPaidWithTabby: viewModel.basketDataValue?.tabbyRedeem ?? 0.0
            )
            SegmentAnalyticsEngine.instance.logEvent(event: orderCompletedEvent)
            
            logPurchaseEventOnTopSort(orderID: order?.dbID.stringValue ?? UUID().uuidString)
        }
        
        func logPurchaseEventOnTopSort(orderID: String) {
            let items = self.viewModel
                .getFinalisedProducts()?
                .map{ [weak self] product -> TopSortEvent.Item in
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    var quantity = 0
                    if let basketItem = ShoppingBasketItem.checkIfProductIsInBasket(
                        product,
                        grocery: self?.grocery,
                        context: context) {
                        
                        quantity = basketItem.count.intValue
                    }
                    
                    var price = product.price.doubleValue
                    if product.promoPrice?.doubleValue ?? 0 > 0 {
                        price = product.promoPrice?.doubleValue ?? 0
                    }
                    
                    return TopSortEvent.Item(productId: product.productId.stringValue,
                                             unitPrice: price,
                                             quantity: quantity)
                } ?? []
            
            TopsortManager.shared.log(.purchases(orderID: orderID, items: items))
        }
    }
}

extension SecondCheckoutVC: NavigationBarProtocol {
    func backButtonClickedHandler() {
        self.backButtonClick()
    }
    
    override func backButtonClick() {
        MixpanelEventLogger.trackElWalletUnifiedClose()
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension SecondCheckoutVC: AdditionalInstructionsViewDelegate {
    func textViewTextChangeDone(text: String) {
        self.viewModel.setAdditionalInstructions(text: text)
        UserDefaults.setAdditionalInstructionsNote(text)
        MixpanelEventLogger.trackCheckoutInstructionAdded(instruction: text)
    }
}

// MARK: - Payment method selection delegate
extension SecondCheckoutVC: PaymentMethodViewDelegate {
    func tap(on view: PaymentMethodView, paymentTypes: [PaymentType]) {

        let vm = PaymentSelectionViewModel(elGrocerAPI: ElGrocerApi.sharedInstance, adyenApiManager: AdyenApiManager(), grocery: self.grocery, selectedPaymentOption: self.viewModel.getSelectedPaymentOption(),cardId: self.viewModel.getCreditCard()?.cardID, paymentTypes: paymentTypes)
        
        let viewController = PaymentMethodSelectionViewController.create(viewModel: vm) { option, applePay, creditCard in
            if let option = option, let groceryId = self.viewModel.getGroceryId() {
                UserDefaults.setPaymentMethod(option.rawValue, forStoreId: groceryId)
                UserDefaults.setCardID(cardID: creditCard?.cardID ?? "", userID: self.viewModel.getUserId()?.stringValue ?? "")
                self.viewModel.updateCreditCard(creditCard)
                self.viewModel.updateApplePay(applePay)
                self.viewModel.setSelectedPaymentOption(id: Int(option.rawValue))
                self.viewModel.updatePaymentMethod(option)
                MixpanelEventLogger.trackCheckoutPaymentMethodSelected(paymentMethodId: "\(option.rawValue)",cardId: creditCard?.cardID ?? "-1", retaiilerId: self.secondCheckOutDataHandler?.activeGrocery?.dbID ?? "")
                
                // Logging segment event for payment method changed
                SegmentAnalyticsEngine.instance.logEvent(event: PaymentMethodChangedEvent(paymentMethodId: Int(option.rawValue), paymentMethodName: option.paymentMethodName))
            }
        }
        MixpanelEventLogger.trackCheckoutPrimaryPaymentMethodClicked()
        let configuration = NBBottomSheetConfiguration(sheetSize: .fixed(self.view.frame.height * 0.6))
        let bottomSheetController = NBBottomSheetController(configuration: configuration)
        
        bottomSheetController.present(viewController, on: self)
    }
}

// MARK: - Collector's View Delegates
extension SecondCheckoutVC: CollectorsViewDelegate {
    func tap(view: CollectorsView) {
        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(CGFloat(400)))
        configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
        let bottomSheetController = NBBottomSheetController(configuration: configuration)
        let controler = OrderCollectorDetailsVC(nibName: "OrderCollectorDetailsVC", bundle: nil)
        controler.dataHandlerView = self //.currentTopVc as? UIViewController
        controler.collectorSelected = { (collector) in
            if let collector = collector {
                view.configure(collector: collector)
            }
        }
        
        bottomSheetController.present(controler, on: self)
    }
}

// MARK: - Collector's Car View Delegates
extension SecondCheckoutVC: CollectorsCarViewDelegate {
    func tap(view: CollectorsCarView) {
        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(CGFloat(400)))
        configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
        let bottomSheetController = NBBottomSheetController(configuration: configuration)
        let controller = OrderCollectorDetailsVC(nibName: "OrderCollectorDetailsVC", bundle: nil)
        controller.detailsType = .car
        controller.dataHandlerView = self
        
        controller.carSelected = { [weak self] (car) in
            guard let car = car else { return }
            view.configure(car: car)
        }
        controller.carDeleted = { (carId) in
           // guard let self = self,  let carId = carId else { return }
        }
        
        bottomSheetController.present(controller, on: self)
    }
}

extension SecondCheckoutVC: PromocodeDelegate {
    func tap(promocode: String?) {
        if self.viewModel.getSelectedPaymentOption() == PaymentOption.none {
            let errorMsg = localizedString("secondary_payment_promocode_error", comment: "")
            ElGrocerUtility.sharedInstance.showTopMessageView(errorMsg, image: nil, -1, false, backButtonClicked: { sender, index, inUndo in
            }, buttonIcon: UIImage(name: "crossWhite"))
            return
        }

        MixpanelEventLogger.trackCheckoutPromocodeClicked()
        let vc = ElGrocerViewControllers.getApplyPromoVC()
        
        vc.previousGrocery = self.viewModel.getGrocery()
        vc.priviousPaymentOption = self.viewModel.getSelectedPaymentOption()
        vc.priviousPrice = self.viewModel.basketDataValue?.finalAmount ?? 0.00
        vc.priviousShoppingItems = self.viewModel.getShoppingItems()
        vc.priviousOrderId = self.viewModel.getOrderId()
        vc.priviousFinalizedProductA = self.viewModel.getFinalisedProducts()
        vc.promoCode = self.viewModel.basketDataValue?.promoCode
        
        vc.isPromoApplied = {[weak self] (success, promoCode) in
            guard let self = self else {return}
            if success {
                self.viewModel.setIsPromoTrue(isPromoTrue: true)
                self.viewModel.setPromoCodeRealisationId(realizationId: String(promoCode?.promotionCodeRealizationId ?? 0), promoAmount: promoCode?.valueCents)
                self.viewModel.updateSecondaryPaymentMethods()
            }else {
                self.viewModel.setIsPromoTrue(isPromoTrue: false)
                self.viewModel.setPromoCodeRealisationId(realizationId: "", promoAmount: nil)
                self.viewModel.updateSecondaryPaymentMethods()
            }
            
            // Logging segment event for promo code applied
            let promoCodeAppliedEvent = PromoCodeAppliedEvent(isApplied: success, promoCode: promoCode?.code, realizationId: promoCode?.promotionCodeRealizationId)
            SegmentAnalyticsEngine.instance.logEvent(event: promoCodeAppliedEvent)
        }
        
        vc.dismissWithoutPromoClosure = { [weak self] (isDismisingWithPromoApplied) in
            guard let _ = self else { return }
            if isDismisingWithPromoApplied == false {
                let message = localizedString("promo_code_apply_notification", comment: "")
                
                ElGrocerUtility.sharedInstance.showTopMessageView(message, image: nil, -1, false, backButtonClicked: { sender, index, inUndo in
                }, buttonIcon: UIImage(name: "crossWhite"))
            }
        }
        
        ElGrocerEventsLogger.sharedInstance.trackScreenNav([FireBaseParmName.CurrentScreen.rawValue : FireBaseScreenName.MyBasket.rawValue , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.ApplyPromoVC.rawValue])
        self.present(vc, animated: true, completion: nil)
    }
}

extension SecondCheckoutVC: SecondaryPaymentViewDelegate {
    func switchStateChange(type: SourceType, switchState: Bool) {
        switch type {
        case .elWallet:
            //  print("elwallet switch changed to >> \(switchState)")
            self.viewModel.setIsWalletTrue(isWalletTrue: switchState)
            self.viewModel.updateSecondaryPaymentMethods()
            if switchState {
                MixpanelEventLogger.trackCheckoutElwalletSwitchOn(balance: String(self.viewModel.basketDataValue?.elWalletBalance ?? 0.00))
            }else {
                MixpanelEventLogger.trackCheckoutElwalletSwitchOff(balance: String(self.viewModel.basketDataValue?.elWalletBalance ?? 0.00))
            }
            
            // Logging segment event for el-wallet toggle enabled
            SegmentAnalyticsEngine.instance.logEvent(event: ElWalletToggleEnabledEvent(isEnabled: switchState))
            break
            
        case .smile:
            // print("smiles switch changed to >> \(switchState)")
            self.viewModel.setIsSmileTrue(isSmileTrue: switchState)
            self.viewModel.updateSecondaryPaymentMethods()
            if switchState {
                MixpanelEventLogger.trackCheckoutSmilesSwitchOn(balance: String(self.viewModel.basketDataValue?.smilesBalance ?? 0.00))
            }else {
                MixpanelEventLogger.trackCheckoutSmilesSwitchOff(balance: String(self.viewModel.basketDataValue?.smilesBalance ?? 0.00))
            }
            
            // Logging segment event for smiles points enabled
            SegmentAnalyticsEngine.instance.logEvent(event: SmilesPointEnabledEvent(isEnabled: switchState))
            break
        }
        
    }
}
extension SecondCheckoutVC : MapPinViewDelegate, LocationMapViewControllerDelegate {
    
    func changeButtonClickedWith(_ currentDetails: UserMapPinAdress?) -> Void {
        EGAddressSelectionBottomSheetViewController.showInBottomSheet(self.viewModel.getGrocery(), mapDelegate: self.mapDelegate, presentIn: self)
    }
    
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) -> Void {
        controller.navigationController?.popViewController(animated: true)
    }
    //optional
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withAddress address: String? ,  withBuilding building: String? , withCity cityName: String?) {
        debugPrint("")
        controller.navigationController?.popViewController(animated: true)
        self.pinView.configureWith(detail: UserMapPinAdress.init(address: address ?? "", addressImageUrl: nil, addressLat: location?.coordinate.latitude ?? 0.0, addressLng: location?.coordinate.longitude ?? 0.0))
        
    }
    
    func locationSelectedAddress(_ address: DeliveryAddress, grocery:Grocery?){
        
        if let order =  self.viewModel.getEditOrderInitialDetail() {
            order.deliveryAddress = address
            DatabaseHelper.sharedInstance.saveDatabase()
        }
       // self.pinView.configureWith(detail: UserMapPinAdress.init(address: address.address, addressImageUrl: address.addressImageUrl, addressLat: address.latitude , addressLng: address.longitude))
       // self.viewModel.setGroceryAndAddressAndRefreshData(grocery, deliveryAddress: address)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}

extension SecondCheckoutVC: TabbyViewDelegate {
    func helpTap() {
        let termsAndContitionsVC = ElGrocerViewControllers.getTabbyTermsAndConditionsViewController()
        self.navigationController?.present(termsAndContitionsVC, animated: true)
    }
    
    func switchStateChanged(_ tabbyView: TabbyView, _ state: Bool) {
        if let tabbyRedirectionUrl = self.viewModel.tabbyWebUrl, tabbyRedirectionUrl.isNotEmpty {
            if state {
                let vc = ElGrocerViewControllers.getTabbyWebViewController()
                vc.tabbyRedirectionUrl = self.viewModel.tabbyWebUrl
                
                vc.tabbyRegistrationHandler = { [weak self] registrationStatus in
                    guard let self = self else { return }
                    
                    self.viewModel.setTabbyEnabled(enabled: registrationStatus == .success)
                    self.viewModel.updateSecondaryPaymentMethods()
                    
                    if registrationStatus == .success && self.viewModel.getSelectedPaymentOption() == .none {
                        self.selectCashAsPrimaryMethod()
                    }
                }
                
                let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                navigationController.hideSeparationLine()
                navigationController.viewControllers = [vc]
                navigationController.modalPresentationStyle = .fullScreen
                self.navigationController?.present(navigationController, animated: true, completion: nil)
            } else {
                self.viewModel.setTabbyEnabled(enabled: false)
                self.viewModel.updateSecondaryPaymentMethods()
            }
        } else {
            self.viewModel.setTabbyEnabled(enabled: state)
            self.viewModel.updateSecondaryPaymentMethods()
            
            if state && self.viewModel.getSelectedPaymentOption() == .none {
                selectCashAsPrimaryMethod()
            }
        }
    }
    
    // Auto select cash as a primary payment method
    private func selectCashAsPrimaryMethod() {
        guard let groceryId = self.viewModel.getGroceryId(), let userId = self.viewModel.getUserId()?.stringValue else { return }
        
        ElGrocerUtility.sharedInstance.delay(0.5) {
            UserDefaults.setPaymentMethod(PaymentOption.cash.rawValue, forStoreId:groceryId)
            UserDefaults.setCardID(cardID: "", userID: userId)
            self.viewModel.updateCreditCard(nil)
            self.viewModel.updateApplePay(nil)
            self.viewModel.setSelectedPaymentOption(id: Int(PaymentOption.cash.rawValue))
            self.viewModel.updatePaymentMethod(PaymentOption.cash)
        }
    }
}
