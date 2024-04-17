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
//import NBBottomSheet
import SwiftMessages
import Adyen
import CoreLocation
import ThirdPartyObjC

class SecondCheckoutVC: UIViewController {

    @IBOutlet var checkoutScrollView: UIScrollView!
    @IBOutlet var checkoutStackView: UIStackView!
    @IBOutlet var checkoutDeliverySlotView: CheckoutDeliverySlotView!
    @IBOutlet var checkoutDeliveryAddressView: CheckoutDeliveryAddressView!
    @IBOutlet var additionalInstructionsView: DeliveryInstructionsView!
    @IBOutlet var paymentMethodView: PaymentMethodView!
    @IBOutlet var promocodeView: PromocodeView!
    @IBOutlet weak var checkoutButtonView: CheckoutButtonView!
    @IBOutlet var pinView: MapPinView! {
        didSet{
            pinView.delegate = self
        }
    }
    @IBOutlet var smilesPointsView: CheckoutSmilesPointsView!
    @IBOutlet var elWalletView: CheckoutElWalletView!
    @IBOutlet var warningView: WarningView!
    
    private var billView = BillView()

    private lazy var mapDelegate: LocationMapDelegation = {
        let delegate = LocationMapDelegation.init(self, type: .basket)
        return delegate
    }()
   
    
    var viewModel: SecondaryViewModel!
    
    var activeAddressObj : DeliveryAddress?
    var selectedPaymentOption: PaymentOption?
    var selectedSlot: DeliverySlot?
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
        
        // adding subviews
        self.addSubViews()
            
        // setting delegates of subviews
        self.paymentMethodView.delegate = self
        self.promocodeView.delegate = self
        self.additionalInstructionsView.delegate = self
        self.smilesPointsView.delegate = self
        self.elWalletView.delegate = self
        
        self.checkoutDeliverySlotView.slotSelectionHandler = { [weak self] (slot) in
            guard let self = self, let slot = slot else {return}
            
            self.viewModel.setSelectedSlotId(slot.id)
            self.viewModel.setDeliverySlot(slot)
            self.viewModel.updateSlotToBackEnd()
        }
        
        // subscribe the delivery slots subject
        viewModel.backSubject
            .subscribe(onNext: { [weak self] _ in self?.backButtonClickedHandler() })
            .disposed(by: disposeBag)
        viewModel.deliverySlotsSubject.subscribe(onNext: { [weak self] deliverySlots in
            guard let self = self else { return }
            
//            self.checkoutDeliverySlotView.configure(selectedDeliverySlot: self.viewModel.getCurrentDeliverySlotId(), deliverySlots: deliverySlots)
        }).disposed(by: disposeBag)
        
        if let _ = self.viewModel.getOrderId() {
            let deliveryInstructions = self.viewModel.getEditOrderInitialDetail()?.orderNote
            self.additionalInstructionsView.configure(instructions: deliveryInstructions)
        }else {
            let deliveryInstructions = UserDefaults.getAdditionalInstructionsNote()
            self.additionalInstructionsView.configure(instructions: deliveryInstructions)
        }
        
