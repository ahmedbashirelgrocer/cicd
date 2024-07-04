//
//  StoreExclusiveDealCollectionCell.swift
//  
//
//  Created by saboor Khan on 25/05/2024.
//

import UIKit
import SDWebImage

class StoreExclusiveDealCollectionCell: UICollectionViewCell, GenericReusableView {
    
    var promo: ExclusiveDealsPromoCode?
    
    private let bgView = UIFactory.makeView(cornerRadiusStyle: .radius(8), borderColor: ApplicationTheme.currentTheme.borderLightGrayColor, borderWidth: 1.0)
    private let imgStore = UIFactory.makeImageView(contentMode: .scaleToFill)
    private let lblGroceryName = UIFactory.makeLabel()
    private let lblPromoTitle = UIFactory.makeLabel()
    let lblCodeBgView = UIFactory.makeView()
    private let lblCode = UIFactory.makeLabel()
    private let btnDetails = UIFactory.makeButton(with: "btnArrowForwardDetails", in: .resource, cornerRadiusStyle: .radius(14.5))
    private let isArabic: Bool = ElGrocerUtility.sharedInstance.isArabicSelected()
    typealias tapped = (_ promo: ExclusiveDealsPromoCode?)-> Void
    var promoTapped: tapped?
    
    // Initializer for programmatic creation
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViewsAndSetConstraints()
        setupInitialAppearance()
        setUpTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(viewModel: any ReusableTableViewCellPresenterType) {
        // cast view model with guard and use fatel error.
        guard let viewModel = viewModel as? StoreExclusiveDealCollectionCellPresenter else {fatalError("data parsing")}
        self.promo = viewModel.promo
        self.imgStore.image = productPlaceholderPhoto
        self.setImage(viewModel.grocery.smallImageUrl ?? "")
        self.lblGroceryName.text = viewModel.grocery.name ?? ""
        self.lblPromoTitle.text = isArabic ? viewModel.promo.title_ar : viewModel.promo.title
        self.lblCode.text = viewModel.promo.code ?? ""
        self.lblCodeBgView.addDashedBorderAroundView(color: ApplicationTheme.currentTheme.themeBasePrimaryBlackColor)
    }
    
    func addViewsAndSetConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.imgStore.translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        contentView.addSubviews([bgView])
        
        bgView.addSubviews([imgStore, lblGroceryName, lblPromoTitle, lblCodeBgView, lblCodeBgView, btnDetails])
        lblCodeBgView.addSubviews([lblCode])
        
        NSLayoutConstraint.activate([
            
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bgView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            bgView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
            imgStore.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 8),
            imgStore.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 8),
            imgStore.heightAnchor.constraint(equalToConstant: 24),
            imgStore.widthAnchor.constraint(equalToConstant: 24),
            
            lblGroceryName.leftAnchor.constraint(equalTo: imgStore.rightAnchor, constant: 8),
            lblGroceryName.centerYAnchor.constraint(equalTo: imgStore.centerYAnchor),
            lblGroceryName.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -8),
            
            lblPromoTitle.topAnchor.constraint(equalTo: imgStore.bottomAnchor, constant: 8),
            lblPromoTitle.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 8),
            lblPromoTitle.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -8),
            
            lblCodeBgView.topAnchor.constraint(equalTo: lblPromoTitle.bottomAnchor, constant: 8),
            lblCodeBgView.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 8),
            lblCodeBgView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -8),
            
            lblCode.topAnchor.constraint(equalTo: lblCodeBgView.topAnchor, constant: 8),
            lblCode.leftAnchor.constraint(equalTo: lblCodeBgView.leftAnchor, constant: 8),
            lblCode.rightAnchor.constraint(equalTo: lblCodeBgView.rightAnchor, constant: -8),
            lblCode.bottomAnchor.constraint(equalTo: lblCodeBgView.bottomAnchor, constant: -8),
            
            btnDetails.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -8),
            btnDetails.centerYAnchor.constraint(equalTo: lblCodeBgView.centerYAnchor),
            btnDetails.heightAnchor.constraint(equalToConstant: 24),
            
            
        ])
    }
    
    func setupInitialAppearance() {
        btnDetails.setTitle("Details", for: UIControl.State())
        btnDetails.semanticContentAttribute = isArabic ? .forceLeftToRight : .forceRightToLeft
        
        btnDetails.addTarget(self, action: #selector(detailsTaped), for: .touchUpInside)
    }
    
    func setUpTheme() {
        
        lblGroceryName.setBody3SemiBoldDarkStyle()
        lblPromoTitle.setCaptionOneRegDarkStyle()
        lblCode.setCaptionOneBoldDarkStyle()
        btnDetails.setCaptionBoldDarkStyle()
        lblCodeBgView.backgroundColor = ApplicationTheme.currentTheme.tableViewBackgroundColor
        
    }
    
    func setImage(_ url : String? ) {
        if url != nil && url?.range(of: "http") != nil {
            self.imgStore.sd_setImage(with: URL(string: url!), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 7), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let self = self else {
                    return
                }
                if error != nil {
                    self.imgStore.image = productPlaceholderPhoto
                    return
                }
                if cacheType == SDImageCacheType.none {
                    self.imgStore.image = image
                }
            })
        }
    }
    
    @objc func detailsTaped() {
        if let promoTapped = self.promoTapped {
            promoTapped(promo)
        }
    }
}
