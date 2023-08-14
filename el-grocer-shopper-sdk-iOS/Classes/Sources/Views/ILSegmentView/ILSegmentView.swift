//
//  ILSegmentView.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 07/06/2023.
//

import UIKit
import RxSwift
import RxCocoa

class ILSegmentView: UICollectionView {
    // Fix Me: Need to make this view dependent on generic type instead of category or touple array
    var categories: [CategoryDTO] = []
    var onTapCompletionWithCategory: ((CategoryDTO) -> Void)?
    
    var segmentData: [(imageURL: String, bgColor: UIColor, text: String)] = []
    var onTapCompletion: ((Int) -> Void)?
    var selectionStyle: AWSegementImageViewcell.SelectionStyle = .imageHighlight
    var selectedItemIndex: Int = 0 {
        didSet {
            let scrollPosition: UICollectionView.ScrollPosition = self.scrollDirection == .horizontal
                ? .centeredHorizontally
                : .centeredVertically
            
            self.selectItem(at: IndexPath(row: selectedItemIndex, section: 0), animated: true, scrollPosition: scrollPosition)
        }
    }
    var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    
    convenience init() {
        self.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        commonInit()
    }
    
    convenience init(scrollDirection: UICollectionView.ScrollDirection, selectionStyle: AWSegementImageViewcell.SelectionStyle) {
        self.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        
        self.scrollDirection = scrollDirection
        self.selectionStyle = selectionStyle
        
        commonInit()
        
    }
    
    private func commonInit() {
        self.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = scrollDirection
            layout.itemSize = CGSize(width: 88, height: 88 + 42 )
            layout.minimumInteritemSpacing = 16
            layout.minimumLineSpacing = 16
            let edgeInset:CGFloat =  16
            layout.sectionInset = UIEdgeInsets(top: edgeInset / 2, left: edgeInset, bottom: 0, right: edgeInset)
            return layout
        }()
        
        self.backgroundColor = .clear
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.allowsSelection = true
        self.allowsMultipleSelection = false
        self.semanticContentAttribute = ElGrocerUtility.sharedInstance.isArabicSelected() ? .forceRightToLeft : .forceLeftToRight
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.register(UINib(nibName: "AWSegementImageViewcell", bundle: Bundle.resource), forCellWithReuseIdentifier: kSegmentImageViewCellIdentifier)
        
        self.delegate = self
        self.dataSource = self
    }
    
    func refreshWith(_ data : [(imageURL: String, bgColor: UIColor, text: String)]) {
        self.segmentData = data
        self.reloadData()
        
        self.selectedItemIndex = 0
    }
    
    func refreshWith(_ categories : [CategoryDTO]) {
        let segmentData = categories.map { ($0.coloredImageUrl ?? "", UIColor.white, $0.name ?? "") }
        self.refreshWith(segmentData)
    }
    
    func onTap(completion: @escaping (Int) -> Void) {
        self.onTapCompletion = completion
    }
    
    func onTap(completion: @escaping (CategoryDTO) -> Void) {
        self.onTapCompletionWithCategory = completion
    }
}

extension ILSegmentView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return segmentData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.dequeueReusableCell(withReuseIdentifier: kSegmentImageViewCellIdentifier, for: indexPath) as! AWSegementImageViewcell
        
        let dataItem = self.segmentData[indexPath.row]
        
        cell.configure(imageURL: dataItem.imageURL,
                       bgColor: dataItem.bgColor,
                       text: dataItem.text,
                       selectionStyle: selectionStyle)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        self.onTapCompletion?(indexPath.row)
        self.onTapCompletionWithCategory?(self.categories[indexPath.row])
        return false
    }
    
}

// MARK: Rx Extension
extension Reactive where Base: ILSegmentView {
    var categories: Binder<[CategoryDTO]> {
        return Binder(self.base) { segmentedView, categories in
            segmentedView.categories = categories
            segmentedView.refreshWith(categories)
        }
    }
    
    var selectedItemIndex: Binder<CategoryDTO> {
        return Binder(self.base) { segmentedView, category in
            DispatchQueue.main.async {
                let index = segmentedView.categories.firstIndex(where: { $0.id == category.id }) ?? 0
                segmentedView.selectedItemIndex = index
            }
        }
    }
}
