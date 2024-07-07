//
//  StoreBuyItAgainView.swift
//  
//
//  Created by saboor Khan on 14/05/2024.
//

import UIKit

class StoreBuyItAgainView: UIView {
    
    var presenter: StoreBuyItAgainViewType!
    private let isArabic: Bool = ElGrocerUtility.sharedInstance.isArabicSelected()
    private var productCellSize: CGSize = CGSize()
    private var collectionViewHeight: NSLayoutConstraint!
    private var containerView: UIView = UIFactory.makeView(with: .clear,cornerRadiusStyle: .radius(8), borderColor: ApplicationTheme.currentTheme.borderLightGrayColor, borderWidth: 1.0)
    private var lblTitle: UILabel = UIFactory.makeLabel()
    private var btnViewAll: UIButton = UIFactory.makeButton(with: "btnViewAllArrowForward", in: .resource, cornerRadiusStyle: .radius(12.5))
    private var collectionView = UIFactory.makeCollectionView(
        collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            layout.sectionInset = UIEdgeInsets.zero
            return layout
        }())
    
    private var cellViewModels: [[StoreBuyItAgainCollectionViewCellPresenter]] = []

        
    convenience init(presenter: StoreBuyItAgainViewType) {
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
        
        self.addSubviews([containerView])
        self.containerView.addSubviews([lblTitle,btnViewAll,collectionView])
        
        NSLayoutConstraint.activate([
            // BGView
            containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            //lblTittle
            lblTitle.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            lblTitle.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            lblTitle.trailingAnchor.constraint(equalTo: btnViewAll.leadingAnchor, constant: -16),
            lblTitle.heightAnchor.constraint(equalToConstant: 22),
            // btn View All
            btnViewAll.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            btnViewAll.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            btnViewAll.heightAnchor.constraint(equalToConstant: 25),
            btnViewAll.widthAnchor.constraint(equalToConstant: 100),
            //CollectionView
            collectionView.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
            
        ])
        
        collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeight.priority = UILayoutPriority(999)
        collectionViewHeight.isActive = true
    }
    
    func setupInitialAppearance() {
        // Collection View
        collectionView.clipsToBounds = false
        collectionView.isPagingEnabled = false
        collectionView.isScrollEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.semanticContentAttribute = isArabic ? .forceRightToLeft : .forceLeftToRight
        // title
        lblTitle.text = localizedString("buy_it_again_text", comment: "")
        lblTitle.textAlignment = isArabic ? .right : .left
        //btn view all
        btnViewAll.setTitle(localizedString("lbl_View_All_Cap", comment: ""), for: UIControl.State())
        btnViewAll.addTarget(self, action: #selector(viewAllHandler), for: .touchUpInside)
        adjustImageOnRightSide()
    }
    
    func setUpTheme() {
        //self
        self.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
        // Collection View
        collectionView.backgroundColor = .clear
        //title
        lblTitle.setH4SemiBoldStyle()
        // btn view all
        btnViewAll.setBackgroundColor(ApplicationTheme.currentTheme.buttonthemeBasePrimaryBlackColor, forState: UIControl.State())
        btnViewAll.setBody3SemiBoldWhiteStyle()
    }
    func adjustImageOnRightSide() {
        self.btnViewAll.semanticContentAttribute = isArabic ? .forceLeftToRight : .forceRightToLeft
        if isArabic {
            btnViewAll.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func registerCollectionCells() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(StoreBuyItAgainCollectionViewCell.self, forCellWithReuseIdentifier: StoreBuyItAgainCollectionViewCell.defaultIdentifier)
    }
    
    @objc func viewAllHandler() {
        self.presenter.inputs?.viewAllTapHandler()
    }

}

extension StoreBuyItAgainView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellVM = cellViewModels[indexPath.section][indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellVM.reusableIdentifier, for: indexPath) as! StoreBuyItAgainCollectionViewCell
        cell.configure(viewModel: cellVM) // should configure cell view model
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return productCellSize
    }
    
}

extension StoreBuyItAgainView: StoreBuyItAgainViewOutputs {
    func getCellViewModels(_ value: [[StoreBuyItAgainCollectionViewCellPresenter]]) {
        self.cellViewModels = value
        self.collectionView.reloadData()
    }
    func getCollectionViewHeight(height: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            self.collectionViewHeight.constant = height
            self.collectionView.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }
    func getCollectionCellSize(size: CGSize) {
        self.productCellSize = size
    }
}
