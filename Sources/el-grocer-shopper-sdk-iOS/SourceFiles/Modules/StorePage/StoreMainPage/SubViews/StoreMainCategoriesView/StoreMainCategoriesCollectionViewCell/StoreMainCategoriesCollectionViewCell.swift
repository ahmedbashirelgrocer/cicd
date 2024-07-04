//
//  StoreMainCategoriesCollectionViewCell.swift
//  
//
//  Created by saboor Khan on 12/05/2024.
//

import UIKit
import SDWebImage

class StoreMainCategoriesCollectionViewCell: UICollectionViewCell, GenericReusableView {
    
    private var isArabic: Bool = ElGrocerUtility.sharedInstance.isArabicSelected()
    
    private let imageView = UIFactory.makeImageView(contentMode: .scaleToFill)
    private var lblName: UILabel = UIFactory.makeLabel()
    // Initializer for programmatic creation
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupInitialAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupViews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        contentView.addSubviews([imageView, lblName])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            //lblName
            lblName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            lblName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            lblName.leftAnchor.constraint(equalTo: imageView.leftAnchor),
            lblName.rightAnchor.constraint(equalTo: imageView.rightAnchor),
            lblName.heightAnchor.constraint(equalToConstant: 13)
        ])
    }
    func setupInitialAppearance() {
        // title label
        lblName.textAlignment = .center
        lblName.setCaptionTwoSemiboldDarkStyle()
        // image view
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
    }
    
    func configure(viewModel: any ReusableTableViewCellPresenterType) {
        // cast view model with guard and use fatel error.
        
        guard let viewModel = viewModel as? StoreMainCategoriesCollectionViewCellPresenter else {
            fatalError("")
        }
        self.lblName.text = isArabic ? viewModel.category.nameAr : viewModel.category.name
        self.setImage(viewModel.category.photoUrl ?? "")
    }
    
    func setImage(_ url : String? ) {
        if url != nil && url?.range(of: "http") != nil {
            self.imageView.sd_setImage(with: URL(string: url!), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 7), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let self = self else {
                    return
                }
                
                if error != nil {
                    self.imageView.image = productPlaceholderPhoto
                    return
                }
                
                if cacheType == SDImageCacheType.none {
                    self.imageView.image = image
                }
            })
        }
    }
}
