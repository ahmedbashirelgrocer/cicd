//
//  FavouritesViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 16.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FirebaseCrashlytics

enum FavouriteTab : Int {
    
    case groceries = 0
    case products = 1
}

class FavouritesViewController : BasketBasicViewController, UICollectionViewDataSource, UICollectionViewDelegate, GroceryCollectionCellProtocol, GroceriesAndProductsCollectionViewLayoutDelegate {
    
    @IBOutlet weak var groceriesButton: UIButton!
    @IBOutlet weak var productsButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentTabMode:FavouriteTab = .products
    
    var groceries:[Grocery] = [Grocery]()
    var products:[Product] = [Product]()
    
    var selectedProduct:Product!
    
    var addingToBasketInfoAlertShown: Bool = false
    
    // MARK: Life cycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
         self.menuItem = MenuItem(title: localizedString("setting_favourites", comment: ""))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localizedString("setting_favourites", comment: "")
        self.view.backgroundColor = ApplicationTheme.currentTheme.viewPrimaryBGColor
        
        addEmptyView()
        
        setUpTabsTexts()
        setButtonAsActiveTab(self.productsButton)
        setButtonAsPassiveTab(self.groceriesButton)
        
        registerCellsForCollection()
        reloadData()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        
        updateFavourites()
        
