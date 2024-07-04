//
//  CollectionView.swift
//  iOSApp
//
//  Created by Abbas on 07/06/2021.
//

import UIKit

public class CollectionView: UICollectionView {

    init() {
        super.init(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
        makeUI()
    }

    override init(frame: CGRect = .zero, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    fileprivate func makeUI() {
        self.layer.masksToBounds = true
        self.backgroundColor = .clear
    }
}

public class CollectionViewDynamicContent: CollectionView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
          self.invalidateIntrinsicContentSize()
        }
      }
    
    public override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    public override func reloadData() {
        super.reloadData()
        self.layoutIfNeeded()
    }
}
