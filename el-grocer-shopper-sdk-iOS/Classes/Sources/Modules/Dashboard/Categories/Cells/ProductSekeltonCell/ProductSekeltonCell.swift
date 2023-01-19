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
        
        viewModel.outputs.shimmring
            .bind(to: self.productImageView.rx.isShimmerOn)
            .disposed(by: disposeBag)
        
        viewModel.outputs.shimmring
            .bind(to: self.productNameLabel.rx.isShimmerOn)
            .disposed(by: disposeBag)
        
        viewModel.outputs.shimmring
            .bind(to: self.productDescriptionLabel.rx.isShimmerOn)
            .disposed(by: disposeBag)
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
