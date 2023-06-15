//
//  OrderConfirmationViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 12/02/2023.
//

import Foundation

import Foundation
import RxSwift
import RxDataSources

protocol OrderConfirmationViewModelInput {
    var orderId: AnyObserver<String> { get } // order id to load data for get order detail api
}

protocol OrderConfirmationViewModelOutput {
    var isArbic: Observable<Bool> { get }
    var loading: Observable<Bool> { get } //  to show api loading progress
    var isNewOrder: Observable<Bool> { get } // will use to display is new order; order coming from place order screen on candidate for new order true value only
    var groceryUrl: Observable<URL?> { get } // order grocery image url
    var groceryName: Observable<String> { get } // order grocery name
    var orderNumber: Observable<String> { get } // order number
    var orderDeliveryDateString: Observable<NSAttributedString> { get } // order delivery date string
    var orderProgressValue: Observable<Float> { get } // order progress value in float to display for UIProgressView
    var orderStatusString: Observable<String> { get } // order status string from config api
    var orderStatus: Observable<OrderStatus> { get } // order status local object
    var picketName: Observable<String> { get } // picker name if any
    var address: Observable<String> { get } // order address normally user current address
    var banners: Observable<[BannerDTO]?> { get } // post checkout banners list
    var error: Observable<ElGrocerError> { get } // error in api if any
    var orderIdForPublicUse: String { get }
}

protocol OrderConfirmationViewModelType: OrderConfirmationViewModelInput, OrderConfirmationViewModelOutput {
    var inputs: OrderConfirmationViewModelInput { get }
    var outputs: OrderConfirmationViewModelOutput { get }
}

extension OrderConfirmationViewModelType {
    var inputs: OrderConfirmationViewModelInput { self }
    var outputs: OrderConfirmationViewModelOutput { self }
}

class OrderConfirmationViewModel: OrderConfirmationViewModelType {
    
    // MARK: Inputs
    var orderId: AnyObserver<String> { orderIdSubject.asObserver() }
    
    // MARK: Outputs
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var isNewOrder: Observable<Bool> { isNewOrderSubject.asObservable() }
    var groceryUrl: Observable<URL?> { groceryUrlSubject.asObservable() }
    var groceryName: Observable<String> { groceryNameSubject.asObservable() }
    var orderNumber: Observable<String> { orderNumberSubject.asObservable() }
    var orderDeliveryDateString: Observable<NSAttributedString> { orderDeliveryDateStringSubject.asObservable() }
    var orderProgressValue: Observable<Float> { orderProgressValueSubject.asObservable() }
    var orderStatusString: Observable<String> { orderStatusStringSubject.asObservable() }
    var orderStatus: Observable<OrderStatus> { orderStatusSubject.asObservable() }
    var picketName: Observable<String> { picketNameSubject.asObservable() }
    var address: Observable<String> { addressSubject.asObservable() }
    var banners: Observable<[BannerDTO]?> { bannersSubject.asObservable() }
    var error: Observable<ElGrocerError> { errorSubject.asObservable() }
    var isArbic: Observable<Bool> { isArbicSubject.asObservable() }
    
    // MARK: Subjects
    private let orderIdSubject = PublishSubject<String>()
    private var isNewOrderSubject = BehaviorSubject<Bool>(value: false)
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private var groceryUrlSubject = BehaviorSubject<URL?>(value: nil)
    private let groceryNameSubject = BehaviorSubject<String>(value: "")
    private let orderNumberSubject = BehaviorSubject<String>(value: "")
    private let orderDeliveryDateStringSubject = BehaviorSubject<NSAttributedString>(value: NSAttributedString.init(string: ""))
    private let orderProgressValueSubject = BehaviorSubject<Float>(value: 0.0)
    private let orderStatusStringSubject = BehaviorSubject<String>(value: "")
    private let orderStatusSubject = BehaviorSubject<OrderStatus>(value: .pending)
    
    private let picketNameSubject = BehaviorSubject<String>(value: "")
    private let addressSubject = BehaviorSubject<String>(value: "")
    private let bannersSubject = BehaviorSubject<[BannerDTO]?>(value: nil)
    private let errorSubject = PublishSubject<ElGrocerError>()
    private let isArbicSubject = BehaviorSubject<Bool>(value: false)
    
    // MARK: Properties
    var orderIdForPublicUse : String = ""
    private var apiClinet: OrderStatusMedule
    private var isNewOrderLocalObj: Bool = false
    private var disposeBag = DisposeBag()
    
