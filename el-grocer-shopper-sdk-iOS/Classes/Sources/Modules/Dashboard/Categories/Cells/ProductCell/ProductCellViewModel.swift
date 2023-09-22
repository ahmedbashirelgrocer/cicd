//
//  ProductCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 17/01/2023.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol ProductCellViewModelInput {
    var addToCartButtonTapObserver: AnyObserver<Void> { get }
    var plusButtonTapObserver: AnyObserver<Void> { get }
    var minusButtonTapObserver: AnyObserver<Void> { get }
    var refreshDataObserver: AnyObserver<Void> { get }
}

protocol ProductCellViewModelOutput {
    var grocery: Grocery? { get }
    var basketUpdated: Observable<Void> { get }
    
    var name: Observable<String?> { get }
    var description: Observable<String?> { get }
    var price: Observable<NSAttributedString?> { get }
    var imageUrl: Observable<URL?> { get }
    var isSponsored: Observable<Bool> { get }
    var plusButtonIconName: Observable<String> { get }
    var minusButtonIconName: Observable<String> { get }
    var cartButtonTintColor: Observable<UIColor?> { get }
    var addToCartButtonType: Observable<Bool> { get }
    var quantity: Observable<String> { get }
    var isSubtituted: Observable<Bool?> { get }
    var isAvailable: Observable<Bool> { get }
    var isPublished: Observable<Bool> { get }
    var isShowLimittedStock: Observable<Bool> { get }
    
    var strikeLabelText: Observable<String?> { get }
    var strikeLabelTextColor: Observable<UIColor?> { get }
    var displayPromotionView: Observable<Bool> { get }
    var strickThrough: Observable<Bool> { get }
    var discountPercentage: Observable<String> { get }
    var offLabelText: Observable<String?> { get }
    var saleViewVisibility: Observable<Bool> { get }
    var promoPriceAttributedText: Observable<NSAttributedString?> { get }
    var isArabic: Observable<Bool> { get }
    var productDB: Product? { get }
    var plusButtonEnabled: Observable<Bool> { get }
    var addToCartButtonEnabled: Observable<Bool> { get }
    var quantityValue: Int { get }
    var border: Observable<Bool> { get }
}

protocol ProductCellViewModelType: ProductCellViewModelInput, ProductCellViewModelOutput {
    var inputs: ProductCellViewModelInput { get }
    var outputs: ProductCellViewModelOutput { get }
}

extension ProductCellViewModelType {
    var inputs: ProductCellViewModelInput { self }
    var outputs: ProductCellViewModelOutput { self }
}

class ProductCellViewModel: ProductCellViewModelType, ReusableCollectionViewCellViewModelType {
    // MARK: Inputs
    var addToCartButtonTapObserver: AnyObserver<Void> { self.quickAddButtonTapSubject.asObserver() }
    var plusButtonTapObserver: AnyObserver<Void> { plusButtonTapSubject.asObserver() }
    var minusButtonTapObserver: AnyObserver<Void> { minusButtonTapSubject.asObserver() }
    var refreshDataObserver: AnyObserver<Void> { refreshDataSubject.asObserver() }
    
    // MARK: Outputs
    var grocery: Grocery?
    var basketUpdated: Observable<Void> { basketUpdatedSubject.asObservable() }
    
    var name: Observable<String?> { nameSubject.asObservable() }
    var description: Observable<String?> { descriptionSubject.asObservable() }
    var price: Observable<NSAttributedString?> { priceSubject.asObservable() }
    var imageUrl: Observable<URL?> { imageUrlSubject.asObservable() }
    var isSponsored: Observable<Bool> { isSponsoredSubject.asObservable() }
    var plusButtonIconName: Observable<String> { plusButtonIconNameSubject.asObservable() }
    var minusButtonIconName: Observable<String> { minusButtonIconNameSubject.asObservable() }
    var cartButtonTintColor: Observable<UIColor?> { cartButtonTintColorSubject.asObservable() }
    var addToCartButtonType: Observable<Bool> { addToCartButtonTypeSubject.asObservable() }
    var quantity: Observable<String> { quantitySubject.asObservable() }
    var isSubtituted: Observable<Bool?> { isSubtitutedSubject.asObservable() }
    var isPublished: Observable<Bool> { isPublishedSubject.asObservable() }
    var isAvailable: Observable<Bool> { isAvailableSubject.asObservable() }
    var isShowLimittedStock: Observable<Bool> { isShowLimittedStockSubject.asObservable() }
    var promoPriceAttributedText: Observable<NSAttributedString?> { promoPriceAttributedTextSubject.asObservable() }
    