        self.checkoutButtonView.checkOutClicked = { [weak self] in
            guard let self = self else { return }
            
            guard self.viewModel.getGrocery()?.deliveryZoneId != nil, self.viewModel.getSelectedPaymentOption() != PaymentOption.none, let grocery = self.viewModel.getGrocery() else {
                return
            }
            
            // check delivery slot and show popup
            if self.viewModel.getCurrentDeliverySlotId() == nil {
                showMessage("Please choose a slot to schedule this order.")
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
                guard let self = self else { return }
                
                SpinnerView.hideSpinnerView()
                if error != nil {
                    MixpanelEventLogger.trackCheckoutOrderError(error: error?.localizedMessage ?? "", value: String(self.viewModel.basketDataValue?.finalAmount ?? 0.00))
                    return
                }
            
                guard order != nil else { return }
                
                func logPurchaseEvents() {
                    self.viewModel.setRecipeCartAnalyticsAndRemoveRecipe()
                    ElGrocerUtility.sharedInstance.delay(0.5) {
                        
                        ElGrocerEventsLogger.sharedInstance.recordPurchaseAnalytics(
                            finalOrderItems:self.viewModel.getShoppingItems() ?? []
                            , finalProducts:self.viewModel.getFinalisedProducts() ?? []
                            , finalOrder: order!
                            , availableProductsPrices:[:]
                            , priceSum : self.viewModel.basketDataValue?.finalAmount! ?? 0.0
                            , discountedPrice : self.viewModel.basketDataValue?.productsSaving! ?? 0.0
                            , grocery : self.viewModel.getGrocery()
                            , deliveryAddress : self.viewModel.getDeliveryAddressObj()
                            , carouselproductsArray : self.viewModel.getCarouselProductsArray() ?? []
                            , promoCode : self.viewModel.basketDataValue?.promoCode?.code ?? ""
                            , serviceFee : self.viewModel.basketDataValue?.serviceFee ?? 0.0
                            , payment : self.viewModel.getSelectedPaymentOption() ?? PaymentOption.none
                            , discount: self.viewModel.basketDataValue?.totalDiscount ?? 0.0
                            , IsSmiles: self.viewModel.getSelectedSmilesPoints() > 0
                            , smilePoints: Int(self.viewModel.basketDataValue?.smilesPoints ?? 0)
                            , pointsEarned:Int(self.viewModel.basketDataValue?.smilesEarn ?? 0)
                            , pointsBurned:Int(self.viewModel.basketDataValue?.smilesRedeem ?? 0),
                            self.self.viewModel.getSelectedElwalletCredit() > 0,
                            self.viewModel.basketDataValue?.elWalletRedeem ?? 0.0
                        )
                    }
                }
                
                if self.viewModel.getSelectedPaymentOption() == .creditCard, let card = self.viewModel.getCreditCard()?.adyenPaymentMethod {
                    // Credit card flow
                    if self.orderPlacement.isForNewOrder == false, let oldOrderCard = self.viewModel.getEditOrderInitialDetail()?.cardID,oldOrderCard.elementsEqual(card.identifier){
                        // Edit order flow when payment method is not changed
                        self.showConfirmationView(order!)
                        logPurchaseEvents()
                        // Logging segment event for for edit order completed or order purchased
                        self.logOrderEditedOrCompletedEvent(order: order)
                        return
                    }else {
                        // Due to: new order flow
                        //  self.paymentWithCard(card, order: order!, amount: self.viewModel.basketDataValue?.finalAmount ?? 0.00)
                        self.processPaymentResponse(apiResponse, order: order!)
                    }
                }else if self.viewModel.getSelectedPaymentOption() == .applePay {
                    // Apple pay flow
                    // self.payWithApplePay(selctedApplePayMethod: card, order: order!, amount: self.viewModel.basketDataValue?.finalAmount ?? 0.00)
                    self.processPaymentResponse(apiResponse, order: order!)
                } else {
                    self.showConfirmationView(order!)
                    
                    // Logging segment event for for edit order completed or order purchased
                    self.logOrderEditedOrCompletedEvent(order: order)
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
     
        
        self.setDeliveryAddress()
        
        // Logging segment screen event and checkout started
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .checkoutScreen))
        SegmentAnalyticsEngine.instance.logEvent(event: CheckoutStartedEvent())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setupNavigationBar()
    }

    func setDeliveryAddress() {
        self.checkoutDeliveryAddressView.configure(address: viewModel.getDeliveryAddress())
        let address = viewModel.getDeliveryAddressObj()
        let addressString = viewModel.getDeliveryAddress()
        self.pinView.configureWith(detail: UserMapPinAdress.init(nickName: address?.nickName ?? "",address: addressString, addressImageUrl: address?.addressImageUrl, addressLat: address?.latitude ?? 0.0, addressLng: address?.longitude ?? 0.0))
    }
    
