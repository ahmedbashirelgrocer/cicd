//
//  ProductCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 17/01/2023.
//

import Foundation
import RxSwift
import RxCocoa

protocol ProductCellViewModelInput {
    var quickAddButtonTapObserver: AnyObserver<Product> { get }
    
}

protocol ProductCellViewModelOutput {
    var grocery: Grocery? { get }
    var product: Observable<ProductDTO?> { get } // remove this one
    var quickAddButtonTap: Observable<Product> { get }
    
    var name: Observable<String?> { get }
    var description: Observable<String?> { get }
    
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
    var quickAddButtonTapObserver: AnyObserver<Product> { self.quickAddButtonTapSubject.asObserver() }
    
    // MARK: Outputs
    var grocery: Grocery?
    var product: Observable<ProductDTO?> { self.productSubject.asObservable() }
    var quickAddButtonTap: Observable<Product> { self.quickAddButtonTapSubject.asObservable() }
    
    var name: Observable<String?> { nameSubject.asObservable() }
    var description: Observable<String?> { descriptionSubject.asObservable() }
    
    // MARK: Subjects
    private var productSubject = BehaviorSubject<ProductDTO?>(value: nil)
    private var quickAddButtonTapSubject = PublishSubject<Product>()
    
    private var nameSubject = BehaviorSubject<String?>(value: nil)
    private var descriptionSubject = BehaviorSubject<String?>(value: nil)
    
    var reusableIdentifier: String { ProductCell.defaultIdentifier }
    
    init(product: ProductDTO, grocery: Grocery?) {
        self.grocery = grocery
        
        nameSubject.onNext(product.name)
        descriptionSubject.onNext(nil)
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