        self.addingToBasketInfoAlertShown = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsFavouritesScreen)
        FireBaseEventsLogger.setScreenName( kGoogleAnalyticsFavouritesScreen , screenClass: String(describing: self.classForCoder))
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_favourite_screen")
    }
    
    func updateFavourites() {
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        
        let updateGroup = DispatchGroup()
        
        updateGroup.enter()
        ElGrocerApi.sharedInstance.getAllFavouritesProducts { (result:Bool, responseObject:NSDictionary?) -> Void in
            
            if result {
                
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
                    context.performAndWait({ () -> Void in
                        
                        Product.insertOrReplaceFavouriteProducts(responseObject!, context: context)
                        DatabaseHelper.sharedInstance.saveDatabase()
                    })
                    
                    DispatchQueue.main.async {
                        updateGroup.leave()
                    }
                }
            } else {
                updateGroup.leave()
            }
        }
        
        updateGroup.enter()
        ElGrocerApi.sharedInstance.getAllFavouritesGroceries { (result:Bool, responseObject:NSDictionary?) -> Void in
            
            if result {
                
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
                    context.performAndWait({ () -> Void in
                        _ = Grocery.insertOrReplaceGroceriesFromDictionary(responseObject!, context: context)
                        DatabaseHelper.sharedInstance.saveDatabase()
                    })
                    
                    DispatchQueue.main.async {
                        updateGroup.leave()
                    }
                }
            } else {
               updateGroup.leave()
            }
        }
        
        updateGroup.notify(queue: DispatchQueue.main) {
            
            DatabaseHelper.sharedInstance.saveDatabase()
            self.reloadData()
            SpinnerView.hideSpinnerView()
            //self.performSelector(#selector(FavouritesViewController.reloadData), withObject: nil, afterDelay: 1.0)
        }
    }
    
    func reloadData() {
        
        let layout = self.collectionView.collectionViewLayout as! GroceriesAndProductsCollectionViewLayout
        
        if self.currentTabMode == .groceries {
            
            self.groceries = Grocery.getAllFavouritesGroceries(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            layout.layoutMode = .grocery
            
        } else {
            
            self.products = Product.getAllFavouritesProducts(true, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            layout.layoutMode = .product
        }
        
        addEmptyView()
        
        self.collectionView.reloadData()
    }
    
    // MARK: Appearance
    
    override func addEmptyView() {
        
        self.emptyView?.removeFromSuperview()
        
        if self.currentTabMode == .groceries {
            
            self.emptyView = EmptyView.createAndAddEmptyView(localizedString("empty_view_favourites_grocery_title", comment: ""), description: localizedString("empty_view_favourites_grocery_description", comment: ""), addToView: self.view)
            self.emptyView?.isHidden = (self.groceries.count > 0)
            
        } else {
            
            self.emptyView = EmptyView.createAndAddEmptyView(localizedString("empty_view_favourites_product_title", comment: ""), description: localizedString("empty_view_favourites_product_description", comment: ""), addToView: self.view)
            self.emptyView?.isHidden = (self.products.count > 0)
        }
    }
    
    func setUpTabsTexts() {
        
        self.groceriesButton.setTitle(localizedString("favourites_groceries_tab", comment: ""), for: UIControl.State())
        self.productsButton.setTitle(localizedString("favourites_products_tab", comment: ""), for: UIControl.State())

        self.groceriesButton.titleLabel?.font = UIFont.bookFont(16.0)
        self.productsButton.titleLabel?.font = UIFont.bookFont(16.0)
    }
    
    func setButtonAsActiveTab(_ button:UIButton) {
        
        button.backgroundColor = UIColor.white
        button.setTitleColor(ApplicationTheme.currentTheme.buttonWithBorderTextColor, for: UIControl.State())
    }
    
    func setButtonAsPassiveTab(_ button:UIButton) {
        
        button.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
        button.setTitleColor(UIColor.white, for: UIControl.State())
    }
    
    // MARK: Actions
    
    @IBAction func onGroceriesButtonClick(_ sender: AnyObject) {
        
        if self.currentTabMode != .groceries {
            
            self.currentTabMode = .groceries
            setButtonAsActiveTab(self.groceriesButton)
            setButtonAsPassiveTab(self.productsButton)
            
            self.reloadData()
        }
    }
    
    @IBAction func onProductsButtonClick(_ sender: AnyObject) {
        
        if self.currentTabMode != .products {
            
            self.currentTabMode = .products
            setButtonAsActiveTab(self.productsButton)
            setButtonAsPassiveTab(self.groceriesButton)
            
            self.reloadData()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func registerCellsForCollection() {
        
        let groceryCellNib = UINib(nibName: "GroceryCollectionCell", bundle: Bundle.resource)
        let productCellNib = UINib(nibName: "ProductCell", bundle: Bundle.resource)
        
        self.collectionView.register(groceryCellNib, forCellWithReuseIdentifier: kGroceryCollectionCellIdentifier)
        self.collectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.currentTabMode == .groceries ? self.groceries.count : self.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.currentTabMode == .groceries {
            
            return configureCellForGrocery(indexPath)
            
        } else {
            
            return configureCellForProduct(indexPath)
        }
    }
    
    func configureCellForGrocery(_ indexPath:IndexPath) -> GroceryCollectionCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kGroceryCollectionCellIdentifier, for: indexPath) as! GroceryCollectionCell
        let grocery = self.groceries[(indexPath as NSIndexPath).row]
        
        cell.configureWithGrocery(grocery)
        cell.delegate = self
        
        return cell
    }
    
    func configureCellForProduct(_ indexPath:IndexPath) -> ProductCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        let product = self.products[(indexPath as NSIndexPath).row]
        
        cell.configureWithProduct(product, grocery:nil, cellIndex: indexPath)
        cell.delegate = self
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.currentTabMode == .products {
            
            //show product details view
            self.selectedProduct = self.products[(indexPath as NSIndexPath).row]
           // ProductDetailsView.showWithProduct(self.selectedProduct, shoppingItem:nil, grocery: nil, delegate: self)
            
        } else {
            
            let selectedGrocery = self.groceries[(indexPath as NSIndexPath).row]
            
            if (selectedGrocery.isInRange.boolValue && (selectedGrocery.isOpen.boolValue && Int(selectedGrocery.deliveryTypeId!) != 1) || (selectedGrocery.isSchedule.boolValue && Int(selectedGrocery.deliveryTypeId!) != 0)) {
                
                //go to grocery categories screen
                var controllersStacks = [UIViewController]()
                let categoriesController = ElGrocerViewControllers.mainCategoriesViewController()
                categoriesController.grocery = selectedGrocery
                ElGrocerUtility.sharedInstance.activeGrocery = selectedGrocery
                controllersStacks.append(categoriesController)
                self.navigationController?.slideMenuViewController?.contentController.viewControllers = controllersStacks
                ElGrocerUtility.sharedInstance.isHomeSelected = true
                
            }else{
                
                if !selectedGrocery.isInRange.boolValue {
                    
                   elDebugPrint("Grocery is not in range of delivery Area.")
                    ElGrocerAlertView.createAlert(localizedString("store_notinrange_alert_title", comment: ""),
                                                  description:localizedString("store_notinrange_alert_message", comment: ""),
                                                  positiveButton: localizedString("store_notinrange_alert_button", comment: ""),
                                                  negativeButton: nil, buttonClickCallback: nil).show()
                    
                    
                }else{
                
                   elDebugPrint("Currently Grocery is closed.")
                    ElGrocerAlertView.createAlert(localizedString("store_close_alert_title", comment: ""),
                                                  description:localizedString("store_close_alert_message", comment: ""),
                                                  positiveButton: localizedString("store_close_alert_button", comment: ""),
                                                  negativeButton: nil, buttonClickCallback: nil).show()
                }
            }
        }
    }
    
    // MARK: ProductDetailsViewProtocol
    
    override func productDetailsViewProtocolDidTouchDoneButton(_ productDetailsView:ProductDetailsView, product:Product, quantity:Int){
        
        self.selectedProduct = product
        
        if !productDetailsView.product.isFavourite.boolValue {
            
            if let index = self.products.firstIndex(of: productDetailsView.product) {
                
                self.collectionView.performBatchUpdates({ () -> Void in
                    
                    let indexPath = IndexPath(row: index, section: 0)
                    self.collectionView.deleteItems(at: [indexPath])
                    
                    self.products.remove(at: index)
                    
                }, completion: nil)
            }
        }
        
        if quantity == 0 {
            
            //remove product from basket
            ShoppingBasketItem.removeProductFromBasket(self.selectedProduct, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        } else {
            
            //Add or update item in basket
            ShoppingBasketItem.addOrUpdateProductInBasket(self.selectedProduct, grocery: nil, brandName: nil, quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            //inform user that product was added to basket
            if !self.addingToBasketInfoAlertShown {
                
                self.addingToBasketInfoAlertShown = true
                
                ElGrocerAlertView.createAlert(localizedString("favourites_adding_to_basket_alert_title", comment: ""),
                    description: localizedString("favourites_adding_to_basket_alert_description", comment: ""),
                    positiveButton: localizedString("favourites_adding_to_basket_alert_button", comment: ""),
                    negativeButton: nil, buttonClickCallback: nil).show()
            }
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        
        productDetailsView.hideProductView()
        
        //reload this product cell
        let index = self.products.firstIndex(of: self.selectedProduct)
        if let notNilIndex = index {
            if (self.collectionView.indexPathsForVisibleItems.contains(IndexPath(row: notNilIndex, section: 0))) {
                self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
            }
         //   self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
        }
        
        refreshBasketIconStatus()
        
        super.productDetailsViewProtocolDidTouchDoneButton(productDetailsView, product: product, quantity: quantity)
    }
    
    override func productDetailsViewProtocolDidTouchFavourite(_ productDetailsView: ProductDetailsView, product: Product) {
        super.productDetailsViewProtocolDidTouchFavourite(productDetailsView, product: product)
        
        self.addEmptyView()
    }
    
    // MARK: GroceriesAndProductsCollectionViewLayoutDelegate
    
    func groceriesAndProductsCollectionViewLayoutSizeForGroceryItem(_ layout: GroceriesAndProductsCollectionViewLayout, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: kGroceryCollectionCellHeight)
    }
    
    func groceriesAndProductsCollectionViewLayoutSizeForProductItem(_ layout: GroceriesAndProductsCollectionViewLayout, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        
        let cellSpacing: CGFloat = 0.25
        
        return CGSize(width: (collectionView.frame.size.width - cellSpacing * 3) / 2, height: kProductCellHeight)
    }
    
    // MARK: ProductCellProtocol
    
    override func productCellOnFavouriteClick(_ productCell: ProductCell, product: Product) {
        
        Product.markSimilarProductsAsFavourite(product, markAsFavourite: false, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        self.collectionView.performBatchUpdates({ () -> Void in
            
            let indexPath = self.collectionView.indexPath(for: productCell)!
            self.collectionView.deleteItems(at: [indexPath])
            
            if let index = self.products.firstIndex(of: product) {
                self.products.remove(at: index)
                
                self.addEmptyView()
            }
            
        }, completion: nil)
        
        // remove product from favourites
        ElGrocerApi.sharedInstance.deleteProductFromFavourites(product, completionHandler: { (result) -> Void in
            
        })
    }
    
    // MARK: Product quick add

    override func addProductToBasketFromQuickAdd(_ product: Product) {
        
       // ElGrocerEventsLogger.sharedInstance.addToCart(product: product)
        
        var productQuantity = 1
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity += product.count.intValue
        }
        
        ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: self.grocery, brandName: nil, quantity: productQuantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        DatabaseHelper.sharedInstance.saveDatabase()
        
        //reload this product cell
        let products = self.products
        let index = products.index(of: product)
        if let notNilIndex = index {
            if (self.collectionView.indexPathsForVisibleItems.contains(IndexPath(row: notNilIndex, section: 0))) {
                self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
            }
           // self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
        }
        
        refreshBasketIconStatus()
        
        //schedule notification
        let SDKManager: SDKManagerType! = sdkManager
        SDKManager.scheduleAbandonedBasketNotification()
        //Hunain 27Dec16
        SDKManager.scheduleAbandonedBasketNotificationAfter24Hour()
        SDKManager.scheduleAbandonedBasketNotificationAfter72Hour()
    }
    
    // MARK: GroceryCollectionCellProtocol
    
    func groceryCollectionCellDidTouchFavourite(_ groceryCell: GroceryCollectionCell, grocery: Grocery) {
        
        self.collectionView.performBatchUpdates({ () -> Void in
            
            let indexPath = self.collectionView.indexPath(for: groceryCell)!
            self.collectionView.deleteItems(at: [indexPath])
            
            if let index = self.groceries.firstIndex(of: grocery) {
                self.groceries.remove(at: index)
                
                self.addEmptyView()
            }
            
        }, completion: nil)
        
        ElGrocerApi.sharedInstance.deleteGroceryFromFavourites(grocery, completionHandler: { (result:Bool) -> Void in
            
        })
    }
    
    func groceryCollectionCellDidTouchScore(_ groceryCell: GroceryCollectionCell, grocery: Grocery) {
        
        let groceryReviewsController = ElGrocerViewControllers.groceryReviewsViewController()
        groceryReviewsController.grocery = grocery
        
        self.navigationController?.pushViewController(groceryReviewsController, animated: true)
    }
    
    // MARK: BasketIconOverlayViewProtocol
    
    override func basketIconOverlayViewDidTouchBasket(_ basketIconOverlayView: BasketIconOverlayView) {
        
       /* self.shoppingBasketView = ShoppingBasketView.showShoppingBasket(self, shouldShowGroceryActiveBasket: false, selectedGroceryForItems: nil, notAvailableProducts: nil, availableProductsPrices: nil)*/
        
        let basketController = ElGrocerViewControllers.myBasketViewController()
        basketController.showShoppingBasket(delegate: self, shouldShowGroceryActiveBasket: false, selectedGroceryForItems: nil, notAvailableProducts: nil, availableProductsPrices: nil)
        ElGrocerUtility.sharedInstance.isFromFavourite = true
        self.navigationController?.pushViewController(basketController, animated: true)
    }
    
    // MARK: ShoppingBasketViewProtocol
    
    override func shoppingBasketViewDidTouchProduct(_ shoppingBasketView: ShoppingBasketView, product: Product, shoppingItem: ShoppingBasketItem) {
        
       // ProductDetailsView.showWithProduct(product, shoppingItem:shoppingItem, grocery: nil, delegate: self)
    }
    
    // MARK: shoppingBasketViewDelegate
    
    override func shoppingBasketViewDidDeleteProduct(_ shoppingBasketView: ShoppingBasketView, product: Product, grocery: Grocery?, shoppingBasketItem: ShoppingBasketItem) {
        super.shoppingBasketViewDidDeleteProduct(shoppingBasketView, product: product, grocery: grocery, shoppingBasketItem: shoppingBasketItem)
        
        self.collectionView.reloadData()
        
    }
    
    // MARK: Product quick Remove
    
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
            ShoppingBasketItem.addOrUpdateProductInBasket(self.selectedProduct, grocery: nil, brandName: nil, quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        
        //reload this product cell
        let products = self.searchString.isEmpty ? self.products : self.searchedProducts
        let index = products.index(of: self.selectedProduct)
        if let notNilIndex = index {
            if (self.collectionView.indexPathsForVisibleItems.contains(IndexPath(row: notNilIndex, section: 0))) {
                self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
            }
           // self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
        }
        
        refreshBasketIconStatus()
    }

}
