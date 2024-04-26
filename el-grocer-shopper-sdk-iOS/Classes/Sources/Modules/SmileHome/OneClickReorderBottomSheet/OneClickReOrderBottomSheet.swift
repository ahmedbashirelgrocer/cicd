//
//  OneClickReOrderBottomSheet.swift
//  Adyen
//
//  Created by Abdul Saboor on 28/02/2024.
//

import UIKit

class OneClickReOrderBottomSheet: UIViewController {
    
    @IBOutlet var bottomSheetBGView: AWView! {
        didSet {
            bottomSheetBGView.roundTopWithTopShadow(radius: 12)
        }
    }
    @IBOutlet var imgGrocery: UIImageView!
    @IBOutlet var lblStoreName: UILabel! {
        didSet {
            lblStoreName.setH3SemiBoldStyle()
        }
    }
    @IBOutlet var btnCross: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var checkoutBGView: AWView! {
        didSet {
            checkoutBGView.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
            checkoutBGView.cornarRadius = 22
        }
    }
    @IBOutlet var itemNumBGView: AWView! {
        didSet {
            itemNumBGView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
            itemNumBGView.cornarRadius = 14
        }
    }
    @IBOutlet var lblItemNum: UILabel! {
        didSet {
            lblItemNum.setBody3RegDarkStyle()
            lblItemNum.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
        }
    }
    @IBOutlet var imgArrowForward: UIImageView! {
        didSet {
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                imgArrowForward.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
        }
    }
    @IBOutlet var lblCheckout: UILabel! {
        didSet {
            lblCheckout.text = localizedString("btn_cart_all_cap", comment: "")
            lblCheckout.setBody3BoldUpperWhiteStyle()
        }
    }
    @IBOutlet var lblPrice: UILabel! {
        didSet {
            lblPrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: 0.00)
            lblPrice.setBody3BoldUpperWhiteStyle()
        }
    }
    
    typealias tapped = ()-> Void
    var checkoutTapped: tapped?
    private var dispatchGroup = DispatchGroup()
    var grocery: Grocery?
    var productsArray: [Product] = []
    var selectedProduct:Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpCollectionView()
        registerCells()
        setGroceryData()
        callFetchProductApi()
        getBasketFromServerWithGrocery(self.grocery)
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .oneClickBottomSheet))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ElGrocerUtility.sharedInstance.activeGrocery = self.grocery
        updatePrice()
    }
    
    func setUpCollectionView() {
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false

    }
    
    func registerCells() {
        let ProductCell = UINib(nibName: "ProductCell", bundle: Bundle.resource)
        self.collectionView.register(ProductCell, forCellWithReuseIdentifier: "ProductCell")
    }
    
    @IBAction func btnCrossHandler(_ sender: Any) {
        SegmentAnalyticsEngine.instance.logEvent(event: OneClickReOrderCloseEvent())
        self.dismiss(animated: true)
    }
    
    @IBAction func btnCheckoutHandler(_ sender: Any) {
        if self.checkoutBGView.backgroundColor != ApplicationTheme.currentTheme.disableButtonColor {
            if let checkoutTapped = checkoutTapped {
                checkoutTapped()
                
                SegmentAnalyticsEngine.instance.logEvent(event: CartClickedEvent(grocery: grocery))
            }
        }
    }
    
    func setGroceryData() {
        ElGrocerUtility.sharedInstance.activeGrocery = self.grocery
        let name = self.grocery?.name ?? ""
        self.lblStoreName.text = name
        
        if let imgUrl = URL(string: self.grocery?.smallImageUrl ?? "") {
            self.imgGrocery.sd_setImage(with: imgUrl)
        }
        
    }
    
    func callFetchProductApi() {
        
        if let jsonSlot = grocery?.initialDeliverySlotData, let dict = grocery?.convertToDictionary(text: jsonSlot) {
            let timeMili = dict["time_milli"] as? Int ?? 0
            self.fetchPreviousPurchasedProducts(deliveryTime: timeMili)
        }else {
            let timeMili = Date().getUTCDate().millisecondsSince1970
            self.fetchPreviousPurchasedProducts(deliveryTime: Int(timeMili))
        }
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
extension OneClickReOrderBottomSheet {
    
    func fetchPreviousPurchasedProducts(deliveryTime: Int) {
        // As for varient other than baseline we are not showing
        if !UserDefaults.isUserLoggedIn() {
            return
        }
    
        SpinnerView.showSpinnerViewInView(self.view)
        
        let parameters = NSMutableDictionary()
        parameters["limit"] = 40
        parameters["offset"] = 0
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)
        parameters["shopper_id"] = UserDefaults.getLogInUserID()
        parameters["delivery_time"] =  deliveryTime as AnyObject
        
        self.dispatchGroup.enter()
        ElGrocerApi.sharedInstance.getTopSellingProductsOfGrocery(parameters , false) { [weak self] (result) in
            guard let self = self else { return }
            
            self.dispatchGroup.leave()
            SpinnerView.hideSpinnerView()
            switch result {
            case .success(let response):
                let products = Product.insertOrReplaceProductsFromDictionary(response, context: DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
                
                if products.products.count > 0 {
                    self.productsArray = products.products
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.updatePrice()
                }
                
            case .failure(let error):
                error.showErrorAlert()
            }
        }
    }
    
}

extension OneClickReOrderBottomSheet: ProductCellProtocol{
    func productCellOnFavouriteClick(_ productCell: ProductCell, product: Product) {
       elDebugPrint(product)
    }
    
    func productCellOnProductQuickAddButtonClick(_ productCell: ProductCell , product: Product) {
       elDebugPrint(product)
        if self.grocery != nil {
            var productQuantity = 1
            
                // If the product already is in the basket, just increment its quantity by 1
            if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                productQuantity += product.count.intValue
            }
            
            let isNewCart = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext).count == 0
            if isNewCart {
                let cartCreatedEvent = CartCreatedEvent(grocery: self.grocery)
                SegmentAnalyticsEngine.instance.logEvent(event: cartCreatedEvent)
                let cartUpdatedEvent = CartUpdatedEvent(grocery: self.grocery, product: product, actionType: .added, quantity: productQuantity)
                SegmentAnalyticsEngine.instance.logEvent(event: cartUpdatedEvent)
            } else {
                let cartUpdatedEvent = CartUpdatedEvent(grocery: self.grocery, product: product, actionType: .added, quantity: productQuantity)
                SegmentAnalyticsEngine.instance.logEvent(event: cartUpdatedEvent)
            }
            
            self.selectedProduct = product
            self.updateProductQuantity(productQuantity)
        }
        
    }
    
    func productCellOnProductQuickRemoveButtonClick(_ productCell: ProductCell, product: Product) {
       elDebugPrint(product)
        var productQuantity = 0
        
            // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity = product.count.intValue - 1
        }
        
        if productQuantity < 0 {return}
        
        let cartDeleted = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext).count == 0
        if cartDeleted {
            let cartDeletedEvent = CartDeletedEvent(grocery: self.grocery)
            SegmentAnalyticsEngine.instance.logEvent(event: cartDeletedEvent)
        } else {
            let cartUpdatedEvent = CartUpdatedEvent(grocery: self.grocery, product: product, actionType: .removed, quantity: productQuantity)
            SegmentAnalyticsEngine.instance.logEvent(event: cartUpdatedEvent)
        }
        
        self.selectedProduct = product
        self.updateProductQuantity(productQuantity)
    }
    
    func chooseReplacementWithProduct(_ product: Product) {
       elDebugPrint(product)
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
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
            self.basketIconOverlay?.grocery = self.grocery
            updatePrice()
        }
    }
    
    func updatePrice() {
        
        var basketItemCount: Int = 0
        var priceSum: Double = 0.0
        
        let products = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        
        for product in products {
            
            if let item = shoppingItemForProduct(product) {
                basketItemCount = basketItemCount + item.count.intValue
                
                let singlePrice = self.getProductPrice(product: product)
                let multiplePrice: Double  = singlePrice.doubleValue * item.count.doubleValue
                
                priceSum = (priceSum + multiplePrice)
            }
        }
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.lblItemNum.text = String(basketItemCount).changeToArabic()
        }else {
            self.lblItemNum.text = String(basketItemCount)
        }
        
        self.lblPrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: priceSum)
        
        self.checkMinBasketValue(priceSum: priceSum)
        
    }
    
    func getProductPrice(product: Product)-> NSNumber {
        
        var price: NSNumber = NSNumber(0.0)
        
        if product.promotion?.boolValue ?? false {
            price = product.promoPrice ?? NSNumber(0.0)
        }else {
            price = product.price
        }
        
        return price
        
    }
    
    fileprivate func shoppingItemForProduct(_ product:Product) -> ShoppingBasketItem? {
        
        return ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    func checkMinBasketValue(priceSum: Double) {
        let minValue = self.grocery?.minBasketValue ?? 0.0
        
        if priceSum < minValue || priceSum == 0.00 {
            self.checkoutBGView.backgroundColor = ApplicationTheme.currentTheme.disableButtonColor
            lblItemNum.textColor = ApplicationTheme.currentTheme.disableButtonColor
        }else {
            self.checkoutBGView.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
            lblItemNum.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
        }
    }
    
    
}