    func updateViewAccordingToData(data: BasketDataClass) {
        
        Thread.OnMainThread {
            self.billView.configure(productTotal: data.productsTotal ?? 0.00, serviceFee: data.serviceFee ?? 0.00, total: data.totalValue ?? 0.00, productSaving: data.totalDiscount ?? 0.00, finalTotal: data.finalAmount ?? 0.00, elWalletRedemed: data.elWalletRedeem ?? 0.00, smilesRedemed: data.smilesRedeem ?? 0.00, promocode: data.promoCode, quantity: data.quantity ?? 0, smilesSubscriber: data.smilesSubscriber ?? false, tabbyRedeem: data.tabbyRedeem)

            self.checkoutDeliverySlotView.configure(selectedDeliverySlot: data.selectedDeliverySlot, deliverySlots: self.viewModel.deliverySlots)
        
            self.checkoutDeliveryAddressView.configure(address: self.viewModel.getDeliveryAddress())

            self.promocodeView.configure(promocode: data.promoCode?.code ?? "", promoCodeValue: data.promoCode?.value, primaryPaymentMethodId: data.primaryPaymentTypeID)
        
        
            self.paymentMethodView.configure(paymentTypes: data.paymentTypes ?? [], selectedPaymentId: self.viewModel.getSelectedPaymentMethodId(),creditCard: self.viewModel.getCreditCard())
            
            // Configuration of elWallet and Smiles Points view
            let (hidesSmilesPoints, hidesElWallet) = self.viewModel.hidesSecondaryPaymentsViews(paymentMethods: data.paymentTypes ?? [])
            
            self.smilesPointsView.isHidden = hidesSmilesPoints
            self.elWalletView.isHidden = hidesElWallet
            
            self.smilesPointsView.configure(smilesPointsRedeemed: data.smilesRedeem ?? 0.0, isEnabled: false, smilesBurntRatio: data.smilesBurnRatio, primaryPaymentMethodId: data.primaryPaymentTypeID)
            self.elWalletView.configure(redeemAmount: data.elWalletRedeem ?? 0.00, primaryPaymentMethodId: data.primaryPaymentTypeID)
            
            // Primary Payment method configuration
            let paymentOption = self.viewModel.createPaymentOptionFromString(paymentTypeId: data.primaryPaymentTypeID ?? 0)
            let isSmilesApplied = (data.smilesRedeem ?? 0) > 0
            // Checkout button configuration
            self.checkoutButtonView.configure(paymentOption: paymentOption, points: self.viewModel.getBurnPointsFromAed(), amount: data.finalAmount ?? 0.00, aedSaved: data.productsSaving ?? 0.00, earnSmilePoints: data.smilesEarn ?? 0, promoCode: data.promoCode, isSmileOn: isSmilesApplied)
            
            // Showing tabby limit reach message
            if let message = data.tabbyThresholdMessage, message.isNotEmpty {
                self.showMessage(message)
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
        
        if ElGrocerUtility.isAddressCentralisation {
            DeliveryAddress
                .getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                .forEach { $0.isSmilesDefault = $0.isActive }
            DatabaseHelper.sharedInstance.saveDatabase()
        }
        
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
        
        checkoutStackView.addArrangedSubview(pinView)
        checkoutStackView.addArrangedSubview(checkoutDeliverySlotView)
        checkoutStackView.addArrangedSubview(additionalInstructionsView)
        checkoutStackView.addArrangedSubview(paymentMethodView)
        checkoutStackView.addArrangedSubview(promocodeView)
        checkoutStackView.addArrangedSubview(smilesPointsView)
        checkoutStackView.addArrangedSubview(elWalletView)
        checkoutStackView.addArrangedSubview(billView)
        checkoutStackView.addArrangedSubview(warningView)
        
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
                isWalletEnabled: viewModel.getSelectedElwalletCredit() > 0,
                isSmilesEnabled: viewModel.getSelectedSmilesPoints() > 0,
                isPromoCodeApplied: viewModel.isPromoApplied(),
                smilesPointsEarned: viewModel.basketDataValue?.smilesEarn ?? 0,
                smilesPointsBurnt: viewModel.basketDataValue?.smilesRedeem ?? 0,
                realizationId: viewModel.basketDataValue?.promoCode?.promotionCodeRealizationID,
                elWalletRedeem: viewModel.basketDataValue?.elWalletRedeem ?? 0,
                grandTotal: viewModel.basketDataValue?.totalValue ?? 0
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

extension SecondCheckoutVC: DeliveryInstructionsViewDelegate {
    func deliveryInstructionsView(_didTap view: DeliveryInstructionsView) {
        let instructions = UserDefaults.getAdditionalInstructionsNote()
        let instructionVC = InstructionsViewController()

        instructionVC.doneButtonTapHandler = { [weak self] instructions in
            view.configure(instructions: instructions)
            self?.viewModel.setAdditionalInstructions(text: instructions ?? "")
        }

        let popupController = STPopupController(rootViewController: instructionVC)
        MixpanelEventLogger.trackCheckoutDeliverySlotClicked()
        popupController.navigationBarHidden = true

        popupController.style = .bottomSheet

        popupController.backgroundView?.alpha = 1
        popupController.containerView.layer.cornerRadius = 16
        popupController.navigationBarHidden = true
        popupController.present(in: self)
    }
}

// MARK: - Payment method selection delegate
extension SecondCheckoutVC: PaymentMethodViewDelegate {
    func tap(on view: PaymentMethodView, paymentTypes: [PaymentType]) {
        let viewContorller = self.makePaymentMethodsViewController(paymentTypes: paymentTypes)
        
        viewContorller.selectionClosure = { [weak self] option, applePay, creditCard in
            guard let self = self else { return }
            
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
        
        let popupController = STPopupController(rootViewController: viewContorller)
        popupController.navigationBarHidden = true
        popupController.style = .bottomSheet
        popupController.backgroundView?.alpha = 1
        popupController.containerView.layer.cornerRadius = 16
        popupController.navigationBarHidden = true
        popupController.present(in: self)
    }
    
    private func makePaymentMethodsViewController(paymentTypes: [PaymentType]) -> PaymentMethodSelectionViewController {
        let viewModel = PaymentSelectionViewModel(
            grocery: self.grocery,
            selectedPaymentOption: self.viewModel.getSelectedPaymentOption(),
            cardId: self.viewModel.getCreditCard()?.cardID,
            paymentTypes: paymentTypes,
            tabbyAuthURL: self.viewModel.getTabbyAuthenticationURL()
        )
        
        let viewContorller = PaymentMethodSelectionViewController(viewModel: viewModel)
        
        return viewContorller
    }
}

extension SecondCheckoutVC: PromocodeDelegate {
    func tap(promocode: String?) {
        let selectedPrimaryPM = PaymentOption(rawValue: UInt32(viewModel.basketDataValue?.primaryPaymentTypeID ?? 0)) ?? .none
        
        if selectedPrimaryPM == .none {
            self.showMessage(localizedString("secondary_payment_promocode_error", comment: ""))
            return
        }

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

extension SecondCheckoutVC : MapPinViewDelegate, LocationMapViewControllerDelegate {
    
    func changeButtonClickedWith(_ currentDetails: UserMapPinAdress?) -> Void {
        if ElGrocerUtility.isAddressCentralisation {
            let isEditOrder = (self.viewModel.getOrderId() ?? "").isNotEmpty
            EGAddressSelectionBottomSheetViewController.showInBottomSheet(self.viewModel.getGrocery(), mapDelegate: self.mapDelegate, presentIn: self, isFromCheckout: true, isEditOrder: isEditOrder)
            return
        }
        EGAddressSelectionBottomSheetViewController.showInBottomSheet(self.viewModel.getGrocery(), mapDelegate: self.mapDelegate, presentIn: self)
    }
    
    func tap(_ currentDetails: UserMapPinAdress) {
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
        if ElGrocerUtility.isAddressCentralisation {
            if (self.navigationController?.viewControllers.last as? DashboardLocationViewController) != nil {
                self.navigationController?.popViewController(animated: false)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}

// MARK: - Smiles points view Tap Handler
extension SecondCheckoutVC: CheckoutSmilesPointsViewDelegate {
    func smilesPointsView(_didTap view: CheckoutSmilesPointsView) {
        let availablePoints = Double(viewModel.basketDataValue?.smilesPoints ?? 0)
        let selectedPrimaryPM = PaymentOption(rawValue: UInt32(viewModel.basketDataValue?.primaryPaymentTypeID ?? 0)) ?? .none
        
        if selectedPrimaryPM == .none {
            showMessage(localizedString("primary_payment_required_error_msg", comment: ""))
            return
        }
        
        if UserDefaults.isSmilesUserLoggedIn() == false && sdkManager.isShopperApp {
            showMessage(localizedString("smiles_points_user_not_logged_in_error_msg", comment: ""))
            return
        }

        if availablePoints <= 1 {
            showMessage(localizedString("smiles_points_insufficient_balance_error_msg", comment: ""))
            return
        }
        
        self.showSmilesPointsBottomSheet()
    }
    
    private func showSmilesPointsBottomSheet() {
        let smilesPointsVC = makeSmilesBottomSheetController()

        smilesPointsVC.confirmButtonTapHandler = { [weak self] smilesPoints in
            guard let self = self else { return }
            
            self.viewModel.setSelectedSmilePoints(selectedSmilePoints: smilesPoints)
            self.viewModel.updateSecondaryPaymentMethods()
            
            let smilesPointEnabled = SmilesPointEnabledEvent(isEnabled: smilesPoints != 0, redeemPoints: smilesPoints)
            SegmentAnalyticsEngine.instance.logEvent(event: smilesPointEnabled)
        }

        let popupController = STPopupController(rootViewController: smilesPointsVC)
        popupController.navigationBarHidden = true
        popupController.style = .bottomSheet

        popupController.backgroundView?.alpha = 1
        popupController.containerView.layer.cornerRadius = 16
        popupController.navigationBarHidden = true
        popupController.present(in: self)
    }
    
    // Common Method
    private func showMessage(_ message: String) {
        ElGrocerUtility.sharedInstance.showTopMessageView(message, image: nil, -1, false, backButtonClicked: { sender, index, inUndo in
        }, buttonIcon: UIImage(name: "crossWhite"))
    }
    
    private func makeSmilesBottomSheetController() -> SmilesPointsViewController {
        let availablePoints = viewModel.basketDataValue?.smilesPoints ?? 0
        let pointsRedeemed = viewModel.basketDataValue?.smilesRedeem ?? 0.0
        let amountToPay = viewModel.basketDataValue?.finalAmount ?? 0.0
        let smilesBurntRatio = viewModel.basketDataValue?.smilesBurnRatio
        
        let viewModel = SmilesPointsViewModel(availablePoints: availablePoints, smilesRedeem: pointsRedeemed, amountToPay: amountToPay, smilesBurntRatio: smilesBurntRatio)
        return SmilesPointsViewController(viewModel: viewModel)
    }
}

// MARK: - elWallet view Tap Handler
extension SecondCheckoutVC: CheckoutElWalletViewDelegate {
    func elWalletView(_didTap view: CheckoutElWalletView) {
        let availableBalance = Double(viewModel.basketDataValue?.elWalletBalance ?? 0)
        let selectedPrimaryPM = PaymentOption(rawValue: UInt32(viewModel.basketDataValue?.primaryPaymentTypeID ?? 0)) ?? .none
        
        if selectedPrimaryPM == .none {
            showMessage(localizedString("primary_payment_required_error_msg", comment: ""))
            return
        }

        if availableBalance <= 1 {
            showMessage(localizedString("el_wallet_insufficient_balance_error_msg", comment: ""))
            return
        }
        
        self.showElWalletBottomSheet()
    }
    
    private func showElWalletBottomSheet() {
        let elWalletVC = self.makeElWalletBottomSheetController()
        
        elWalletVC.confirmButtonTapHandler = { [weak self] redeem in
            guard let self = self else { return }
            
            self.viewModel.setSelectedElwaletPoints(selectedElWalletPoints: redeem)
            self.viewModel.updateSecondaryPaymentMethods()
            
            let elWalletToggleEnabled = ElWalletToggleEnabledEvent(isEnabled: redeem != 0, redeemAmount: redeem)
            SegmentAnalyticsEngine.instance.logEvent(event: elWalletToggleEnabled)
        }

        let popupController = STPopupController(rootViewController: elWalletVC)
        popupController.navigationBarHidden = true
        popupController.style = .bottomSheet
        popupController.backgroundView?.alpha = 1
        popupController.containerView.layer.cornerRadius = 16
        popupController.navigationBarHidden = true
        popupController.present(in: self)
    }
    
    private func makeElWalletBottomSheetController() -> ElwalletViewController {
        let availableBalance = viewModel.basketDataValue?.elWalletBalance ?? 0.0
        let redeemAmount = viewModel.basketDataValue?.elWalletRedeem ?? 0.0
        let amountToPay = viewModel.basketDataValue?.finalAmount ?? 0.0
        
        let viewModel = ElWalletViewModel(availableAmount: availableBalance, redeemedAmount: redeemAmount, amountToPay: amountToPay)
        return ElwalletViewController(viewModel: viewModel)
    }
}
