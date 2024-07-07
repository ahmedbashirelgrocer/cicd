//
//  StoreExclusiveDealsListView.swift
//  
//
//  Created by saboor Khan on 25/05/2024.
//

import UIKit


class StoreExclusiveDealsListView: UIView {
 
    var presenter: StoreExclusiveDealsListViewType!
    private let isArabic: Bool = ElGrocerUtility.sharedInstance.isArabicSelected()
    private var collectionViewHeight: NSLayoutConstraint!
    private var bGView: UIView = UIFactory.makeView()
    private var lblTitle: UILabel = UIFactory.makeLabel()
    private var collectionView = UIFactory.makeCollectionView(
        collectionViewLayout: {
            let layout = ArabicCollectionFlow()
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            layout.sectionInset = UIEdgeInsets.zero
            return layout
        }())
    
    private var cellViewModels: [[StoreExclusiveDealCollectionCellPresenter]] = []
    
    convenience init(presenter: StoreExclusiveDealsListViewType) {
        // Call the designated initializer of the superclass (UIView)
        self.init(frame: .zero)
        // Set the custom value
        self.presenter = presenter
        self.presenter.delegateOutputs =  self
        // Perform additional initialization if needed
        initialSetUp()
        
    }
    
    func initialSetUp() {
        self.addViewsAndSetConstraints()
        self.setupInitialAppearance()
        self.setUpTheme()
        self.registerCollectionCells()
    }
    
    func addViewsAndSetConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = false
        
        self.addSubviews([bGView])
        self.bGView.addSubviews([lblTitle,collectionView])
        
        NSLayoutConstraint.activate([
            // BGView
            bGView.topAnchor.constraint(equalTo: self.topAnchor),
            bGView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bGView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bGView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            //label
            lblTitle.topAnchor.constraint(equalTo: bGView.topAnchor, constant: 0),
            lblTitle.leadingAnchor.constraint(equalTo: bGView.leadingAnchor, constant: 16),
            lblTitle.trailingAnchor.constraint(equalTo: bGView.trailingAnchor, constant: -16),
            lblTitle.heightAnchor.constraint(equalToConstant: 22),
            //CollectionView
            collectionView.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 4),
            collectionView.leadingAnchor.constraint(equalTo: bGView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: bGView.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: bGView.bottomAnchor)
        ])
        
        collectionViewHeight = collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 107 / 343)
        collectionViewHeight.priority = UILayoutPriority(999)
        collectionViewHeight.isActive = true
    }
    
    func setupInitialAppearance() {
        self.lblTitle.text = localizedString("title_available_offers", comment: "")
        self.lblTitle.setHeadLine5MediumDarkStyle()
        self.lblTitle.textAlignment = isArabic ? .right : .left
        // Collection View
        collectionView.clipsToBounds = false
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.semanticContentAttribute = isArabic ? .forceRightToLeft : .forceLeftToRight
    }
    
    func setUpTheme() {
        //bgView
        bGView.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
        // Collection View
        collectionView.backgroundColor = .clear
    }
    
    func registerCollectionCells() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(StoreExclusiveDealCollectionCell.self, forCellWithReuseIdentifier: StoreExclusiveDealCollectionCell.defaultIdentifier)
    }

}

extension StoreExclusiveDealsListView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellVM = cellViewModels[indexPath.section][indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellVM.reusableIdentifier, for: indexPath) as! StoreExclusiveDealCollectionCell
        cell.configure(viewModel: cellVM) // should configure cell view model
        cell.promoTapped = {[weak self] promo in
            guard let promo = promo else {return}
            self?.presenter.delegate?.promoTapHandler(promo: promo)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.presenter.inputs?.promoTapHandler(promo: cellViewModels[indexPath.section][indexPath.row].promo)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? StoreExclusiveDealCollectionCell {
            DispatchQueue.main.async { [weak cell] in
                cell?.lblCodeBgView.addDashedBorderAroundView(color: ApplicationTheme.currentTheme.themeBasePrimaryBlackColor)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat(ScreenSize.SCREEN_WIDTH * 0.7)
        let height = CGFloat(100)
        
        return CGSize(width: width, height: height)
    }
    
}

extension StoreExclusiveDealsListView: StoreExclusiveDealsListViewOutputs {
    func setBanners() {
        print("")
    }
    
    func getCellViewModels(_ value: [[StoreExclusiveDealCollectionCellPresenter]]) {
        self.cellViewModels = value
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
}
