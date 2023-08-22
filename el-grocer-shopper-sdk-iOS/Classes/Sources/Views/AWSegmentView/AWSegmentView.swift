//
//  AWSegmentView.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 24/04/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol AWSegmentViewProtocol : class {
    
    func subCategorySelectedWithSelectedIndex(_ selectedSegmentIndex:Int)
    func subCategorySelectedWithSelectedCategory(_ selectedSubCategory: SubCategory)
}

extension AWSegmentViewProtocol {
    func subCategorySelectedWithSelectedCategory(_ selectedSegmentIndex: SubCategory) { }
}

enum segmentViewType {
    case editLocation
    case subCategories
}

class ArabicCollectionFlow: UICollectionViewFlowLayout {
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return ElGrocerUtility.sharedInstance.isArabicSelected()
    }
}
class AWSegmentView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var subCategories: [SubCategory] = []
    var segmentTitles: [String]!
    var lastSelection:IndexPath!
    
    weak var segmentDelegate:AWSegmentViewProtocol?
    var segmentViewType : segmentViewType = .editLocation
   
    // MARK: Life cycle
    class func initSegmentView(_ frame: CGRect) -> AWSegmentView {
        
        let view = Bundle.resource.loadNibNamed("AWSegmentView", owner: nil, options: nil)![0] as! AWSegmentView
        view.frame = frame
        view.commonInit()
        return view
    }
    
    func commonInit(){
        
        registerCellForCollection()
        self.delegate = self
        self.dataSource = self
        
//        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
//        if currentLang == "ar" {
//            self.transform = CGAffineTransform(scaleX: -1, y: 1)
//            self.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
//        }
        
        self.lastSelection = IndexPath(row: 0, section: 0)
        
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        let flowLayout:UICollectionViewFlowLayout = ArabicCollectionFlow()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        self.collectionViewLayout = flowLayout
        
        self.semanticContentAttribute = ElGrocerUtility.sharedInstance.isArabicSelected() ? .forceRightToLeft : .forceLeftToRight
    }
    

    func registerCellForCollection() {
        
        let segmentCellNib = UINib(nibName: "AWSegmentViewCell", bundle: Bundle.resource)
        self.register(segmentCellNib, forCellWithReuseIdentifier: kSegmentViewCellIdentifier)
    }
    
    func refreshWith(dataA : [String]) {
        self.segmentTitles = dataA
        ElGrocerUtility.sharedInstance.delay(0.01) {
            self.reloadData()
            self.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    func refreshWith(dataA: [SubCategory]) {
        self.subCategories = dataA
        self.refreshWith(dataA: dataA.map { $0.subCategoryName })
        self.lastSelection = IndexPath(row: 0, section: 0)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard segmentTitles != nil else {return 0}
        return segmentTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            return configureCellForProduct(indexPath)
    }
    
    func configureCellForProduct(_ indexPath:IndexPath) -> AWSegmentViewCell {
        
        let cell = self.dequeueReusableCell(withReuseIdentifier: kSegmentViewCellIdentifier, for: indexPath) as! AWSegmentViewCell
        if segmentTitles.count > indexPath.row {
            let segmentTitle = self.segmentTitles[(indexPath as NSIndexPath).row]
            cell.configareCellWithTitle(segmentTitle, withSelectedState: indexPath == self.lastSelection ? true : false)
        }
//        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
//        if currentLang == "ar" {
//            cell.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
//           //withOutDividerCellIndex = 0
//        }        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let segmentTitle = self.segmentTitles[(indexPath as NSIndexPath).row]
        let titleFont = UIFont.SFProDisplaySemiBoldFont(15.0)
        let cellTopBottomPadding : CGFloat = 10
        
        var cellWidth = titleFont.sizeOfString(segmentTitle, constrainedToHeight: Double(SegmentViewCellHeight)).width
        if segmentViewType == .editLocation{

        }else{
            if indexPath.item == 0{
                cellWidth = 100
            }
//            if cellWidth < 100 {
//                cellWidth = 100
//            }
        }

        var cellSize = CGSize(width: cellWidth + 30, height: SegmentViewCellHeight + cellTopBottomPadding)
        if cellSize.width > collectionView.frame.width {
            cellSize.width = collectionView.frame.width
        }
        
        if cellSize.height > collectionView.frame.height {
            cellSize.height = collectionView.frame.height
        }
        
        return cellSize
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0 , left: 12 , bottom: 0 , right: 16)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
       elDebugPrint("Selected Index:%d",(indexPath as NSIndexPath).row)
        
        if self.lastSelection != indexPath {
            self.lastSelection = indexPath
            self.reloadData()
        }
        
        guard indexPath.row < segmentTitles.count else {
            return
        }
        
        self.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        self.segmentDelegate?.subCategorySelectedWithSelectedIndex((indexPath as NSIndexPath).row)
        
        if self.subCategories.isNotEmpty {
            self.segmentDelegate?.subCategorySelectedWithSelectedCategory(self.subCategories[indexPath.row])
        }
    }
}

// MARK: Rx Extension
extension Reactive where Base: AWSegmentView {
    var subCategories: Binder<[SubCategory]> {
        return Binder(self.base) { view, subCategories in
            view.refreshWith(dataA: subCategories)
        }
    }
    
    var selected: Binder<SubCategory?> {
        return Binder(self.base) { view, subCategory in
            DispatchQueue.main.async {
                if let subCategory = subCategory {
                    let index = view.subCategories.firstIndex(where: { $0.subCategoryId == subCategory.subCategoryId }) ?? 0
                    view.lastSelection = IndexPath(item: index, section: 0)
                }
            }
        }
    }
}
