//
//  StoreBuyItAgainCollectionViewCell.swift
//  
//
//  Created by saboor Khan on 14/05/2024.
//

import UIKit
import SDWebImage

class StoreBuyItAgainCollectionViewCell: UICollectionViewCell, GenericReusableView {
    
    private let imageView = UIFactory.makeImageView(contentMode: .scaleToFill)
    
    
    // Initializer for programmatic creation
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(viewModel: any ReusableTableViewCellPresenterType) {
        // cast view model with guard and use fatel error.
        
        guard let viewModel = viewModel as? StoreBuyItAgainCollectionViewCellPresenter else {
            fatalError()
        }
        self.imageView.image = productPlaceholderPhoto
        self.setImage(viewModel.imageUrl)
    }
    
    func setupViews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        contentView.addSubviews([imageView])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])
    }
    
    func setImage(_ url : String? ) {
        if url != nil && url?.range(of: "http") != nil {
            self.imageView.sd_setImage(with: URL(string: url!), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 7), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let self = self else {
                    return
                }
                if error != nil {
                    self.imageView.image = productPlaceholderPhoto
                }
                if cacheType == SDImageCacheType.none {
                    self.imageView.image = image
                }
            })
        }
    }

}