    var displayPromotionView: Observable<Bool> { displayPromotionViewSubject.asObservable() }
    var strikeLabelText: Observable<String?> { strikeLabelTextSubject.asObservable() }
    var strikeLabelTextColor: Observable<UIColor?> { strikeLabelTextColorSubject.asObservable() }
    var strickThrough: RxSwift.Observable<Bool> { strickThroughSubject.asObservable() }
    var discountPercentage: RxSwift.Observable<String> { discountPercentageSubject.asObservable() }
    var offLabelText: RxSwift.Observable<String?> { offLabelTextSubject.asObservable() }
    var saleViewVisibility: RxSwift.Observable<Bool> { saleViewVisibilitySubject.asObservable() }
    var isArabic: Observable<Bool> { isArabicSubject.asObserver() }
    var productDB: Product? { self.product.productDB }
    var plusButtonEnabled: Observable<Bool> { plusButtonEnabledSubject.asObservable() }
    var addToCartButtonEnabled: Observable<Bool> { addToCartButtonEnabledSubject.asObservable() }
    var quantityValue: Int { getShoppingBasketItemForActiveRetailer()?.count.intValue ?? 0 }
    var border: Observable<Bool> { borderSubject.asObservable() }
    
    // MARK: Subjects
    private var quickAddButtonTapSubject = PublishSubject<Void>()
    private var basketUpdatedSubject = PublishSubject<Void>()
    
    private var nameSubject = BehaviorSubject<String?>(value: nil)
    private var descriptionSubject = BehaviorSubject<String?>(value: nil)
    private var priceSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private var imageUrlSubject = BehaviorSubject<URL?>(value: nil)
    private var isSponsoredSubject = BehaviorSubject<Bool>(value: false)
    private var plusButtonIconNameSubject = BehaviorSubject<String>(value: "add_product_cell")
    private var minusButtonIconNameSubject = BehaviorSubject<String>(value: "remove_product_cell")
    private var cartButtonTintColorSubject = BehaviorSubject<UIColor?>(value: nil)
    private var addToCartButtonTypeSubject = BehaviorSubject<Bool>(value: false)
    private var quantitySubject = BehaviorSubject<String>(value: "0")
    private var isSubtitutedSubject = BehaviorSubject<Bool?>(value: nil)
    private var isPublishedSubject = BehaviorSubject<Bool>(value: true)
    private var isAvailableSubject = BehaviorSubject<Bool>(value: true)
    private var isShowLimittedStockSubject = BehaviorSubject<Bool>(value: false)
    private var promoPriceAttributedTextSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    
    private var displayPromotionViewSubject = BehaviorSubject<Bool>(value: false)
    private var strikeLabelTextSubject = BehaviorSubject<String?>(value: nil)
    private var strikeLabelTextColorSubject = BehaviorSubject<UIColor?>(value: nil)
    private var strickThroughSubject = BehaviorSubject<Bool>(value: false)
    private var discountPercentageSubject = BehaviorSubject<String>(value: "0")
    private var offLabelTextSubject = BehaviorSubject<String?>(value: nil)
    private var saleViewVisibilitySubject = BehaviorSubject<Bool>(value: true)
    private var plusButtonTapSubject = PublishSubject<Void>()
    private var minusButtonTapSubject = PublishSubject<Void>()
    private var isArabicSubject = BehaviorSubject<Bool>(value: ElGrocerUtility.sharedInstance.isArabicSelected())
    private var plusButtonEnabledSubject = BehaviorSubject<Bool>(value: true)
    private var addToCartButtonEnabledSubject = BehaviorSubject<Bool>(value: true)
    private var refreshDataSubject = PublishSubject<Void>()
    private var borderSubject = BehaviorSubject<Bool>(value: true)

