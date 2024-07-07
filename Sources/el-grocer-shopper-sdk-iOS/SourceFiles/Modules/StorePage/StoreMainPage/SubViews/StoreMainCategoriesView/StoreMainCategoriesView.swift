//
//  StoreMainCategoriesView.swift
//  
//
//  Created by saboor Khan on 12/05/2024.
//

import UIKit

class StoreMainCategoriesView: UIView {

    
    var presenter: StoreMainCategoriesViewType!
    private let isArabic: Bool = ElGrocerUtility.sharedInstance.isArabicSelected()
    private var categoryCellSize: CGSize = CGSize()
    private var collectionViewHeight: NSLayoutConstraint!
    private var collectionViewBottomConstraint: NSLayoutConstraint!
    private var bGView: UIView = UIFactory.makeView()
    private var lblTitle: UILabel = UIFactory.makeLabel()
    private var btnHideAllCategories: UIButton = UIFactory.makeButton(with: "arrow_white_up", in: .resource, cornerRadiusStyle: .radius(14.5))
    private var btnViewAllCategories: UIButton = UIFactory.makeButton(with: "MyBasket_Arrow_white", in: .resource, cornerRadiusStyle: .radius(14.5))
    private var opacityViewForCollapseState: UIView = UIFactory.makeView()
    
    private var collectionView = UIFactory.makeCollectionView(
        collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            layout.sectionInset = UIEdgeInsets.zero
            return layout
        }())
    
    private var cellViewModels: [[StoreMainCategoriesCollectionViewCellPresenter]] = []
        
    convenience init(presenter: StoreMainCategoriesViewType) {
        // Call the designated initializer of the superclass (UIView)
        self.init(frame: .zero)
        // Set the custom value
        self.presenter = presenter
        self.presenter.delegateOutputs = self
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
        self.bGView.addSubviews([lblTitle, collectionView, btnHideAllCategories, opacityViewForCollapseState, btnViewAllCategories])
        
        NSLayoutConstraint.activate([
            // BGView
            bGView.topAnchor.constraint(equalTo: self.topAnchor),
            bGView.leftAnchor.constraint(equalTo: self.leftAnchor),
            bGView.rightAnchor.constraint(equalTo: self.rightAnchor),
            bGView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            // lblTitle
            lblTitle.topAnchor.constraint(equalTo: bGView.topAnchor, constant: 16),
            lblTitle.leftAnchor.constraint(equalTo: bGView.leftAnchor, constant: 16),
            lblTitle.rightAnchor.constraint(equalTo: bGView.rightAnchor, constant: -16),
            lblTitle.heightAnchor.constraint(equalToConstant: 24),
            //CollectionView
            collectionView.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 16),
            collectionView.leftAnchor.constraint(equalTo: bGView.leftAnchor, constant: 16),
            collectionView.rightAnchor.constraint(equalTo: bGView.rightAnchor, constant: -16),
            //btnHideAllCategories
            btnHideAllCategories.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            btnHideAllCategories.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor, constant: 0),
            btnHideAllCategories.heightAnchor.constraint(equalToConstant: 29),
            btnHideAllCategories.widthAnchor.constraint(equalToConstant: 190),
            //btnViewAllCategories
            btnViewAllCategories.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor, constant: 0),
            btnViewAllCategories.heightAnchor.constraint(equalToConstant: 29),
            btnViewAllCategories.widthAnchor.constraint(equalToConstant: 190),
            btnViewAllCategories.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -16),
            // opacityViewForCollapseState: opacity view to fade 3rd row when collapsed
            opacityViewForCollapseState.leftAnchor.constraint(equalTo: collectionView.leftAnchor, constant: 0),
            opacityViewForCollapseState.rightAnchor.constraint(equalTo: collectionView.rightAnchor, constant: 0),
            opacityViewForCollapseState.heightAnchor.constraint(equalToConstant: 50),
            opacityViewForCollapseState.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 0)
            
        ])
        
        collectionViewBottomConstraint = collectionView.bottomAnchor.constraint(equalTo: bGView.bottomAnchor, constant: -16)
        collectionViewBottomConstraint.isActive = true
        collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeight.priority = UILayoutPriority(999)
        collectionViewHeight.isActive = true
    }
    
    func setupInitialAppearance() {
        // Collection View
        collectionView.clipsToBounds = true
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.semanticContentAttribute = isArabic ? .forceRightToLeft : .forceLeftToRight
        // title label
        lblTitle.text = localizedString("lbl_Shop_Category", comment: "")
        //button hide All Categories
        btnHideAllCategories.setTitle(localizedString("btn_hide_all_categories", comment: ""), for: UIControl.State())
        btnHideAllCategories.addTarget(self, action: #selector(hideAllCategoriesTapped), for: .touchUpInside)
        //button View All Categories
        btnViewAllCategories.setTitle(localizedString("btn_view_all_categories", comment: ""), for: UIControl.State())
        btnViewAllCategories.addTarget(self, action: #selector(viewAllCategoriesTapped), for: .touchUpInside)
        
        adjustImageOnRightSide()
        
    }
    
    func adjustImageOnRightSide() {
        
        // need to set opposite semantic design requirement
        self.btnHideAllCategories.semanticContentAttribute = isArabic ? .forceLeftToRight : .forceRightToLeft
        self.btnViewAllCategories.semanticContentAttribute =  isArabic ? .forceLeftToRight : .forceRightToLeft
    }
    
    func setUpTheme() {
        //bgView
        bGView.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
        // Collection View
        collectionView.backgroundColor = .clear
        // title label
        lblTitle.setHeadLine5BoldDarkStyle()
        // hideAllCategories button
        btnHideAllCategories.backgroundColor = ApplicationTheme.currentTheme.smilePrimaryPurpleColor
        btnHideAllCategories.setBody3BoldWhiteStyle()
        // ViewAllCategories button
        btnViewAllCategories.backgroundColor = ApplicationTheme.currentTheme.smilePrimaryPurpleColor
        btnViewAllCategories.setBody3BoldWhiteStyle()
        //arabic mode
        lblTitle.textAlignment = isArabic ? .right: .left
        //opacity view
        opacityViewForCollapseState.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
        opacityViewForCollapseState.alpha = 0.35
    }
    
    func registerCollectionCells() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(StoreMainCategoriesCollectionViewCell.self, forCellWithReuseIdentifier: StoreMainCategoriesCollectionViewCell.defaultIdentifier)
    }
    
    @objc func hideAllCategoriesTapped() {
        self.presenter.inputs?.viewHideAllCategories(isExpanded: false)
    }
    
    @objc func viewAllCategoriesTapped() {
        self.presenter.inputs?.viewHideAllCategories(isExpanded: true)
    }

}

