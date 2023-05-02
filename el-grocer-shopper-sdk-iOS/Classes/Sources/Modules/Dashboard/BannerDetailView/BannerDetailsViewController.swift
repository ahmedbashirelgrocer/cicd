//
//  BannerDetailsViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 13/06/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

class BannerDetailsViewController: BasketBasicViewController,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var titleString = localizedString("featured_products_title", comment: "")
    var productsArray = [Product]()
    
    var selectedProduct:Product!
    var bannerLink: BannerLink!
    
    
    
    var currentLoadedPage = 0
    var currentOffset = 0
    var currentLimit = 25
    
    var isFirst = true
    var isMoreProducts = false
    var isGettingProducts = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = titleString
        addBackButton()
        
        self.registerCellsForCollection()
        
        self.basketIconOverlay?.grocery = self.grocery
        self.refreshBasketIconStatus()
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        self.getProductsForSelectedBanner((self.grocery?.dbID)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func registerCellsForCollection() {
        let productCellNib = UINib(nibName: "ProductCell", bundle: .resource)
        self.collectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        
        self.collectionView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor

        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.init(top: 5 , left: 5, bottom: 10 , right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return configureCellForSearchedProducts(indexPath)
    }
    
    func configureCellForSearchedProducts(_ indexPath:IndexPath) -> ProductCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        
        let product = self.productsArray[(indexPath as NSIndexPath).row]
        cell.configureWithProduct(product, grocery: self.grocery, cellIndex: indexPath)
        cell.delegate = self
        return cell
    }
    
    //MARK: - CollectionView Layout Delegate Methods (Required)
    //** Size for the cells in Layout */
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let cellSpacing: CGFloat = 0.0
//        let cellSize = CGSize(width: (collectionView.frame.size.width - cellSpacing * 4) / 3, height: kProductCellHeight)
//        return cellSize
//    }

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


    
    // MARK: Product quick add
    
    override func addProductToBasketFromQuickAdd(_ product: Product) {
        
        ElGrocerEventsLogger.sharedInstance.addToCart(product: product)
        
//        ElGrocerUtility.sharedInstance.createBranchLinkForProduct(product)
//        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("add_item_to_cart")
//
//        ElGrocerUtility.sharedInstance.logAddToCartEventWithProduct(product)
        
        var productQuantity = 1
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity += product.count.intValue
        }
        
        self.selectedProduct = product
        self.updateProductQuantity(productQuantity)
    }
    
    override func removeProductToBasketFromQuickRemove(_ product: Product){
        
        var productQuantity = 0
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity = product.count.intValue - 1
        }
        
        if productQuantity < 0 {return}
        
        self.selectedProduct = product
        self.updateProductQuantity(productQuantity)
    }
    
    func updateProductQuantity(_ quantity: Int) {
        
        if quantity == 0 {
            
            //remove product from basket
            ShoppingBasketItem.removeProductFromBasket(self.selectedProduct, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        } else {
            
            //Add or update item in basket
            ShoppingBasketItem.addOrUpdateProductInBasket(self.selectedProduct, grocery: self.grocery, brandName: nil, quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        
        //reload this product cell
        let index = self.productsArray.firstIndex(of: self.selectedProduct)
        if let notNilIndex = index {
            if (self.collectionView.indexPathsForVisibleItems.contains(IndexPath(row: notNilIndex, section: 0))) {
                 self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
            }
        }
        
        self.basketIconOverlay?.grocery = self.grocery
        self.refreshBasketIconStatus()
    }
    
    // MARK: Banner Products
    private func getProductsForSelectedBanner(_ gorceryId:String){
        
        self.isGettingProducts = true
        self.currentOffset = self.currentOffset + self.currentLimit
        
        currentLoadedPage = isFirst ? 0 : currentLoadedPage + 1
        self.currentOffset = self.currentLimit*currentLoadedPage
        
        let parameters = NSMutableDictionary()
        
        parameters["limit"] = self.currentLimit
        parameters["offset"] = self.currentOffset
        parameters["retailer_id"] = gorceryId
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
        
        if self.bannerLink.bannerbrandId > 0 {
            parameters["brand_id"] = self.bannerLink.bannerbrandId
        }
        
        if self.bannerLink.bannerSubCategoryId > 0 {
            parameters["category_id"] = self.bannerLink.bannerSubCategoryId
        }
       
        
        ElGrocerApi.sharedInstance.getProductsOfBannerFromServer(parameters) { (result) in
            
            switch result {
                
            case .success(let response):
                self.saveResponseData(response)
                
            case .failure(let error):
                SpinnerView.hideSpinnerView()
                error.showErrorAlert()
            }
        }
    }
    
    // MARK: Data
    func saveResponseData(_ responseObject:NSDictionary) {
        
        let dataDict = responseObject["data"] as! NSDictionary
        isMoreProducts = dataDict["next"] as! Bool
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
            context.performAndWait({ () -> Void in
                let newProduct = Product.insertOrReplaceAllProductsFromDictionary(responseObject, context:context)
                self.productsArray += newProduct.products
            })
            
           elDebugPrint("Products Array Count:%@",self.productsArray.count)
            
            DispatchQueue.main.async(execute: {
                self.isGettingProducts = false
                self.collectionView.reloadData()
                SpinnerView.hideSpinnerView()
            })
        }
    }
    
    //MARK: - Scrolling
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //load more only if we are searching
        let kLoadingDistance = 2 * kProductCellHeight + 8
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        if y + kLoadingDistance > scrollView.contentSize.height && self.isGettingProducts == false && self.isMoreProducts == true {
            self.isFirst = false
            self.getProductsForSelectedBanner((self.grocery?.dbID)!)
        }
    }
}
