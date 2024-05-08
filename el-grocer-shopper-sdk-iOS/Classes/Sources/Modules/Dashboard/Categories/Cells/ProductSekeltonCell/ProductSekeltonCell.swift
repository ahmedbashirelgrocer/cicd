//
//  ProductSekeltonCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 21/06/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
import Shimmer
import RxSwift
import RxCocoa

let kProductSekeltonCellIdentifier = "ProductSekeltonCell"

protocol ProductSekeltonCellViewModelInput {
}

protocol ProductSekeltonCellViewModelOutput {
    var shimmring: Observable<Bool> { get }
}

protocol ProductSekeltonCellViewModelType: ProductSekeltonCellViewModelInput, ProductSekeltonCellViewModelOutput {
    var inputs: ProductSekeltonCellViewModelInput { get }
    var outputs: ProductSekeltonCellViewModelOutput { get }
}

extension ProductSekeltonCellViewModelType {
    var inputs: ProductSekeltonCellViewModelInput { self }
    var outputs: ProductSekeltonCellViewModelOutput { self }
}

class ProductSekeltonCellViewModel: ProductSekeltonCellViewModelType, ReusableCollectionViewCellViewModelType {
    var reusableIdentifier: String { ProductSekeltonCell.defaultIdentifier }
    
    // MARK: Outputs
    var shimmring: Observable<Bool> { self.shimmringSubject.asObservable() }
    
    // MARK: Subjects
    var shimmringSubject = BehaviorSubject<Bool>(value: false)
    
    init() {
        shimmringSubject.onNext(true)
    }
    
}

class ProductSekeltonCell: RxUICollectionViewCell {
    
    @IBOutlet weak var productContainer: UIView!
    @IBOutlet weak var productView: UIView!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var imageShimmerView: FBShimmeringView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productNameShimmerView: FBShimmeringView!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productPriceShimmerView: FBShimmeringView!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productDescriptionShimmerView: FBShimmeringView!
    
    @IBOutlet weak var addToCantainerView: UIView!
    
    var placeholderPhoto = UIImage(name: "product_placeholder")!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.productContainer.layer.cornerRadius = 5
        self.productContainer.layer.masksToBounds = true
    }
    
    override func configure(viewModel: Any) {
        let viewModel = viewModel as! ProductSekeltonCellViewModelType
        
        self.imageShimmerView.contentView = self.productImageView
        self.imageShimmerView.isShimmering = true
        
        self.productNameShimmerView.contentView = self.productNameLabel
        self.productNameShimmerView.isShimmering = true
        
        self.productPriceShimmerView.contentView = self.productPriceLabel
        self.productPriceShimmerView.isShimmering = true
        
        self.productDescriptionShimmerView.contentView = self.productDescriptionLabel
        self.productDescriptionShimmerView.isShimmering = true
    }
    
    func configureSekeltonCell() {
        
        
        self.imageShimmerView.contentView = self.productImageView
        self.imageShimmerView.isShimmering = true
        
        self.productNameShimmerView.contentView = self.productNameLabel
        self.productNameShimmerView.isShimmering = true
        
        self.productPriceShimmerView.contentView = self.productPriceLabel
        self.productPriceShimmerView.isShimmering = true
        
        self.productDescriptionShimmerView.contentView = self.productDescriptionLabel
        self.productDescriptionShimmerView.isShimmering = true
        
        
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
        let light = UIColor.colorWithHexString(hexString: "#ECEDF4").withAlphaComponent(0.9).cgColor
        let alpha = UIColor.colorWithHexString(hexString: "#ECEDF4").withAlphaComponent(0.2).cgColor
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
