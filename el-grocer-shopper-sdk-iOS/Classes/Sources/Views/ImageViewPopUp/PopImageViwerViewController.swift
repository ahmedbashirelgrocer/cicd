//
//  PopImageViwerViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 10/10/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import NBBottomSheet
import SDWebImage

enum PopImageControllerType{
    case productDeepLink
    case productCell
}


class PopImageViwerViewController: UIViewController {
    
    @IBOutlet var lblDistanceFromPercentageView: NSLayoutConstraint!
    @IBOutlet var strikeLblDistanceFromQtyLbl: NSLayoutConstraint!
    @IBOutlet weak var saleView: UIImageView!
    @IBOutlet weak var storeLogo: UIImageView!
    @IBOutlet weak var lblProductName: UILabel!{
        didSet{
            lblProductName.setH2BoldDarkStyle()
            lblProductName.textAlignment = .natural
        }
    }
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet var productQuantity: UILabel!{
        didSet{
            productQuantity.setBody3RegDarkStyle()
            productQuantity.textAlignment = .natural
        }
    }
    @IBOutlet var zoomView: UIView!
    @IBOutlet var offerView: AWView!{
        didSet{
            offerView.backgroundColor = .promotionRedColor()
            offerView.roundCorners(corners:[.topRight , .bottomRight] , radius: 18)
            offerView.isHidden = true
        }
    }
    @IBOutlet var lblOffer: UILabel!{
        didSet{
            lblOffer.setBody3BoldUpperYellowStyle()
        }
    }
    @IBOutlet var lblOrignalPriceStrike: UILabel!{
        didSet{
            lblOrignalPriceStrike.setBody3RegDarkStyle()
            lblOrignalPriceStrike.isHidden = true
        }
    }
    @IBOutlet var offerPercentView: AWView!{
        didSet{
            offerPercentView.backgroundColor = .promotionRedColor()
            offerPercentView.cornarRadius = 12.5
            offerPercentView.isHidden = true
        }
    }
    @IBOutlet var lblDiscountPercent: UILabel!{
        didSet{
            lblDiscountPercent.setBody3BoldUpperYellowStyle()
        }
    }
    @IBOutlet var lblPrice: UILabel!{
        didSet{
//            lblPrice.isHidden = true
        }
    }
    @IBOutlet var addToCartBGView: AWView!{
        didSet{
            
            //addToCartBGView.roundCorners(corners: [.topLeft , .topRight], radius: 8)
            addToCartBGView.cornarRadius = 8
            addToCartBGView.layer.maskedCorners = [.layerMaxXMinYCorner , .layerMinXMinYCorner]
            addToCartBGView.shadowOffset = CGSize(width: 2.0, height: 2.0)
            addToCartBGView.shadowRadius = 4
            addToCartBGView.shadowOpacity = 16
            addToCartBGView.shadowColor = .newBlackColor()
        }
    }
    @IBOutlet var btnAddToCart: AWButton!{
        didSet{
            btnAddToCart.cornarRadius = 28
            btnAddToCart.setH4SemiBoldWhiteStyle()
        }
    }
    @IBOutlet var btnPlusButton: AWButton!{
        didSet{
            btnPlusButton.cornarRadius = 22
            btnPlusButton.setH4SemiBoldWhiteStyle()
        }
    }
    @IBOutlet var btnMinusButton: AWButton!{
        didSet{
            btnMinusButton.cornarRadius = 22
            btnMinusButton.setH4SemiBoldWhiteStyle()
            btnMinusButton.backgroundColor = .newBorderGreyColor()
        }
    }
    @IBOutlet var lblItemCount: UILabel!{
        didSet{
            lblItemCount.setBody1RegDarkStyle()
        }
    }
    @IBOutlet var shopFromStoreBGView: UIView!
    @IBOutlet var btnShopFromStore: AWButton!{
        didSet{
            btnShopFromStore.cornarRadius = 28
            btnShopFromStore.setH4SemiBoldWhiteStyle()
            btnShopFromStore.setTitle(localizedString("btn_add_from_store", comment: ""), for: UIControl.State())
        }
    }
    
    @IBOutlet var topScrollView: UIScrollView! {
        didSet {
            topScrollView.isScrollEnabled = false
        }
    }
    @IBOutlet var boughtItemView: CustomCollectionView!
    
    lazy var boughtItems : [Product] = []
    lazy var relatedItems : [Product] = []
    
    @IBOutlet var lblFrequentlyBought: UILabel!
    @IBOutlet var lblReatedTogether: UILabel!
    @IBOutlet var relatedItemView: CustomCollectionView!
    
    lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.configureNoProducts()
        return noStoreView!
    }()
    private lazy var productDelegate : ProductDelegate = {
        let productsD = ProductDelegate()
        productsD.delegate = self
        return productsD
      }()
    
    var didDissmiss: ((Bool, _ products: [Product],_ grocery: Grocery,_ brandId: String) -> Void)?
    var controllerType: PopImageControllerType = .productCell
    var product: Product?
    var priviousImage = UIImage()
    var productCount : Int = 0
    var barcodeString: String = "" // promotional: 6291100002085, nonPromo : 8906005505354
    var productId: String = ""
    var grocery: Grocery?
    var groceryController: DeepLinkBottomGroceryVC?
    
    var screeName = "ViewItem"
    var source = "ProductDeepLink"
    var type = "Global"
    var deepLink = ""
   
    
    lazy var placeholderPhoto : UIImage = {
        return UIImage(name: "product_placeholder")!
    }()
    
    var storeImageURL: String?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height:  ScreenSize.SCREEN_HEIGHT)
        landscapeContentSizeInPopup = CGSize(width: ScreenSize.SCREEN_HEIGHT, height:  ScreenSize.SCREEN_WIDTH)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    
    var isAddedToCart : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpApearance()
        self.setDeepLink()
        
        // Logging segment screen event
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .productDetailsScreen))
    }
    override func viewDidAppear(_ animated: Bool) {
        super
            .viewDidAppear(animated)
        FireBaseEventsLogger.setScreenName( FireBaseScreenName.ViewItem.rawValue , screenClass: String(describing: self.classForCoder))
        trackViewProductEvent()
        setDeepLinkBottom()
        if self.controllerType == .productCell{
            setZoomImage()
        }else{
            searchAlgolia()
        }
        
        let productCellNib = UINib(nibName: "ProductCell", bundle: .resource)
        boughtItemView.collectionView?.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        relatedItemView.collectionView?.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        boughtItemView.collectionView?.dataSource = self
        boughtItemView.collectionView?.delegate = self
        relatedItemView.collectionView?.dataSource = self
        relatedItemView.collectionView?.delegate = self
        // self.getBoughtItems()
        // self.getRelatedItems()
        // self.getRelatedItems()()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDeepLinkBottom()
        if let product = self.product {
            FireBaseEventsLogger.trackProductView(product: product, deepLink: self.deepLink, position: -1, source: self.screeName , type: self.type)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let didDissmiss = self.didDissmiss {
            if self.product != nil && self.grocery != nil, self.product?.brandId?.stringValue != nil{
                didDissmiss(true,[self.product!],self.grocery!,product?.brandId?.stringValue ?? "")
            }
            
        }
    }
    
    func checkNoDataView(){
        if self.product == nil {
            NoDataView.frame = CGRect(x: 0, y: 50, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - 50)
            self.view.addSubview(NoDataView)
            NoDataView.isHidden = false
            self.view.bringSubviewToFront(NoDataView)
        }else{
            NoDataView.isHidden = true
            self.NoDataView.removeFromSuperview()
        }
    }
    
    func setDeepLinkBottom(){
        if self.controllerType == .productDeepLink{
            self.shopFromStoreBGView.isHidden = false
            self.shopFromStoreBGView.roundTopWithTopShadow(radius: 8)
           
        }else{
            self.shopFromStoreBGView.isHidden = true
            self.shopFromStoreBGView.roundTopWithTopShadow(radius: 8)
        }
    }
    
    
    func setDeepLink() {
        
        if !ElGrocerUtility.sharedInstance.deepLinkShotURL.isEmptyStr {
            self.deepLink = ElGrocerUtility.sharedInstance.deepLinkShotURL
            ElGrocerUtility.sharedInstance.deepLinkShotURL = ""
        }
    }
    
    func setZoomImage(){
        
        ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.saleView)
        setSaleImageView()
        if let productIamgeURL = self.product?.imageUrl {
             self.setLargeImageLogo(productIamgeURL.replacingOccurrences(of: "/medium/", with: "/original/"))
        }
//        self.setImageZoomer(self.productImage.image ?? self.placeholderPhoto)
    }
    
    func configureProduct(){
        if controllerType == .productDeepLink, let product = self.product{
            
            self.lblProductName.text = product.name
            self.productQuantity.text = product.descr ?? ""
            if self.grocery == nil{
                var priceValue : NSNumber? = nil
                var isPromotional: Bool = false
                if let shopsA = product.shops {

                    let shopsList = product.convertToDictionaryArray(text: shopsA)
                    let shops = shopsList?.filter({ data in
                        let isDataAvailable =  ElGrocerUtility.sharedInstance.groceries.filter { grocery in
                            return (data["retailer_id"] as! NSNumber).stringValue == grocery.getCleanGroceryID()
                        }
                        return isDataAvailable.count > 0
                    })

                    for shop in shops ?? [] {
                        if let price = shop["price"] as? NSNumber {
                            if priceValue == nil ||  price < (priceValue ?? NSNumber.init(value : Double.greatestFiniteMagnitude)) {
                                priceValue = price
                            }
                        }
                    }
                    if (shops?.count ?? 0) > 0 {
                        if let shopsA = product.promotionalShops {
                            let shopsList = product.convertToDictionaryArray(text: shopsA)
                            let shops = shopsList?.filter({ data in
                                let isDataAvailable =  ElGrocerUtility.sharedInstance.groceries.filter { grocery in
                                    return (data["retailer_id"] as! NSNumber).stringValue == grocery.getCleanGroceryID()
                                }
                                return isDataAvailable.count > 0
                            })
                            for shop in shops ?? [] {
                                let strtTime = shop["start_time"] as? Int ?? 0
                                let endTime = shop["end_time"] as? Int ?? 0

                                let retailerId = shop["retailer_id"] as? String ?? "-1"
                                let time = ElGrocerUtility.sharedInstance.getCurrentMillisOfGrocery(id: retailerId)
                                if strtTime <= time && endTime >= time {
                                    if let price = shop["price"] as? NSNumber,let standardPrice = shop["standard_price"] as? NSNumber {
                                        if priceValue == nil || price < (priceValue ?? NSNumber.init(value : Double.greatestFiniteMagnitude)) {
                                            priceValue = price
                                            product.price = standardPrice
                                            product.promotion = true
                                            product.promoPrice = price
                                            isPromotional = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if priceValue != nil {
                    product.price = priceValue!
                }
                

                if priceValue != nil {

                    self.lblPrice.isHidden = !(priceValue! > 0)

                    if priceValue!.doubleValue > 0 {
//                        let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.secondaryBlackColor()]
//                        let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
//                        let attributedString1 = NSMutableAttributedString(string: CurrencyManager.getCurrentCurrency() , attributes:attrs1 as [NSAttributedString.Key : Any])
//                        let price =  NSString(format: " %.2f" , priceValue!.doubleValue)
//                        let attributedString2 = NSMutableAttributedString(string:price as String , attributes:attrs2 as [NSAttributedString.Key : Any])
//                        attributedString1.append(attributedString2)
//                        self.lblPrice.attributedText = attributedString1
                        self.lblPrice.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: priceValue!.doubleValue)
                    }
                }
                if isPromotional {
                    checkPromotionView(product: product)
                }
            }else{
                self.lblPrice.isHidden = false
                self.offerPercentView.isHidden = false
                self.lblOrignalPriceStrike.isHidden = false
                checkPromotionView(product: product)
            }
            setZoomImage()
        }
    }
    
    
    func setSaleImageView() {
        
        if let product = self.product , product.promotion?.boolValue == true {
            
            let time =  ElGrocerUtility.sharedInstance.getCurrentMillis() //Int64(Date().getUTCDate().timeIntervalSince1970 * 1000)
            let strtTime = product.promoStartTime?.millisecondsSince1970 ?? time
            let endTime = product.promoEndTime?.millisecondsSince1970 ?? time
            if strtTime <= time && endTime >= time{
                if product.price.doubleValue.rounded() <= product.promoPrice?.doubleValue.rounded() ?? 0 {
                    self.saleView.isHidden = true
                }else{
                    self.saleView.isHidden = true
                }
            }else{
                self.saleView.isHidden = true
            }
            
        }else{
            self.saleView.isHidden = true
        }
        
        
    }
    
    //MARK: Product Promotion
    func checkPromotionView(product : Product){
        
        let promotionValues = ProductQuantiy.checkPromoNeedToDisplay(product)
        if promotionValues.isNeedToDisplayPromo{
            self.offerPercentView.isHidden = false
            self.lblOrignalPriceStrike.isHidden = false
        }else{
            self.offerPercentView.isHidden = true
            self.lblOrignalPriceStrike.isHidden = true
        }
        configurePromotionValues(product: product , isNeedToDisplayPromo: promotionValues.isNeedToDisplayPromo , isNeedToShowPercentage: promotionValues.isNeedToShowPromoPercentage)
        if product != nil{
            checkIfProductIsInBasket(product: product)
        }
        
    }
    func configurePromotionValues(product : Product , isNeedToDisplayPromo : Bool , isNeedToShowPercentage : Bool){
        if isNeedToDisplayPromo{
            if product.promoPrice != nil {
                let price = product.price
                if let promoPrice = product.promoPrice{
                    
                    let percentage = ProductQuantiy.getPercentage(product: product)
                    
//                    let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.secondaryBlackColor()]
//                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
//                    let attributedString1 = NSMutableAttributedString(string: CurrencyManager.getCurrentCurrency() , attributes:attrs1 as [NSAttributedString.Key : Any])
//                    let priceToDisplay =  NSString(format: " %.2f" , promoPrice.doubleValue)
//                    let attributedString2 = NSMutableAttributedString(string:priceToDisplay as String , attributes:attrs2 as [NSAttributedString.Key : Any])
//                    attributedString1.append(attributedString2)
//                    self.lblPrice.attributedText = attributedString1
                    self.lblPrice.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: promoPrice.doubleValue)
                    
                    if !isNeedToShowPercentage{
                        self.lblOrignalPriceStrike.text = ""
                        self.lblOrignalPriceStrike.strikeThrough(false)
                        self.lblDiscountPercent.text = localizedString("lbl_Special_Discount", comment: "")
                    }else{
//                        self.lblOrignalPriceStrike.text = localizedString("aed", comment: "") + price.doubleValue.formateDisplayString()
                        self.lblOrignalPriceStrike.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: price.doubleValue)
                        self.lblOrignalPriceStrike.strikeThrough(true)
                    }
                    self.setSpecialDiscountView(isNeedToShowPercentage: isNeedToShowPercentage, percentage: percentage)
                   
                }
            }
        }else{
            let price = product.price
//            let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.secondaryBlackColor()]
//            let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
//            let attributedString1 = NSMutableAttributedString(string: CurrencyManager.getCurrentCurrency() , attributes:attrs1 as [NSAttributedString.Key : Any])
//            let priceToDisplay =  NSString(format: " %.2f" , price.doubleValue)
//            let attributedString2 = NSMutableAttributedString(string:priceToDisplay as String , attributes:attrs2 as [NSAttributedString.Key : Any])
//            attributedString1.append(attributedString2)
//            self.lblPrice.attributedText = attributedString1
            self.lblPrice.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: price.doubleValue)
        }
        
       
        
    }
    
    func setSpecialDiscountView(isNeedToShowPercentage : Bool , percentage : Int) {
        
        if !isNeedToShowPercentage{
            self.lblOrignalPriceStrike.visibility = .gone
            self.lblOrignalPriceStrike.attributedText = nil
            self.lblOrignalPriceStrike.text = ""
            self.lblDiscountPercent.text = localizedString("lbl_Special_Discount", comment: "")
            self.offerPercentView.isHidden = false
            self.strikeLblDistanceFromQtyLbl.constant = 23
            self.lblDistanceFromPercentageView.constant = 0
        }else{
            self.lblDiscountPercent.text = "-" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(percentage)) + " " + localizedString("txt_off", comment: "")
            self.strikeLblDistanceFromQtyLbl.constant = 4
            self.lblDistanceFromPercentageView.constant = 10
        }
        
    }
    
    func getPercentage(product : Product) -> Int{
        
        guard let promoPrice = product.promoPrice as? Double else{return 0}
        guard let price = product.price as? Double else{return 0}
        
        var percentage : Double = 0
        if price > 0{
            let percentageDecimal = ((price - promoPrice)/price)
            percentage = percentageDecimal * 100
           // percentage  = (promoPrice / price) * 100
        }
        
        
        return Int(percentage)
    }
    
    
    
    func setImageZoomer(_ withImage :UIImage){
        
        self.productImage.isHidden = true
        
        for viewScrol in self.zoomView.subviews {
            if viewScrol is UIScrollView {
                for imgView in viewScrol.subviews {
                    if imgView is UIView {
                        for scrolSubImg in imgView.subviews {
                            if scrolSubImg is ImageViewZoom {
                                (scrolSubImg as! ImageViewZoom).display(image: withImage)
                                return
                            }
                        }
                    }
                }
            }
        }
        
        let viewHeight: CGFloat = self.zoomView.bounds.size.height
        let viewWidth: CGFloat = self.zoomView.bounds.size.width
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0 , width: viewWidth, height: viewHeight))
        scrollView.tag = -1212
        var xPostion: CGFloat = 0
        let view = UIView(frame: CGRect(x: xPostion, y: 0, width: viewWidth, height: viewHeight))
        xPostion += viewWidth
        let imageView = ImageViewZoom(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        imageView.setup()
        imageView.imageScrollViewDelegate = self
        imageView.imageContentMode = .aspectFit
        imageView.initialOffset = .center
        imageView.display(image: withImage)
        
        view.addSubview(imageView)
        scrollView.addSubview(view)

        scrollView.contentSize = CGSize(width: xPostion, height: 1000)
        self.zoomView.addSubview(scrollView)
       
        
        
    }
    
    fileprivate func setUpApearance(){
        
        self.navigationController?.isNavigationBarHidden = true
        self.lblOffer.text = localizedString("lbl_offer", comment: "")
        self.btnAddToCart.setTitle(localizedString("btn_add_to_cart_product_zoom", comment: ""), for: UIControl.State())
        UpdateCountLabel()
        self.NoDataView.delegate = self
        //sab
        //self.storeLogo.layer.cornerRadius = self.storeLogo.frame.size.width / 2
        //self.storeLogo.isHidden = true
        

    }
    func setProductImage(image : UIImage){
        self.productImage.image = image
    }
    
    func showBottomSheet (_ searchString : String , grocery : [Grocery] , isError : Bool = false , ingredients : [RecipeIngredients]?) {
        if let topVc  = UIApplication.topViewController() {
            if topVc is GroceryFromBottomSheetViewController {
                let groc : GroceryFromBottomSheetViewController = topVc as! GroceryFromBottomSheetViewController
                if isError {
                    groc.showErrorMessage(searchString)
                }else{
                    groc.configuer(grocery, searchString: searchString)
                }
                return
            }
        }
        if self.groceryController == nil {
            self.groceryController  = ElGrocerViewControllers.getDeepLinkBottomGroceryVC()
        }
        
        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(550))
        configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
        let bottomSheetController = NBBottomSheetController(configuration: configuration)
        bottomSheetController.present(groceryController!, on: self)
        groceryController?.deepLink = self.deepLink
        groceryController?.source = self.screeName
        groceryController?.type = self.type
        groceryController?.configure(grocery,product: self.product!, searchString: searchString,false)
        groceryController?.selectedGrocery = { [weak self] grocery in
            guard let self = self else {return}
            func processGroceryChange() {
                self.grocery = grocery
                ElGrocerUtility.sharedInstance.activeGrocery = grocery
                GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsRecipeDetailScreen)
                if let topVc = UIApplication.topViewController() {
                    if let tabbar = topVc.tabBarController {
                        ElGrocerUtility.sharedInstance.resetTabbar(tabbar)
                    }
                }
                UserDefaults.setCurrentSelectedDeliverySlotId(0)
                UserDefaults.setPromoCodeValue(nil)
                if (grocery.isOpen.boolValue && Int(grocery.deliveryTypeId!) != 1) || (grocery.isSchedule.boolValue && Int(grocery.deliveryTypeId!) != 0){
                    let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    if currentAddress != nil  {
                        UserDefaults.setGroceryId(grocery.dbID , WithLocationId: (currentAddress?.dbID)!)
                    }
                }
                
                self.configureProduct()
                self.groceryController?.dismiss(animated: true, completion: nil)
                if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
                    FireBaseEventsLogger.setScreenName(topControllerName, screenClass: String(describing: self.view.classForCoder))
                }
                
                let productId = self.product?.getCleanProductId() ?? 0
                self.searchProductFromAlgolia("\(productId)" , groceryID: self.grocery?.getCleanGroceryID() ?? "")
            }
            ElGrocerUtility.sharedInstance.checkActiveGroceryNeedsToClear(grocery) { (isUserApproved) in
                if isUserApproved {
                    processGroceryChange()
                }
            }
        }
    }
    
    
    func searchProductFromAlgolia( _ productId : String, groceryID : String) {
        
        
        
        
        guard productId.count > 0, groceryID.count > 0 else {
            return
        }
        
        AlgoliaApi.sharedInstance.searchProductWithBarCode("", productId, storeIDs: [groceryID], searchType: "single_search")  { (data, error) in
            
            guard data != nil else {
                return
            }
            if  let responseObject : NSDictionary = data as NSDictionary? {
                Thread.OnMainThread {
                    let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    if newProducts.products.count > 0 {
                        DatabaseHelper.sharedInstance.saveDatabase()
                        let newProduct  = newProducts.products[0]
                        self.product = newProduct
                        self.btnAddToCrtHandler(self)
                    }else{
                       elDebugPrint("no product found")
                        
                    }
                }
            }
        }
        
    }
    
    
    
    
    
    @IBAction func btnShopInStoreHandler(_ sender: Any) {
        btnAddToCrtHandler(self)
    }
    @IBAction func btnAddToCrtHandler(_ sender: Any) {
        
        if self.product != nil{
            //addToCartPressed(product: self.product!)
            
            if controllerType == .productDeepLink {
                
                if self.grocery == nil {
                    Thread.OnMainThread {
                        let shopIdsA = self.product?.shopIds
                        let groceryA = ElGrocerUtility.sharedInstance.groceries.filter({ (grocery) in
                                return shopIdsA?.first(where: { id in
                                    return id.stringValue == grocery.dbID
                                }) != nil
                            })
                        self.showBottomSheet(self.product?.name ?? "", grocery: groceryA, ingredients: nil)
                        return
                    }
                    return
                }
            }
            
            
            if productCount == 0 {
                productCount = productCount + 1
            }
         
            ProductQuantiy.checkLimitReachedWithType(self.product!, count: productCount) { [weak self] isQuantityReached, isPromoLimitReached, isLimitReached in
                
                guard let self = self else {return}
                
                if !isLimitReached {
                    
                    self.firstAddProcductFromQuickkAdd(self.product!, grocery: ElGrocerUtility.sharedInstance.activeGrocery)
                    self.UpdateCountLabel()
                    self.crossAction(sender)
                    
                }else if isPromoLimitReached {
                  
                    let msg = String(format: localizedString("promotion_changed_alert_description", comment: ""), "\(self.product!.name ?? "")" , "\(self.product!.promoProductLimit ?? 0) ")
                    
                    let notification = ElGrocerAlertView.createAlert(localizedString("quantity_changed_alert_title", comment: "") ,
                                                                     description: msg ,
                                                                     positiveButton: localizedString("promo_code_alert_ok", comment: ""),
                                                                     negativeButton: nil, buttonClickCallback: nil )
                    notification.show()
                    
                    if isLimitReached {
                        self.productCount = self.product!.promoProductLimit?.intValue ?? 1
                        self.UpdateCountLabel()
                    }
                    
                } else if isQuantityReached {
                    
                    let msg = String(format: localizedString("promotion_changed_alert_description", comment: ""), "\(self.product!.name ?? "")" , "\(self.product!.availableQuantity ) ")
                    
                    let notification = ElGrocerAlertView.createAlert(localizedString("quantity_changed_alert_title", comment: "") ,
                                                                     description: msg ,
                                                                     positiveButton: localizedString("promo_code_alert_ok", comment: ""),
                                                                     negativeButton: nil, buttonClickCallback: nil )
                    notification.show()
                    
                    if isLimitReached {
                        self.productCount = self.product!.availableQuantity.intValue
                        self.UpdateCountLabel()
                    }
                    
                }
                
                
            }
            
 
        }
    }
    @IBAction func btnPlusButtonHandler(_ sender: Any) {
        
        //productCount = productCount + 1
        if self.product != nil{
            
            if controllerType == .productDeepLink{
                if self.grocery == nil{
                    Thread.OnMainThread {
                        let shopIdsA = self.product?.shopIds
                        let groceryA = ElGrocerUtility.sharedInstance.groceries.filter({ (grocery) in
                                return shopIdsA?.first(where: { id in
                                    return id.stringValue == grocery.dbID
                                }) != nil
                            })
                        self.showBottomSheet(self.product?.name ?? "", grocery: groceryA, ingredients: nil)
                        return
                    }
                    
                    return
                }
            }
            
            //plusButtonPressed(product: self.product!)
            addProductInShoppingBasketFromQuickAdd(self.product!, grocery: ElGrocerUtility.sharedInstance.activeGrocery)
            UpdateCountLabel()
        }
    }
    @IBAction func btnMinusButtonHandler(_ sender: Any) {
        if productCount > 0{
            //productCount = productCount - 1
            if self.product != nil{
               // minusButtonPressed(product: self.product!)
                removeProductToBasketFromQuickRemove(self.product!, grocery: ElGrocerUtility.sharedInstance.activeGrocery)
                UpdateCountLabel()
            }
        }
    }
    
    func UpdateCountLabel(){
        if productCount == 0 {
            self.lblItemCount.text = String(1)
            if ElGrocerUtility.sharedInstance.isArabicSelected(){
                self.lblItemCount.text = String(1).changeToArabic()
            }
            self.btnMinusButton.backgroundColor = .newBorderGreyColor()
        }else if productCount > 0{
            self.lblItemCount.text = String(productCount)
            if ElGrocerUtility.sharedInstance.isArabicSelected(){
                self.lblItemCount.text = String(productCount).changeToArabic()
            }
            self.btnMinusButton.backgroundColor = .disableButtonColor()
        }
        if isAddedToCart{
            self.btnAddToCart.isHidden = true
        }else{
            self.btnAddToCart.isHidden = false
        }
        
    }
    
    //MARK: Add to cart
    
    func checkIfProductIsInBasket(product : Product){
        if let item = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: ElGrocerUtility.sharedInstance.activeGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
           
            self.productCount = item.count.intValue
            
                //if promotionValues.isNeedToDisplayPromo {
            if ProductQuantiy.checkPromoLimitReached(product, count: item.count.intValue){
                self.btnAddToCart.isHidden = true
                self.isAddedToCart = true
                self.btnPlusButton.isEnabled = false
                self.btnPlusButton.backgroundColor = .newBorderGreyColor()
                FireBaseEventsLogger.trackInventoryReach(product: product, isCarousel: false)
                
            } else {
                
                if productCount >= 1 {
                    
                    self.btnAddToCart.isHidden = true
                    self.isAddedToCart = true
                    self.btnPlusButton.isEnabled = true
                    self.btnPlusButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
                    
                } else {
                    
                    self.btnAddToCart.isHidden = false
                    self.isAddedToCart = false
                    
                }

            }
        }else{
            self.isAddedToCart = false
        }
        UpdateCountLabel()
        
    }
    
    func firstAddProcductFromQuickkAdd(_ selectedProduct: Product, grocery : Grocery?){
        
        
        
        if selectedProduct.promotion?.boolValue == true{
            if (productCount <= selectedProduct.promoProductLimit!.intValue) || selectedProduct.promoProductLimit?.intValue ?? 0 == 0 {
                let productQuantity = self.productCount
                self.productCount = productQuantity
                for _ in 1...productQuantity {
                    ElGrocerEventsLogger.sharedInstance.addToCart(product: selectedProduct)
                }
                self.updateProductsQuantity(productQuantity, selectedProduct: selectedProduct,grocery: grocery)
                self.isAddedToCart = true
            }else{
               elDebugPrint("show error adding more quantity then limit")
                let msg = localizedString("msg_limited_stock_start", comment: "") + "\(selectedProduct.promoProductLimit!)" + localizedString("msg_limited_stock_end", comment: "")
                let title = localizedString("msg_limited_stock_title", comment: "")
                ElGrocerUtility.sharedInstance.showTopMessageView(msg ,title, image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
                
            }
            
        }else{
            let productQuantity = self.productCount
            self.productCount = productQuantity
            for _ in 1...productQuantity {
                ElGrocerEventsLogger.sharedInstance.addToCart(product: selectedProduct)
            }
           
            self.updateProductsQuantity(productQuantity, selectedProduct: selectedProduct,grocery: grocery)
            self.isAddedToCart = true
        }
        
        if self.product != nil{
            checkIfProductIsInBasket(product: self.product!)
        }
    }
    
    func addProductInShoppingBasketFromQuickAdd(_ selectedProduct: Product, grocery : Grocery?){
        if isAddedToCart{
            let productQuantity = self.productCount + 1
            self.productCount = productQuantity
            self.updateProductsQuantity(productQuantity, selectedProduct: selectedProduct,grocery: grocery)
            
            ElGrocerEventsLogger.sharedInstance.addToCart(product: selectedProduct)
            
            if product?.promotion?.boolValue == true{
                if (productCount >= selectedProduct.promoProductLimit!.intValue) && selectedProduct.promoProductLimit!.intValue > 0 {
                    self.btnPlusButton.isEnabled = false
                    self.btnPlusButton.backgroundColor = .newBorderGreyColor()
                    
                    let msg = localizedString("msg_limited_stock_start", comment: "") + "\(selectedProduct.promoProductLimit!)" + localizedString("msg_limited_stock_end", comment: "")
                    let title = localizedString("msg_limited_stock_title", comment: "")
                    ElGrocerUtility.sharedInstance.showTopMessageView(msg ,title, image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
                    
                }else{
                    self.btnPlusButton.isEnabled = true
                    self.btnPlusButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
                }
            }else{
                self.btnPlusButton.isEnabled = true
                self.btnPlusButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
            }
           
        }else{
            
            if product?.promotion?.boolValue == true{
                if (productCount >= selectedProduct.promoProductLimit!.intValue) && selectedProduct.promoProductLimit!.intValue > 0 {
                    
                    let msg = localizedString("msg_limited_stock_start", comment: "") + "\(selectedProduct.promoProductLimit!)" + localizedString("msg_limited_stock_end", comment: "")
                    let title = localizedString("msg_limited_stock_title", comment: "")
                    ElGrocerUtility.sharedInstance.showTopMessageView(msg ,title, image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
                    
                }else{
                    self.productCount = productCount + 1
                    UpdateCountLabel()
                }
            }else{
                self.productCount = productCount + 1
                UpdateCountLabel()
            }
            
            
        }
        
        if self.product != nil{
            checkIfProductIsInBasket(product: self.product!)
        }
    }

    func removeProductToBasketFromQuickRemove(_ selectedProduct: Product,grocery : Grocery?){
        if isAddedToCart{
            guard grocery != nil else {return}
            let productQuantity = self.productCount - 1
            self.productCount = productQuantity
            self.updateProductsQuantity(productQuantity, selectedProduct: selectedProduct,grocery: grocery)
            
            if product?.promotion?.boolValue == true{
                if (productCount >= selectedProduct.promoProductLimit!.intValue) && selectedProduct.promoProductLimit!.intValue > 0{
                    self.btnPlusButton.isEnabled = false
                    self.btnPlusButton.backgroundColor = .newBorderGreyColor()
                }else{
                    self.btnPlusButton.isEnabled = true
                    self.btnPlusButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
                }
            }else{
                self.btnPlusButton.isEnabled = true
                self.btnPlusButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
            }
           
        }else{
            if self.productCount > 0{
                self.productCount = productCount - 1
                UpdateCountLabel()
            }
            
        }
        
        if self.product != nil{
            checkIfProductIsInBasket(product: self.product!)
        }
        
    }

    func updateProductsQuantity(_ quantity: Int, selectedProduct: Product , grocery : Grocery?) {

        if quantity == 0 {

            //remove product from basket
            ShoppingBasketItem.removeProductFromBasket(selectedProduct, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
//            self.addIngrediant(false)
//            view.itemsInCart = view.itemsInCart - 1
//            view.UpdateCartCount()
           

        } else {

            //Add or update item in basket
            ShoppingBasketItem.addOrUpdateProductInBasket(selectedProduct, grocery: grocery, brandName: selectedProduct.brandNameEn , quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
//            ElGrocerUtility.sharedInstance.delay(1.0) {
//                let msg = localizedString("product_added_to_cart", comment: "")
//                ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
//            }
//            self.addIngrediant(true)
//            view.itemsInCart = view.itemsInCart + 1
//            view.UpdateCartCount()
           
        }
        DatabaseHelper.sharedInstance.saveDatabase()
    
    }

    
    fileprivate func setStoreLogo(_ imageURl : String?) {
        
        if imageURl != nil && imageURl?.range(of: "http") != nil {
            
            self.storeLogo.sd_setImage(with: URL(string: imageURl!), placeholderImage: self.placeholderPhoto , options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let  self = self else {return}
                if cacheType == SDImageCacheType.none {
                    UIView.transition(with: self.storeLogo, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {() -> Void in
                        self.storeLogo.image = image
                    }, completion: nil)
                }
            })
        }
    }
    
    fileprivate func setLargeImageLogo(_ imageURl : String?) {
        if imageURl != nil && imageURl?.range(of: "http") != nil {
            self.productImage.sd_setImage(with: URL(string: imageURl!), placeholderImage: self.productImage.image , options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let  self = self else {return}
                if cacheType == SDImageCacheType.none {
                    UIView.transition(with: self.productImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {() -> Void in
                        self.productImage.image = image
                    }, completion: nil)
                }
                self.setImageZoomer(image ?? self.placeholderPhoto)
            })
        }
    }
    
    fileprivate func trackViewProductEvent () {
        guard let productIS = self.product else {
             elDebugPrint("Facebook view will not logged")
            return
        }
        
        let clearProductID = "\(Product.getCleanProductId(fromId: productIS.dbID))"
        
        /* ---------- facebook Event ----------*/
        let facebookProductParams = ["id" : clearProductID , "quantity" : 1 ] as [AnyHashable: Any]
        let fbDataA : [[AnyHashable : Any]] = [facebookProductParams]
        let paramsJSON = JSON(fbDataA)
        let paramsString = paramsJSON.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!
        
        let facebookParams = [AppEvents.ParameterName.contentID: clearProductID ,AppEvents.ParameterName.contentType:"product",AppEvents.ParameterName.currency: kProductCurrencyEngAEDName , AppEvents.ParameterName.content : paramsString] as [AnyHashable: Any]
        
        AppEvents.logEvent(AppEvents.Name.viewedContent, valueToSum: Double(truncating: productIS.price), parameters: facebookParams as! [AppEvents.ParameterName : Any])
        FireBaseEventsLogger.trackViewItem(productIS)
        AlgoliaApi.sharedInstance.viewItemAlgolia(product: productIS)
        
        elDebugPrint("facebook eventName : \(AppEvents.Name.viewedContent)")
        elDebugPrint("facebook Parm Print : \(productIS.price)")
        elDebugPrint("facebook Parm Print : \(facebookParams)")
        
    }

    @IBAction func crossAction(_ sender: Any) {
        //closure call to dynamic link helper to present brand deep-link with selected product
        //normal dissmiss
        self.dismiss(animated: false, completion: nil)
    }
    //MARK: product Deep Link
    
    func getAvailableRetailerIds()-> [String]{
        let retailers = ElGrocerUtility.sharedInstance.groceries
        var retailerIds:[String] = []
        for retailer in retailers {
            retailerIds.append(retailer.dbID)
        }
        return retailerIds
    }
    
    func searchAlgolia(){
        if self.barcodeString != "" || self.productId != "" {
            var spiner = SpinnerView.showSpinnerViewInView(self.view)
            var storeIDs = self.getAvailableRetailerIds()
            if self.grocery != nil{
                storeIDs = [self.grocery!.dbID]
            }
            AlgoliaApi.sharedInstance.searchProductWithBarCode(self.barcodeString,self.productId, storeIDs: storeIDs,searchType: "single_search")  { (data, error) in
                
                DispatchQueue.main.async {
                    spiner?.removeFromSuperview()
                }
                
                guard data != nil else {
                    return
                }
                if  let responseObject : NSDictionary = data as NSDictionary? {
                    Thread.OnMainThread {
                      
                        let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext, searchString: nil, nil, false)
                        
                        if newProducts.products.count > 0 {
                            DatabaseHelper.sharedInstance.saveDatabase()
                            self.product = newProducts.products[0]
                            self.configureProduct()
                            
                        }else{
                           elDebugPrint("no product found")
                            
                        }
                        self.checkNoDataView()
                    }
                }
            }
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


@objc public protocol ImageViewZoomDelegate: UIScrollViewDelegate {
    func imageScrollViewDidChangeOrientation(imageViewZoom: ImageViewZoom)
}

open class ImageViewZoom: UIScrollView {
    
    @objc public enum ScaleMode: Int {
        case aspectFill
        case aspectFit
        case widthFill
        case heightFill
    }
    
    @objc public enum Offset: Int {
        case begining
        case center
    }
    
    static let kZoomInFactorFromMinWhenDoubleTap: CGFloat = 2
    
    @objc open var imageContentMode: ScaleMode = .widthFill
    @objc open var initialOffset: Offset = .begining
    
    @objc public private(set) var zoomView: UIImageView? = nil
    
    @objc open weak var imageScrollViewDelegate: ImageViewZoomDelegate?
    
    var imageSize: CGSize = CGSize.zero
    private var pointToCenterAfterResize: CGPoint = CGPoint.zero
    private var scaleToRestoreAfterResize: CGFloat = 1.0
    var maxScaleFromMinScale: CGFloat = 3.0
    
    override open var frame: CGRect {
        willSet {
            if frame.equalTo(newValue) == false && newValue.equalTo(CGRect.zero) == false && imageSize.equalTo(CGSize.zero) == false {
                prepareToResize()
            }
        }
        
        didSet {
            if frame.equalTo(oldValue) == false && frame.equalTo(CGRect.zero) == false && imageSize.equalTo(CGSize.zero) == false {
                recoverFromResizing()
            }
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initialize() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        decelerationRate = UIScrollView.DecelerationRate.fast
        delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ImageViewZoom.changeOrientationNotification), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc public func adjustFrameToCenter() {
        
        guard let unwrappedZoomView = zoomView else {
            return
        }
        
        var frameToCenter = unwrappedZoomView.frame
        
        // center horizontally
        if frameToCenter.size.width < bounds.width {
            frameToCenter.origin.x = (bounds.width - frameToCenter.size.width) / 2
        }
        else {
            frameToCenter.origin.x = 0
        }
        
        // center vertically
        if frameToCenter.size.height < bounds.height {
            frameToCenter.origin.y = (bounds.height - frameToCenter.size.height) / 2
        }
        else {
            frameToCenter.origin.y = 0
        }
        
        unwrappedZoomView.frame = frameToCenter
    }
    
    private func prepareToResize() {
        let boundsCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        pointToCenterAfterResize = convert(boundsCenter, to: zoomView)
        
        scaleToRestoreAfterResize = zoomScale
        
        if scaleToRestoreAfterResize <= minimumZoomScale + CGFloat(Float.ulpOfOne) {
            scaleToRestoreAfterResize = 0
        }
    }
    
    private func recoverFromResizing() {
        setMaxMinZoomScalesForCurrentBounds()
        
        let maxZoomScale = max(minimumZoomScale, scaleToRestoreAfterResize)
        zoomScale = min(maximumZoomScale, maxZoomScale)
        
        let boundsCenter = convert(pointToCenterAfterResize, to: zoomView)
        
        var offset = CGPoint(x: boundsCenter.x - bounds.size.width/2.0, y: boundsCenter.y - bounds.size.height/2.0)
        
        let maxOffset = maximumContentOffset()
        let minOffset = minimumContentOffset()
        
        var realMaxOffset = min(maxOffset.x, offset.x)
        offset.x = max(minOffset.x, realMaxOffset)
        
        realMaxOffset = min(maxOffset.y, offset.y)
        offset.y = max(minOffset.y, realMaxOffset)
        
        contentOffset = offset
    }
    
    private func maximumContentOffset() -> CGPoint {
        return CGPoint(x: contentSize.width - bounds.width,y:contentSize.height - bounds.height)
    }
    
    private func minimumContentOffset() -> CGPoint {
        return CGPoint.zero
    }
    
    // MARK: - Set up
    
    open func setup() {
        var topSupperView = superview
        
        while topSupperView?.superview != nil {
            topSupperView = topSupperView?.superview
        }
        
        // Make sure views have already layout with precise frame
        topSupperView?.layoutIfNeeded()
    }
    
    // MARK: - Display image
    
    @objc open func display(image: UIImage) {
        
        if let zoomView = zoomView {
            zoomView.image = image
        }else{
             zoomView = UIImageView(image: image)
            zoomView!.isUserInteractionEnabled = true
            addSubview(zoomView!)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ImageViewZoom.doubleTapGestureRecognizer(_:)))
            tapGesture.numberOfTapsRequired = 2
            zoomView!.addGestureRecognizer(tapGesture)
             configureImageForSize(image.size)
        }

    }
    
    private func configureImageForSize(_ size: CGSize) {
        imageSize = size
        contentSize = imageSize
        setMaxMinZoomScalesForCurrentBounds()
        zoomScale = minimumZoomScale
        
        switch initialOffset {
            case .begining:
                contentOffset =  CGPoint.zero
            case .center:
                let xOffset = contentSize.width < bounds.width ? 0 : (contentSize.width - bounds.width)/2
                let yOffset = contentSize.height < bounds.height ? 0 : (contentSize.height - bounds.height)/2
                
                switch imageContentMode {
                    case .aspectFit:
                        contentOffset =  CGPoint.zero
                    case .aspectFill:
                        contentOffset = CGPoint(x: xOffset, y: yOffset)
                    case .heightFill:
                        contentOffset = CGPoint(x: xOffset, y: 0)
                    case .widthFill:
                        contentOffset = CGPoint(x: 0, y: yOffset)
            }
        }
    }
    
    private func setMaxMinZoomScalesForCurrentBounds() {
        // calculate min/max zoomscale
        let xScale = bounds.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = bounds.height / imageSize.height   // the scale needed to perfectly fit the image height-wise
        
        var minScale: CGFloat = 1
        
        switch imageContentMode {
            case .aspectFill:
                minScale = max(xScale, yScale)
            case .aspectFit:
                minScale = min(xScale, yScale)
            case .widthFill:
                minScale = xScale
            case .heightFill:
                minScale = yScale
        }
        
        
        let maxScale = maxScaleFromMinScale*minScale
        
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
        if minScale > maxScale {
            minScale = maxScale
        }
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale * 0.999 // the multiply factor to prevent user cannot scroll page while they use this control in UIPageViewController
    }
    
    // MARK: - Gesture
    
    @objc func doubleTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        // zoom out if it bigger than middle scale point. Else, zoom in
        if zoomScale >= maximumZoomScale / 2.0 {
            setZoomScale(minimumZoomScale, animated: true)
        }
        else {
            let center = gestureRecognizer.location(in: gestureRecognizer.view)
            let zoomRect = zoomRectForScale(ImageViewZoom.kZoomInFactorFromMinWhenDoubleTap * minimumZoomScale, center: center)
            zoom(to: zoomRect, animated: true)
        }
    }
    
    private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        
        zoomRect.size.height = frame.size.height / scale
        zoomRect.size.width  = frame.size.width  / scale
        
        // choose an origin so as to get the right center.
        zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0)
        zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
    open func refresh() {
        if let image = zoomView?.image {
            display(image: image)
        }
    }
    
    // MARK: - Actions
    
    @objc func changeOrientationNotification() {
        // A weird bug that frames are not update right after orientation changed. Need delay a little bit with async.
        DispatchQueue.main.async {
            self.configureImageForSize(self.imageSize)
            self.imageScrollViewDelegate?.imageScrollViewDidChangeOrientation(imageViewZoom: self)
        }
    }
}

extension ImageViewZoom: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        imageScrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        imageScrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        imageScrollViewDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        imageScrollViewDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustFrameToCenter()
        imageScrollViewDelegate?.scrollViewDidZoom?(scrollView)
    }
    
}
extension PopImageViwerViewController : ImageViewZoomDelegate {
    func imageScrollViewDidChangeOrientation(imageViewZoom: ImageViewZoom) {
     //  elDebugPrint("Did change orientation")
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
     //  elDebugPrint("scrollViewDidEndZooming at scale \(scale)")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
     //  elDebugPrint("scrollViewDidScroll at offset \(scrollView.contentOffset)")
    }
}
extension PopImageViwerViewController : NoStoreViewDelegate {
    