    // MARK: Initlizations
    init(_ apiClinet: OrderStatusMedule = OrderStatusMedule(), orderId: String, _ isNewOrder: Bool = false) {
        self.apiClinet = apiClinet
        self.isNewOrderLocalObj = isNewOrder
        self.orderIdForPublicUse = orderId
        self.orderIdSubject.subscribe { orderId in
            self.getOrderDetails(orderId: orderId)
        }.disposed(by: disposeBag)
        self.orderId.onNext(orderId)
        self.getBanners()
        self.isArbicSubject.onNext(ElGrocerUtility.sharedInstance.isArabicSelected())
        
    }
    
    
}

// MARK: Helpers

private extension OrderConfirmationViewModel {
    
    
    private func getOrderStatus(_ order : Order) -> String {
        let status = order.getOrderDynamicStatus()
        let statusString : String = ElGrocerUtility.sharedInstance.isArabicSelected() ? status.nameAr : status.nameEn
        let statusUppercased = statusString.uppercased()
        return statusUppercased
    }
    
    
    private func orderProgressFloatValueWithOrderStatus(_ order : Order) -> Float {
        if ElGrocerUtility.sharedInstance.appConfigData != nil {
            return self.setProgressAccordingToStatus(order.getOrderDynamicStatus(), totalStep: ElGrocerUtility.sharedInstance.appConfigData.orderTotalSteps.floatValue)
        }
        return 0.0
    }
    
    private func setProgressAccordingToStatus(_ status : DynamicOrderStatus? , totalStep : Float) -> Float {
        guard status != nil else {
            return 0.0
        }
        let progress : Float = status!.stepNumber.floatValue / totalStep
        return progress
    }
    
    
    
    
}

private extension OrderConfirmationViewModel {
    
    private func getOrderDetails(orderId: String) {
        self.loadingSubject.onNext(true)
        self.apiClinet.getOrderDetail(orderId) { (result) in
            self.loadingSubject.onNext(false)
            switch result {
                case .success(let response):
                    if let orderDict = response["data"] as? NSDictionary {
                        let latestOrderObj = Order.insertOrReplaceOrderFromDictionary(orderDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        self.groceryUrlSubject.onNext(URL(string: latestOrderObj.grocery.smallImageUrl ?? ElGrocerUtility.sharedInstance.activeGrocery?.smallImageUrl ?? ""))
                        self.groceryNameSubject.onNext(latestOrderObj.grocery.name ?? "")
                        self.orderNumberSubject.onNext(latestOrderObj.dbID.stringValue)
                        self.orderDeliveryDateStringSubject.onNext(NSAttributedString.init(string: latestOrderObj.getSlotDisplayStringOnOrder()))
                        self.picketNameSubject.onNext(((latestOrderObj.picker?.name ?? "") + "\n" + localizedString("txt_Picker", comment: "")) )
                        self.orderProgressValueSubject.onNext(self.orderProgressFloatValueWithOrderStatus(latestOrderObj))
                        self.orderStatusStringSubject.onNext(self.getOrderStatus(latestOrderObj))
                        self.orderStatusSubject.onNext(latestOrderObj.getOrderDynamicStatus().getMappingTypeWithOrderStatus())
                      
                        let addressString = ElGrocerUtility.sharedInstance.getFormattedAddress(latestOrderObj.deliveryAddress) + latestOrderObj.deliveryAddress.address
                        self.addressSubject.onNext(addressString)
                        self.isNewOrderSubject.onNext(self.isNewOrderLocalObj) // This should be last updated; As it will update constraints to not show irralvent views
                        if self.isNewOrderLocalObj {
                            self.deleteBasketFromServerWithGrocery(latestOrderObj.grocery)
                        }
                    }
                case .failure(let error):
                    self.errorSubject.onNext(error)
            }
        }
    }
    
    private func getBanners() {
        
        let location =  BannerLocation.post_checkout.getType()
        let retailer_ids = sdkManager.isGrocerySingleStore ? [ElGrocerUtility.sharedInstance.activeGrocery?.dbID ?? ""] :  ElGrocerUtility.sharedInstance.groceries.map { $0.dbID }
        
        ElGrocerApi.sharedInstance.getBanners(for: location, retailer_ids: retailer_ids) { result in
            switch result {
            case .success(let data):
                self.bannersSubject.onNext(data.map{ $0.toBannerDTO() })
            case .failure(_):
                self.bannersSubject.onNext([])
                break
            }
        }
    }
    
    private func deleteBasketFromServerWithGrocery(_ grocery:Grocery?){
        
        guard UserDefaults.isUserLoggedIn() else {return}
        ElGrocerApi.sharedInstance.deleteBasketFromServerWithGrocery(grocery) { (result) in
            switch result {
            case .success(let responseDict):
               elDebugPrint("Delete Basket Response:%@",responseDict)
            case .failure(let error):
               elDebugPrint("Delete Basket Error:%@",error.localizedMessage)
            }
        }
        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)//
        DatabaseHelper.sharedInstance.saveDatabase()
        ElGrocerUtility.sharedInstance.resetBasketPresistence()
        
    }
}

