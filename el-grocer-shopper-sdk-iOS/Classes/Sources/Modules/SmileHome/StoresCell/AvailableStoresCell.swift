//
//  AvailableStoresCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 12/06/2023.
//

import UIKit

class AvailableStoresCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    
    var groceries: [Grocery] = []
    var onTapCompletion: ((Grocery) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.itemSize = CGSize(width: (ScreenSize.SCREEN_WIDTH - 64)/3,
                                     height: (ScreenSize.SCREEN_WIDTH - 64)/3)
            layout.minimumInteritemSpacing = 15
            layout.minimumLineSpacing = 15
            let edgeInset: CGFloat =  16
            layout.sectionInset = UIEdgeInsets(top: edgeInset / 2, left: edgeInset, bottom: edgeInset / 2, right: edgeInset)
            return layout
        }()
        
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "GroceryCellForHome", bundle: .resource), forCellWithReuseIdentifier: "GroceryCellForHome")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.layoutIfNeeded()
        if self.cellHeight.constant != collectionView.contentSize.height {
            self.cellHeight.constant = collectionView.contentSize.height
            self.invalidateIntrinsicContentSize()
        }
    }
}

extension AvailableStoresCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groceries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroceryCellForHome", for: indexPath) as! GroceryCellForHome
        cell.configure(grocery: groceries[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.onTapCompletion?(self.groceries[indexPath.row])
    }
}

extension AvailableStoresCell {
    @discardableResult
    func configure(groceries: [Grocery]) -> Self {
        self.groceries = groceries
        self.cellHeight.constant = ((ScreenSize.SCREEN_WIDTH - 64)/3 + 16) * ceil(CGFloat(groceries.count) / 3)
        self.collectionView.reloadData()
        self.invalidateIntrinsicContentSize()
        return self
    }
    
    @discardableResult
    func onTap(completion: @escaping (Grocery) -> Void) -> Self  {
        self.onTapCompletion = completion
        return self
    }
}
 