    var reusableIdentifier: String { ProductCell.defaultIdentifier }
    
    private var disposeBag = DisposeBag()
    private var product: ProductDTO
    private let PRODUCT_LIMIT = 3
    
    init(product: ProductDTO, grocery: Grocery?, border: Bool = true) {
        self.grocery = grocery
        self.product = product
        CellSelectionState.shared.grocery = grocery
        self.borderSubject.onNext(border)
        
        self.refreshCell()
        
        refreshDataSubject.asObservable().subscribe(onNext: { [weak self] in
            self?.refreshCell()
        }).disposed(by: disposeBag)
        
        // MARK: Add To Cart Button Tap Listner
        quickAddButtonTapSubject
            .withLatestFrom(self.quantity)
            .subscribe(onNext: { [weak self] quantity in
            guard let self = self else { return }
            
            CellSelectionState.shared.inputs.selectProductWithID.onNext(self.productDB?.dbID ?? "")
            if (quantity as NSString).integerValue > 0 {
                CellSelectionState.shared.inputs.productQuantityObserver.onNext(self.product.id)
                return
            }
            
            product.isPg18
                ? self.showPg18PopupAndAddToCart()
                : self.isActiveBasketExistForOtherGrocery() ? self.showActiveBasketPopup() : self.addProductToCart()
            
        }).disposed(by: disposeBag)
        
        CellSelectionState.shared.outputs.selectionChanged
            .compactMap { [weak self] in CellSelectionState.shared.outputs.isProductSelected(id: self?.productDB?.dbID ?? "") }
            .share()
            .bind(to: addToCartButtonTypeSubject)
            .disposed(by: disposeBag)

        // MARK: Plus Button Tap Listner
        plusButtonTapSubject.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            
            product.isPg18
                ? self.showPg18PopupAndAddToCart()
                : self.addProductToCart()
            
        }).disposed(by: disposeBag)
        
        // MARK: Minus Button Tap Listner
        minusButtonTapSubject.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            
            self.removeProductFromCart()
        }).disposed(by: disposeBag)
    }
    
    private func refreshCell() {
        showProductAttributes()
        checkProductExistanceInCartAndUpdateUI()
        checkPromotionValidityAndUpdateUI()
        checkStockAvailabilityAndUpdateUI()
        
        if CellSelectionState.shared.outputs.isProductSelected(id: self.productDB?.dbID ?? "") {
            CellSelectionState.shared.inputs.selectProductWithID.onNext("")
        }
    }
}

// MARK: Helpers
// TODO: Renaming these methods
private extension ProductCellViewModel {
    func showProductAttributes() {
        nameSubject.onNext(product.name)
        descriptionSubject.onNext(product.sizeUnit)
        priceSubject.onNext(ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: product.fullPrice ?? 0.0))
        imageUrlSubject.onNext(URL(string: product.imageURL ?? ""))
        isSponsoredSubject.onNext(product.productDB?.isSponsoredProduct ?? false)
        isAvailableSubject.onNext(product.isAvailable ?? true)
        isPublishedSubject.onNext(product.isPublished ?? true)
        
