//
//  AdvertBrandViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 15/04/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

extension AdvertBrandViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class AdvertBrandViewController:  BasketBasicViewController {

    
    @IBOutlet var customCollectionView: UICollectionView!
    lazy var tblList : [Any] = []

    var bannerlinks : BannerLink?
    var brandDataWorkItem:DispatchWorkItem?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
        self.registerCell()
        self.addBackButton()
        self.title = bannerlinks?.bannerLinkTitle
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
       
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
         startApiCallForData()
    }
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func registerCell(){
       
        let productCellNib = UINib(nibName: "ProductCell", bundle: Bundle.resource)
        self.customCollectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.init(top: 5 , left: 5, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        self.customCollectionView.collectionViewLayout = flowLayout
        
    }
      

}

extension AdvertBrandViewController {
    
    
    fileprivate func startApiCallForData() {
        
        self.brandDataWorkItem = DispatchWorkItem {
            for categoryObj in self.grocery?.categories ?? [] {
                if categoryObj is Category {
                    self.getTopSellingProductsFromServer(false, withGroceryId: (self.grocery?.dbID)!, withCategory: categoryObj as? Category, andIsGetTrendingProduct: false)
                    break
                }
            }
        }
        DispatchQueue.global(qos: .userInitiated).async(execute: self.brandDataWorkItem!)
        
        
    }
    
    // MARK: Top Selling
    private func getTopSellingProductsFromServer(_ shouldClearArray:Bool,  withGroceryId gorceryId:String, withCategory category:Category?, andIsGetTrendingProduct isTrending:Bool, isGettingBakset isBasketProducts:Bool = false){
        
    
        let parameters = NSMutableDictionary()
        parameters["limit"] = 20
        parameters["offset"] = 0
        parameters["retailer_id"] = gorceryId
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
        if let banLink = self.bannerlinks {
             parameters["screen_id"]  = banLink.bannerLinkId
        }
        elDebugPrint("activeGrocery : retailer_id API : \(String(describing: parameters["retailer_id"]))")
        ElGrocerApi.sharedInstance.getCustomProductsOfGrocery(parameters) { (result) in
            switch result {
                case .success(let response):
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async { [weak self] in
                        guard let self = self else {return}
                        self.saveResponseDataWithTitle(response: response , andWithGroceryId: gorceryId)
                     }
                case .failure(let error):
                    error.showErrorAlert()
            }
        }
    }
    
    
    // MARK: Top Selling Data
    func saveResponseDataWithTitle( response:NSDictionary, andWithGroceryId gorceryId:String) {
        
        var newProduct = [Product]()
        let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
        context.performAndWait({ () -> Void in
            newProduct = Product.insertOrReplaceAllProductsFromDictionary(response, context:context).products
           elDebugPrint("New ungrouped Products Array Count:",newProduct.count)
            
        })
        self.tblList += newProduct
        DispatchQueue.main.async {
             self.customCollectionView.reloadData()
        }
       

    }

    
    
}

extension AdvertBrandViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tblList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let product = self.tblList[indexPath.row];
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        cell.configureWithProduct(product as! Product, grocery: self.grocery, cellIndex: indexPath)
        return cell
    
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSpacing: CGFloat = 0.0
        var numberOfCell: CGFloat = 2.09
        if self.view.frame.size.width == 320 {
            cellSpacing = 8.0
            numberOfCell = 1.9
        }
        var cellSize = CGSize(width: (collectionView.frame.size.width - cellSpacing * 4) / numberOfCell , height: kProductCellHeight)
        
        
        if cellSize.width > collectionView.frame.width {
            cellSize.width = collectionView.frame.width
        }
        
        if cellSize.height > collectionView.frame.height {
            cellSize.height = collectionView.frame.height
        }
        
        return cellSize
    }

    
    
    
}