extension StoreMainCategoriesView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellVM = cellViewModels[indexPath.section][indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellVM.reusableIdentifier, for: indexPath) as! StoreMainCategoriesCollectionViewCell
        cell.configure(viewModel: cellVM) // should configure cell view model
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.presenter.inputs?.categoryTapHandler(category: cellViewModels[indexPath.section][indexPath.row].category)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let category = cellViewModels[indexPath.section][indexPath.row].category
        let width = (category.customPage != nil && indexPath.row == 0) ? (self.categoryCellSize.width * 2) + 8 : self.categoryCellSize.width
        return CGSize(width: width , height: self.categoryCellSize.height)
        
    }
    
}

extension StoreMainCategoriesView: StoreMainCategoriesViewOutputs {
    func getCellViewModels(_ value: [[StoreMainCategoriesCollectionViewCellPresenter]]) {
        self.cellViewModels = value
        self.collectionView.reloadData()
    }
    
    func getCollectionViewHeight(height: CGFloat) {
            self.collectionViewHeight.constant = height
            self.collectionView.layoutIfNeeded()
            self.layoutIfNeeded()
    }
    
    func getCollectionCellSize(size: CGSize) {
        self.categoryCellSize = size
    }
    func getbuttonState(btnViewAllVisible: Bool, btnHideAllVisible: Bool) {
        
        self.btnViewAllCategories.isHidden = !btnViewAllVisible
        self.opacityViewForCollapseState.isHidden = !btnViewAllVisible
        self.collectionViewBottomConstraint.constant = btnHideAllVisible ? -61 : -16
        self.btnHideAllCategories.isHidden = !btnHideAllVisible
        self.layoutIfNeeded()
    }
}
