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
    private var billView = BillView()
    
    private lazy var secondaryPaymentView: SecondaryPaymentView = SecondaryPaymentView()
    
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
        
        self.checkoutDeliverySlotView.changeSlot = { [weak self] (slot) in
            self?.viewModel.setSelectedSlotId(slot?.dbID)
            self?.viewModel.setDeliverySlot(slot)
            self?.viewModel.updateSlotToBackEnd()
        }
        
        self.checkoutButtonView.checkOutClicked = { [weak self] in
            guard let self = self else { return }
            guard self.viewModel.getGrocery()?.deliveryZoneId != nil, self.viewModel.getSelectedPaymentOption() != PaymentOption.none, self.viewModel.getCurrentDeliverySlot() != nil, let grocery = self.viewModel.getGrocery() else {
                return
            }
            
            let _ = SpinnerView.showSpinnerViewInView(self.view)

            let orderPlacement = PlaceOrderHandler.init(finalOrderItems: self.viewModel.getShoppingItems() ?? [], activeGrocery: grocery , finalProducts: self.viewModel.getFinalisedProducts() ?? [], orderID: self.viewModel.getOrderId(), finalOrderAmount: self.viewModel.basketDataValue?.finalAmount ?? 0.00, orderPlaceOrEditApiParams: self.viewModel.getOrderPlaceApiParams())
            if let _ = self.viewModel.getOrderId() {
                orderPlacement.editedOrder()
            }else {
                orderPlacement.placeOrder()
            }
            orderPlacement.orderPlaced = { [weak self] order, error in
                 
                SpinnerView.hideSpinnerView()
                
                guard order != nil else { return }
                
                if self?.viewModel.getSelectedPaymentOption() == .creditCard, let card = self?.viewModel.getCreditCard()?.adyenPaymentMethod {
                    if let oldOrder = self?.viewModel.getEditOrderInitialDetail(),oldOrder.cardID == self?.viewModel.getCreditCard()?.cardID {
                        self?.showConfirmationView(order!)
                        return
                    }
                    self?.paymentWithCard(card, order: order!)
                }else if self?.viewModel.getSelectedPaymentOption() == .applePay, let card = self?.viewModel.getApplePay(){
                    self?.payWithApplePay(selctedApplePayMethod: card, order: order!)
                } else {
                    self?.showConfirmationView(order!)
                }
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
            
            self.updateViewAccordingToData(data: data)
        })
        .disposed(by: disposeBag)
        
        viewModel.getBasketData.subscribe(onNext: { [weak self] data in
            
            guard let self = self, let data = data else { return }
            
            self.updateViewAccordingToData(data: data)
        })
        .disposed(by: disposeBag)
        
        self.viewModel.getCreditCardsFromAdyen()
        
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
    }
    
    func updateViewAccordingToData(data: BasketDataClass) {
        
        
        Thread.OnMainThread {

        self.checkoutDeliverySlotView.configure(slots: data.deliverySlots ?? [], selectedSlotId: data.selectedDeliverySlot ?? -1)
        // configure bill view
            self.billView.configure(productTotal: data.productsTotal ?? 0.00, serviceFee: data.serviceFee ?? 0.00, total: data.totalValue ?? 0.00, productSaving: data.totalDiscount ?? 0.00, finalTotal: data.finalAmount ?? 0.00, elWalletRedemed: data.elWalletRedeem ?? 0.00, smilesRedemed: data.smilesRedeem ?? 0.00, promocode: data.promoCode, quantity: data.quantity ?? 0)

        
        self.checkoutDeliveryAddressView.configure(address: self.viewModel.getDeliveryAddress())
        if self.viewModel.getOrderId()?.count ?? 0 > 0 {
            self.promocodeView.isHidden = true
        }else {
            self.promocodeView.isHidden = false
            self.promocodeView.configure(promocode: data.promoCode?.code ?? "")
        }
        
        self.paymentMethodView.configure(paymentTypes: data.paymentTypes ?? [], selectedPaymentId: self.viewModel.getSelectedPaymentMethodId(),creditCard: self.viewModel.getCreditCard())
        
        let secondaryPaymentTypes = self.viewModel.getShouldShowSecondaryPayments(paymentMethods: data.paymentTypes ?? [])
        if secondaryPaymentTypes == .none {
            self.secondaryPaymentView.isHidden = true
        }else {
            
            if self.viewModel.getOrderId()?.count ?? 0 > 0 {
                
                self.secondaryPaymentView.isHidden = true
                
            }else {
                
                self.secondaryPaymentView.configure(smilesBalance: data.smilesBalance ?? 0.00, elWalletBalance: data.elWalletBalance ?? 0.00, smilesRedeem: data.smilesRedeem ?? 0.00, elWalletRedeem: data.elWalletRedeem ?? 0.00, smilesPoint: data.smilesPoints ?? 0, paymentTypes: secondaryPaymentTypes)
            }
           
        }
        let paymentOption = self.viewModel.createPaymentOptionFromString(paymentTypeId: data.primaryPaymentTypeID ?? 0)
        
            self.checkoutButtonView.configure(paymentOption: paymentOption, points: self.viewModel.getBurnPointsFromAed(), amount: data.finalAmount ?? 0.00, aedSaved: data.productsSaving ?? 0.00, earnSmilePoints: self.viewModel.getEarnPointsFromAed(), promoCode: data.promoCode, isSmileOn: self.viewModel.getIsSmileTrue() )
        }
    }
    
    func paymentWithCard(_ selectedMethod: StoredCardPaymentMethod, order : Order) {
           
        AdyenManager.sharedInstance.makePaymentWithCard(controller: self, amount: NSDecimalNumber.init(value: 0), orderNum: order.dbID.stringValue, method: selectedMethod )
            AdyenManager.sharedInstance.isPaymentMade = { (error, response,adyenObj) in
                SpinnerView.hideSpinnerView()
                if error {
                    if let resultCode = response["resultCode"] as? String,  resultCode.count > 0 {
                        print(resultCode)
                        let refusalReason =  (response["refusalReason"] as? String) ?? resultCode
                        AdyenManager.showErrorAlert(descr: refusalReason)
                    }
                }else {
                    self.showConfirmationView(order)
                }
            }
    }
    
    func payWithApplePay(selctedApplePayMethod: ApplePayPaymentMethod,order: Order) {
        
            
            let authValue = NSDecimalNumber.init(value: 1)
            
            AdyenManager.sharedInstance.makePaymentWithApple(controller: self, amount: authValue, orderNum: order.dbID.stringValue, method: selctedApplePayMethod)
            AdyenManager.sharedInstance.isPaymentMade = { (error, response,adyenObj) in
               
                SpinnerView.hideSpinnerView()
                
                if error {
                    if let resultCode = response["resultCode"] as? String {
                        print(resultCode)
                        if let reason = response["refusalReason"] as? String {
                            AdyenManager.showErrorAlert(descr: reason)
                        }
                       
                    }
                }else {
                    self.showConfirmationView(order)
                }
                
            }
    }
    
    
    func showConfirmationView(_ order : Order) {
        
        defer {
            
            UserDefaults.setLeaveUsNote(nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "resetBasketObjData"), object: nil)
            
        }
        
        UserDefaults.resetEditOrder()
    
        self.resetLocalDBData(order)
        let orderConfirmationController = ElGrocerViewControllers.orderConfirmationViewController()
        orderConfirmationController.order = order
        orderConfirmationController.grocery = self.viewModel.getGrocery()
        orderConfirmationController.finalOrderItems = self.viewModel.getShoppingItems() ?? []
        orderConfirmationController.finalProducts = self.viewModel.getFinalisedProducts()
        orderConfirmationController.deliveryAddress = self.viewModel.getAddress()
        self.navigationController?.pushViewController(orderConfirmationController, animated: true)
        
    }
    
    private func resetLocalDBData(_ order: Order) {
        ElGrocerUtility.sharedInstance.resetBasketPresistence()
        ElGrocerApi.sharedInstance.deleteBasketFromServerWithGrocery(order.grocery) { (result) in
            debugPrint(result)
        }
    }
    
    
}