        let isEnabled = grocery?.inventoryControlled?.boolValue == true ?  product.availableQuantity != 0 : true
        addToCartButtonEnabledSubject.onNext(isEnabled)
    }
    
    func checkProductExistanceInCartAndUpdateUI() {
        CellSelectionState.shared.inputs.productQuantityObserver.onNext(self.product.id)
        if let item = getShoppingBasketItemForActiveRetailer() {
            plusButtonIconNameSubject.onNext("add_product_cell")
            minusButtonIconNameSubject.onNext(item.count == 1 ? "delete_product_cell" : "remove_product_cell")
            cartButtonTintColorSubject.onNext(ApplicationTheme.currentTheme.navigationBarWhiteColor)
            // addToCartButtonTypeSubject.onNext(true)
            quantitySubject.onNext(ElGrocerUtility.sharedInstance.isArabicSelected() ? "\(item.count.intValue)".changeToArabic() : "\(item.count.intValue)")
            isSubtitutedSubject.onNext(item.isSubtituted.boolValue)
            
            if let productDB = product.productDB {
                let isLimitReached = ProductQuantiy.checkPromoLimitReached(productDB, count: item.count.intValue)
                self.plusButtonEnabledSubject.onNext(!isLimitReached)
            }
            return
        }
        
        plusButtonIconNameSubject.onNext("add_product_cell")
        minusButtonIconNameSubject.onNext("remove_product_cell")
        cartButtonTintColorSubject.onNext(ApplicationTheme.currentTheme.themeBasePrimaryColor)
        addToCartButtonTypeSubject.onNext(false)
        quantitySubject.onNext("0")
    }
    
    func checkPromotionValidityAndUpdateUI() {
        let promotionValidity = ProductQuantiy.checkPromoValidity(product: product)
        
        displayPromotionViewSubject.onNext(promotionValidity.displayPromo)
        
        if promotionValidity.displayPromo {
            if promotionValidity.showPercentage {
                let percentage = getPromoPercentage()
                strikeLabelTextSubject.onNext(ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: product.fullPrice ?? 0.0))
                strikeLabelTextColorSubject.onNext(.navigationBarWhiteColor())
                strickThroughSubject.onNext(true)
                
                if percentage == 0 {
                    strikeLabelTextSubject.onNext(localizedString("lbl_Special_Discount", comment: ""))
                    strikeLabelTextColorSubject.onNext(.elGrocerYellowColor())
                    strickThroughSubject.onNext(false)
                    discountPercentageSubject.onNext("")
                    saleViewVisibilitySubject.onNext(false)
                    offLabelTextSubject.onNext("")
                } else {
                    discountPercentageSubject.onNext("-" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(percentage)) + "%")
                    saleViewVisibilitySubject.onNext(true)
                    offLabelTextSubject.onNext(localizedString("txt_off_Single", comment: ""))
                    
                }
            } else {
                strikeLabelTextSubject.onNext(localizedString("lbl_Special_Discount", comment: ""))
                strikeLabelTextColorSubject.onNext(.elGrocerYellowColor())
                strickThroughSubject.onNext(false)
                discountPercentageSubject.onNext("")
                saleViewVisibilitySubject.onNext(false)
                offLabelTextSubject.onNext("")
            }
            
            self.promoPriceAttributedTextSubject.onNext(ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: self.product.promoPrice ?? 0.0, isProductWhite: true))
        } else {
            saleViewVisibilitySubject.onNext(true)
        }
    }
    
    func checkStockAvailabilityAndUpdateUI() {
        if let aQuantity = product.availableQuantity, let promoProductLimit = product.promoProductLimit {
            isShowLimittedStockSubject.onNext((aQuantity > 0 && aQuantity < PRODUCT_LIMIT) || (promoProductLimit > 0))
        }
    }
}

// MARK: Helpers ( Operations )
private extension ProductCellViewModel {
    func addProductToCart() {
        var currentQuantity = 0
        var updatedQuantity = 0

        if let item = getShoppingBasketItemForActiveRetailer() {
            currentQuantity = item.count.intValue
            updatedQuantity = item.count.intValue + 1

            if (product.promotion == true) && (currentQuantity >= product.promoProductLimit ?? 0) && (product.promoProductLimit ?? 0 > 0) {
                showOverLimitMsg()
                return
            } else if (product.availableQuantity ?? 0 > 0) && (product.availableQuantity ?? 0 <= updatedQuantity) {
                showOverLimitMsg()
            }
        } else {
            updatedQuantity += 1
        }
        
        // Logging segment event for cart created and product added
        if let product = self.product.productDB {
            let isNewCart = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext).count == 0
            if isNewCart {
                SegmentAnalyticsEngine.instance.logEvent(event: CartCreatedEvent(grocery: self.grocery))
            }
            
            SegmentAnalyticsEngine.instance.logEvent(event: CartUpdatedEvent(grocery: self.grocery, product: product, actionType: .added, quantity: updatedQuantity))
        }
        
