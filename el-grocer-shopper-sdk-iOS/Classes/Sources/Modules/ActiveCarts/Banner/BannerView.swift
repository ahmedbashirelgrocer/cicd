//
//  BannerView.swift
//  Adyen
//
//  Created by Rashid Khan on 18/11/2022.
//

import UIKit

struct BannerDTO: Codable { }

class BannerView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
}

extension BannerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let collectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    }
}