    func noDataButtonDelegateClick(_ state : actionState) -> Void{
        self.crossAction("")
    }
}


extension PopImageViwerViewController {
    
    
    func getBoughtItems () {
        
        AlgoliaApi.sharedInstance.getSuggestionForRelatableProducts(self.product?.objectId ?? "", stores: self.product?.groceryId != nil ? [self.product!.groceryId] : [] , type : ModelType.BoughtTogether , completion: { [weak self](responseObject, error) in
            
            if let response = responseObject?["results"] {
                if let data = response as? NSArray, data.count > 0, let final = data[0] as? NSDictionary {
                    Thread.OnMainThread {
                        let newProducts = Product.insertOrReplaceProductsFromDictionary(final, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        
                        self?.lblFrequentlyBought.isHidden = (newProducts.products.count == 0)
                        
                        
                        if newProducts.products.count > 0 {
                            self?.boughtItems = newProducts.products
                           // self?.topScrollView.contentSize = CGSize(width: ScreenSize.SCREEN_WIDTH, height: 1000)
                            self?.boughtItemView.visibility = .visible
                        }else {
                            self?.boughtItemView.visibility = .gone
                        }
                        self?.boughtItemView.collectionView?.reloadDataOnMainThread()
                    }
                }
            }
        })
    }
    
    
    func getRelatedItems () {
        
        AlgoliaApi.sharedInstance.getSuggestionForRelatableProducts(self.product?.objectId ?? "", stores: self.product?.groceryId != nil ? [self.product!.groceryId] : [] , type : ModelType.RelatedProducts , completion: { [weak self](responseObject, error) in
            
            if let response = responseObject?["results"] {
                if let data = response as? NSArray, data.count > 0, let final = data[0] as? NSDictionary {
                    Thread.OnMainThread {
                        let newProducts = Product.insertOrReplaceProductsFromDictionary(final, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        
                        self?.lblReatedTogether.isHidden = (newProducts.products.count == 0)
                        
                        if newProducts.products.count > 0 {
                            self?.relatedItems = newProducts.products
                                // self?.topScrollView.contentSize = CGSize(width: ScreenSize.SCREEN_WIDTH, height: 1000)
                            self?.relatedItemView.visibility = .visible
                        }else {
                            self?.relatedItemView.visibility = .goneY
                        }
                        self?.relatedItemView.collectionView?.reloadDataOnMainThread()
                    }
                }
            }
        })
    }
    
    
    
}
extension PopImageViwerViewController : ProductUpdationDelegate {
  func productUpdated(_ product : Product?) {
    DispatchQueue.main.async {
        self.boughtItemView.reloadData()
        self.relatedItemView.reloadData()
//        self.refreshBasketIconStatus()
    }
  }
}

extension PopImageViwerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == boughtItemView.collectionView {
            return boughtItems.count
        }
        return relatedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        if collectionView == boughtItemView.collectionView {
            let product =  boughtItems[indexPath.row]
            productCell.configureWithProduct(product, grocery: self.grocery, cellIndex: indexPath)
            
        }else {
            let product =  relatedItems[indexPath.row]
            productCell.configureWithProduct(product, grocery: self.grocery, cellIndex: indexPath)
        }
        let grocery = ElGrocerUtility.sharedInstance.activeGrocery
        productCell.delegate = productDelegate.setGrocery(grocery)
       // productCell.productPriceLabel.isHidden = true
        return productCell
    }
}
extension PopImageViwerViewController: UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            // create a cell size from the image size, and return the size
        let height = kProductCellHeight
        var cellSize:CGSize = CGSize(width: kProductCellWidth, height: height)
        return cellSize
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       
        return UIEdgeInsets(top: -5, left: 8 , bottom: 0 , right: 16)
    }
    
    
    
}
