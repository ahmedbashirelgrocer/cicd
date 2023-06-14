//
//  ILSegmentView.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 07/06/2023.
//

import UIKit

class ILSegmentView: UICollectionView {
    
    var segmentData: [(imageURL: String, bgColor: UIColor, text: String)] = []
    var onTapCompletion: ((Int) -> Void)?
    
    convenience init() {
        self.init(frame: .zero, collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 88, height: 88 + 42 )
            layout.minimumInteritemSpacing = 16
            layout.minimumLineSpacing = 16
            let edgeInset:CGFloat =  16
            layout.sectionInset = UIEdgeInsets(top: edgeInset / 2, left: edgeInset, bottom: 0, right: edgeInset)
            return layout
        }())
        
        self.backgroundColor = .clear
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.allowsSelection = true
        self.allowsMultipleSelection = false
        self.semanticContentAttribute = ElGrocerUtility.sharedInstance.isArabicSelected() ? .forceRightToLeft : .forceLeftToRight
        
        self.register(UINib(nibName: "AWSegementImageViewcell", bundle: Bundle.resource), forCellWithReuseIdentifier: kSegmentImageViewCellIdentifier)
        
        self.delegate = self
        self.dataSource = self
    }
    
    func refreshWith(_ data : [(imageURL: String, bgColor: UIColor, text: String)]) {
        self.segmentData = data
        self.reloadData()
        self.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
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
                       text: dataItem.text)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        self.onTapCompletion?(indexPath.row)
        return false
    }
    
}
