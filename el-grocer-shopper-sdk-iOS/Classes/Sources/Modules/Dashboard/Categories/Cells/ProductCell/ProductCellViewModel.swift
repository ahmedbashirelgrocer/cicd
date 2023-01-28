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
    var quickAddButtonTapObserver: AnyObserver<Void> { get }
    
}

protocol ProductCellViewModelOutput {
    var grocery: Grocery? { get }
    var quickAddButtonTap: Observable<Void> { get }
    
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
    var quickAddButtonTapObserver: AnyObserver<Void> { self.quickAddButtonTapSubject.asObserver() }
    
    // MARK: Outputs
    var grocery: Grocery?
    var quickAddButtonTap: Observable<Void> { self.quickAddButtonTapSubject.asObservable() }
    
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

    
    var reusableIdentifier: String { ProductCell.defaultIdentifier }
    
    private var disposeBag = DisposeBag()
    private var product: ProductDTO
    private let PRODUCT_LIMIT = 3
    
    init(product: ProductDTO, grocery: Grocery?) {
        self.grocery = grocery
        self.product = product
        
        nameSubject.onNext(product.name)
        descriptionSubject.onNext(product.sizeUnit)
        priceSubject.onNext(ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: product.fullPrice ?? 0.0))
        imageUrlSubject.onNext(URL(string: product.imageURL ?? ""))
        isSponsoredSubject.onNext(product.isSponsored ?? false)
        isAvailableSubject.onNext(product.isAvailable ?? true)
        isPublishedSubject.onNext(product.isPublished ?? true)
        
        // displying limited stock view logic
        if let aQuantity = product.availableQuantity, let promoProductLimit = product.promoProductLimit {
            isShowLimittedStockSubject.onNext((aQuantity > 0 && aQuantity < PRODUCT_LIMIT) || (promoProductLimit > 0))
        }
        
        let _ = self.isItemInBasket()
        checkPromotionValidity()
        
        quickAddButtonTapSubject.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
                
            let product = self.product
            
            if product.isPg18 {
                self.showPg18PopupAndAddToCart()
            } else {
                self.addProductToCart()
            }
            
        }).disposed(by: disposeBag)
    }
    
}

private extension ProductCellViewModel {
    func isItemInBasket() -> ShoppingBasketItem? {
        
        if let grocery = grocery, let item = ShoppingBasketItem.checkIfProductIsInBasket(productId: product.id, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            
            self.plusButtonIconNameSubject.onNext("add_product_cell")
            self.minusButtonIconNameSubject.onNext(item.count == 1 ? "delete_product_cell" : "remove_product_cell")
            self.cartButtonTintColorSubject.onNext(ApplicationTheme.currentTheme.themeBasePrimaryColor)
            self.addToCartButtonTypeSubject.onNext(true)
            self.quantitySubject.onNext(ElGrocerUtility.sharedInstance.isArabicSelected() ? "\(item.count.intValue)".changeToArabic() : "\(item.count.intValue)")
            self.isSubtitutedSubject.onNext(item.isSubtituted.boolValue)
            
            return item
        }
        
        self.plusButtonIconNameSubject.onNext("add_product_cell")
        self.minusButtonIconNameSubject.onNext("delete_product_cell")
        self.cartButtonTintColorSubject.onNext(ApplicationTheme.currentTheme.themeBasePrimaryColor)
        self.addToCartButtonTypeSubject.onNext(false)
        self.quantitySubject.onNext("0")
        
        return nil
    }
    
