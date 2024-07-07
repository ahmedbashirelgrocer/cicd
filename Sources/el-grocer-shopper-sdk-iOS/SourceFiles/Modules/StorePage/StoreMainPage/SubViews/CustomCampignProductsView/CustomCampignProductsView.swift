//
//  GenericBannersListView.swift
//  
//
//  Created by saboor Khan on 07/05/2024.
//

import UIKit

class CustomCampaignsProductsView: UIView {
    private lazy var containerView = UIFactory.makeView()
    private lazy var imageViewBanner = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var collectionView = UIFactory.makeCollectionView(
        collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: kProductCellWidth, height: kProductCellHeight)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets.zero
            return layout
    }())
    
    private var containerHeightConstraint: NSLayoutConstraint!
    private var bannerViewHeightConstraint: NSLayoutConstraint!
    
    private var presenter: CustomCampignProductsViewPresenterType!
    private var productCellVMs: [ReusableCollectionViewCellViewModelType] = []
    
    convenience init(presenter: CustomCampignProductsViewPresenterType) {
        self.init(frame: .zero)
        self.presenter = presenter
        
        setup()
        setupConstraint()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
    
        addSubview(containerView)
        containerView.addSubviews([imageViewBanner, collectionView])
        
        presenter.outputs = self
        
        imageViewBanner.isUserInteractionEnabled = true
        imageViewBanner.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bannerTapped)))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: ProductCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: ProductCell.defaultIdentifier)
        collectionView.register(UINib(nibName: ViewAllCollectionCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: ViewAllCollectionCell.defaultIdentifier)
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.collectionView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            imageViewBanner.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageViewBanner.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageViewBanner.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: imageViewBanner.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 0)
        containerHeightConstraint.priority = UILayoutPriority(999)
        containerHeightConstraint.isActive = true
        
        bannerViewHeightConstraint = imageViewBanner.heightAnchor.constraint(equalToConstant: 0)
        bannerViewHeightConstraint.priority = UILayoutPriority(999)
        bannerViewHeightConstraint.isActive = true
    }
    
    @objc func bannerTapped(_ sender: UITapGestureRecognizer) {
        presenter.inputs?.imageBannerTapped()
    }
}

extension CustomCampaignsProductsView: CustomCampignProductsViewPresenterOutput {
    func productCellVMsAvailable(_ productCellVMs: [ReusableCollectionViewCellViewModelType]) {
        self.productCellVMs = productCellVMs
        self.collectionView.reloadData()
        
        let bannerHeight = ScreenSize.SCREEN_WIDTH * (136/375)
        let padding = 16.0
        
        bannerViewHeightConstraint.constant = productCellVMs.isEmpty ? 0 : bannerHeight
        containerHeightConstraint.constant = productCellVMs.isEmpty ? 0 : (kProductCellHeight + bannerHeight + padding)
    }
    
    func bannerImageUrl(_ url: URL) {
        imageViewBanner.sd_setImage(with: url)
    }
    
    func backgroundColor(_ color: String?) {
        containerView.backgroundColor = UIColor.colorWithHexString(hexString: color ?? "#EBECEE")
    }
}

extension CustomCampaignsProductsView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productCellVMs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellMV = self.productCellVMs[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellMV.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
        cell.configure(viewModel: cellMV)
        return cell
    }
}
