//
//  CarouselProductsView.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 03/07/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

class CarouselProductsView: CustomCollectionView {
    
    var removeProduct: ((ProductCell, Product ,Int )->Void)?
    var addNewProduct: ((ProductCell, Product ,Int )->Void)?
    var ProductLoaded: ((Int)->Void)?
   
    private var carouselWorkItem:DispatchWorkItem?
    
    var carouselproducts:[AnyObject] = [AnyObject]()
    var grocery:Grocery! {
        didSet {
           // self.callForCarouselProduct()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
        
    }

    func nibSetup() {
        // no task here
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerdCell()
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        for _ in 1...10 {
            self.carouselproducts.append("" as AnyObject)
        }
        self.reloadData()
        self.backgroundColor = .clear
    }
    
    func registerdCell () {
        
        let productCellNib = UINib(nibName: "ProductCell", bundle: Bundle.resource)
        self.collectionView!.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        
        
        let productSekeltonCelllNib = UINib(nibName: "ProductSekeltonCell", bundle: Bundle.resource)
        self.collectionView!.register(productSekeltonCelllNib, forCellWithReuseIdentifier: kProductSekeltonCellIdentifier)
       
    }
    
    func configureData(_ carosalProducts : [AnyObject]) {
        
        self.carouselproducts = carosalProducts
        self.reloadData()
    }
    
}
extension CarouselProductsView {
    
    
    func removecarouselCall () {
        if let carouselWork = self.carouselWorkItem {
            carouselWork.cancel()
        }
    }
    
    func callForCarouselProduct(){
        self.removecarouselCall()
        self.carouselWorkItem = DispatchWorkItem {
            self.getCarouselProduct()
        }
        DispatchQueue.global().async(execute: self.carouselWorkItem!)
    }

    fileprivate func getCarouselProduct () {
        
        
        ElGrocerApi.sharedInstance.getCarouselProducts(self.grocery) {[unowned self] (result) -> Void in
            
            switch result {
                
            case .success(let response):
               // elDebugPrint(response)
                self.saveCarouselProductResponseForCategory(response)
            case .failure(let error):
                elDebugPrint(error.localizedMessage)
                self.productsLoaded()
            }
        }
        
    }
    
    func saveCarouselProductResponseForCategory(_ response: NSDictionary) {
        
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        context.performAndWait({ () -> Void in
            let newProduct = Product.insertOrReplaceCarouselFromDictionary(response, context:context)
            self.carouselproducts = [AnyObject]() 
            // if product is already added to basket it will not display in carousel products
            for productData in newProduct {
               
                if let _ = ShoppingBasketItem.checkIfProductIsInBasket(productData , grocery: grocery, context: context) {
                    
                }else{
                  self.carouselproducts.append(productData)
                }
            }
            
            //self.carouselproducts = newProduct
            DispatchQueue.main.async { [unowned self] in
                self.reloadData()
                self.productsLoaded();
            }
        })
    }
    
    fileprivate func productsLoaded() {
        if let clouser = self.ProductLoaded {
            clouser(self.carouselproducts.count)
           // clouser(0)
        }
    }
    
}

extension CarouselProductsView : UICollectionViewDelegate , UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.carouselproducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard self.carouselproducts[indexPath.row] is Product else {
            let productSekeltonCell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductSekeltonCellIdentifier, for: indexPath) as! ProductSekeltonCell
            productSekeltonCell.configureSekeltonCell()
            return productSekeltonCell
        }
        
       let currentProduct = self.carouselproducts[indexPath.row] as? Product
        let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        productCell.configureWithProduct(currentProduct! , grocery: ElGrocerUtility.sharedInstance.activeGrocery, cellIndex: indexPath)
         productCell.delegate = self
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
           // productCell.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
              productCell.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
        //productCell.addToCartCOntainerHeight.constant = CGFloat.leastNormalMagnitude
        productCell.quickAddToCartButton.isUserInteractionEnabled = true
        //productCell.lblAddToCartProductView.isHidden = false
        // productCell.addToContainerView.isHidden = false
       // productCell.lblAddToCartHeight.constant = 0
       // productCell.bottomPossition.constant = 0
        //productCell.addToCartCOntainerHeight.constant = 32
        productCell.tag = indexPath.row
        return productCell
  
    }
    
    func addProductToShoppingItems(product : Product) { }

}
extension CarouselProductsView : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSize = CGSize(width: kProductCellWidth  , height: collectionView.frame.height)
        
        if cellSize.width > collectionView.frame.width {
            cellSize.width = collectionView.frame.width
        }
        
        if cellSize.height > collectionView.frame.height {
            cellSize.height = collectionView.frame.height
        }
        
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 10 , bottom: 0, right: 5)
    }
    
}
extension CarouselProductsView :  ProductCellProtocol {
    
    func productCellOnFavouriteClick(_ productCell: ProductCell, product: Product) {
        self.delegateCall(productCell, product: product)
    }
    
    func productCellOnProductQuickAddButtonClick(_ productCell: ProductCell, product: Product) {
        self.delegateCall(productCell, product: product)
    }
    
    func productCellOnProductQuickRemoveButtonClick(_ productCell: ProductCell, product: Product) {
        if self.removeProduct != nil {
            self.removeProduct!(productCell, product , self.carouselproducts.count - 1)
        }
        //   self.carouselproducts.remove(at: productCell.tag)
        //self.reloadData()
    }
    
    func chooseReplacementWithProduct(_ product: Product) { }
    
    func delegateCall (_ productCell: ProductCell, product: Product) {
        if self.addNewProduct != nil {
            self.addNewProduct!(productCell, product , self.carouselproducts.count - 1)
        }
       // self.carouselproducts.remove(at: productCell.tag)
//        self.reloadData()
    }
    
}

