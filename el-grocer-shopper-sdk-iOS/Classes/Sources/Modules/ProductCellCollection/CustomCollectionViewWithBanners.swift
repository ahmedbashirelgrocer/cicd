//
//  CustomCollectionViewWithBanners.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/06/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import Foundation
class CustomCollectionViewWithBanners: CustomCollectionView {


    var grocery:Grocery?

    var homeFeed:Home? {
        didSet{
            self.resetConstraintsForCollectionView()
            self.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerCollectionCell()
    }

    func registerCollectionCell() {


        let BasketBannerCollectionViewCellNIB = UINib(nibName: "BasketBannerCollectionViewCell", bundle: Bundle(for: SearchViewController.self))
        self.collectionView?.register(BasketBannerCollectionViewCellNIB , forCellWithReuseIdentifier: BasketBannerCollectionViewCellIdentifier)

        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.reloadData()
        self.collectionView?.isScrollEnabled = false
        self.collectionView?.alwaysBounceHorizontal = false
        self.collectionView?.alwaysBounceVertical = false
       

    }

}


extension CustomCollectionViewWithBanners : UICollectionViewDelegate , UICollectionViewDataSource  {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.homeFeed == nil ? 0 : 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BasketBannerCollectionViewCellIdentifier, for: indexPath) as! BasketBannerCollectionViewCell
        cell.grocery = self.grocery
        cell.homeFeed = self.homeFeed
        return cell
    }


}
extension CustomCollectionViewWithBanners : UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // let rowHeight =  (ScreenSize.SCREEN_WIDTH / KBannerRation)
        let cellSize = CGSize(width: ScreenSize.SCREEN_WIDTH  , height: ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner())

        return cellSize
}


}