extension OneClickReOrderBottomSheet: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        
        cell.configureWithProduct(productsArray[indexPath.row], grocery: self.grocery, cellIndex: indexPath)
        cell.delegate = self
        
        return cell
    }
    
}
extension OneClickReOrderBottomSheet: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        var cellSpacing:  CGFloat = -20.0
        var numberOfCell: CGFloat = 2.13
        if self.view.frame.size.width == 320 {
            cellSpacing = 3.0
            numberOfCell = 1.965
        }
        let cellSize = CGSize(width: ((collectionView.frame.size.width - 32) - cellSpacing * 2 ) / numberOfCell , height: kProductCellHeight)
        return cellSize
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 6 , bottom: 0 , right: 6)
    }
}

extension OneClickReOrderBottomSheet {
    
    // MARK: Get Basket Data
    func getBasketFromServerWithGrocery(_ grocery:Grocery?){
        
        let spinnerView = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.fetchBasketFromServerWithGrocery(grocery) { (result) in
            
            spinnerView?.removeFromSuperview()
            switch result {
                case .success(let responseDict):
                   print("Fetch Basket Response:%@",responseDict)
                    self.saveResponseData(responseDict, andWithGrocery: grocery)
                    
                    SegmentAnalyticsEngine.instance.logEvent(event: CartViewdEvent(grocery: self.grocery))
                case .failure(let error):
                   elDebugPrint("Fetch Basket Error:%@",error.localizedMessage)
                    spinnerView?.removeFromSuperview()
            }
        }
    }
        // MARK: Basket Data
    func saveResponseData(_ responseObject:NSDictionary, andWithGrocery grocery:Grocery?) {
        
            //guard let dataDict = responseObject["data"] as? NSDictionary else {return}
        guard let shopperCartProducts = responseObject["data"] as? [NSDictionary] else {return}
        
        var isPromoChanged = false
        
        Thread.OnMainThread {
            let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
            context.performAndWait {
                ShoppingBasketItem.clearActiveGroceryShoppingBasket(context)
            }
            
            for responseDict in shopperCartProducts {
                
                
                if let productDict =  responseDict["product"] as? NSDictionary {
                    
                    let quantity = responseDict["quantity"] as! Int
                    let updatedAt = responseDict["updated_at"] as? String ?? ""
                    let createdAt = responseDict["created_at"] as? String ?? ""
                    
                    let updatedDate : Date? = updatedAt.isEmpty ? nil : updatedAt.convertStringToCurrentTimeZoneDate()
                    let createdDate : Date? = createdAt.isEmpty ? nil : createdAt.convertStringToCurrentTimeZoneDate()
                    
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    let product = Product.createProductFromDictionary(productDict, context: context ,  createdDate ,  updatedDate )
                    
                        //insert brand
                    if let brandDict = productDict["brand"] as? NSDictionary {
                        
                        let brandId = brandDict["id"] as! Int
                        let brandName = brandDict["name"] as? String
                        let brandImage = brandDict["image_url"] as? String
                        let brandSlugName = brandDict["slug"] as? String
                        
                        
                        let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                        brand.name = brandName
                        brand.nameEn = brandSlugName
                        brand.imageUrl = brandImage
                        product.brandId = brand.dbID
                        
                    }
                    
                    DatabaseHelper.sharedInstance.saveDatabase()
                    ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: grocery, brandName: nil, quantity: quantity, context: context, orderID: nil, nil, false)
                    
                }
                
            }
            
            ElGrocerUtility.sharedInstance.delay(0.2) {
                
                self.collectionView.reloadData()
                self.updatePrice()
            
            }
        }
    }
}