        createOrUpdateBasketItem(updatedQuantity: updatedQuantity)
    }
    
    func removeProductFromCart() {
        if let item = getShoppingBasketItemForActiveRetailer() {
            let updatedQuantity = item.count.intValue - 1
            
            if updatedQuantity < 0 { return }
            
            createOrUpdateBasketItem(updatedQuantity: updatedQuantity)
            
            // Logging segment event for cart deleted and product removed
            if let product = self.product.productDB {
                let cartDeleted = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext).count == 0
                if cartDeleted {
                    SegmentAnalyticsEngine.instance.logEvent(event: CartDeletedEvent(grocery: self.grocery))
                }
                
                SegmentAnalyticsEngine.instance.logEvent(event: CartUpdatedEvent(grocery: self.grocery, product: product, actionType: .removed, quantity: updatedQuantity))
            }
        }
    }
    
    func createOrUpdateBasketItem(updatedQuantity: Int) {
        guard let selectedProduct = product.productDB else { return }
        
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        
        if updatedQuantity == 0 {
            ShoppingBasketItem.removeProductFromBasket(selectedProduct, grocery: self.grocery, context: context)
            CellSelectionState.shared.inputs.selectProductWithID.onNext("")
        } else {
            ShoppingBasketItem.addOrUpdateProductInBasket(selectedProduct, grocery: self.grocery, brandName: selectedProduct.brandNameEn , quantity: updatedQuantity, context: context)
        }
        
        checkProductExistanceInCartAndUpdateUI()
        basketUpdatedSubject.onNext(())
    }
    
    func getShoppingBasketItemForActiveRetailer() -> ShoppingBasketItem? {
        guard let retailer = self.grocery else { return nil }
        
        return ShoppingBasketItem.checkIfProductIsInBasket(productId: product.id, grocery: retailer, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    func isActiveBasketExistForOtherGrocery() -> Bool {
        guard let grocery = grocery else { return false }
        
        let isOtherGroceryBasketActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive(grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let activeBasketGrocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if isOtherGroceryBasketActive && activeBasketGrocery != nil && activeBasketGrocery!.dbID != String(product.retailerID ?? 0) {
            return true
        }
        
        return false
    }
    
    func getPromoPercentage() -> Int {
        var percentage : Double = 0
        guard let actualPrice = product.fullPrice, let promoPrice = product.promoPrice else { return 0 }
        
        if actualPrice > 0 {
            let percentageDecimal = ((actualPrice - promoPrice) / actualPrice)
            percentage = percentageDecimal * 100
        }

        return Int(percentage.rounded())
    }
    
    // TODO: Move these methods to Views or Coordinator
    func showOverLimitMsg() {
        let msg = localizedString("msg_limited_stock_start", comment: "") + "\(product.availableQuantity ?? 0)" + localizedString("msg_limited_stock_end", comment: "")
        let title = localizedString("msg_limited_stock_Quantity_title", comment: "")
        ElGrocerUtility.sharedInstance.showTopMessageView(msg ,title, image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
    }
    
    func showActiveBasketPopup() {
        
        if !UserDefaults.isUserLoggedIn() {
            let SDKManager = SDKManager.shared
            let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "NoCartPopUp") , header: localizedString("products_adding_different_grocery_alert_title", comment: ""), detail: localizedString("products_adding_different_grocery_alert_message", comment: ""),localizedString("grocery_review_already_added_alert_cancel_button", comment: ""),localizedString("select_alternate_button_title_new", comment: "") , withView: SDKManager.window!) { (buttonIndex) in
                
                if buttonIndex == 1 {
                    //clear active basket and add product
                    ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    ElGrocerUtility.sharedInstance.resetBasketPresistence()
                    
                    self.addProductToCart()
                }
            }
            
            return
        }
        
        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        ElGrocerUtility.sharedInstance.resetBasketPresistence()
        
        addProductToCart()
    }
    
    func showPg18PopupAndAddToCart() {
        // TODO: This is view controller on coordinator responsibility to show popup
        if let SDKManager = UIApplication.shared.delegate {
            let alertView = TobbacoPopup.showNotificationPopup(topView: (SDKManager.window ?? UIApplication.topViewController()?.view)!, msg: ElGrocerUtility.sharedInstance.appConfigData.pg_18_msg , buttonOneText: localizedString("over_18", comment: "") , buttonTwoText: localizedString("less_over_18", comment: ""))
            
            alertView.TobbacobuttonClickCallback = { [weak self] (buttonIndex) in
                guard let self = self else { return }
                
                UserDefaults.setOver18(buttonIndex == 0)
                if buttonIndex == 0 {
                    self.addProductToCart()
                }
            }
        }
    }
}

protocol CellSelectionStateInputs {
    var selectProductWithID: AnyObserver<String> { get }
    var productQuantityObserver: AnyObserver<Int> { get }
}
protocol CellSelectionStateOutputs {
    var selectionChanged: Observable<Void> { get }
    var productQuantity: Observable<String> { get }
    func isProductSelected(id: String) -> Bool
}
protocol CellSelectionStateType: CellSelectionStateInputs, CellSelectionStateOutputs {
    var inputs: CellSelectionStateInputs { get }
    var outputs: CellSelectionStateOutputs { get }
}
extension CellSelectionStateType  {
    var inputs: CellSelectionStateInputs { self }
    var outputs: CellSelectionStateOutputs { self }
}

class CellSelectionState: CellSelectionStateType {
    
    static var shared = CellSelectionState()
    
    // Inputs
    var selectProductWithID: RxSwift.AnyObserver<String> { productIDSubject.asObserver() }
    var productQuantityObserver: AnyObserver<Int> { productQuantityChangedSubject.asObserver() }
    
    // Outputs
    var selectionChanged: RxSwift.Observable<Void> { selectionChangedSubject.asObservable() }
    var productQuantity: RxSwift.Observable<String> { quantitySubject.asObservable() }
    func isProductSelected(id: String) -> Bool { return _selectedProductID == id }
    
    private var productIDSubject = RxSwift.PublishSubject<String>()
    private var selectionChangedSubject = RxSwift.PublishSubject<Void>()
    private var productQuantityChangedSubject = RxSwift.PublishSubject<Int>()
    private var quantitySubject = RxSwift.PublishSubject<String>()
    
    private var disposeBag = DisposeBag()
    private var _selectedProductID = ""
    var grocery: Grocery?
    
    
    init() {
        productIDSubject
            .subscribe(onNext: { [weak self] id in
                self?._selectedProductID = id
                self?.selectionChangedSubject.onNext(())
            })
            .disposed(by: disposeBag)
        
        productQuantityChangedSubject.subscribe(onNext: { [weak self] productId in
            guard let self = self else { return }
            
            let quantity = self.getShoppingBasketItemForActiveRetailer(productId: productId)?.count.stringValue ?? "0"
            self.quantitySubject.onNext(ElGrocerUtility.sharedInstance.isArabicSelected() ? quantity.changeToArabic() : quantity)
        }).disposed(by: disposeBag)
    }
    
    func getShoppingBasketItemForActiveRetailer(productId: Int) -> ShoppingBasketItem? {
        guard let retailer = self.grocery else { return nil }
        
        return ShoppingBasketItem.checkIfProductIsInBasket(productId: productId, grocery: retailer, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
}
