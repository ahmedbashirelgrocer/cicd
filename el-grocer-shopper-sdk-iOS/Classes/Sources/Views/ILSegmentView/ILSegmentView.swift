//
//  ILSegmentView.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 07/06/2023.
//

import UIKit
import RxSwift
import RxCocoa

enum viewBorder: String {
    case Left = "borderLeft"
    case Right = "borderRight"
    case Top = "borderTop"
    case Bottom = "borderBottom"
}

class ILSegmentView: UICollectionView {
    // Fix Me: Need to make this view dependent on generic type instead of category or touple array
    var categories: [CategoryDTO] = []
    var onTapCompletionWithCategory: ((CategoryDTO) -> Void)?
    
    var segmentData: [(imageURL: String, bgColor: UIColor, text: String)] = []
    var onTapCompletion: ((Int) -> Void)?
    var selectedItemIndex: Int = 0 {
        didSet {
//            let scrollPosition: UICollectionView.ScrollPosition = self.scrollDirection == .horizontal
//                ? .centeredHorizontally
//                : .centeredVertically
//            
//            self.selectItem(at: IndexPath(row: selectedItemIndex, section: 0), animated: true, scrollPosition: scrollPosition)
        }
    }
    var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    var isCategories: Bool = false
    
    convenience init() {
        self.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        commonInit()
    }
    
    convenience init(scrollDirection: UICollectionView.ScrollDirection, isCategories: Bool = false) {
        self.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        
        self.scrollDirection = scrollDirection
        self.isCategories = isCategories
        
        commonInit()
        
    }
    
    private func commonInit() {
        if self.isCategories {
            self.collectionViewLayout = {
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = scrollDirection
                layout.itemSize = CGSize(width: 72, height: 106)
                layout.minimumInteritemSpacing = 16
                layout.minimumLineSpacing = 16
                let edgeInset:CGFloat =  16
                layout.sectionInset = UIEdgeInsets(top: edgeInset / 2, left: 0, bottom: 0, right: 0)
                return layout
            }()
        } else {
            self.collectionViewLayout = {
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = scrollDirection
                layout.itemSize = CGSize(width: 88, height: 88 )
                layout.minimumInteritemSpacing = 0
                layout.minimumLineSpacing = 0
                let edgeInset:CGFloat =  16
                layout.sectionInset = UIEdgeInsets(top: edgeInset , left: edgeInset, bottom: 0, right: edgeInset)
                return layout
            }()
        }
        
        self.backgroundColor = .clear
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.allowsSelection = true
        self.allowsMultipleSelection = false
        self.semanticContentAttribute = ElGrocerUtility.sharedInstance.isArabicSelected() ? .forceRightToLeft : .forceLeftToRight
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.register(UINib(nibName: "AWSegementImageViewcell", bundle: Bundle.resource), forCellWithReuseIdentifier: kSegmentImageViewCellIdentifier)
        self.register(UINib(nibName: kCategoriesSegmentedImageViewCell, bundle: Bundle.resource), forCellWithReuseIdentifier: kCategoriesSegmentedImageViewCell)
        
        self.delegate = self
        self.dataSource = self
        
//        self.addBottomBorder()
        addBorder(vBorder: .Bottom, color: .red, width: 5)
    }
    
    func addBorder(vBorder: viewBorder, color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.name = vBorder.rawValue
        
        
        
        let bGView = UIView()
        bGView.backgroundColor = .clear
        self.backgroundView = bGView
        
        switch vBorder {
            case .Left:
                border.frame = CGRectMake(0, 0, width, self.frame.size.height)
            case .Right:
                border.frame = CGRectMake(self.frame.size.width - width, 0, width, self.frame.size.height)
            case .Top:
                border.frame = CGRectMake(0, 0, self.frame.size.width, width)
            case .Bottom:
                border.frame = CGRectMake(0, self.frame.size.height - width, self.frame.size.width, width)
        }
        
        self.backgroundView?.layer.addSublayer(border)
    }

        func removeBorder(border: viewBorder) {
            var layerForRemove: CALayer?
            for layer in self.layer.sublayers! {
                if layer.name == border.rawValue {
                    layerForRemove = layer
                }
            }
            if let layer = layerForRemove {
                layer.removeFromSuperlayer()
            }
        }
    
    func refreshWith(_ data : [(imageURL: String, bgColor: UIColor, text: String)]) {
        self.segmentData = data
        self.reloadData()
        
        self.selectedItemIndex = 0
        if segmentData.count > 0 {
            self.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func refreshWith(_ categories : [CategoryDTO]) {
        self.categories = categories
        self.reloadData()
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
        return self.categories.isEmpty ? segmentData.count : categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.categories.isEmpty {
            let cell = self.dequeueReusableCell(withReuseIdentifier: kSegmentImageViewCellIdentifier, for: indexPath) as! AWSegementImageViewcell
            
            let dataItem = self.segmentData[indexPath.row]
            cell.configure(imageURL: dataItem.imageURL,
                           bgColor: dataItem.bgColor,
                           text: dataItem.text, isSelected: indexPath.row == selectedItemIndex)
            return cell
        } else {
            let cell = self.dequeueReusableCell(withReuseIdentifier: kCategoriesSegmentedImageViewCell, for: indexPath) as! AWCategoriesSegmentedImageViewCell
            
            let category = self.categories[indexPath.row]
            cell.configure(imageURL: category.coloredImageUrl ?? "", text: category.name ?? "", isSelected: indexPath.row == selectedItemIndex)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedItemIndex = indexPath.row
        // collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
//        self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.onTapCompletion?(indexPath.row)
        self.onTapCompletionWithCategory?(self.categories[indexPath.row])
        collectionView.reloadData()
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
    
    var selectedCategory: Binder<CategoryDTO?> {
        return Binder(self.base) { segmentedView, category in
            DispatchQueue.main.async {
                if let category = category {
                    let index = segmentedView.categories.firstIndex(where: { $0.id == category.id }) ?? 0
                    segmentedView.selectedItemIndex = index
                }
            }
        }
    }
}
