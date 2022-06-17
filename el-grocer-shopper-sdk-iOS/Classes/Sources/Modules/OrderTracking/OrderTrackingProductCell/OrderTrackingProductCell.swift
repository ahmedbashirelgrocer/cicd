//
//  OrderTrackingProductCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 28/03/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

let kOrderTrackingProductCellIdentifier = "OrderTrackingProductCell"
let kOrderTrackingProductCellHeight: CGFloat = 100

class OrderTrackingProductCell: UITableViewCell {
    
    @IBOutlet weak var cartImgView: UIImageView!
    @IBOutlet weak var cartLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var orderProducts:[Product]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setUpViewAppearance()
        
        let itemCellNib = UINib(nibName: "ItemCell", bundle:nil)
        self.collectionView.register(itemCellNib, forCellWithReuseIdentifier: kItemCellIdentifier)
    }
    
    private func setUpViewAppearance() {
        
        self.cartLabel.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        self.cartLabel.textColor = UIColor.black
        self.cartLabel.sizeToFit()
        self.cartLabel.numberOfLines = 1
        
        self.cartImgView.image = UIImage(name: "icBasket")
        self.cartImgView.image = self.cartImgView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.cartImgView.tintColor = UIColor.navigationBarColor()
    }
    
    func configureCell(_ products: Array<Product>){
        
        let totalQuantity = products.count
        let countLabel = totalQuantity == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")
        
        self.cartLabel.text   = String(format: "%d %@",totalQuantity,countLabel)
        
        self.orderProducts = products
        self.collectionView.reloadData()
    }
}

extension OrderTrackingProductCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.orderProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: kItemCellIdentifier, for: indexPath) as! ItemCell
        let product = self.orderProducts[(indexPath as NSIndexPath).row]
        itemCell.configureWithProduct(product)
        return itemCell
    }
}

extension OrderTrackingProductCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width/7, height: self.collectionView.frame.width/7);
    }
}
