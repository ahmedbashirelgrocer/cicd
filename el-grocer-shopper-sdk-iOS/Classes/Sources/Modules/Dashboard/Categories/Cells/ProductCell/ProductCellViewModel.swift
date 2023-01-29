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
}

protocol ProductCellViewModelOutput {
    var grocery: Grocery? { get }
    var quickAddButtonTap: Observable<ProductDTO> { get }
    
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
    
    // MARK: Outputs
    var grocery: Grocery?
    var quickAddButtonTap: Observable<ProductDTO> { self.quickAddButtonTapSubject.map { self.product }.asObservable() }
    
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
    
    // MARK: Subjects
    private var quickAddButtonTapSubject = PublishSubject<Void>()
    
    private var nameSubject = BehaviorSubject<String?>(value: nil)
    private var descriptionSubject = BehaviorSubject<String?>(value: nil)
    private var priceSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private var imageUrlSubject = BehaviorSubject<URL?>(value: nil)
    private var isSponsoredSubject = BehaviorSubject<Bool>(value: false)
    private var plusButtonIconNameSubject = BehaviorSubject<String>(value: "icPlusGray")
    private var minusButtonIconNameSubject = BehaviorSubject<String>(value: "icDashGrey")
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

    
    var reusableIdentifier: String { ProductCell.defaultIdentifier }
    
    private var disposeBag = DisposeBag()
    private var product: ProductDTO
    private let PRODUCT_LIMIT = 3
    
    init(product: ProductDTO, grocery: Grocery?) {
        self.grocery = grocery
        self.product = product
        
        showProductAttributes()
        checkProductExistanceInCartAndUpdateUI()
        checkPromotionValidityAndUpdateUI()
        checkStockAvailabilityAndUpdateUI()
        
        quickAddButtonTapSubject.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            
            product.isPg18
                ? self.showPg18PopupAndAddToCart()
                : self.checkActiveCartExistanceAndAddToCart()
            
        }).disposed(by: disposeBag)
        
        plusButtonTapSubject.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            
            product.isPg18
                ? self.showPg18PopupAndAddToCart()
                : self.plusButtonTapHandler()
            
        }).disposed(by: disposeBag)
    }
}

// MARK: Helpers
private extension ProductCellViewModel {
    func showProductAttributes() {
        nameSubject.onNext(product.name)
        descriptionSubject.onNext(product.sizeUnit)
        priceSubject.onNext(ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: product.fullPrice ?? 0.0))
        imageUrlSubject.onNext(URL(string: product.imageURL ?? ""))
        isSponsoredSubject.onNext(product.isSponsored ?? false)
        isAvailableSubject.onNext(product.isAvailable ?? true)
        isPublishedSubject.onNext(product.isPublished ?? true)
    }
    
    func checkProductExistanceInCartAndUpdateUI() {
        if let item = isProductExistInBasket() {
            plusButtonIconNameSubject.onNext("add_product_cell")
            minusButtonIconNameSubject.onNext(item.count == 1 ? "delete_product_cell" : "remove_product_cell")
            cartButtonTintColorSubject.onNext(ApplicationTheme.currentTheme.themeBasePrimaryColor)
            addToCartButtonTypeSubject.onNext(true)
            quantitySubject.onNext(ElGrocerUtility.sharedInstance.isArabicSelected() ? "\(item.count.intValue)".changeToArabic() : "\(item.count.intValue)")
            isSubtitutedSubject.onNext(item.isSubtituted.boolValue)
            return
        }
        
        plusButtonIconNameSubject.onNext("add_product_cell")
        minusButtonIconNameSubject.onNext("delete_product_cell")
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
    func checkActiveCartExistanceAndAddToCart() {
        if let item = self.isProductExistInBasket() {
            let count = item.count.intValue + 1
            
            if count != 1 {
                let updatedQuantity = ElGrocerUtility.sharedInstance.isArabicSelected() ? "\(count)".changeToArabic() : "\(count)".changeToArabic()
                quantitySubject.onNext(updatedQuantity)
                return
            }
        }
        
        isActiveBasketExistForOtherGrocery()
            ? addProductToBasket()
            : addProductToBasket()
    }
    
    func addProductToBasket() {
        guard let selectedProduct = product.productDB else { return }
        
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        
        var productQuantity = 1
        
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(productId: product.id, grocery: grocery!, context: context) {
            productQuantity += product.count.intValue
        }
        
        if productQuantity == 0 {
            ShoppingBasketItem.removeProductFromBasket(selectedProduct, grocery: self.grocery, context: context)
        } else {
            ShoppingBasketItem.addOrUpdateProductInBasket(selectedProduct, grocery: self.grocery, brandName: selectedProduct.brandNameEn , quantity: productQuantity, context: context)
        }
        
        checkProductExistanceInCartAndUpdateUI()
    }
    
    func showPg18PopupAndAddToCart() {
        // TODO: This is view controller on coordinator responsibility to show popup
        if let SDKManager = UIApplication.shared.delegate {
            let alertView = TobbacoPopup.showNotificationPopup(topView: (SDKManager.window ?? UIApplication.topViewController()?.view)!, msg: ElGrocerUtility.sharedInstance.appConfigData.pg_18_msg , buttonOneText: localizedString("over_18", comment: "") , buttonTwoText: localizedString("less_over_18", comment: ""))
            
            alertView.TobbacobuttonClickCallback = { [weak self] (buttonIndex) in
                guard let self = self else { return }
                
                UserDefaults.setOver18(buttonIndex == 0)
                if buttonIndex == 0 {
                    self.checkActiveCartExistanceAndAddToCart()
                }
            }
        }
    }
    
    func isProductExistInBasket() -> ShoppingBasketItem? {
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
    
    func showOverLimitMsg() {
        let msg = localizedString("msg_limited_stock_start", comment: "") + "\(self.product.availableQuantity)" + localizedString("msg_limited_stock_end", comment: "")
        let title = localizedString("msg_limited_stock_Quantity_title", comment: "")
        ElGrocerUtility.sharedInstance.showTopMessageView(msg ,title, image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
    }
    
    func plusButtonTapHandler() {
        var currentQuantity = 0
        var updatedQuantity = 0
        
        if let item = isProductExistInBasket() {
            currentQuantity = item.count.intValue
            updatedQuantity = item.count.intValue
            
            if product.promotion == true {
                if (currentQuantity >= product.promoProductLimit ?? 0) && (product.promoProductLimit ?? 0 > 0) {
                    // TODO: Show promo over limit message
                    showOverLimitMsg()
                } else {
                    updatedQuantity += 1
                }
            } else {
                updatedQuantity += 1
            }
            
        }
        
        if updatedQuantity != 1 {
            if product.promotion == true {
                if (currentQuantity >= product.promoProductLimit ?? 0) && (product.promoProductLimit ?? 0 > 0) {
                    showOverLimitMsg()
                    self.checkProductExistanceInCartAndUpdateUI()
                } else {
                    addProductToBasket()
                    
                    // ProductQuantiy.checkLimitForDisplayMsgs(selectedProduct: self.product, counter: updatedQuantity)
                }
                
            } else {
                
                if (product.availableQuantity ?? 0 >= 0) && (product.availableQuantity ?? 0 <= currentQuantity) {
                    showOverLimitMsg()
                    return
                }
                
                addProductToBasket()
            }
            
            return
        }
        
        addProductToBasket()
    }
}