    func checkPromotionValidity() {
        let promotionValidity = ProductQuantiy.checkPromoValidity(product: product)
        
        displayPromotionViewSubject.onNext(promotionValidity.displayPromo)
        
        if promotionValidity.displayPromo {
            if promotionValidity.showPercentage {
                let percentage = getPercentage()
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
    
    func getPercentage() -> Int {
        var percentage : Double = 0
        guard let actualPrice = product.fullPrice, let promoPrice = product.promoPrice else { return 0 }
        
        if actualPrice > 0 {
            let percentageDecimal = ((actualPrice - promoPrice) / actualPrice)
            percentage = percentageDecimal * 100
        }

        return Int(percentage.rounded())
    }
    
    func addProductToCart() {
        if let productDB = self.product.productDB {
            if let item = ShoppingBasketItem.checkIfProductIsInBasket(productDB, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                let count = item.count.intValue + 1
                
                if count != 1 {
                    let updatedQuantity = ElGrocerUtility.sharedInstance.isArabicSelected() ? "\(count)".changeToArabic() : "\(count)".changeToArabic()
                    quantitySubject.onNext(updatedQuantity)
                    return
                }
            }
        }
        
        let isActiveBasket = checkForOtherGroceryActiveBasket(product: self.product)
        
        if isActiveBasket {
            // show active cart popup
        } else {
            addProductInShoppingBasketFromQuickAdd(product: product)
        }
    }
    
    func addProductInShoppingBasketFromQuickAdd(product: ProductDTO) {
        guard let selectedProduct = product.productDB else { return }
        
        var productQuantity = 1
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(selectedProduct, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity += product.count.intValue
            
        }
        
        // Logging Segment Event
        let isNewCart = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext).count == 0
        if isNewCart {
            let cartCreatedEvent = CartCreatedEvent(product: selectedProduct, activeGrocery: self.grocery)
            SegmentAnalyticsEngine.instance.logEvent(event: cartCreatedEvent)
        } else {
            let cartUpdatedEvent = CartUpdatedEvent(grocery: self.grocery, product: selectedProduct, actionType: .added, quantity: productQuantity)
            SegmentAnalyticsEngine.instance.logEvent(event: cartUpdatedEvent)
        }
        
        // ElGrocerUtility.sharedInstance.logAddToCartEventWithProduct(selectedProduct)
        self.updateProductsQuantity(productQuantity, product: self.product)
        MixpanelEventLogger.trackStoreAddItem(product: selectedProduct)
    }
    
    func updateProductsQuantity(_ quantity: Int, product: ProductDTO) {
        guard let selectedProduct = product.productDB else { return }
        
        if quantity == 0 {
            
            //remove product from basket
            ShoppingBasketItem.removeProductFromBasket(selectedProduct, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        } else {
            
            //Add or update item in basket
            ShoppingBasketItem.addOrUpdateProductInBasket(selectedProduct, grocery: self.grocery, brandName: selectedProduct.brandNameEn , quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        isItemInBasket()
        
//        self.refreshBasketIconStatus()
    }
    
    func checkForOtherGroceryActiveBasket(product: ProductDTO) -> Bool {
        var isAnOtherActiveBasket = false
        guard let grocery = grocery else { return false }
        
        //check if other grocery basket is active
        let isOtherGroceryBasketActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive(grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let activeBasketGrocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if isOtherGroceryBasketActive && activeBasketGrocery != nil && activeBasketGrocery!.dbID != String(product.retailerID ?? 0) {
            isAnOtherActiveBasket = true
        }
        
        return isAnOtherActiveBasket
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

// MARK: View + Shimmer layer
public extension UIView {
    var isShimmerOn: Bool {
        get { return shimmerable }
        set { shimmerable = newValue
            newValue ? startShimmeringEffect() : stopShimmeringEffect()
        }
    }

    private var shimmerable: Bool {
        get { return objc_getAssociatedObject(self, "pkey") as? Bool ?? false }
        set { objc_setAssociatedObject(self, "pkey", newValue, objc_AssociationPolicy(rawValue: 1)!) }
    }
    
    private  func removeShimmerLayer(){
        layer.mask = nil
    }
    
    func startShimmeringEffect() {
        let light = UIColor.gray.withAlphaComponent(0.3).cgColor
        let alpha = UIColor.gray.withAlphaComponent(0.1).cgColor
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width:self.bounds.size.width, height: self.bounds.size.height)
        gradient.colors = [light, alpha, alpha, light]
        gradient.startPoint = CGPoint(x: 0.0, y: 1)
        gradient.endPoint = CGPoint(x: 1.0,y: 1)
        gradient.locations = [0.0, 0.3, 0.5, 1]
        
        gradient.cornerRadius = 5
        gradient.masksToBounds = true
        
        self.layer.addSublayer(gradient)
        clipsToBounds = true
        
        let animation = CABasicAnimation(keyPath: "locations")
        
        animation.fromValue = [-1, -0.3, -0.5, 0]
        animation.toValue = [1.0, 1.3, 1.5, 2]
        animation.duration = 1.7
        animation.repeatCount = .infinity
        
        gradient.add(animation, forKey: "shimmer")
    
        addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        
    }
    
    func stopShimmeringEffect() {
        if let gradientLayer =  self.layer.sublayers?.first(where: { (layer) -> Bool in
            return layer.isKind(of: CAGradientLayer.self)
        })
        {
            gradientLayer.removeFromSuperlayer()
        }
        layer.mask = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
        if let gradientLayer =  self.layer.sublayers?.first(where: { (layer) -> Bool in
            return layer.isKind(of: CAGradientLayer.self)
        })
        {
            gradientLayer.frame = CGRect(x:0 , y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        }
    }
}

extension Reactive where Base: UIView {
    public var isShimmerOn: Binder<Bool> {
        return Binder(self.base) { view, shimmering in
            view.isShimmerOn = shimmering
        }
    }
}
