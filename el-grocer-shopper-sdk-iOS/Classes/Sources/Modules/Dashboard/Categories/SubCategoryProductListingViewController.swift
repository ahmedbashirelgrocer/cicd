//
//  SubCategoryProductListingViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/08/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class SubCategoryProductListingViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var subCategory : SubCategory?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCells()
        
        // Do any additional setup after loading the view.
    }
    
    func registerCells() {
        
        let productCellNib = UINib(nibName: "ProductCell", bundle: Bundle(for: SubCategoriesViewController.self))
        self.collectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.collectionViewLayout = SubcategoryCustomFlowLayout()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SubCategoryProductListingViewController : UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSpacing: CGFloat = 0.0
        var numberOfCell: CGFloat = 2.09
        if self.view.frame.size.width == 320 {
            cellSpacing = 8.0
            numberOfCell = 1.9
        }
        let cellSize = CGSize(width: (collectionView.frame.size.width - cellSpacing * 4) / numberOfCell , height: kProductCellHeight)
        return cellSize
    }
    
    
    
    
}