// MARK: - Helpers Methods
private extension SecondCheckoutVC {
    func addSubViews() {
        
        checkoutStackView.addArrangedSubview(checkoutDeliverySlotView)
        checkoutStackView.addArrangedSubview(viewWarning)
        checkoutStackView.addArrangedSubview(checkoutDeliveryAddressView)
        checkoutStackView.addArrangedSubview(additionalInstructionsView)
        checkoutStackView.addArrangedSubview(viewCollectorCar)
        checkoutStackView.addArrangedSubview(viewCollector)
        checkoutStackView.addArrangedSubview(viewCollector)
        checkoutStackView.addArrangedSubview(paymentMethodView)
        checkoutStackView.addArrangedSubview(promocodeView)
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
}

extension SecondCheckoutVC: NavigationBarProtocol {
    func backButtonClickedHandler() {
        self.backButtonClick()
    }
    
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension SecondCheckoutVC: AdditionalInstructionsViewDelegate {
    func textViewTextChangeDone(text: String) {
        self.viewModel.setAdditionalInstructions(text: text)
    }
}

// MARK: - Payment method selection delegate
extension SecondCheckoutVC: PaymentMethodViewDelegate {
    func tap(on view: PaymentMethodView, paymentTypes: [PaymentType]) {
        let vm = PaymentSelectionViewModel(elGrocerAPI: ElGrocerApi.sharedInstance, adyenApiManager: AdyenApiManager(), grocery: self.grocery, selectedPaymentOption: self.viewModel.getSelectedPaymentOption(),cardId: self.viewModel.getCreditCard()?.cardID)
        let viewController = PaymentMethodSelectionViewController.create(viewModel: vm) { option, applePay, creditCard in
            if let option = option, let groceryId = self.viewModel.getGroceryId() {
                UserDefaults.setPaymentMethod(option.rawValue, forStoreId: groceryId)
                UserDefaults.setCardID(cardID: creditCard?.cardID ?? "", userID: self.viewModel.getUserId()?.stringValue ?? "")
                self.viewModel.updateCreditCard(creditCard)
                self.viewModel.updateApplePay(applePay)
                self.viewModel.updatePaymentMethod(option)
            }
        }

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
            guard let self = self,  let car = car else { return }
            
            view.configure(car: car)
        }
        controller.carDeleted = { [weak self] (carId) in
            guard let self = self,  let carId = carId else { return }
            
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

        
        let vc = ElGrocerViewControllers.getApplyPromoVC()
        
        vc.previousGrocery = self.viewModel.getGrocery()
        vc.priviousPaymentOption = self.viewModel.getSelectedPaymentOption()
        vc.priviousPrice = self.viewModel.basketDataValue?.finalAmount ?? 0.00
        vc.priviousShoppingItems = self.viewModel.getShoppingItems()
        vc.priviousOrderId = self.viewModel.getOrderId()
        vc.priviousFinalizedProductA = self.viewModel.getFinalisedProducts()
        vc.promoCode = self.viewModel.basketDataValue?.promoCode?.code
        
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
        
        ElGrocerEventsLogger.sharedInstance.trackScreenNav([FireBaseParmName.CurrentScreen.rawValue : FireBaseScreenName.MyBasket.rawValue , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.ApplyPromoVC.rawValue])
        self.present(vc, animated: true, completion: nil)
    }
}

extension SecondCheckoutVC: SecondaryPaymentViewDelegate {
    func switchStateChange(type: SourceType, switchState: Bool) {
        switch type {
        case .elWallet:
            print("elwallet switch changed to >> \(switchState)")
            self.viewModel.setIsWalletTrue(isWalletTrue: switchState)
            self.viewModel.updateSecondaryPaymentMethods()
            break
            
        case .smile:
            print("smiles switch changed to >> \(switchState)")
            self.viewModel.setIsSmileTrue(isSmileTrue: switchState)
            self.viewModel.updateSecondaryPaymentMethods()
            break
        }
        
    }
}
