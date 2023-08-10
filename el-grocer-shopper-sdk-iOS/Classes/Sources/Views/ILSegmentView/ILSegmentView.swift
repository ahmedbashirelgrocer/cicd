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
    
    var segmentData: [(imageURL: String, bgColor: UIColor, text: String)] = []
    var onTapCompletion: ((Int) -> Void)?
    var selectionStyle: AWSegementImageViewcell.SelectionStyle = .imageHighlight
    var selectedItemIndex: Int = 0 {
        didSet {
            self.selectItem(at: IndexPath(row: selectedItemIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.collectionViewLayout = Self.layoutCollectionView()
        commonInit()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    convenience init() {
        self.init(frame: .zero, collectionViewLayout: Self.layoutCollectionView())
        commonInit()
    }
    
    private static func layoutCollectionView() -> UICollectionViewFlowLayout {
        return {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 88, height: 88 + 42 )
            layout.minimumInteritemSpacing = 16
            layout.minimumLineSpacing = 16
            let edgeInset:CGFloat =  16
            layout.sectionInset = UIEdgeInsets(top: edgeInset / 2, left: edgeInset, bottom: 0, right: edgeInset)
            return layout
        }()
    }
    
    private func commonInit() {
        
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
        return false
    }
    
}

// MARK: Rx Extension
extension Reactive where Base: ILSegmentView {
    var categories: Binder<[CategoryDTO]> {
        return Binder(self.base) { segmentedView, categories in
            segmentedView.refreshWith(categories)
        }
    }
    
    var selectedItemIndex: Binder<Int> {
        return Binder(self.base) { segmentedView, index in
            segmentedView.selectedItemIndex = index
        }
    }
}
