//
//  GenericBannersListView.swift
//  
//
//  Created by saboor Khan on 07/05/2024.
//

import UIKit

class GenericBannersListView: UIView {
    static let height = ((ScreenSize.SCREEN_WIDTH - 32) * 107/343) + 48
    
    var presenter: GenericBannersListViewType!
    private var scrollTimer: Timer?
    private let isArabic: Bool = ElGrocerUtility.sharedInstance.isArabicSelected()
    private var collectionViewHeight: NSLayoutConstraint!
    private var bGView: UIView = UIFactory.makeView()
    private var collectionView = UIFactory.makeCollectionView(
        collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            let width = ScreenSize.SCREEN_WIDTH - 32
            layout.itemSize = CGSize(width: width, height: width * 107 / 343)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets.zero
            return layout
        }())
    
    private var cellViewModels: [[GenericBannersCollectionCellPresenter]] = []
    private var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    convenience init(presenter: GenericBannersListViewType) {
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
        self.bGView.addSubviews([collectionView, pageControl])
        
        NSLayoutConstraint.activate([
            // BGView
            bGView.topAnchor.constraint(equalTo: self.topAnchor),
            bGView.leftAnchor.constraint(equalTo: self.leftAnchor),
            bGView.rightAnchor.constraint(equalTo: self.rightAnchor),
            bGView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            //CollectionView
            collectionView.topAnchor.constraint(equalTo: bGView.topAnchor, constant: 16),
            collectionView.leftAnchor.constraint(equalTo: bGView.leftAnchor, constant: 16),
            collectionView.rightAnchor.constraint(equalTo: bGView.rightAnchor, constant: -16),
            // page Controll
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 5),
            pageControl.bottomAnchor.constraint(equalTo: bGView.bottomAnchor, constant: -16),
            pageControl.heightAnchor.constraint(equalToConstant: 10),
            pageControl.centerXAnchor.constraint(equalTo: bGView.centerXAnchor)
        ])
        
        collectionViewHeight = collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 107 / 343)
        collectionViewHeight.priority = UILayoutPriority(999)
        collectionViewHeight.isActive = true
    }
    
    func setupInitialAppearance() {
        // Collection View
        collectionView.clipsToBounds = false
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.semanticContentAttribute = isArabic ? .forceRightToLeft : .forceLeftToRight
        //page control
        pageControl.numberOfPages = 5
        pageControl.currentPage = 0
    }
    
    func setUpTheme() {
        //bgView
        bGView.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
        // Collection View
        collectionView.backgroundColor = .clear
        //page control
        pageControl.backgroundColor = .clear
        pageControl.currentPageIndicatorTintColor = ApplicationTheme.currentTheme.themeBasePrimaryBlackColor
        pageControl.tintColor = ApplicationTheme.currentTheme.tableViewBackgroundColor
        pageControl.pageIndicatorTintColor = ApplicationTheme.currentTheme.tableViewBackgroundColor
    }
    
    func registerCollectionCells() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(GenericBannersCollectionCell.self, forCellWithReuseIdentifier: GenericBannersCollectionCell.defaultIdentifier)
    }
    
    func setPageControl(section: Int) {
        self.pageControl.numberOfPages = cellViewModels[section].count
    }
    
    private func setUpTimer() {
        if let timer = self.scrollTimer {
            timer.invalidate()
            self.scrollTimer  = nil
        }
        self.scrollTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(scrollToNextItem), userInfo: nil, repeats: true)
    }
    // Function to scroll to the next item
    @objc
    func scrollToNextItem() {
        guard isVisible(collectionView: collectionView) else { return }
        
        let visibleItems = collectionView.indexPathsForVisibleItems
        let currentItem = visibleItems.sorted().first

        guard let currentItem = currentItem else { return }
        
        var nextItem: IndexPath
        
        if currentItem.item < collectionView.numberOfItems(inSection: currentItem.section) - 1 {
            nextItem = IndexPath(item: currentItem.item + 1, section: currentItem.section)
        } else {
            nextItem = IndexPath(item: 0, section: currentItem.section)
        }

        collectionView.scrollToItem(at: nextItem, at: .centeredHorizontally, animated: true)
    }

    // Function to check if the collection view is visible
    func isVisible(collectionView: UICollectionView) -> Bool {
        return collectionView.window != nil
    }

}

extension GenericBannersListView: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.setPageControl(section: section)
        return cellViewModels[section].count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellVM = cellViewModels[indexPath.section][indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellVM.reusableIdentifier, for: indexPath) as! GenericBannersCollectionCell
        cell.configure(viewModel: cellVM) // should configure cell view model
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.presenter.inputs?.bannerTapHandler(banner: cellViewModels[indexPath.section][indexPath.row].banner, index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        self.pageControl.currentPage = indexPath.item
    }
    
}

extension GenericBannersListView: GenericBannersListViewOutputs {
    func setBanners() {
        print("")
    }
    
    func getCellViewModels(_ value: [[GenericBannersCollectionCellPresenter]]) {
        self.cellViewModels = value
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.setUpTimer()
        }
    }
}
