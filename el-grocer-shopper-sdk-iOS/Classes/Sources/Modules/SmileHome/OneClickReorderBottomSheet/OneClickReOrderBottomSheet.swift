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
    @IBOutlet var imgArrowForward: UIImageView!
    @IBOutlet var lblCheckout: UILabel! {
        didSet {
            lblCheckout.text = localizedString("CHECKOUT", comment: "")
            lblCheckout.setBody3BoldUpperWhiteStyle()
        }
    }
    @IBOutlet var lblPrice: UILabel! {
        didSet {
            lblPrice.text = localizedString("AED 777.99", comment: "")
            lblPrice.setBody3BoldUpperWhiteStyle()
        }
    }
    
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
        self.dismiss(animated: true)
    }
    
    @IBAction func btnCheckoutHandler(_ sender: Any) {
        
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
        
        for product in self.productsArray {
            
            if let item = shoppingItemForProduct(product) {
                basketItemCount = basketItemCount + item.count.intValue
                
                let singlePrice = self.getProductPrice(product: product)
                let multiplePrice: Double  = singlePrice.doubleValue * item.count.doubleValue
                
                priceSum = (priceSum + multiplePrice)
            }
        }
        
        self.lblItemNum.text = String(basketItemCount)
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
        
        if priceSum < minValue {
            self.checkoutBGView.backgroundColor = ApplicationTheme.currentTheme.disableButtonColor
        }else {
            self.checkoutBGView.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
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
