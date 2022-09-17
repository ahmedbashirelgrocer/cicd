//
//  MyBasketViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 08/01/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseAnalytics
import IQKeyboardManagerSwift
import STPopup
import MaterialComponents.MaterialBottomSheet
import NBBottomSheet
import FirebaseCrashlytics
import RxSwift

protocol MyBasketViewProtocol : class {
    
    func shoppingBasketViewCheckOutTapped(_ isGroceryBasket:Bool, grocery:Grocery?, notAvailableItems:[Int]?, availableProductsPrices:NSDictionary?) -> Void
}

    //MARK:- BasketIconOverlayViewProtocol Methods
    //MARK:-

extension MyBasketViewController : BasketIconOverlayViewProtocol {
    func basketIconOverlayViewDidTouchBasket(_ basketIconOverlayView:BasketIconOverlayView) -> Void {  }
}

    //MARK:- MyBasketCheckOutDelegate Methods
    //MARK:-

extension MyBasketViewController : MyBasketCheckOut {
    
    func receivedReasonAndSelectedReason ( reasonA : [Reasons] , selectedReason : Int?) {
        elDebugPrint("getreasons")
        
        self.tblBasket.reloadDataOnMain()
    }
    
}

    //MARK:- NoStoreViewDelegate Methods
    //MARK:-

extension MyBasketViewController : NoStoreViewDelegate {
    
    func noDataButtonDelegateClick(_ state: actionState) {
        
        if self.tabBarController == nil {
            self.dismiss(animated: true, completion: nil)
            return
        }
        if self.grocery == nil {
            if let tabbarHidden = self.tabBarController?.tabBar.isHidden, tabbarHidden == true {
                self.navigationController?.popViewController(animated: true)
            }
            self.tabBarController?.selectedIndex = 0
            return
        }
        self.tabBarController?.selectedIndex = 1
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

class MyBasketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MyBasketCellProtocol   {
    
        //MARK:- IBOutlet
        //MARK:-
        //MARK: LayoutConstraint Outlets
    @IBOutlet var tblViewYPossition: NSLayoutConstraint!
    @IBOutlet var placeOrderViewHeight: NSLayoutConstraint!
    
        //MARK: Listing Outlets
    @IBOutlet weak var tblBasket: UITableView!
    @IBOutlet weak var customCollectionViewWithCarouselProducts: CarouselProductsView!
    
    
        //MARK: View outlets
    @IBOutlet var signView: AWView!
    @IBOutlet var viewAddAddress: AWView!
    @IBOutlet var tblFooterCheckOutView: AWView!
    @IBOutlet var checkOutViewForButton: AWView!
    @IBOutlet var viewForSearch: UIView!
    @IBOutlet var checkOutView: UIView!
    @IBOutlet var savedAmountBGView: UIView!{
        didSet{
            savedAmountBGView.backgroundColor = .promotionRedColor()
            savedAmountBGView.clipsToBounds = true
            savedAmountBGView.layer.cornerRadius = 8
            if ElGrocerUtility.sharedInstance.isArabicSelected(){
                    //savedAmountBGView.roundCorners(corners: [.topLeft , .bottomRight , .bottomLeft , .topRight], radius: 8)
                savedAmountBGView.layer.maskedCorners = [.layerMinXMinYCorner , .layerMaxXMaxYCorner ]
            }else{
                    //savedAmountBGView.roundCorners(corners: [.topRight , .bottomLeft], radius: 8)
                savedAmountBGView.layer.maskedCorners = [.layerMaxXMinYCorner , .layerMinXMaxYCorner]
            }
            savedAmountBGView.isHidden = true
        }
    }
    
        //MARK: Buttons outlets
    @IBOutlet var btnSignIn: AWButton!
    @IBOutlet var btnSIgnUp: AWButton!
    @IBOutlet var btnAddAddress: UIButton!
    @IBOutlet weak var checkoutBtn: UIButton!
    
        //MARK: Label outlets
    @IBOutlet weak var itemsCount: UILabel!
    @IBOutlet weak var itemsTotalPrice: UILabel!
    @IBOutlet var lblTopViewEdgeCaseMsg: UILabel!
    @IBOutlet weak var lblRecomendedItems: UILabel! {
        didSet {
            lblRecomendedItems.text = localizedString("carousel_View_Title", comment: "")
        }
    }
    @IBOutlet var lblSavedAmount: UILabel!{
        didSet{
            lblSavedAmount.setCaptionTwoSemiboldYellowStyle()
            
        }
    }
    @IBOutlet var lblPlaceOrderTitle: UILabel! {
        didSet{
            lblPlaceOrderTitle.text =  localizedString("shopping_basket_payment_button", comment: "")
        }
    }
    @IBOutlet var lblApplePayTitle: UILabel! {
        didSet{
            lblApplePayTitle.setH3SemiBoldWhiteStyle()
            lblApplePayTitle.text =  localizedString("place_apple_pay_title_label", comment: "")
        }
    }
    
    @IBOutlet weak var minOrderLabel: UILabel!
    
    //MARK: ImageView outlets
    @IBOutlet var imgViewTopCardView: UIImageView!
    @IBOutlet var imgbasketArrow: UIImageView!
    @IBOutlet weak var minOrderImageView: UIImageView!
    
    @IBOutlet weak var minOrderProgressView: UIProgressView!
    
        //MARK:- Variables
        //MARK:-
    
        //MARK: Cell Identifiers
    static let kShoppingBasketCellIdentifier = "BasketCell"
    
        //MARK: Allocated Obj
    var userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    var myBasketDataObj = MyBasket.init()
    var carouselProductsArray:[Product] = [Product]()
    var replaceProductsList : [Product] = [Product]()
    var carouselProducts = [AnyObject]()
    var deliverySlotsArray:[DeliverySlot] = [DeliverySlot]()
    var currentDeliverySlot:DeliverySlot!
    var orderToReplace : Bool =  UserDefaults.isOrderInEdit()
    var substituteProduct : Dictionary< String , Array<Product> > = Dictionary()
    var shoppingItems:[ShoppingBasketItem]!
    var products:[Product] = [Product]()
    var availableProducts:[Product] = [Product]()
    var notAvailableProductsList:[Product] = [Product]()
    var outOfStockProducts:[Product]!
    var notAvailableProducts:[Int]?
    
    
        //MARK: Height Constants
    let kShoppingBasketCellHeight: CGFloat = 147
    let KFooterHeight : CGFloat = 248.0
    let notAvailableProductSectionNumber = 2
    
        //MARK: Invoice Var
    var priceSum = 0.00
    var itemsQuantity = 0
    var discountedPrice = 0.00
    var serviceFee = 0.0
    
        //MARK: Bool Var
    
    var isComingFromReplacement = false
    var isAddressCompleted = false
    var isNextSlotAvailable = true
    var isDeliveryMode = true
    var isPromoCheckedForEditOrder = true
    var promotionalItemChanged : Bool = false
    var bottomHiding = false
    var shouldShowGroceryActiveBasket:Bool?
    var groceryStatus = false
    var isOutOfStockProductAvailable = false
    // if true show OOS products substituted items will not be considered as available
    var isOutOfStockProductAvailablePreCart = false
    var isFromOrderbanner = false
    var isNeedToHideBackButton = false
    var isItemOOSCellsNeedToExpand = true
    
        //MARK: IndexPath Var
    var promoCellIndex : NSIndexPath = NSIndexPath.init(row: 1, section: 2)
    var selectedIndex : IndexPath? = nil
    
    
        //MARK: Custom obj var
    var order:Order!
    var currentAddress : DeliveryAddress?
    var availableProductsPrices:NSDictionary = [:]
    var selectedProduct:Product!
    var grocery:Grocery?
    var groceryFetchRetry: Int = 0
    
        //MARK: String var
    var orderTypeDescription = ""
    var promotionalItemChangedMessage : String = ""
    
        //MARK: DispatchWorkItem Var
    private var carouselWorkItem:DispatchWorkItem?
    var getPaymentWorkItem:DispatchWorkItem?
    var basketWorkItem:DispatchWorkItem?
    var slotWorkItem:DispatchWorkItem?
    
        //MARK: View Var
    var myBasketOutOfStockInfo : MyBasketOutOfStockInfo = {
        let locationHeader = MyBasketOutOfStockInfo.loadFromNib()
        locationHeader?.configure()
        locationHeader?.alpha = 1
        return locationHeader!
    }()
    lazy var locationHeader : ElgrocerlocationView = {
        let locationHeader = ElgrocerlocationView.loadFromNib()
        return locationHeader!
    }()
    lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.delegate = self
        noStoreView?.configureNoDefaultSelectedStoreCart()
        return noStoreView!
    }()
    
    var searchBar:CategorySearchBar!
    
    
        //MARK: Float & Double Var
    var scrollY: CGFloat = 0
    var purchasedItemCount = 0
    var itemsSummaryValue:Double = 0
    var minimumBasketValueForGrocery:Double {
        return self.grocery?.minBasketValue ?? 0.0
    }
    
        //MARK: delegate weak var
    weak var delegate:MyBasketViewProtocol?
    
    
    
    
    
        // MARK:- Life cycle Start
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addCustomTitleViewWithTitle(localizedString("shopping_basket_title_label", comment: ""))
        self.setUpIQKeyBoard()
        
        self.setUpOrderData()
        self.registeredCell()
        self.setUpView()
        self.addClousure()
        self.addNotification()
        
        if UserDefaults.isOrderInEdit() {
            isPromoCheckedForEditOrder = false
        }
        self.viewAddAddress.isHidden = true
        self.signView.isHidden = true
        hidesBottomBarWhenPushed = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let topVc = UIApplication.topViewController()
        guard !(topVc is ReplacementViewController) else {
            self.isComingFromReplacement = true
            return
        }
        updateGroceryData()
        self.myBasketDataObj.getReasons()
        self.isItemOOSCellsNeedToExpand = self.myBasketDataObj.getSelectedReason() == nil
        if UserDefaults.isUserLoggedIn() {
            let _ = SpinnerView.showSpinnerViewInView(self.view)
            self.tblBasket.isHidden = true
            self.checkOutView.isHidden = true
        }
        
        self.setUpBasicArabicAppearance()
        if UIApplication.topViewController() is CreditCardListViewController {
            
        }else{
            self.tblBasket.setContentOffset(.zero, animated: true)
        }
   
        //hide tabbar
        self.hideTabBar()
        self.navigationItem.hidesBackButton = true
        self.basketIconOverlay?.shouldShow = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsBasketScreen)
        FireBaseEventsLogger.setScreenName( FireBaseScreenName.MyBasket.rawValue , screenClass: String(describing: self.classForCoder))
        self.setUpNavigationAppearance()
        self.orderToReplace = ( UserDefaults.isOrderInEdit() && self.order != nil )
        if self.orderToReplace && self.order != nil {
            self.isDeliveryMode = !self.order.isCandCOrder()
            if self.order.isCandCOrder() {
                if let vehicleID = self.order.vehicleDetail?.dbID?.intValue {
                    UserDefaults.setCurrentSelectedCar(vehicleID)
                }
                if let collectorId = self.order.collector?.dbID.intValue {
                    UserDefaults.setCurrentSelectedCollector(collectorId)
                }
            }else{
                self.isDeliveryMode = ElGrocerUtility.sharedInstance.isDeliveryMode
            }
        }else {
            self.isDeliveryMode = ElGrocerUtility.sharedInstance.isDeliveryMode
        }

        self.reloadTableData()
        self.setControlerTitle()
        if self.isComingFromReplacement {
            self.isComingFromReplacement = false
            return
        }
        self.refreshBasketIcon()
        self.getAllBasketData()
        
        self.refreshBasketIcon()
        if let groceryA = self.grocery {
            self.checkIsAddressFull(groceryA)
        }
        let _ = self.getFinalAmount()
        
        //hide tabbar
        self.hideTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        
        if let item = self.basketWorkItem {
            item.cancel()
        }
        if let item = self.slotWorkItem {
            item.cancel()
        }
        
    }
    
        // MARK: Life cycle End
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
    
        // MARK:- SetUp Methods
    
    func setUpIQKeyBoard() {
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 40
        IQKeyboardManager.shared.toolbarBarTintColor = .white
    }
    
    
    func setUpBasicArabicAppearance() {
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            
            self.imgbasketArrow.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.imgbasketArrow.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
        
    }
    
    func setUpNavigationAppearance() {

        self.navigationController?.navigationBar.isHidden = false
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.hideSeparationLine()
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
    }
    
    func setControlerTitle() {
        if self.orderToReplace {

            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
            self.title = localizedString("Edit_Basket_Title", comment: "")
            self.addCustomTitleViewWithTitleDarkShade(localizedString("Edit_Basket_Title", comment: "") , true)
            self.navigationItem.hidesBackButton = true
            self.lblPlaceOrderTitle.text = localizedString("place_order_title_label", comment: "")   // place_order_title_label localizedString("confirm_button_title", comment: "").uppercased()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        }else{
            self.title = localizedString("Cart_Title", comment: "")
            if self.isDeliveryMode{
                
                self.addCustomTitleViewWithTitleDarkShade(localizedString("Cart_Title", comment: "") , true)
            }else{
                    self.title = localizedString("cart_title_ClickAndCollect", comment: "")
                self.addCustomTitleViewWithTitleDarkShade(localizedString("cart_title_ClickAndCollect", comment: "") , true)
            }
            
                // addBackButton()
            
        }
    }
    
    func refreshBasketIcon() {
        
        if ElGrocerUtility.sharedInstance.activeGrocery != nil {
            addBasketIconOverlay(self, grocery: ElGrocerUtility.sharedInstance.activeGrocery, shouldShowGroceryActiveBasket:  ElGrocerUtility.sharedInstance.activeGrocery != nil)
            self.basketIconOverlay?.grocery = ElGrocerUtility.sharedInstance.activeGrocery
            self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
            self.refreshBasketIconStatus()
        }
        
    }
    
        // MMARK:- Basket Data
    
    func getAllBasketData() {
        
        self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
        if UserDefaults.isUserLoggedIn() && !self.orderToReplace {
            
            self.basketWorkItem = DispatchWorkItem {
                DispatchQueue.main.async {
                    self.getBasketFromServerWithGrocery(self.grocery)
                }
            }
            DispatchQueue.global(qos: .default).async(execute: self.basketWorkItem!)
        }else{
            
            if self.products.count > 0 {
                self.basketWorkItem = DispatchWorkItem {
                    DispatchQueue.main.async {
                        self.getBasketFromServerWithGrocery(self.grocery)
                    }
                }
                DispatchQueue.global(qos: .default).async(execute: self.basketWorkItem!)
                return
            }
            
            let _ = SpinnerView.showSpinnerViewInView(self.view)
            ElGrocerUtility.sharedInstance.delay(1) {
                self.checkData()
                ElGrocerUtility.sharedInstance.delay(0.2) {
                    self.checkData()
                    self.loadShoppingBasketData()
                    self.reloadTableData()
                }
                ElGrocerUtility.sharedInstance.delay(0.5) {
                    self.tblBasket.isHidden = false
                    SpinnerView.hideSpinnerView()
                }
            }
            
        }
        
    }
    
    func updateGroceryData() {
        
        if let retailer = ElGrocerUtility.sharedInstance.activeGrocery,let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() {
            let groceryChangeObj = GroceryChangeHandler()
            groceryChangeObj.delegate = self
            SpinnerView.showSpinnerView()
            if ElGrocerUtility.sharedInstance.isDeliveryMode {
                groceryChangeObj.updateDeliveryGroceryData(retailerId: retailer.getCleanGroceryID(), lat: "\(address.latitude)", lng: "\(address.longitude)")
            }else {
                groceryChangeObj.updateCandCGroceryData(retailerId: retailer.getCleanGroceryID(), lat: "\(address.latitude)", lng: "\(address.longitude)")
            }
        }
    }
    
    
    func checkData() {
        
        if self.grocery != nil {
            self.refreshViewWithOutPop()
        }
        if  self.grocery  != nil && self.products.count == 0 {
            self.checkNoProductView()
            self.placeOrderViewHeight.constant = 0
            self.tblViewYPossition.constant = 0
            self.checkOutView.isHidden = true
            self.slotWorkItem = DispatchWorkItem {
                self.updateSlotsAndChooseNextAvailable(false)
            }
            DispatchQueue.global(qos: .utility).async(execute: self.slotWorkItem!)
            self.setOrderTypeLabelText()
            callForCarouselProduct()
            
        }  else if let _ = self.grocery {
            self.tblBasket.backgroundView = nil
            let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
            self.userProfile = UserProfile.getUserProfile(context)
            if let _ = userProfile  {
                self.tblViewYPossition.constant = 0
            }else{
                self.tblViewYPossition.constant = 150
            }
                //  self.progressHeader.isHidden = false
            self.checkOutView.isHidden = false
            self.placeOrderViewHeight.constant = 77+36
            self.setSummaryData()
            
            self.updateSlotsAndChooseNextAvailable(false)
            self.setOrderTypeLabelText()
                // self.setTableViewHeader(grocery)
            self.reloadTableData()
            
            callForCarouselProduct()
        }else{
            checkNoDataView()
            self.placeOrderViewHeight.constant = 0
            self.tblViewYPossition.constant = 0
            self.checkOutView.isHidden = true
        }
        
        
        if let groceryA = self.grocery {
            self.checkIsAddressFull(groceryA)
        }
        
        if !self.isAddressCompleted && (userProfile != nil) && (self.grocery != nil)  {
            self.signView.isHidden = false
            self.tblViewYPossition.constant = 160
            self.lblTopViewEdgeCaseMsg.text = localizedString("lbl_myBasket_add_Address", comment: "")
            self.imgViewTopCardView.image = UIImage(name: "addAddress")
            self.btnAddAddress.setTitle(localizedString("btn_add_address_alert_title", comment: ""), for: .normal)
            self.viewAddAddress.isHidden = false
        } else if userProfile == nil && self.grocery != nil {
            self.signView.isHidden = false
            self.tblViewYPossition.constant = 150
            self.lblTopViewEdgeCaseMsg.text = localizedString("lbl_myBasket_signInSIgnUp", comment: "")
            self.imgViewTopCardView.image = UIImage(name: "MYBasketSignInView")
            self.viewAddAddress.isHidden = true
            self.btnSignIn.setTitle(localizedString("area_selection_login_button_title", comment: ""), for: .normal)
            self.btnSIgnUp.setTitle(localizedString("Sign_up", comment: ""), for: .normal)
            
        } else {
            self.tblViewYPossition.constant = 10
            self.viewAddAddress.isHidden = true
            self.signView.isHidden = true
            

        }
        
        if  self.orderToReplace  {
            self.tblViewYPossition.constant = 76
            self.view.bringSubviewToFront(self.viewForSearch)
        }
        
    }
    
    func setUpOrderData() {
        
        if self.order != nil {
            if let currentUserProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                if let paymentAvailable = self.order!.payementType {
                    let storeId = ElGrocerUtility.sharedInstance.cleanGroceryID(self.order.grocery.dbID)
                    UserDefaults.setPaymentMethod(paymentAvailable.uint32Value, forStoreId: storeId)
                    if paymentAvailable.uint32Value == PaymentOption.creditCard.rawValue {
                        if let cardID = self.order.cardID {
                            UserDefaults.setCardID(cardID: cardID  , userID: currentUserProfile.dbID.stringValue)
                        }
                    }
                }
            }
        }
    }
    
    
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
                    self.reloadTableData()
            }
        }
        
    }
    
    func saveCarouselProductResponseForCategory(_ response: NSDictionary) {
        
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        context.performAndWait({ () -> Void in
            let newProduct = Product.insertOrReplaceCarouselFromDictionary(response, context:context)
            self.carouselProducts = [AnyObject]()
                // if product is already added to basket it will not display in carousel products
            for productData in newProduct {
                
                if let _ = ShoppingBasketItem.checkIfProductIsInBasket(productData , grocery: grocery, context: context) {
                    
                }else{
                    self.carouselProducts.append(productData)
                }
            }
            
                //indexPath.section == 2
            
            
            self.reloadTableData()
        })
    }
    
        // MARK: Address check
    
    func checkIsAddressFull (_ grocery : Grocery) {
        
        self.isAddressCompleted = self.isDeliveryMode ? false : true
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        guard userProfile != nil else {
            return
        }
        if let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            currentAddress = deliveryAddress
            let isDataFilled = ElGrocerUtility.sharedInstance.validateUserProfile(userProfile, andUserDefaultLocation: deliveryAddress)
            if isDataFilled {
                self.isAddressCompleted = true
            }
        }
    }
    
        // MARK: No data check methods
    
    func checkNoDataView() {
        
        if self.grocery == nil {
            
            self.NoDataView.configureNoDefaultSelectedStoreCart()
            self.tblBasket.backgroundView = self.NoDataView
            self.NoDataView.setNeedsLayout()
            self.NoDataView.layoutIfNeeded()
            self.tblBasket.setNeedsLayout()
            self.tblBasket.layoutIfNeeded()
            self.tblBasket.reloadDataOnMain()
            self.tblViewYPossition.constant = 0
            
            SpinnerView.hideSpinnerView()
            
        } else {
            self.tblBasket.backgroundView = UIView()
            self.reloadTableData()
        }
    }
    
    func checkNoProductView() {
        
        self.NoDataView.configureNoCart()
        self.tblBasket.backgroundView = self.NoDataView
            //self.NoDataView.imageCenterPosstion.setMultiplier(multiplier: 0.73)
        self.NoDataView.btnBottomConstraint.constant = 0
        self.tblBasket.reloadDataOnMain()
        self.NoDataView.setNeedsLayout()
        self.NoDataView.layoutIfNeeded()
        self.tblBasket.setNeedsLayout()
        self.tblBasket.layoutIfNeeded()
        self.tblViewYPossition.constant = 0
        
        self.checkOutView.isHidden = true
        
    }
    
    func refreshDataInViewWillAppear() {
        self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
        if  let navMain  = self.tabBarController?.viewControllers?[1] as? UINavigationController  {
            if navMain.viewControllers.count > 0 {
                if let mainVC =   navMain.viewControllers[0] as? MainCategoriesViewController {
                    self.showShoppingBasket(delegate: mainVC , shouldShowGroceryActiveBasket: (self.grocery != nil || self.shouldShowGroceryActiveBasket != nil), selectedGroceryForItems: nil, notAvailableProducts: nil, availableProductsPrices: nil)
                }
            }
        }
            // self.loadShoppingBasketData()
        if !UserDefaults.isUserLoggedIn()  {  self.loadShoppingBasketData()  }
        
        
    }
    
    
    
    
    func registeredCell () {
        
        self.tblBasket.estimatedRowHeight = UITableView.automaticDimension
        self.tblBasket.rowHeight = UITableView.automaticDimension
        
        let questionareCell = UINib(nibName: "QuestionareCell", bundle: Bundle.resource)
        self.tblBasket.register(questionareCell, forCellReuseIdentifier: "QuestionareCell")
        
        let itemOOS = UINib(nibName: "ItemsOutOfStockQuestionnaire", bundle: Bundle.resource)
        self.tblBasket.register(itemOOS, forCellReuseIdentifier: "ItemsOutOfStockQuestionnaire")
        
        let candCGetDetailTableViewCell = UINib(nibName: "CandCGetDetailTableViewCell", bundle: Bundle.resource)
        self.tblBasket.register(candCGetDetailTableViewCell, forCellReuseIdentifier: "CandCGetDetailTableViewCell")
        
        let subsitutionActionButtonTableViewCell = UINib(nibName: "SubsitutionActionButtonTableViewCell", bundle: Bundle.resource)
        self.tblBasket.register(subsitutionActionButtonTableViewCell, forCellReuseIdentifier: "SubsitutionActionButtonTableViewCell")
        
        let myBasketProgressTableViewCell = UINib(nibName: "MyBasketProgressTableViewCell" , bundle: Bundle.resource)
        self.tblBasket.register(myBasketProgressTableViewCell, forCellReuseIdentifier: "MyBasketProgressTableViewCell")
        
        let myBasketStroreNameTableViewCell = UINib(nibName: "MyBasketStroreNameTableViewCell" , bundle: Bundle.resource)
        self.tblBasket.register(myBasketStroreNameTableViewCell, forCellReuseIdentifier: "MyBasketStroreNameTableViewCell")
        
        
        let myBasketDeliveryDetailsTableViewCell = UINib(nibName: "MyBasketDeliveryDetailsTableViewCell" , bundle: Bundle.resource)
        self.tblBasket.register(myBasketDeliveryDetailsTableViewCell, forCellReuseIdentifier: "MyBasketDeliveryDetailsTableViewCell")
        
        
        let carosalCell = UINib(nibName: "MyBasketCarousalTableViewCell" , bundle: Bundle.resource)
        self.tblBasket.register(carosalCell, forCellReuseIdentifier: "MyBasketCarousalTableViewCell")
        
        
        
        let myBasketPromoAndPaymentTableViewCell = UINib(nibName: "MyBasketPromoAndPaymentTableViewCell" , bundle: Bundle.resource)
        self.tblBasket.register(myBasketPromoAndPaymentTableViewCell, forCellReuseIdentifier: "MyBasketPromoAndPaymentTableViewCell")
        
        
        let productImageCell = UINib(nibName: KProductsImagesTableViewCellIdentifier , bundle: Bundle.resource)
        self.tblBasket.register(productImageCell, forCellReuseIdentifier: KProductsImagesTableViewCellIdentifier)
        
        
        let replaceProductCell = UINib(nibName: "MyBasketReplaceProductTableViewCell", bundle: Bundle.resource)
        self.tblBasket.register(replaceProductCell, forCellReuseIdentifier: KMyBasketReplaceProductIdentifier)
        
        
        let instructionCell = UINib(nibName: "MyBasketInstructionTableViewCell", bundle: Bundle.resource)
        self.tblBasket.register(instructionCell, forCellReuseIdentifier: "MyBasketInstructionTableViewCell")
        
        let warningCell = UINib(nibName: "warningAlertCell", bundle: Bundle.resource)
        self.tblBasket.register(warningCell, forCellReuseIdentifier: "warningAlertCell")
        
        let genericViewTitileTableViewCell = UINib(nibName: KGenericViewTitileTableViewCell, bundle: Bundle.resource)
        self.tblBasket.register(genericViewTitileTableViewCell, forCellReuseIdentifier: KGenericViewTitileTableViewCell)
        
        let spaceTableViewCell = UINib(nibName: "SpaceTableViewCell", bundle: Bundle.resource)
        self.tblBasket.register(spaceTableViewCell, forCellReuseIdentifier: "SpaceTableViewCell")
        
        
            // self.tblBasket.tableFooterView = tblFooterCheckOutView
        
        searchBar = Bundle.resource.loadNibNamed("CategorySearchBar", owner: self, options: nil)![0] as? CategorySearchBar
        searchBar.delegate = self
        
        self.myBasketDataObj.delegate = self
        
        
    }
    
    func addClousure() {
        
        
        self.customCollectionViewWithCarouselProducts.addNewProduct = { [weak self] (productCell,product , loadedProductsCount) in
            guard let self = self  else {
                return
            }
            
            self.selectedProduct = product
            var counter = self.getItemCounterWithProduct(self.selectedProduct)
            counter += 1
            
            ShoppingBasketItem.addOrUpdateProductInBasket(self.selectedProduct, grocery: self.grocery, brandName: nil, quantity: counter , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            DatabaseHelper.sharedInstance.saveDatabase()
            
            self.shoppingItems = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            self.products.append(product)
            
            self.reloadTableData()
            self.checkIfOutOfStockProductAvailable()
            self.setSummaryData()
            
            var footerHeight : CGFloat = self.KFooterHeight
            if loadedProductsCount == 0   {
                footerHeight = 0
            }
            self.tblFooterCheckOutView.frame = CGRect.init(x: self.tblFooterCheckOutView.frame.origin.x, y: self.tblFooterCheckOutView.frame.origin.y, width: self.tblFooterCheckOutView.frame.size.width, height: footerHeight)
            self.setFooterAgain()
            
            let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
            let userProfile = UserProfile.getUserProfile(context)
            context.performAndWait({ [unowned self] in
                
                let productID = Product.getCleanProductId(fromId: self.selectedProduct!.dbID)
                let groceryID = Int64(Grocery.getGroceryIdForGrocery(self.grocery))
                let userID = Int64(truncating: userProfile?.dbID ?? 0)
                CarouselProducts.createOrUpdateCarouselCart(dbID: Int64(productID) , groceryID: groceryID ?? -1, userID: userID , name: self.selectedProduct.name ?? "", context: context)
                
                if let _ = self.selectedProduct.name {
                    ElGrocerEventsLogger.sharedInstance.addToCart(product: self.selectedProduct , "", "", true, nil)
                    
                }
            })
        }
        
        self.customCollectionViewWithCarouselProducts.ProductLoaded = { [weak self] (loadedProductsCount) in
            
            guard let self = self else {return}
            guard  self.products != nil else {return}
            
            let productCount = self.products.count
            var footerHeight : CGFloat = self.KFooterHeight
            if loadedProductsCount == 0   {
                footerHeight = 0
            }
            let updateMultiplier = 1.0
            if loadedProductsCount > 0 && productCount == 0 {
                    //footerHeight = 568
                    // updateMultiplier = 0.5
                if self.orderToReplace {
                        //   updateMultiplier = 0.40
                }
            }
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let self = self else {return}
                self.tblFooterCheckOutView.frame = CGRect.init(x: self.tblFooterCheckOutView.frame.origin.x, y: self.tblFooterCheckOutView.frame.origin.y, width: self.tblFooterCheckOutView.frame.size.width, height: footerHeight)
                self.setFooterAgain()
                self.customCollectionViewWithCarouselProducts.isHidden =  productCount > 0 && loadedProductsCount == 0
            })
            
        }
        
    }
    
    
    func addNotification() {
        
        NotificationCenter.default.addObserver(self,selector: #selector(MyBasketViewController.refreshViewForEdit), name: NSNotification.Name(rawValue: kBasketUpdateForEditNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(MyBasketViewController.startCheckOutProcess), name: NSNotification.Name(rawValue: kStartCheckOutProcessKey), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(MyBasketViewController.resetData), name: NSNotification.Name(rawValue: "resetBasketObjData"), object: nil)
    }
    
    fileprivate func setFooterAgain() {
        
        guard self.grocery != nil else {
            self.tblBasket.tableFooterView = UIView()
            self.tblBasket.reloadDataOnMain()
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
            return
        }
    }
    
    @objc fileprivate func resetData() {
        
        self.myBasketDataObj.order = nil
    }
    
    func showShoppingBasket(delegate:MyBasketViewProtocol?, shouldShowGroceryActiveBasket:Bool, selectedGroceryForItems:Grocery?, notAvailableProducts:[Int]?, availableProductsPrices:NSDictionary?){
        
        self.shouldShowGroceryActiveBasket = shouldShowGroceryActiveBasket
        self.notAvailableProducts = notAvailableProducts
        self.availableProductsPrices = availableProductsPrices ?? [:]
        self.delegate = delegate
        
        if shouldShowGroceryActiveBasket {
            
            if (self.order != nil){
                self.grocery = order.grocery
            }else{
                self.grocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            }
            
        }else {
            self.grocery = selectedGroceryForItems
        }
        
        if ElGrocerUtility.sharedInstance.activeGrocery != nil {
            
            if self.grocery == nil {
                self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
            }
            let isBasketForOtherGroceryActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive(ElGrocerUtility.sharedInstance.activeGrocery!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            if isBasketForOtherGroceryActive {
                ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                DatabaseHelper.sharedInstance.saveDatabase()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
                ElGrocerUtility.sharedInstance.resetBasketPresistence()
                self.navigationController?.popViewController(animated: true)
            }else{
                if UserDefaults.isUserLoggedIn() && isFromOrderbanner == false {
                    self.getBasketFromServerWithGrocery(self.grocery)
                }
            }
        }
    }
    
    /* ----- SetUp method is called to set all view appearence in controller ----- */
    func setUpView(){
        
        customCollectionViewWithCarouselProducts.collectionView?.backgroundColor = .clear
        self.tblBasket.separatorColor = UIColor.borderGrayColor()
        self.tblBasket.separatorInset = UIEdgeInsets.zero
        self.tblBasket.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)//UIColor.white
        self.view.backgroundColor = .navigationBarWhiteColor()//#colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)// UIColor.white
        
        if  self.orderToReplace  {
            self.searchBar.frame = CGRect.init(x: 0, y: 0, width: self.viewForSearch.frame.size.width , height: self.viewForSearch.frame.size.height)
            self.searchBar.backgroundColor = .navigationBarColor()
            self.viewForSearch.backgroundColor = .navigationBarColor()
            self.viewForSearch.addSubview(self.searchBar)
        }
        
        self.setupBottomView()
        self.setUpCheckoutButtonAppearance()
        self.setSummaryData()
        
        //self.checkOutView.alpha = 0.0
        self.tblFooterCheckOutView.alpha = 0.0
    }
    
    fileprivate func setupBottomView(){
        
        if LanguageManager.sharedInstance.getSelectedLocale().caseInsensitiveCompare("ar") == ComparisonResult.orderedSame {
            self.itemsCount.textAlignment       = .natural //NSTextAlignment.left
            self.itemsTotalPrice.textAlignment  = .natural //NSTextAlignment.left
        }
        
    }
    
    fileprivate func setUpCheckoutButtonAppearance() {
        
        self.checkOutView.roundTopWithTopShadow(radius: 8)
//        self.checkOutView.layer.cornerRadius = 10.0
//            // shadow
//        self.checkOutView.layer.shadowColor = UIColor.black.cgColor
//        self.checkOutView.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
//        //self.checkOutView.layer.shadowOffset = CGSize(width: 0, height: -4)
//        self.checkOutView.layer.shadowOpacity = 0.5
//        self.checkOutView.layer.shadowRadius = 8.0 // 3.0
        
    }
    
    fileprivate func setCheckoutButtonEnabled(_ enabled:Bool) {
        
        if DispatchQueue.isRunningOnMainQueue {
            self.checkoutBtn.isEnabled = enabled
            self.checkoutBtn.alpha = enabled ? 1 : 0.3
            self.checkOutViewForButton.backgroundColor  = enabled ? UIColor.navigationBarColor() : UIColor.disableButtonColor()
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.checkoutBtn.isEnabled = enabled
            self.checkoutBtn.alpha = enabled ? 1 : 0.3
            self.checkOutViewForButton.backgroundColor  = enabled ? UIColor.navigationBarColor() : UIColor.disableButtonColor()
        }
        
    }
    
        // MARK: Actions
    override func backButtonClick() {
        
        
        if self.orderToReplace {
            UserDefaults.resetEditOrder(false)
        }
        
        if self.tabBarController?.selectedIndex == 4 && self.navigationController?.viewControllers.count == 1 {
            self.tabBarController?.selectedIndex = 1
            return
        }
        
        if self.orderToReplace{
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        MixpanelEventLogger.trackCartclose()
        NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func plusButtonClick() {
        self.goToHomeScreen()
        self.navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
    }
    
    override func deleteButtonClick() {
        
        ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description:localizedString("Del_Alert_Text", comment: ""),positiveButton: localizedString("remove_button_title", comment: ""),negativeButton: localizedString("products_adding_different_grocery_alert_cancel_button", comment: ""),buttonClickCallback: { (buttonIndex:Int) -> Void in
            
            if buttonIndex == 0 {
                    //clear active basket and add product
                
                if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                    self.deleteBasketFromServerWithGrocery(grocery)
                    FireBaseEventsLogger.trackClearBasket()
                }
                ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)//
                
                DatabaseHelper.sharedInstance.saveDatabase()
                ElGrocerUtility.sharedInstance.resetBasketPresistence()
                
                self.products = [] // reset products
                self.checkIfBasketIsClear()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
                
                
            }else{ }
            
        }).show()
        
        
    }
    
    
    func deleteBasketFromServerWithGrocery(_ grocery:Grocery?){
        
        guard UserDefaults.isUserLoggedIn() else {return}
        
        ElGrocerApi.sharedInstance.deleteBasketFromServerWithGrocery(grocery) { (result) in
            switch result {
                case .success(let responseDict):
                   elDebugPrint("Delete Basket Response:%@",responseDict)
                    
                case .failure(let error):
                   elDebugPrint("Delete Basket Error:%@",error.localizedMessage)
            }
        }
    }
    
    
    func goToHomeScreen() {
        
        ElGrocerUtility.sharedInstance.tabBarSelectedIndex = 1
        let SDKManager = SDKManager.shared
        if let nav = SDKManager.rootViewController as? UINavigationController {
            if nav.viewControllers.count > 0 {
                if  nav.viewControllers[0] as? UITabBarController != nil {
                    let tababarController = nav.viewControllers[0] as! UITabBarController
                    tababarController.selectedIndex = ElGrocerUtility.sharedInstance.tabBarSelectedIndex
                    return
                }
            }
        }
        
    }
    
    func checkSavedAmount() {
        
        
        self.getTotalShoppingAmount()
        let _ = self.getFinalAmount()
        let _ = self.getFinalAmountToDisplay()
        
        var discountedPriceIs : Double = 0.0
        if let promoCodeValue = UserDefaults.getPromoCodeValue() {
            
            discountedPriceIs = self.getTotalSavingsAmountWithoutPromo()
            if discountedPriceIs > 0{
                
                
                    // for cart above place order button
                self.savedAmountBGView.isHidden = false
                self.lblSavedAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: discountedPriceIs) + " " + localizedString("txt_Saved", comment: "")
                self.savedAmountBGView.layoutIfNeeded()
                
                    //                    lblPromoCodeDiscount.isHidden = true
                    //                    lblPromoDiscountValue.isHidden = true
            }
        }else{
            discountedPriceIs = self.getTotalSavingsAmountWithoutPromo()
            if discountedPriceIs > 0{
                    // for cart above place order button
                
                self.savedAmountBGView.isHidden = false
                self.lblSavedAmount.text = localizedString("aed", comment: "") + discountedPriceIs.formateDisplayString() + " " + localizedString("txt_Saved", comment: "")
                self.savedAmountBGView.layoutIfNeeded()
            }
        }
        if discountedPriceIs == 0{
            self.savedAmountBGView.isHidden = true
        }
        
    }
    
    
    @IBAction func addItems(_ sender: AnyObject) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func signInAction(_ sender: Any) {
        showSignInVC()
    }
    @IBAction func signUpAction(_ sender: Any) {
        showRegistrationVC()
    }
    
    fileprivate func showSignInVC(){
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("LogIn")
        let signInVC = ElGrocerViewControllers.signInViewController()
        signInVC.isForLogIn = true
        signInVC.isCommingFrom = .cart
        signInVC.dismissMode = .dismissModal
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [signInVC]
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
        
    }
    
    fileprivate func showRegistrationVC(){
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("CreateAccount")
        let signInVC = ElGrocerViewControllers.signInViewController()
        signInVC.isForLogIn = false
        signInVC.isCommingFrom = .cart
        signInVC.dismissMode = .dismissModal
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [signInVC]
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
        
        
            //        if let navController = self.navigationController {
            //            navController.viewControllers = [registrationVC]
            //            navController.modalPresentationStyle = .fullScreen
            //            present(navController, animated: true, completion: nil)
            //        }
    }
    
    func checkIsOverLimitProductAvailable(_ grocery : Grocery?) -> Product? {
        
        var overLimitProduct : Product? = nil
        for product in products {
            
            if let item = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                
                
                let itemCount = item.count.doubleValue
                var promoLimit = 0.0
                if let promotionAvailable = product.promotion , promotionAvailable == true {
                    promoLimit = product.promoProductLimit?.doubleValue  ?? 0
                }
                let available_Quantity = product.availableQuantity
                if itemCount > available_Quantity.doubleValue && available_Quantity.doubleValue != -1 && (grocery?.inventoryControlled?.boolValue ?? false) {
                    overLimitProduct = product
                }else if itemCount > promoLimit && promoLimit != 0 {
                    overLimitProduct = product
                }
            
            }
            
            if overLimitProduct != nil {
                break
            }
        }
        return overLimitProduct
    }
    
    func populateMyBasketObjForCheckout() -> MyBasket {
        
        
        self.myBasketDataObj.finalizedProductsA = self.products
        self.myBasketDataObj.shoppingItemsA = self.shoppingItems
        self.myBasketDataObj.deliverySlotsA = self.deliverySlotsArray
        self.myBasketDataObj.activeGrocery = self.grocery
        self.myBasketDataObj.activeAddress = ""
        self.myBasketDataObj.activeAddressObj = self.myBasketDataObj.order == nil ? ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() : self.myBasketDataObj.order?.deliveryAddress
        self.myBasketDataObj.orderType = ElGrocerUtility.sharedInstance.isDeliveryMode ? .delivery : .CandC
        self.myBasketDataObj.order = self.order == nil ? nil : self.order
        return self.myBasketDataObj
        /*
         let productsArray = self.products
         let deliverySlotsArray = self.deliverySlotsArray
         let address = ""
         var activeGrocery = self.grocery
         
         if activeGrocery == nil{
         let AGrocery = ElGrocerUtility.sharedInstance.activeGrocery
         if AGrocery != nil{
         activeGrocery = AGrocery
         }
         }
         
         let Obj = MyBasket(productArray: productsArray, shoppingItemsArray: self.shoppingItems, deliverySlotArray: deliverySlotsArray, activeSlot: self.currentDeliverySlot, activeAddress: address,  Grocery: activeGrocery!)
         
         return Obj
         */
        
    }
    
    
    @IBAction func checkoutButtonHandler(_ sender: Any) {
        
        self.proceedToCheckOutWithGrocery(self.grocery!)
    }
        
    private func proceedToCheckOutWithGrocery(_ grocery:Grocery){
        
        self.checkIfOutOfStockProductAvailable()
        
//        if self.isOutOfStockProductAvailable {
//            self.removeOutOfStockProductsFromBasket()
//            return
//        }
        
        guard isOutOfStockProductAvailable == false else {
            self.showOutOfStockAlert()
            return
        }
        guard !self.isOutOfStockProductAvailablePreCart else {
           ElGrocerUtility.sharedInstance.delay(0.15)  {
               self.isOutOfStockProductAvailablePreCart = false
               self.removeOutOfStockProductsFromBasket()
               self.tblBasket.reloadDataOnMain()
               self.tblBasket.setContentOffset(.zero, animated: true)
               
               // resetting the view of checkoutButton
               self.itemsCount.isHidden = self.isOutOfStockProductAvailablePreCart
               self.itemsTotalPrice.isHidden = self.isOutOfStockProductAvailablePreCart
               self.imgbasketArrow.isHidden = self.isOutOfStockProductAvailablePreCart
               self.lblPlaceOrderTitle.text = self.isOutOfStockProductAvailablePreCart ? localizedString("Confirm_OOS_Title", comment: "") : localizedString("shopping_basket_payment_button", comment: "")
               self.itemsCount.visibility = self.isOutOfStockProductAvailablePreCart ? .goneX : .visible
               self.itemsTotalPrice.visibility = self.isOutOfStockProductAvailablePreCart ? .goneX : .visible
               self.imgbasketArrow.visibility = self.isOutOfStockProductAvailablePreCart ? .goneX : .visible
               self.lblPlaceOrderTitle.textAlignment = self.isOutOfStockProductAvailablePreCart ? .center : .natural
               self.title = localizedString("Cart_Title", comment: "")
           }
           return
        }
        
        if let overLimitProduct = checkIsOverLimitProductAvailable(self.grocery) {
            if let index = self.products.firstIndex(of: overLimitProduct) {
                guard index < self.products.count else {return}
                self.tblBasket.scrollToRow(at: NSIndexPath.init(row: index , section: 4) as IndexPath, at: .top, animated: true)
                let indexPath = IndexPath.init(row: index, section: 4)
                let isVisible = self.tblBasket.indexPathsForVisibleRows?.contains{$0 == indexPath}
                if let cell = self.tblBasket.cellForRow(at: indexPath) , let validCell = cell as? MyBasketTableViewCell {
                    validCell.viewMainContainer.backgroundColor = UIColor.newborderColor()
                    ElGrocerUtility.sharedInstance.delay(0.5) {
                        validCell.viewMainContainer.backgroundColor = UIColor.white
                    }
                }
                let msg = String(format: localizedString("promotion_changed_alert_description", comment: ""), "\(overLimitProduct.name ?? "")" , "\(overLimitProduct.promoProductLimit ?? 0) ")
                
                let notification = ElGrocerAlertView.createAlert(localizedString("quantity_changed_alert_title", comment: "") ,
                                                                 description: msg ,
                                                                 positiveButton: localizedString("promo_code_alert_ok", comment: ""),
                                                                 negativeButton: nil, buttonClickCallback: nil )
                notification.show()
                
            }
            
            
            return
        }
        
        if !self.isDeliveryMode {
            self.naviagteUserToOrderSummary()
            return
        }
        
        var isAddreeCompleted : Bool = false
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        if let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            currentAddress = deliveryAddress
            let isDataFilled = ElGrocerUtility.sharedInstance.validateUserProfile(userProfile, andUserDefaultLocation: deliveryAddress)
            if isDataFilled {
                isAddreeCompleted = true
                if grocery.deliveryFee > 0 {
                    self.naviagteUserToOrderSummary()
                }else{
                    
                    if self.isMinimumOrderValueFulfilled() {
                        self.naviagteUserToOrderSummary()
                    }else{
                        
                        let shoppingAmount = String(format:"%0.2f", self.itemsSummaryValue)
                       elDebugPrint("Shopping Cart Value:%@",shoppingAmount)
                        FireBaseEventsLogger.setUserProperty(shoppingAmount, key: "shopping_cart_amount")
                       elDebugPrint("Store Name:%@",self.grocery?.name ?? "Store Name is NULL")
                        FireBaseEventsLogger.setUserProperty(self.grocery?.name, key: "store_name")
                        ElGrocerAlertView.createAlert(localizedString("order_no_minimum_value_alert_title", comment: ""),
                                                      description: localizedString("order_no_minimum_value_alert_description", comment: "") + " \(self.minimumBasketValueForGrocery)",
                                                      positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                                      negativeButton: nil, buttonClickCallback: nil).show()
                    }
                    
                }
                
                
            }
        }
        
        if !isAddreeCompleted {
            
            if let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                let editLocationController = ElGrocerViewControllers.editLocationViewController()
                editLocationController.deliveryAddress = deliveryAddress
                editLocationController.editScreenState = .isFromCart
                self.navigationController?.pushViewController(editLocationController, animated: true)
                
            }
        }
        
    }
    
    private func showOutOfStockAlert(){
        
        
        
        let appDelegate = SDKManager.shared
        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "checkOutPopUp") , header: localizedString("shopping_OOS_title_label", comment: "") , detail: localizedString("out_of_stock_message", comment: "")  ,localizedString("sign_out_alert_no", comment: "") ,localizedString("title_checkout_screen", comment: "") , withView: appDelegate.window!) { (buttonIndex) in
            
            if buttonIndex == 1 {
                self.removeOutOfStockProductsFromBasket()
                ElGrocerUtility.sharedInstance.delay(0.15)  {
                    self.tblBasket.setContentOffset(.zero, animated: true)
                }
            }
        }
        
        
        
        
        
            //        let alertVC = PMAlertController(title: localizedString("out_of_stock_message_title", comment: "") , description: localizedString("out_of_stock_message", comment: "") , image: UIImage(name: "img.png"), style: .alert)
            //
            //        alertVC.addAction(PMAlertAction(title: localizedString("sign_out_alert_no", comment: ""), style: .cancel, action: { () -> Void in
            //           elDebugPrint("Capture action Cancel")
            //        }))
            //
            //        alertVC.addAction(PMAlertAction(title: localizedString("sign_out_alert_yes", comment: ""), style: .default, action: { () in
            //           self.removeOutOfStockProductsFromBasket()
            //        }))
            //
            //        self.present(alertVC, animated: true, completion: nil)
        
        
            //        /*------------------- Fabcebook ---------------*/
            //        let paramsJSON = JSON(fbDataA)
            //        let paramsString = paramsJSON.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!
            //
            //    let param = [AFEventParamPrice: self.itemsSummaryValue , AFEventParamCurrency : kProductCurrencyEngAEDName , AFEventParamQuantity : self.itemsCount.text ?? "" , AFEventParamContentType : "product" , AFEventParamContentId : productIds.joined(separator: ",")  , AFEventParamPaymentInfoAvailable : self.grocery?.availablePayments.boolValue ?? false  , AppEvents.ParameterName.content : paramsString ] as! [String : Any]
            //        AppsFlyerLib.shared().trackEvent(AFEventInitiatedCheckout, withValues:param)
            //
            //        /* ---------- Fabric Checkout Event ----------*/
            //        let decimalPrice = NSDecimalNumber(value: self.itemsSummaryValue as Double)
            // Answers.StartCheckout(withPrice: decimalPrice,currency: kProductCurrencyAEDName ,itemCount: self.purchasedItemCount as NSNumber?,customAttributes: nil)
        
        
        
        
            //        ElGrocerAlertView.createAlert(localizedString("out_of_stock_message_title", comment: ""),description:localizedString("out_of_stock_message", comment: ""),positiveButton: localizedString("sign_out_alert_yes", comment: ""),negativeButton: localizedString("sign_out_alert_no", comment: ""),buttonClickCallback: { (buttonIndex:Int) -> Void in
            //            if buttonIndex == 0 {
            //                self.removeOutOfStockProductsFromBasket()
            //            }
            //        }).show()
    }
    
    
    
    
    
    
        // MARK: Data
    
    @objc func loadShoppingBasketData() {
        
        if self.shouldShowGroceryActiveBasket == nil {
            self.shouldShowGroceryActiveBasket = true
        }
        
        if self.shouldShowGroceryActiveBasket! {
            
            self.products = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            self.shoppingItems = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        } else {
            
            self.products = ShoppingBasketItem.getBasketProductsForOrder(nil, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            self.shoppingItems = ShoppingBasketItem.getBasketItemsForOrder(nil, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }

        var finalProductsA : [Product] = []
        
        for product in self.products {
            
            if let index =  finalProductsA.firstIndex(where: { finalArrayProduct in
                return finalArrayProduct.dbID == product.dbID
            }) {
                let existingProduct = finalProductsA[index]
                
                let existingProductDate = existingProduct.updatedAt
                let loopProductDate = product.updatedAt
                
                if existingProductDate == nil && loopProductDate != nil {
                    finalProductsA[index] = product
                }
                if existingProductDate != nil && loopProductDate != nil {
                    if existingProductDate!.compare(loopProductDate!) == .orderedAscending {
                        finalProductsA[index] = product
                    }
                }
            }else {
                finalProductsA.append(product)
            }
        }
      
            // remove at not available items
        let finalData = finalProductsA
        for product in finalData {
            if let item = shoppingItemForProduct(product) {
                if product.updatedAt != nil {
                    item.updatedAt = product.updatedAt
                    do {
                        try DatabaseHelper.sharedInstance.mainManagedObjectContext.save()
                    } catch (let error) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                    }
                }
            } else {
                self.products.removeAll{$0 == product}
            }
            
        }

        self.products = finalData.filter({ (product) -> Bool in
            return shoppingItemForProduct(product) != nil
        })
        
        self.products =   self.products.sorted(by: { (leftProduct, rightProduct) -> Bool in
            if let leftitem = shoppingItemForProduct(leftProduct) , let rightItem = shoppingItemForProduct(rightProduct) {
                guard  leftitem.updatedAt != nil , rightItem.updatedAt != nil else {return false}
                return ((leftitem.updatedAt!.timeIntervalSinceNow > rightItem.updatedAt!.timeIntervalSinceNow))
            }
            return false
        })
        
        self.products =   self.products.sorted(by: { (leftProduct, rightProduct) -> Bool in
            return leftProduct.isPublished.boolValue == true && leftProduct.isAvailable.boolValue == true
        })
        
        
        self.availableProducts =   self.products.filter({ (product) -> Bool in
            return (product.isAvailable.boolValue && product.isPublished.boolValue )
        })
        
        self.notAvailableProductsList =   self.products.filter({ (product) -> Bool in
            if let item = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                if item.isSubtituted.boolValue {
                    let firstIndex = self.products.filter({ (data) -> Bool in
                        if data.dbID == item.subStituteItemID {
                            return true
                        }
                        return false
                    })
                    if firstIndex.count > 0 {
                        return false
                    }
                    
                }
            }
            return !(product.isAvailable.boolValue && product.isPublished.boolValue )
        })
    
        self.loadSubsituteItems()
        self.checkIfOutOfStockProductAvailable()
        self.setSummaryData()
        self.checkIfOutOfStockProductAvailableForPreCart()
       
      
    }
    
    
    func loadShoppingBasketDataRefreshed( oldProduct : Product , newProduct : Product) {
        
        if self.shouldShowGroceryActiveBasket! {
            
            self.shoppingItems = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        } else {
            
            self.shoppingItems = ShoppingBasketItem.getBasketItemsForOrder(nil, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }

        let productIndex = self.availableProducts.indexes(of: oldProduct)
        if  productIndex.count > 0 {
            let firstIndex = productIndex[0]
            self.availableProducts[firstIndex] = newProduct
            
            if self.availableProducts.count > 1 {
                self.tblBasket.reloadRows(at: [IndexPath.init(row: firstIndex, section: 4)], with: .none)
            }else {
                self.reloadTableData()
            }
            
           
        }else {
            self.reloadTableData()
        }
        self.checkIfOutOfStockProductAvailable()
        self.checkIfOutOfStockProductAvailableForPreCart()
        self.setSummaryData()
    }
    
  
    
    
    func loadSubsituteItems () {
        
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        let userProfile = UserProfile.getUserProfile(context)
        RecipeCart.GETSpecficUserAddToCartListRecipes(forDBID: userProfile?.dbID ?? 0 , context) {[weak self] (recipeCartList) in
            guard let self = self else {return}
                // elDebugPrint(self)
            let filterdA =  self.products.filter { !($0.isAvailable.boolValue && $0.isPublished.boolValue) }
            if let recipeList = recipeCartList {
                for data in filterdA {
                    let productId = Product.getCleanProductId(fromId: data.dbID)
                    let dbIDAvailable = NSNumber(value:Int64(productId))
                    let isProductIsFoodItem =  recipeList.filter({
                        
                            // elDebugPrint($0.ingredients)
                            // elDebugPrint(data.dbID)
                        return $0.ingredients.contains(dbIDAvailable)
                    })
                    if isProductIsFoodItem.count > 0 {
                        self.getSubsituteFoodItem(data)
                    }else{
                        self.getSubsituteGeneralItem(data)
                    }
                }
            }
        }
        
    }
    
    func getSubsituteFoodItem (_ product : Product) {
        
        let subProductList = self.substituteProduct[product.dbID]
        guard subProductList?.count ?? 0 == 0 else {
            return
        }
        let storeID = Grocery.getGroceryIdForGrocery(self.grocery)
        guard  storeID != "0" else {
            return
        }
        AlgoliaApi.sharedInstance.searchQueryForOOSItemsCurrentStoreItems(product.name! , storeID: storeID , pageNumber: 0, isFood: true, subCategoryID: product.subcategoryId.intValue > 0 ? product.subcategoryId.stringValue : "", searchType: "alternate") { [weak self] (content, error) in
            guard let self = self else {return}
            if content != nil {
                if  let responseObject : NSDictionary = content as NSDictionary? {
                    DispatchQueue.main.async {
                        let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        DatabaseHelper.sharedInstance.saveDatabase()
                        self.substituteProduct[product.dbID] = newProducts
                        
                        if let first  =   self.notAvailableProductsList.firstIndex(of: product) {
                            let indexPath = NSIndexPath.init(row: first, section: self.notAvailableProductSectionNumber) as IndexPath
                            if  self.tblBasket.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                self.tblBasket.reloadRows(at:  [indexPath], with: .fade)
                            }else{
                                    // self.reloadTableData()
                            }
                        }else{
                            self.reloadTableData()
                        }
                    }
                }
                return
            }
            self.substituteProduct[product.dbID] = []
           // self.reloadTableData()
        }
    }
    func getSubsituteGeneralItem (_ product : Product ) {
        
        let subProductList = self.substituteProduct[product.dbID]
        guard subProductList?.count ?? 0 == 0 else {
            return
        }
        let storeID = Grocery.getGroceryIdForGrocery(self.grocery)
        guard  storeID != "0" else {
            return
        }
        AlgoliaApi.sharedInstance.searchQueryForOOSItemsCurrentStoreItems(product.name! , storeID: storeID , pageNumber: 0 , subCategoryID : product.subcategoryId.intValue > 0 ? product.subcategoryId.stringValue : "" , searchType: "alternate") { [weak self] (content, error) in
            guard let self = self else {return}
            if content != nil {
                if  let responseObject : NSDictionary = content as NSDictionary? {
                    Thread.OnMainThread {
                        let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , product )
                        DatabaseHelper.sharedInstance.saveDatabase()
                        self.substituteProduct[product.dbID] = newProducts
                        self.reloadTableData()
                    }
                    return
                }
            }
            
            self.substituteProduct[product.dbID] = []
           // self.reloadTableData()
        }
        
    }
    
    
    private func checkIfOutOfStockProductAvailableForPreCart() {
        
        self.isOutOfStockProductAvailablePreCart = false
       // var isOOS: Bool = false
        self.outOfStockProducts = [Product]()
        for product in self.notAvailableProductsList {
            if let _ = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                self.isOutOfStockProductAvailablePreCart = true
                self.outOfStockProducts.append(product)
            }
        }
        
        if isOutOfStockProductAvailablePreCart {
            self.title = localizedString("shopping_OOS_title_label", comment: "")
        }
        
        self.itemsCount.isHidden = self.isOutOfStockProductAvailablePreCart
        self.itemsTotalPrice.isHidden = self.isOutOfStockProductAvailablePreCart
        self.imgbasketArrow.isHidden = self.isOutOfStockProductAvailablePreCart
        self.lblPlaceOrderTitle.text = self.isOutOfStockProductAvailablePreCart ? localizedString("Confirm_OOS_Title", comment: "") : localizedString("shopping_basket_payment_button", comment: "")
        
        self.itemsCount.visibility = self.isOutOfStockProductAvailablePreCart ? .goneX : .visible
        self.itemsTotalPrice.visibility = self.isOutOfStockProductAvailablePreCart ? .goneX : .visible
        self.imgbasketArrow.visibility = self.isOutOfStockProductAvailablePreCart ? .goneX : .visible
        self.lblPlaceOrderTitle.textAlignment = self.isOutOfStockProductAvailablePreCart ? .center : .natural
        
        var isConfirmButtonEnable = false
        for product in self.notAvailableProductsList {
            if let item = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                if item.isSubtituted.boolValue {
                    isConfirmButtonEnable = true
                    break
                }
            }
        }
        self.setCheckoutButtonEnabled(isConfirmButtonEnable)
        
    }
    
    private func checkIfOutOfStockProductAvailable(){
        
        self.isOutOfStockProductAvailable = false
        self.outOfStockProducts = [Product]()
        for product in self.notAvailableProductsList {
            if let item = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                if !item.isSubtituted.boolValue {
                    self.isOutOfStockProductAvailable = true
                    self.outOfStockProducts.append(product)
                }
            }
                //            if (!(product.isPublished.boolValue && product.isAvailable.boolValue)){
                //                self.isOutOfStockProductAvailable = true
                //                self.outOfStockProducts.append(product)
                //            }
        }
        
    }
    
    private func setSummaryData() {
        
        var summaryCount = 0
        var notAvailableCount = 0
        var priceSum = 0.00
        
        for product in products {
            
            let item = shoppingItemForProduct(product)
            let isProductAvailable = isProductAvailableInGrocery(product)
            let priceDict = getPriceDictionaryForProduct(product)
            
            if let notNilItem = item {
                if let itemSub =   ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                    if itemSub.isSubtituted.boolValue  {
                        continue
                    }
                }
                summaryCount += notNilItem.count.intValue
                if !isProductAvailable {
                    notAvailableCount += notNilItem.count.intValue
                } else {
                    
                    if(product.isPublished.boolValue && product.isAvailable.boolValue){
                        var price = product.price.doubleValue
                        if let priceFromGrocery = priceDict?["price_full"] as? NSNumber {
                            price = priceFromGrocery.doubleValue
                        }
                        if product.promotion?.boolValue == true{
                            if let promoPrice = product.promoPrice?.doubleValue{
                                price = promoPrice
                                
                            }
                            if let promoDict = priceDict?["promotion"] as? NSDictionary {
                                if let promoPrice = promoDict["price"] as? Double {
                                    price = promoPrice
                                }
                                
                            }
                        }
                        
                        priceSum += price * notNilItem.count.doubleValue
                        
                    }
                }
            }
        }
        
        self.itemsSummaryValue = priceSum
        self.getTotalShoppingAmount()
        
        var priceStr = ElGrocerUtility.sharedInstance.isArabicSelected() ? String(format:"%.2f",self.getFinalAmount()).changeToArabic() : String(format:"%.2f",self.getFinalAmount())
        priceStr = CurrencyManager.getCurrentCurrency() + priceStr
        
//        self.itemsTotalPrice.text =       String(format:"%@ %.2f",CurrencyManager.getCurrentCurrency() , self.getFinalAmount())
        self.itemsTotalPrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: self.getFinalAmount())
        
        
        if self.notAvailableProducts != nil {
            self.purchasedItemCount = summaryCount - notAvailableCount
            self.itemsCount.text = "\(summaryCount - notAvailableCount)/\(summaryCount) " + localizedString("shopping_basket_available_label", comment: "")
            self.itemsCount.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(summaryCount - notAvailableCount)/\(summaryCount) ") + localizedString("shopping_basket_available_label", comment: "")
        } else {
            self.purchasedItemCount = summaryCount
            self.itemsCount.text = "(" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(summaryCount)") +  "\(localizedString("brand_items_count_label", comment: "")))"
        }
        
        if (self.grocery  != nil && self.products.count == 0) {
            self.checkNoProductView()
        }
        
        let shoppingAmount = String(format:"%0.2f", self.itemsSummaryValue)
       elDebugPrint("Shopping Cart Value:%@",shoppingAmount)
        FireBaseEventsLogger.setUserProperty(shoppingAmount, key: "shopping_cart_amount")
       elDebugPrint("Store Name:%@",self.grocery?.name ?? "Store Name is NULL")
        FireBaseEventsLogger.setUserProperty(self.grocery?.name, key: "store_name")
        
        
        self.refreshBasketIcon()
        if self.purchasedItemCount > 0 {
            let barButton = self.tabBarController?.navigationItem.rightBarButtonItem as? BBBadgeBarButtonItem
            barButton?.badgeValue = ElGrocerUtility.sharedInstance.isArabicSelected() ? "\(self.purchasedItemCount)".changeToArabic() : "\(self.purchasedItemCount)"
            self.tabBarController?.tabBar.items?[4].badgeValue = ElGrocerUtility.sharedInstance.isArabicSelected() ? "\(self.purchasedItemCount)".changeToArabic() : "\(self.purchasedItemCount)"
        }
        
        //update minimum order detail here

        if (self.itemsSummaryValue ) < self.grocery?.minBasketValue ?? 0 {
            
            // Order amount is less then minimum basket amount
            // change color, disable button ...
            var remainingValue = "0.00"
            let remainingPrice = minimumBasketValueForGrocery - self.getPriceWithOutTobaco()
            remainingValue = String(format:"%.2f",remainingPrice)
            //self.minOrderLabel.text = "\(localizedString("lbl_Add", comment: "")) " + remainingValue + " \(CurrencyManager.getCurrentCurrency()) " + "\(localizedString("to_reach_minimum_order", comment: "")) "
            
            self.minOrderLabel.attributedText =  NSMutableAttributedString()
                .normal(localizedString("lbl_Add", comment: ""),
                        UIFont.SFProDisplayNormalFont(12), color: .secondaryDarkGreenColor())
                .normal(" " + ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: remainingPrice) + " ",
                        UIFont.SFProDisplayBoldFont(12), color: .secondaryDarkGreenColor())
                .normal(localizedString("to_reach_minimum_order", comment: ""),
                        UIFont.SFProDisplayNormalFont(12), color: .secondaryDarkGreenColor())
            
            self.minOrderImageView.image = UIImage(name: "cart-addmore")
            let progressValue = Float(priceSum/(self.grocery?.minBasketValue)!)
            self.minOrderProgressView.setProgress(progressValue, animated: true)
            self.title = localizedString("shopping_OOS_title_label", comment: "")
            self.checkoutBtn.isEnabled = false
            self.checkOutViewForButton.backgroundColor = UIColor.colorWithHexString(hexString: "909090")
            //greyish
        }else{
            
            // Order amount more then or eqaul to minimum basket amount
            // change color to gree, enable button ...
            self.minOrderLabel.text = "\(localizedString("lbl_congrtz", comment: "")) "
            self.minOrderImageView.image = UIImage(name: "cart-price")
            self.minOrderProgressView.setProgress(1.0, animated: true)
            if UserDefaults.isUserLoggedIn() && notAvailableCount == 0 {
            self.checkoutBtn.isEnabled = true
            self.checkOutViewForButton.backgroundColor = UIColor.colorWithHexString(hexString: "05BC66")
            //green
            }
        }
        
    }
    
    
        // MARK: UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
            // return 1;
        return self.grocery != nil ? 5 : 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard self.tblBasket.backgroundView == nil else{
            return 0
        }
        
        if section == 0 {
            return 4
        }
        if section == 1 {
            return self.myBasketDataObj.getReasonA().count + 1
        }
        if section == 2 {
            return self.notAvailableProductsList.count
        }
        if section == 3 {
            return 3
        }
        if section == 4 {
            return self.availableProducts.count + ((self.orderToReplace || self.isOutOfStockProductAvailablePreCart) ? 1 : 0)
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard self.tblBasket.backgroundView == nil else {
            return 0//.leastNormalMagnitude
        }
        guard !self.isOutOfStockProductAvailablePreCart else {
            if indexPath.section == 0 {
                return indexPath.row == 0 ? 60 : 0
            }
            if indexPath.section == self.notAvailableProductSectionNumber {
                return kProductCellHeight + 15
            } else if indexPath.section == 4 {
                
                if ( self.orderToReplace && indexPath.row == self.availableProducts.count) || (self.isOutOfStockProductAvailablePreCart && indexPath.row == self.availableProducts.count) {
                    return 88
                }
                return 0.01
            } else {
                return 0.01
            }
            
            
        }
            // basic info section
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                return 60
                // Disabling progress view cell in favour of new design
                if self.isMinimumOrderValueFulfilled() { return 90 }
                return (priceSum < minimumBasketValueForGrocery) ? 155 : 90
            } else if indexPath.row == 1 {
                // hiding summary cell in favour of new design
                return 0
                return (self.products.count > 0) ? 40 :  0.1
            } else if indexPath.row == 2 {  return (self.products.count > 0) ? 104 :  0.1 }
            else if indexPath.row == 3 {  return 15 }
        }
        if indexPath.section == 1 {
            if indexPath.row == 0 { return 40 }
            if indexPath.row == 1 { return UITableView.automaticDimension }
            return self.isItemOOSCellsNeedToExpand ? UITableView.automaticDimension : 0.1
        } // reason section
        if indexPath.section == 2 { return kProductCellHeight + 15 }
        if indexPath.section == 3 {
            if indexPath.row == 0 {  return self.carouselProducts.count > 0 ? 50 :  0.1  }
            if indexPath.row == 1 {  return self.carouselProducts.count > 0 ? kProductCellHeight :  0.1 }
            if indexPath.row == 2 {  return self.availableProducts.count > 0 ? 60 :  0.1   }
        }
        if indexPath.section == 4 {
            if indexPath.row < self.availableProducts.count {
                let product = self.availableProducts[indexPath.row]
                guard product.isAvailable.boolValue && product.isPublished.boolValue  else{
                    return kProductCellHeight
                }
                return kShoppingBasketCellHeight
            }
            if self.orderToReplace && indexPath.row == self.availableProducts.count {
                return 0.1 //88
            }
        }
        return 0//.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard self.tblBasket.backgroundView == nil else{
            return .leastNormalMagnitude
        }
        
        if  self.orderToReplace && section == 0 {
            return .leastNormalMagnitude
        }
        
        if section == 2 {
            if  self.notAvailableProductsList.count > 0 {
                return 72
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard self.tblBasket.backgroundView == nil else{
            return nil
        }
        
        
        if  self.orderToReplace  && section == 0 {
            return nil
        }
        
        if section == 2 {
            if  self.notAvailableProductsList.count > 0 {
                return self.myBasketOutOfStockInfo
            }
        }
        return UIView.init(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if  cell is MyBasketProgressTableViewCell {
            (cell as? MyBasketProgressTableViewCell)?.setAnimationForProgress(minValue: minimumBasketValueForGrocery , progressValue : self.getPriceWithOutTobaco())
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if self.isDeliveryMode {
                
                    // basket progress
                    //order summary title
                    // Product images
                    // space
                
                if indexPath.row == 0 {
                    let cell : MyBasketStroreNameTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyBasketStroreNameTableViewCell" , for: indexPath) as! MyBasketStroreNameTableViewCell
                    cell.setGrocery(grocery: self.grocery)
                    return cell
                    // Disabling progress view cell in favour of new design
                    /*
                    let cell : MyBasketProgressTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyBasketProgressTableViewCell" , for: indexPath) as! MyBasketProgressTableViewCell
                    cell.setTopVC(basket: self)
                    cell.setGrocery(grocery: self.grocery)
                    if self.isMinimumOrderValueFulfilled() {
                        cell.setMessageForShopper(true, minLimit: "", remainingLimit: "", storeName: "")
                    }else{
                        var remainingValue = "0.00"
                        if self.getPriceWithOutTobaco() < minimumBasketValueForGrocery {
                            let remainingPrice = minimumBasketValueForGrocery - self.getPriceWithOutTobaco()
                            remainingValue = String(format:"%.2f",remainingPrice)
                            cell.setMessageForShopper(false, minLimit: String(format:"%.2f",minimumBasketValueForGrocery) , remainingLimit: remainingValue, storeName: self.grocery?.name ?? "")
                        }else{
                            cell.setMessageForShopper(true, minLimit: "", remainingLimit: "", storeName: "")
                        }
                    }
                    cell.setAnimationForProgress(minValue: minimumBasketValueForGrocery , progressValue : self.getPriceWithOutTobaco())
                    
                    return cell
                    */
                }else if indexPath.row == 1 {
                    
                    let cell : GenericViewTitileTableViewCell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
                    cell.configureCell(title: localizedString("order_summary_label", comment: ""))
                    return cell
                    
                }else if indexPath.row == 2 {
                    let replaceProductCell : ProductsImagesTableViewCell = tableView.dequeueReusableCell(withIdentifier: KProductsImagesTableViewCellIdentifier , for: indexPath) as! ProductsImagesTableViewCell
                    if let grocer = self.grocery {
                        let notAWithNoSub = self.notAvailableProductsList.filter { (product) -> Bool in
                            if let item = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                                if item.isSubtituted.boolValue {
                                    return false
                                }
                            }
                            return true
                        }
                        
                        let productList = notAWithNoSub + self.availableProducts
                        replaceProductCell.configuredData(productList, self.shoppingItems, grocery: grocer)
                    }
                    replaceProductCell.selectedProduct = { [weak self] (selectedProdc , index) in
                        if let prod = selectedProdc {
                            if let indexOfProd = self?.notAvailableProductsList.firstIndex(of: prod) {
                                tableView.scrollToRow(at: NSIndexPath.init(row: indexOfProd, section: 2) as IndexPath, at: .top, animated: true)
                                return
                            }
                        }
                        let outOfStockProductCount = self?.notAvailableProductsList.count ?? 0
                        tableView.scrollToRow(at: NSIndexPath.init(row: index - outOfStockProductCount , section: 4) as IndexPath, at: .top, animated: true)
                    }
                    return replaceProductCell
                    
                } else if indexPath.row == 3 {
                    
                    let spaceTableViewCell : SpaceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell" , for: indexPath) as! SpaceTableViewCell
                    return spaceTableViewCell
                    
                }
                
            } else {
                
                if indexPath.row == 0 {
                    let cell : MyBasketStroreNameTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyBasketStroreNameTableViewCell" , for: indexPath) as! MyBasketStroreNameTableViewCell
                    cell.setGrocery(grocery: self.grocery)
                    return cell
                    // Disabling progress view cell in favour of new design
                    /*
                    let cell : MyBasketProgressTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyBasketProgressTableViewCell" , for: indexPath) as! MyBasketProgressTableViewCell
                    cell.setTopVC(basket: self)
                    cell.setGrocery(grocery: self.grocery)
                    if self.isMinimumOrderValueFulfilled(){
                        cell.setMessageForShopper(true, minLimit: "", remainingLimit: "", storeName: "")
                    }else{
                        var remainingValue = "0.00"
                        if self.getPriceWithOutTobaco() < minimumBasketValueForGrocery {
                            let remainingPrice = minimumBasketValueForGrocery - self.getPriceWithOutTobaco()
                            remainingValue = String(format:"%.2f",remainingPrice)
                            cell.setMessageForShopper(false, minLimit: String(format:"%.2f",minimumBasketValueForGrocery) , remainingLimit: remainingValue, storeName: self.grocery?.name ?? "")
                        }else{
                            cell.setMessageForShopper(true, minLimit: "", remainingLimit: "", storeName: "")
                        }
                    }
                    cell.setAnimationForProgress(minValue: minimumBasketValueForGrocery , progressValue : self.getPriceWithOutTobaco())
                    
                    return cell
                    */
                }
                if indexPath.row == 1 {
                    
                    let cell : GenericViewTitileTableViewCell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
                    cell.configureCell(title: localizedString("order_summary_label", comment: ""))
                    return cell
                    
                }
                
                if indexPath.row == 2 {
                    let replaceProductCell : ProductsImagesTableViewCell = tableView.dequeueReusableCell(withIdentifier: KProductsImagesTableViewCellIdentifier , for: indexPath) as! ProductsImagesTableViewCell
                    if let grocer = self.grocery {
                        
                        let notAWithNoSub = self.notAvailableProductsList.filter { (product) -> Bool in
                            if let item = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                                if item.isSubtituted.boolValue {
                                    return false
                                }
                            }
                            return true
                        }
                        
                        let productList = notAWithNoSub + self.availableProducts
                        replaceProductCell.configuredData(productList, self.shoppingItems, grocery: grocer)
                    }
                    replaceProductCell.selectedProduct = { [weak self] (selectedProdc , index) in
                        if let prod = selectedProdc {
                            if let _ = self?.notAvailableProductsList.firstIndex(of: prod) {
                                tableView.scrollToRow(at: NSIndexPath.init(row: 9, section: 0) as IndexPath, at: .top, animated: true)
                                return
                            }
                        }
                        let outOfStockProductCount = self?.notAvailableProductsList.count ?? 0
                        tableView.scrollToRow(at: NSIndexPath.init(row: index - outOfStockProductCount , section: 4) as IndexPath, at: .top, animated: true)
                    }
                    return replaceProductCell
                    
                }
                
                if indexPath.row == 3 {
                    
                    let replaceProductCell : SpaceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell" , for: indexPath) as! SpaceTableViewCell
                    return replaceProductCell
                    
                }
                
                /*
                 if indexPath.row == 3 {
                 let replaceProductCell : MyBasketInstructionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyBasketInstructionTableViewCell" , for: indexPath) as! MyBasketInstructionTableViewCell
                 if UserDefaults.getLeaveUsNote() == nil {
                 replaceProductCell.crossAction("")
                 }else{
                 if let note = UserDefaults.getLeaveUsNote() {
                 if note.count > 0 {
                 //replaceProductCell.txtInsutrction.text = note
                 replaceProductCell.txtNoteView.text = note
                 replaceProductCell.textViewDidEndEditing(replaceProductCell.txtNoteView)
                 }
                 }
                 
                 replaceProductCell.textViewDidBeginEditing(replaceProductCell.txtNoteView)
                 
                 }
                 return replaceProductCell
                 }
                 if indexPath.row == 4 {
                 let cell : MyBasketDeliveryDetailsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyBasketDeliveryDetailsTableViewCell" , for: indexPath) as! MyBasketDeliveryDetailsTableViewCell
                 cell.cellType = .cAndc
                 cell.setTopVC(basket: self)
                 cell.setPickUpAddress()
                 cell.setUserData(user : self.userProfile)
                 cell.setDeliverySlot(orderTypeDescription)
                 return cell
                 }
                 
                 if indexPath.row == 5 {
                 
                 let cell : GenericViewTitileTableViewCell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
                 cell.configureCell(title: localizedString("Someone_else_is_collectiing", comment: ""))
                 cell.isTitleOnly = true
                 return cell
                 
                 }
                 
                 if indexPath.row == 6 {
                 
                 let cell : CandCGetDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: KCandCGetDetailTableViewCellIdentifier , for: indexPath) as! CandCGetDetailTableViewCell
                 return cell
                 
                 }
                 
                 
                 if indexPath.row == 7 {
                 
                 let cell : GenericViewTitileTableViewCell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
                 cell.configureCell(title: localizedString("Which_car_is_collecting_the_order", comment: ""))
                 cell.isTitleOnly = true
                 return cell
                 
                 }
                 
                 
                 if indexPath.row == 8 {
                 
                 let cell : CandCGetDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: KCandCGetDetailTableViewCellIdentifier , for: indexPath) as! CandCGetDetailTableViewCell
                 return cell
                 
                 }
                 if indexPath.row == 9 {
                 let replaceProductCell : SpaceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell" , for: indexPath) as! SpaceTableViewCell
                 return replaceProductCell
                 }*/
            }
        }
        
        if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                
                let cell : GenericViewTitileTableViewCell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
                cell.configureCellWithEditOrder(title: localizedString("If_items_are_out_of_stock_unselected", comment: ""))
                cell.viewAll.isHidden = !(self.myBasketDataObj.getSelectedReason() != nil)
                cell.viewAllAction = { [weak self] in
                    if self?.orderToReplace ?? false{
                        MixpanelEventLogger.trackEditCartEditOOSInstruction()
                    }else {
                        MixpanelEventLogger.trackCartEditOOSInstruction()
                    }
                    
                    self?.isItemOOSCellsNeedToExpand = !(self?.isItemOOSCellsNeedToExpand ?? false)
                    self?.tblBasket.reloadDataOnMain()
                }
                return cell
                
            }else {
                
                let cell : QuestionareCell = tableView.dequeueReusableCell(withIdentifier: "QuestionareCell") as! QuestionareCell
                cell.buttonClicked = { [weak self] (selectedReason , index) in
                    guard self?.tblBasket != nil , index != nil else {return }
                    let reason: String = (selectedReason as? Reasons)?.reasonString ?? ""
                    if self?.orderToReplace ?? false {
                        MixpanelEventLogger.trackEditCartOOSInstructionSelected(reason: reason)
                    }else {
                        MixpanelEventLogger.trackCartOOSInstructionSelected(instruction: reason)
                    }
                    self?.tableView(self!.tblBasket, didSelectRowAt: index!)
                }
                let reasonIndex = indexPath.row - 1
                let reason = self.myBasketDataObj.getSortedReasonA()[reasonIndex]
                let isSelected = self.myBasketDataObj.getSelectedReason()?.reasonKey == reason.reasonKey
                cell.ConfigureCell(isSelected: isSelected, text: reason.reasonString, reason, indexPath)
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell
                
            }
            
        }
        
        if indexPath.section == 2 {
            
            let product = self.notAvailableProductsList[(indexPath as NSIndexPath).row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: KMyBasketReplaceProductIdentifier, for: indexPath) as! MyBasketReplaceProductTableViewCell
            cell.bottomLine.backgroundColor = UIColor.textfieldBackgroundColor()
            cell.customCollectionView.moreCellType = .ShowSubstitute
            cell.lblProductName.text = "" +  "\(product.name ?? "")"
            if product.descr != nil && product.descr?.isEmpty == false  {
                let earylyText = cell.lblProductName.text ?? ""
                cell.lblProductName.text =  earylyText + " - " + product.descr!
            }
            cell.currentAlternativeProduct = product
            cell.currentGrocery = self.grocery
            
            var subProductList = self.substituteProduct[product.dbID]
            subProductList = subProductList?.filter({ (productAData) -> Bool in
                
                if let productItem = ShoppingBasketItem.checkIfProductIsInBasket(product , grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                    if productItem.isSubtituted.boolValue {
                        if productItem.subStituteItemID == productAData.dbID {
                            return true
                        }
                    }
                }
                if let _ = ShoppingBasketItem.checkIfProductIsInBasket(productAData , grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                    return false
                }
                return true
            })
            
            
            if subProductList != nil {
                var firstObject : Array <Product> = [product] // add current alternative bedefualt
                firstObject += subProductList ?? []
                    // cell.customCollectionView.isHidden =  subProductList != nil && subProductList?.count ?? 0 == 0
                if  firstObject.count > 0 {
                    cell.customCollectionView.configuredCell(productA: firstObject )
                }else{
                    cell.customCollectionView.configuredCell(productA: ["" as AnyObject])
                }
            }else{
                cell.customCollectionView.configuredCell(productA: ["" as AnyObject])
            }
            
            
            cell.productUpdated = { [weak self ] ( oldProduct , selectedProduct  ) in
                guard let self = self else { return }
                
                
                
                if let availablePIndex = self.availableProducts.firstIndex(of: selectedProduct) {
                    let product = ShoppingBasketItem.checkIfProductIsInBasket(selectedProduct , grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    
                    if product?.count.intValue ?? 0 < 1 {
                        self.availableProducts.remove(at: availablePIndex)
                    }
                    
                }else {
                    self.availableProducts.append(selectedProduct)
                }
                
                
                
                if let availablePIndex = self.products.firstIndex(of: selectedProduct) {
                    let product = ShoppingBasketItem.checkIfProductIsInBasket(selectedProduct , grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    if product?.count.intValue ?? 0 < 1 {
                        self.products.remove(at: availablePIndex)
                    }
                    
                }else {
                    self.products.append(selectedProduct)
                }
                
                
                    //loadShoppingBasketData()
                self.loadShoppingBasketDataRefreshed( oldProduct: oldProduct , newProduct: selectedProduct )
                ElGrocerEventsLogger.sharedInstance.addToCart(product: selectedProduct , "", "",  false,  nil)
                MixpanelEventLogger.trackCartOOSSelected(product: selectedProduct, OOSProduct: oldProduct)
                
            }
            
            cell.viewMoreCalled = { [weak self ] (selectedProduct) in
                guard let self = self else { return }
                self.gotoReplacementVC(index: 0 , selectedProduct)
            }
            
            cell.removeMoreCalled = { [weak self ] (selectedProduct) in
                guard let self = self else { return }
                self.deleteProduct(-1, selectedProduct)
                
            }
            
            cell.deleteUnAvailableRow = { [weak self ] (selectedProduct) in
                guard let self = self else { return }
                
                if let item = ShoppingBasketItem.checkIfProductIsInBasket(selectedProduct, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                        //elDebugPrint(item.subStituteItemID)
                    
                    let index = self.availableProducts.filter { (prr) -> Bool in
                        return prr.dbID == item.subStituteItemID
                    }
                    if index.count > 0 {
                        let prod = index[0]
                        if let fInndex = self.availableProducts.firstIndex(of: prod) {
                            self.availableProducts.remove(at: fInndex)
                        }
                        
                    }
                    let indexProducts = self.products.filter { (prr) -> Bool in
                        return prr.dbID == item.subStituteItemID
                    }
                    if indexProducts.count > 0 {
                        let prod = indexProducts[0]
                        if let fInndex = self.products.firstIndex(of: prod) {
                            self.products.remove(at: fInndex)
                            ShoppingBasketItem.removeProductFromBasket(prod, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        }
                        
                    }
                }
                
                self.tblBasket.reloadDataOnMain()
                
                if let index = self.notAvailableProductsList.firstIndex(of: selectedProduct) {
                    
                    self.tblBasket.beginUpdates()
                    self.notAvailableProductsList.remove(at: index)
                    self.tblBasket.reloadSections(IndexSet.init(arrayLiteral: 2), with: .fade)
                    self.tblBasket.endUpdates()
                    
                    if let index = self.products.firstIndex(of: selectedProduct) {
                        self.products.remove(at: index)
                    }
                    
                    
                    
                    ElGrocerUtility.sharedInstance.delay(0.1) {
                        self.deleteProduct(-1, selectedProduct)
                    }
                    ElGrocerUtility.sharedInstance.showTopMessageView(localizedString("lbl_outODStock_Undo", comment: ""), image: UIImage(name: "MyBasketOutOfStockStatusBar"), index , backButtonClicked: { [weak self] (sender , index , isUnDo) in
                        
                        if isUnDo {
                            ShoppingBasketItem.addOrUpdateProductInBasket(selectedProduct, grocery:self?.grocery, brandName:nil, quantity: 1, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                            self?.notAvailableProductsList.insert(selectedProduct, at: index )
                            self?.products.append(selectedProduct)
                            self?.tblBasket.reloadData()
                        }else{
                            self?.deleteProduct(-1, selectedProduct)
                        }
                    })
                }
            }
            
            cell.customCollectionView.collectionView?.backgroundColor = .colorWithHexString(hexString: "F5F5F5")
            
            cell.contentView.setNeedsLayout()
            cell.contentView.layoutIfNeeded()
            
            let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
            if currentLang == "ar" {
                cell.customCollectionView.collectionView?.transform = CGAffineTransform(scaleX: -1, y: 1)
                cell.customCollectionView.collectionView?.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            }
            
            return cell
            
        }
        
        if indexPath.section == 3 {
            
            if indexPath.row == 0 {
                
                let cell : GenericViewTitileTableViewCell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
                cell.configureCell(title: localizedString("txt_recommende_for_you", comment: ""))
                return cell
                
            }else if indexPath.row == 1 {
                let cell : MyBasketCarousalTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyBasketCarousalTableViewCell" , for: indexPath) as! MyBasketCarousalTableViewCell
                cell.configureCarousal(self.carouselProducts as! [Product])
                
                cell.carosalView.removeProduct = {  [weak self] (productCell,product , loadedProductsCount) in
                    guard let self = self  else {
                        return
                    }
                    
                    self.selectedProduct = product
                    var counter = self.getItemCounterWithProduct(self.selectedProduct)
                    counter -= 1
                    
                    if counter < 1 {
                        
                            //remove product from basket
                        ShoppingBasketItem.removeProductFromBasket(self.selectedProduct, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        
                    }else{
                        ShoppingBasketItem.addOrUpdateProductInBasket(self.selectedProduct, grocery: self.grocery, brandName: nil, quantity: counter , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    }
                    
                    
                    DatabaseHelper.sharedInstance.saveDatabase()
                    
                    self.shoppingItems = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    
                    if let index = self.products.firstIndex(of: product)  {
                        if counter < 1 {
                            self.products.remove(at: index)
                        }
                        
                        
                    }
                    if let index = self.availableProducts.firstIndex(of: product) {
                        if counter < 1 {
                            self.availableProducts.remove(at: index)
                        }
                        
                    }
                    
                    self.checkIfOutOfStockProductAvailable()
                    self.setSummaryData()
                    DispatchQueue.main.async(execute: {
                        UIView.performWithoutAnimation {
                            cell.carosalView.reloadData()
                        }
                    })
                    
                    
                }
                
                cell.carosalView.addNewProduct = {  [weak self] (productCell,product , loadedProductsCount) in
                    guard let self = self  else {
                        return
                    }
                    
                    self.selectedProduct = product
                    var counter = self.getItemCounterWithProduct(self.selectedProduct)
                    counter += 1
                    
                    ShoppingBasketItem.addOrUpdateProductInBasket(self.selectedProduct, grocery: self.grocery, brandName: nil, quantity: counter , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    DatabaseHelper.sharedInstance.saveDatabase()
                    
                    self.shoppingItems = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    
                    if self.products.firstIndex(of: product) == nil {
                        self.products.append(product)
                        
                    }
                    if self.availableProducts.firstIndex(of: product) == nil {
                        self.availableProducts.append(product)
                        
                    }
                    if self.carouselProducts is [Product] {
                            //                        if let index =  (self.carouselproducts as! [Product]).firstIndex(of: product) {
                            //                            self.carouselproducts.remove(at: index)
                            //                        }
                    }
                    
                    self.reloadTableData()
                    self.checkIfOutOfStockProductAvailable()
                    self.setSummaryData()
                    
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    context.performAndWait({ [unowned self] in
                        
                        let productID = Product.getCleanProductId(fromId: self.selectedProduct!.dbID)
                        let groceryID = Int64((self.grocery?.dbID)!)
                        let userID = Int64(truncating: self.userProfile?.dbID ?? 0)
                        CarouselProducts.createOrUpdateCarouselCart(dbID: Int64(productID) , groceryID: groceryID ?? -1, userID: userID , name: self.selectedProduct.name ?? "", context: context)
                        
                        if let _ = self.selectedProduct.name {
                            ElGrocerEventsLogger.sharedInstance.addToCart(product: self.selectedProduct , "", "", true, nil)
                            
                        }
                    })
                    DispatchQueue.main.async(execute: {
                        UIView.performWithoutAnimation {
                            cell.carosalView.reloadData()
                        }
                    })
                    
                }
                cell.contentView.layoutIfNeeded()
                cell.contentView.setNeedsLayout()
                
                return cell
            }else if indexPath.row == 2 {
                
                let cell : GenericViewTitileTableViewCell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
                cell.configureCell(title: localizedString("lbl_Cart_details", comment: ""))
                return cell
                
            }
            
        }
        
        
        if indexPath.row < self.availableProducts.count && !self.isOutOfStockProductAvailablePreCart {
            
            let product = self.availableProducts[(indexPath as NSIndexPath).row]
            let item = shoppingItemForProduct(product)
            let isProductAvailable = isProductAvailableInGrocery(product)
            let priceDict = getPriceDictionaryForProduct(product)
            
            guard product.isAvailable.boolValue && product.isPublished.boolValue  else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: KMyBasketReplaceProductIdentifier, for: indexPath) as! MyBasketReplaceProductTableViewCell
                cell.customCollectionView.moreCellType = .ShowSubstitute
                cell.lblProductName.text = "" +  "\(product.name ?? "")"
                if product.descr != nil && product.descr?.isEmpty == false  {
                    let earylyText = cell.lblProductName.text ?? ""
                    cell.lblProductName.text =  earylyText + " - " + product.descr!
                }
                cell.currentAlternativeProduct = product
                cell.currentGrocery = self.grocery
                
                let subProductList = self.substituteProduct[product.dbID]
                if subProductList != nil {
                    var firstObject : Array <Product> = [product] // add current alternative bedefualt
                    firstObject += subProductList ?? []
                        // cell.customCollectionView.isHidden =  subProductList != nil && subProductList?.count ?? 0 == 0
                    if  firstObject.count > 0 {
                        cell.customCollectionView.configuredCell(productA: firstObject )
                    }else{
                        cell.customCollectionView.configuredCell(productA: ["" as AnyObject])
                    }
                }else{
                    cell.customCollectionView.configuredCell(productA: ["" as AnyObject])
                }
                
                
                cell.productUpdated = { [weak self ] ( oldProduct , selectedProduct  ) in
                    guard let self = self else { return }
                    self.loadShoppingBasketDataRefreshed( oldProduct: oldProduct , newProduct: selectedProduct )
                    ElGrocerEventsLogger.sharedInstance.addToCart(product: selectedProduct , "", "",  false,  nil)
                }
                
                cell.viewMoreCalled = { [weak self ] (selectedProduct) in
                    guard let self = self else { return }
                    self.gotoReplacementVC(index: 0 , selectedProduct)
                }
                
                cell.removeMoreCalled = { [weak self ] (selectedProduct) in
                    guard let self = self else { return }
                    self.deleteProduct(-1, selectedProduct)
                }
                
                cell.contentView.setNeedsLayout()
                cell.contentView.layoutIfNeeded()
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: MyBasketViewController.kShoppingBasketCellIdentifier, for: indexPath) as! MyBasketTableViewCell
            cell.delegate = self
            if item != nil  {
                
                cell.configureWithProduct(item!, product: product, shouldHidePrice: self.grocery == nil, isProductAvailable: isProductAvailable, priceDictFromGrocery: priceDict, currentRow: (indexPath as NSIndexPath).row)
            }
            return cell
            
        } else  if indexPath.row < self.availableProducts.count && self.isOutOfStockProductAvailablePreCart {
            
            
            let spaceTableViewCell : SpaceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell" , for: indexPath) as! SpaceTableViewCell
            return spaceTableViewCell
            
            
        }
        
        if (self.orderToReplace && indexPath.row == self.availableProducts.count) || (self.isOutOfStockProductAvailablePreCart && indexPath.row == self.availableProducts.count) {
            
            let cell : SubsitutionActionButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SubsitutionActionButtonTableViewCell" , for: indexPath) as! SubsitutionActionButtonTableViewCell
            cell.configure(!self.isOutOfStockProductAvailablePreCart)
            cell.buttonclicked = { [weak self] (isCancel) in
                if isCancel {
                    if let orderDBID : NSNumber = UserDefaults.getEditOrderDbId(){
                            //                        self?.cancelOrder(orderDBID.stringValue)
                        self?.cancelOrderHandler(orderDBID.stringValue)
                    }
                }else if self?.isOutOfStockProductAvailablePreCart ?? false {
                    self?.removeOutOfStockProductsFromBasket()
                    self?.setControlerTitle()
                }
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MyBasketViewController.kShoppingBasketCellIdentifier , for: indexPath) as! MyBasketTableViewCell
        cell.delegate = self
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        elDebugPrint("")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row > 0 {
            let reasonIndex = indexPath.row - 1
            let reason = self.myBasketDataObj.getSortedReasonA()[reasonIndex]
            self.myBasketDataObj.setNewSelectedReason(reason)
            self.isItemOOSCellsNeedToExpand = false
            self.reloadTableData()
        }
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        scrollY = scrollView.contentOffset.y
        
    }
    
    
    func reloadTableData() {
        self.tblBasket.reloadDataOnMain()
        self.checkSavedAmount()
        
    }
    
    func showPromotionChangedMessage(){
        if self.promotionalItemChanged{
            let msg = localizedString("promotion_changed_alert_title", comment: "")
            ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "MyBasketOutOfStockStatusBar") , -1 , false) { (sender , index , isUnDo) in  }
        }
    }
    
        // MARK: Helpers
    
    func getPriceWithOutTobaco() -> Double {
        var priceSumV = 0.00
        for product in products {
            let item = shoppingItemForProduct(product)
            let isProductAvailable = isProductAvailableInGrocery(product)
            let priceDict = getPriceDictionaryForProduct(product)
            if let notNilItem = item {
                if isProductAvailable  {
                    if(product.isPublished.boolValue && product.isAvailable.boolValue && !product.isPg18.boolValue){
                        var price = product.price.doubleValue
                        if let priceFromGrocery = priceDict?["price_full"] as? NSNumber {
                            price = priceFromGrocery.doubleValue
                        }
                        
                        if product.promotion?.boolValue == true{
                            if product.promoPrice != nil{
                                price = product.promoPrice!.doubleValue
                            }
                            if let priceFromGrocery = priceDict?["promotion"] as? NSDictionary {
                                if let priceFromGrocery = priceFromGrocery["price"] as? Double {
                                    price = priceFromGrocery
                                }
                            }
                        }
                        
                        priceSumV += price * notNilItem.count.doubleValue
                    }
                }
            }
        }
        return priceSumV
    }
    
    fileprivate func isMinimumOrderValueFulfilled() -> Bool {
        
        guard self.grocery != nil else {
            return false
        }
        
        return (self.grocery?.minBasketValue)! <= self.getPriceWithOutTobaco()
    }
    
    fileprivate func shoppingItemForProduct(_ product:Product) -> ShoppingBasketItem? {
        
        
        return ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        for item in self.shoppingItems {
            if product.dbID == item.productId {
                return item
            }
        }
        
        return nil
    }
    
    fileprivate func isProductAvailableInGrocery(_ product:Product) -> Bool {
        
        var result = true
        
        if  self.notAvailableProductsList != nil {
            let filter = self.notAvailableProductsList.filter { (newProduct) -> Bool in
                return newProduct.productId.intValue == product.productId.intValue
            }
            if filter.count > 0 {
                result = false
            }
        }
        
        
        
        return result
    }
    
    fileprivate func getPriceDictionaryForProduct(_ product:Product) -> NSDictionary? {
        
        return self.availableProductsPrices[product.productId.intValue] as? NSDictionary
    }
    
    func removeProductFromAvailableAndProductA () {
        
        if let indexRow = self.availableProducts.firstIndex(of: self.selectedProduct ) {
            let indexPath = IndexPath(row:indexRow , section: 4)
            self.availableProducts.remove(at: (indexPath as NSIndexPath).row)
            self.tblBasket.deleteRows(at: [indexPath], with: UITableView.RowAnimation.none)
        }
        if let indexRow = self.products.firstIndex(of: self.selectedProduct ) {
            self.products.remove(at: indexRow)
        }
        
        
    }
    
    
    func updateSelectedProductsQuantity(_ quantity: Int, andWithProductIndex productIndex:NSInteger) {
        
        
        if self.shouldShowGroceryActiveBasket! {
            
            if quantity == 0 {
                    // Remove product from basket
                ShoppingBasketItem.removeProductFromBasket(self.selectedProduct, grocery: self.grocery, orderID: nil , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                self.removeProductFromAvailableAndProductA ()
                
            } else {
                
                    //Add or updaMyBasketViewController.te item in basket
                ShoppingBasketItem.addOrUpdateProductInBasket(self.selectedProduct, grocery:self.grocery, brandName:nil, quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            }
            
        } else {
            
            if quantity == 0 {
                
                    //remove product from basket
                ShoppingBasketItem.removeProductFromBasket(self.selectedProduct, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                self.removeProductFromAvailableAndProductA ()
                
            } else {
                
                    //Add or update item in basket
                ShoppingBasketItem.addOrUpdateProductInBasket(self.selectedProduct, grocery: nil, brandName: nil, quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            }
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        
        self.loadShoppingBasketDataRefreshed(oldProduct: self.selectedProduct, newProduct: self.selectedProduct)
            // self.loadShoppingBasketData()
            //self.reloadTableData()
        /*
        elDebugPrint("Product Index: ",productIndex)
         let indexPath = IndexPath(item: productIndex, section: 0)
         
         if quantity == 0 {
         //remove product from tableview
         //self.tblBasket.deleteRows(at: [indexPath], with: .none)
         self.tblBasket.reloadDataOnMain()
         }else{
         self.tblBasket.reloadRows(at: [indexPath], with: .none)
         }
         */
        
        self.checkIfBasketIsClear()
        
            // self.refreshView()
    }
    
    
        // MARK: Refresh
    
    
    @objc func refreshViewWithOutPop() {
        
        loadShoppingBasketData()
        self.reloadTableData()
        self.checkIfBasketIsClear(false)
        
    }
    
    
    
    @objc func refreshView() {
        
        loadShoppingBasketData()
        self.reloadTableData()
        self.checkIfBasketIsClear()
        
    }
    @objc func refreshViewForEdit() {
        guard UIApplication.topViewController() is MyBasketViewController else {
            return
        }
            // refresh for new loading
        self.orderToReplace =  UserDefaults.isOrderInEdit()
        loadShoppingBasketData()
        self.reloadTableData()
        self.checkIfBasketIsClear()
        if self.orderToReplace {
            self.navigationItem.hidesBackButton = true
            self.navigationItem.leftBarButtonItem = nil
            self.tblBasket.setContentOffset(.zero, animated:true)
            self.addCustomTitleViewWithTitle(localizedString("Edit_Basket_Title", comment: ""))
           
        }
        
    }
    
    
    @objc func startCheckOutProcess() {
        
        self.checkoutButtonHandler("")
        
    }
    
    private func checkIfBasketIsClear(_ isNeedToPop : Bool = true){
        
        
        if !isNeedToPop {
            return
        }
        
            //check if something is still in basket
        if self.products.count == 0 {
            
            if self.orderToReplace {
                ElGrocerAlertView.createAlert(localizedString("order_confirmation_Edit_order_button", comment: ""),description:localizedString("order_Cancel_popUp_message", comment: ""),positiveButton: localizedString("cancel_OrderButtonTitle", comment: ""),negativeButton: localizedString("AddMoreItemsButtonTitle", comment: ""),buttonClickCallback: { [weak self] (buttonIndex:Int) -> Void in
                    
                    if buttonIndex == 0 {
                        guard let self = self else {return}
                        if let orderDBID : NSNumber = UserDefaults.getEditOrderDbId(){
                                //                            self.ancelOrder(orderDBID.stringValue)
                            self.cancelOrderHandler(orderDBID.stringValue)
                        }else{
                            self.finalRemoveCall();
                        }
                    }else{
                        guard let self = self else {return}
                            // do nothing let user add more things
                        self.loadShoppingBasketData()
                        self.reloadTableData()
                    }
                    
                }).show()
                
            }else{
                self.finalRemoveCall(isNeedToPop);
            }
        }
    }
    private func finalRemoveCall (_ isNeedToPop : Bool = true) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
        if isNeedToPop {
            
            self.removeAllRecipeItems()
                //self.navigationController?.popViewController(animated: true)
            self.navigationController?.popToRootViewController(animated: true)
            ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("clear_basket")
                // PushWooshTracking.addEventForCartCleared()
            ElGrocerUtility.sharedInstance.resetBasketPresistence()
        }
        
        
        
    }
    
    func cancelOrderHandler(_ orderId : String){
        guard !orderId.isEmpty else {return}
        MixpanelEventLogger.trackEditCartCancelOrderClicked(oId: orderId)
        let cancelationHandler = OrderCancelationHandler.init { (isCancel) in
            elDebugPrint("")
            self.orderCancelled(isSuccess: isCancel)
        }
        cancelationHandler.startCancelationProcess(inVC: self, with: orderId)
    }
    
    func orderCancelled(isSuccess: Bool) {
       elDebugPrint(" OrderCancelationHandlerProtocol checkIfOrderCancelled fuction called")
        if isSuccess{
            self.currentDeliverySlot = nil
            self.order = nil
            UserDefaults.resetEditOrder()
            self.finalRemoveCall();
            if self.isNeedToHideBackButton {
                // if let SDKManager = SDKManager.shared {
                SDKManager.shared.rootViewController?.dismiss(animated: false, completion: nil)
                (SDKManager.shared.rootViewController as? UINavigationController)?.popToRootViewController(animated: false)
                // }
                if let tab = ((getSDKManager().rootViewController as? UINavigationController)?.viewControllers[0] as? UITabBarController) {
                    ElGrocerUtility.sharedInstance.resetTabbar(tab)
                    tab.selectedIndex = 1
                }
            }
            Thread.OnMainThread {
                self.navigationController?.popToRootViewController(animated: true)
            }
            
            
        }else{
           elDebugPrint("protocol fuction called Error")
        }
    }
 
    private func cancelOrder(_ orderId : String){
        
        /*
         func finalCancelCall() {
         
         let spinner = SpinnerView.showSpinnerViewInView(self.view)
         ElGrocerApi.sharedInstance.cancelOrder(orderId, completionHandler: { (result) -> Void in
         
         spinner?.removeFromSuperview()
         
         switch result {
         case .success(_):
         
         //                        let notification = ElGrocerAlertView.createAlert(localizedString("order_cancel_alert_title", comment: ""),description: localizedString("order_cancel_success_message", comment: ""),positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
         //                        notification.showPopUp()
         let msg = localizedString("order_cancel_success_message", comment: "")
         ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "MyBasketOutOfStockStatusBar") , -1 , false) { (sender , index , isUnDo) in  }
         
         UserDefaults.resetEditOrder()
         self.finalRemoveCall();
         
         case .failure(let error):
         error.showErrorAlert()
         }
         })
         
         } */
        
        guard !orderId.isEmpty else {return}
            //show confirmation alert
        self.cancelOrderHandler(orderId)
        
        /*
         let SDKManager = SDKManager.shared
         let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "NoCartPopUp") , header: "" , detail: localizedString("order_history_cancel_alert_message", comment: "") ,localizedString("sign_out_alert_no", comment: "") , localizedString("sign_out_alert_yes", comment: "") , withView: SDKManager.window!) { (buttonIndex) in
         
         if buttonIndex == 1 {
         finalCancelCall()
         self.cancelOrderHandler(orderId)
         //  FireBaseEventsLogger.trackSubstitutionsEvents("CancelOrder")
         }
         }
         */
        
        
        
        
        
        
        /*
         ElGrocerAlertView.createAlert(localizedString("order_history_cancel_alert_title", comment: ""),
         description: localizedString("order_history_cancel_alert_message", comment: ""),
         positiveButton: localizedString("sign_out_alert_yes", comment: ""),
         negativeButton: localizedString("sign_out_alert_no", comment: "")) { (buttonIndex:Int) -> Void in
         
         if buttonIndex == 0 {
         finalCancelCall()
         FireBaseEventsLogger.trackSubstitutionsEvents("CancelOrder")
         }
         
         }.show()
         */
        
    }
    
    private func removeAllRecipeItems() -> Void {
        
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        let userProfile = UserProfile.getUserProfile(context)
        if let profile = userProfile {
            context.perform {
                RecipeCart.DeleteAll(forDBID: Int64(truncating: profile.dbID), context)
            }
            
        }
        
    }
    
    private func getItemCounterWithProduct(_ product:Product) -> NSInteger{
        
        var itemCount = 0
        let item = shoppingItemForProduct(product)
        if let notNilItem = item {
            itemCount = notNilItem.count.intValue
        }
        
        return itemCount
    }
    
    func chooseReplacementWithProductIndex(_ index:NSInteger){
        
            //  elDebugPrint("Replacement Button Tag:%d",index)
        if (self.products != nil && index >= 0 && index < self.products.count){
            
            self.selectedIndex = IndexPath.init(row: index, section: 0)
            if let indexAvailable = self.selectedIndex {
                self.tblBasket.reloadRows(at: [indexAvailable], with: .fade)
                self.setreplceProductData(at: indexAvailable)
            }
            
                //            var textToReplaceList = [String]()
                //            var productIDList = [Product]()
                //            for data in  self.products {
                //                //let isProductAvailable = isProductAvailableInGrocery(data)
                //                let isProductOutOfStock = data.isPublished.boolValue && data.isAvailable.boolValue
                //                if !isProductOutOfStock {
                //                    textToReplaceList.append(data.name!)
                //                    productIDList.append(data)
                //                }
                //            }
                //            let shoppingListController = ElGrocerViewControllers.shoppingListViewController()
                //            shoppingListController.searchList = textToReplaceList.joined(separator: "\n" ).lowercased()
                //            shoppingListController.isChooseAlternative = true
                //            shoppingListController.chooseAlternativeProducts = productIDList
                //            self.navigationController?.pushViewController(shoppingListController, animated: true)
            
            
            
        }
    }
    
    func gotoReplacementVC ( index : Int , _ product : Product? = nil ) {
        
        var productToReplace : Product?
        
        if let data = product {
            productToReplace = data
        }else{
            productToReplace = self.products[index]
        }
        let currentProductsA = self.products.map { $0.dbID }
        let replacementVC = ElGrocerViewControllers.replacementViewController()
        replacementVC.besketSelectedProductsId = currentProductsA
        replacementVC.isFromBasket = true
        replacementVC.currentAlternativeProduct = productToReplace
        replacementVC.cartGrocery = self.grocery
        replacementVC.notAvailableProducts = []
        replacementVC.chooseReplacementClouser = { (currentAlternativeProduct , alternativeProducts) in
            self.substituteProduct[currentAlternativeProduct.dbID] = alternativeProducts
            
            
            if let itemSub =   ShoppingBasketItem.checkIfProductIsInBasket(currentAlternativeProduct, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                if itemSub.isSubtituted.boolValue  {
                    if let productID = itemSub.subStituteItemID {
                        let proct = self.products.filter { (prodct) -> Bool in
                            if prodct.dbID == productID {
                                return true
                            }
                            return false
                        }
                        for productToDelete in proct {
                            ShoppingBasketItem.removeProductFromBasket(productToDelete, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                            DatabaseHelper.sharedInstance.saveDatabase()
                            if let dataI = self.products.firstIndex(of: productToDelete) {
                                self.products.remove(at: dataI)
                            }
                            if let dataI = self.availableProducts.firstIndex(of: productToDelete) {
                                self.availableProducts.remove(at: dataI)
                            }
                        }
                    }
                }
            }
            
            for selectedProduct in alternativeProducts {
                if let _ = self.products.firstIndex(of: selectedProduct) { }else {
                    self.products.append(contentsOf: alternativeProducts)
                }
                if let _ = self.availableProducts.firstIndex(of: selectedProduct) { }else {
                    self.availableProducts.append(contentsOf: alternativeProducts)
                }
                self.loadShoppingBasketDataRefreshed( oldProduct: currentAlternativeProduct , newProduct: selectedProduct )
                ElGrocerEventsLogger.sharedInstance.addToCart(product: selectedProduct , "", "",  false,  nil)
                MixpanelEventLogger.trackCartOOSSelected(product: selectedProduct, OOSProduct: currentAlternativeProduct)
            }
            
            self.tblBasket.reloadDataOnMain()
            
        }
        
        Thread.OnMainThread {
            self.present(replacementVC, animated: true, completion: nil)
        }
        
        
    }
    
    func setreplceProductData (at IndexPath : IndexPath) -> Void {
        
        let product = self.products[IndexPath.row]
        
        ElGrocerApi.sharedInstance.getReplacementProducts( product.name! , limit: 10 , offset: 0, product:  product , grocery: self.grocery , completionHandler: { [weak self](result:Bool, responseObject:NSDictionary?) -> Void in
            
            guard let self = self else { return }
            
            if result {
                Thread.OnMainThread {
                    let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    DatabaseHelper.sharedInstance.saveDatabase()
                    self.replaceProductsList = newProducts
                    self.tblBasket.reloadRows(at: [IndexPath], with: .fade)
                }
            }
            
        })
        
    }
    
    func deleteProductInBasketWithProductIndex(_ index:NSInteger){
        self.deleteProduct(index, nil)
    }
    
    
    func deleteProduct (_ index: NSInteger , _ product : Product?) {
        
        
        if product != nil {
            
            if (self.products != nil ) {
                
                if  let productToDelete  = product {
                    
                    ShoppingBasketItem.removeProductFromBasket(productToDelete, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    DatabaseHelper.sharedInstance.saveDatabase()
                    if self.orderToReplace {
                        MixpanelEventLogger.trackEditCartRemoveItem(product: productToDelete)
                    }else {
                        MixpanelEventLogger.trackCartRemoveItem(product: productToDelete)
                    }
                    if let indexRow = self.products.firstIndex(of: productToDelete) {
                        self.products.remove(at: indexRow)
                    }
                    if let indexRow = self.notAvailableProductsList.firstIndex(of: productToDelete) {
                            //  self.tblBasket.beginUpdates()
                            //  let indexPath = IndexPath(row:indexRow , section: 1)
                        self.notAvailableProductsList.remove(at: indexRow)
                            // self.tblBasket.deleteRows(at: [indexPath], with: .fade)
                            //  self.tblBasket.endUpdates()
                    }
                    
                    if let indexRow = self.availableProducts.firstIndex(of: productToDelete) {
                            //  self.tblBasket.beginUpdates()
                            //  let indexPath = IndexPath(row:indexRow , section: 1)
                        self.availableProducts.remove(at: indexRow)
                            // self.tblBasket.deleteRows(at: [indexPath], with: .fade)
                            //  self.tblBasket.endUpdates()
                    }
                    
                    self.tblBasket.reloadDataOnMain()
                }
                
//                refreshView()
            }
            
        }else {
            
                // elDebugPrint("Delete Button Tag:%d",index)
            if (self.products != nil && index >= 0 && index < self.products.count){
                
                let productToDelete  = self.products[index]
                
                ShoppingBasketItem.removeProductFromBasket(productToDelete, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                DatabaseHelper.sharedInstance.saveDatabase()
                if self.orderToReplace {
                    MixpanelEventLogger.trackEditCartRemoveItem(product: productToDelete)
                }else {
                    MixpanelEventLogger.trackCartRemoveItem(product: productToDelete)
                }
                let indexPath = IndexPath(row:index, section: 0)
                
                    //remove product from table
                self.products.remove(at: (indexPath as NSIndexPath).row)
                self.tblBasket.deleteRows(at: [indexPath], with: UITableView.RowAnimation.none)
                
                refreshView()
            }else{
                
                self.navigationController?.popViewController(animated: true)
                
            }
        }
    }
    
    func addProductInBasketWithProductIndex(_ index:NSInteger){
       elDebugPrint("Plus Button Tag:%d",index)
        guard index > -1 , index < self.availableProducts.count else {return}
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("increase_quantity_at_my_basket_screen")
        self.selectedProduct = self.availableProducts[index]
        if self.orderToReplace {
            MixpanelEventLogger.trackEditCartAddItem(product: self.selectedProduct)
        }else {
            MixpanelEventLogger.trackCartAddItem(product: self.selectedProduct)
        }
        var counter = self.getItemCounterWithProduct(self.selectedProduct)
        ProductQuantiy.canAddProduct(selectedProduct: selectedProduct, counter: counter) {[weak self] limitAvailable in
            guard let self = self else {return}
            if limitAvailable {
                counter += 1
                self.updateSelectedProductsQuantity(counter, andWithProductIndex: index)
                self.updateQuantityAndPriceColour(index)
                self.logAddProductEvent(self.selectedProduct)
                
                if self.selectedProduct.promotion?.boolValue == true {
                    
                    func showOverLimitMsg() {
                        let msg = localizedString("msg_limited_stock_start", comment: "") + "\(self.selectedProduct.promoProductLimit!)" + localizedString("msg_limited_stock_end", comment: "")
                        let title = localizedString("msg_limited_stock_title", comment: "")
                        ElGrocerUtility.sharedInstance.showTopMessageView(msg ,title, image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
                    }
                    
                    if (counter >= self.selectedProduct.promoProductLimit as! Int) && self.selectedProduct.promoProductLimit?.intValue ?? 0 > 0 {
                        showOverLimitMsg()
                        
                    }
                }else {
                    
                    if self.selectedProduct.availableQuantity >= 0 && self.selectedProduct.availableQuantity.intValue <= counter {
                        func showOverLimitMsg() {
                            let msg = localizedString("msg_limited_stock_start", comment: "") + "\(self.selectedProduct.availableQuantity)" + localizedString("msg_limited_stock_end", comment: "")
                            let title = localizedString("msg_limited_stock_Quantity_title", comment: "")
                            ElGrocerUtility.sharedInstance.showTopMessageView(msg ,title, image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
                        }
                        showOverLimitMsg()
                    }
                }
            }
        }
        
    }
    
    func logAddProductEvent (_ product : Product) {
        
        ElGrocerEventsLogger.sharedInstance.addToCart(product: product, "", "", false , nil)
        
    }
    
    func discardProductInBasketWithProductIndex(_ index:NSInteger){
        
        if index < self.products.count && index >= 0 {
            
            self.selectedProduct = self.products[index]
                //  UserDefaults.setPromoCodeValue(nil) // now we reapplying this code every time.
            var counter = self.getItemCounterWithProduct(self.selectedProduct)
            if counter > 0 {
                counter -= 1
                if counter < 1  && UserDefaults.isOrderInEdit() {
                    ElGrocerUtility.sharedInstance.showTopMessageView(localizedString("lbl_edit_delete", comment: ""), image: UIImage(name: "MyBasketOutOfStockStatusBar"), index , backButtonClicked: { [weak self] (sender , index , isUnDo) in
                        if isUnDo {
                            if let availableP = self?.selectedProduct {
                                self?.updateSelectedProductsQuantity(1, andWithProductIndex: index)
                                self?.loadShoppingBasketData()
                                self?.reloadTableData()
                            }
                        }else{
                            
                        }
                    })
                    
                }
                self.updateSelectedProductsQuantity(counter, andWithProductIndex: index)
                if(counter > 0){
                    self.updateQuantityAndPriceColour(index)
                }
                ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("decrease_quantity_at_my_basket_screen")
                FireBaseEventsLogger.trackDecrementAddToProduct(product: self.selectedProduct)
            }else if (counter == 0){
                self.updateSelectedProductsQuantity(counter, andWithProductIndex: index)
                
            }
            if self.orderToReplace {
                MixpanelEventLogger.trackEditCartRemoveItem(product: self.selectedProduct)
            }else {
                MixpanelEventLogger.trackCartRemoveItem(product: self.selectedProduct)
            }
            
        }
        
        
        
    }
    
    func updateQuantityAndPriceColour(_ index:NSInteger){
        
        let shoppingItem = shoppingItemForProduct(self.selectedProduct)
        let priceDict = getPriceDictionaryForProduct(self.selectedProduct)
        
        var price = self.selectedProduct.price
        if let priceFromGrocery = priceDict?["price_full"] as? NSNumber {
            price = priceFromGrocery
        }
        
        let indexPath = IndexPath(row:index, section: 4)
        guard self.tblBasket.indexPathsForVisibleRows?.contains(indexPath) ?? false  == true else {
            return
        }
        guard !(self.tblBasket.cellForRow(at: indexPath) is  MyBasketReplaceProductTableViewCell) else {
            return
        }
        
        let cell = self.tblBasket.cellForRow(at: indexPath) as! MyBasketTableViewCell
        let dict1 = [NSAttributedString.Key.foregroundColor: UIColor.darkTextGrayColor(),NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(6.0)]
        
        let dict2 = [NSAttributedString.Key.foregroundColor:UIColor.lightBlackColor(),NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(11.0)]
        
        let dict3 = [NSAttributedString.Key.foregroundColor: UIColor.red,NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(11.0)]
        
        let partAED = NSMutableAttributedString(string:NSString(format: "%@\n",CurrencyManager.getCurrentCurrency()) as String, attributes:dict1)
        
        let partTwoProductPrice = NSMutableAttributedString(string:String(format:"%.2f ",price.doubleValue), attributes:dict2)
        
        let partThreeItemCount = NSMutableAttributedString(string:String(format:"%@%d","x",shoppingItem!.count.intValue), attributes:dict3)
        
        let attStringProductPrice = NSMutableAttributedString()
        
        attStringProductPrice.append(partAED)
        attStringProductPrice.append(partTwoProductPrice)
        attStringProductPrice.append(partThreeItemCount)
        
        let priceSum = price.doubleValue * shoppingItem!.count.doubleValue
        
        let partTwoProductTotalPrice = NSMutableAttributedString(string:String(format:"%.2f",priceSum), attributes:dict3)
        
        let attStringProductTotalPrice = NSMutableAttributedString()
        
        attStringProductTotalPrice.append(partAED)
        attStringProductTotalPrice.append(partTwoProductTotalPrice)
        
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            
            let partTwoProductPrice = NSMutableAttributedString(string:String(format:"%.2f %@%d",price.doubleValue,"x",shoppingItem!.count.intValue), attributes:dict2)
            
            let attStringProductPrice = NSMutableAttributedString()
            
            attStringProductPrice.append(partAED)
            attStringProductPrice.append(partTwoProductPrice)
            
            let priceSum = price.doubleValue * shoppingItem!.count.doubleValue
            
            let partTwoProductTotalPrice = NSMutableAttributedString(string:String(format:"%.2f",priceSum), attributes:dict2)
            
            let attStringProductTotalPrice = NSMutableAttributedString()
            
            attStringProductTotalPrice.append(partAED)
            attStringProductTotalPrice.append(partTwoProductTotalPrice)
            
            cell.productTotalPrice.textColor = UIColor.white
            cell.lblQuantity.textColor = UIColor.white
            self.itemsTotalPrice.textColor =  UIColor.white
            self.itemsCount.textColor = UIColor.white
        })
        
    }
    
    
    
        // MARK: Data
    func saveResponseData(_ responseObject:NSDictionary) {
        
        
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        
        context.perform {
            () -> Void in
            _ = DeliverySlot.insertOrReplaceDeliverySlotsFromDictionary(responseObject, context: context)
        }
        
        context.perform({ () -> Void in
            Grocery.updateActiveGroceryDeliverySlots(with: responseObject, context: context)
        })
        
        DispatchQueue.main.async(execute: { [weak self] in
            guard let self = self else { return }
            if(self.groceryStatus != self.grocery?.isOpen.boolValue){
                let schedulePopUp = SchedulePopUp.createSchedulePopUpWithGrocery(self.grocery)
                schedulePopUp.showPopUp()
            }
        })
        
    }
    
        // MARK: Get Basket Data
    func getBasketFromServerWithGrocery(_ grocery:Grocery?){
        
        let spinnerView = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.fetchBasketFromServerWithGrocery(grocery) { (result) in
                //elDebugPrint(result)
            self.tblBasket.isHidden = false
            spinnerView?.removeFromSuperview()
            switch result {
                case .success(let responseDict):
                   elDebugPrint("Fetch Basket Response:%@",responseDict)
                    self.saveResponseData(responseDict, andWithGrocery: grocery)
                case .failure(let error):
                   elDebugPrint("Fetch Basket Error:%@",error.localizedMessage)
                    spinnerView?.removeFromSuperview()
                    self.checkData()
            }
        }
    }
        // MARK: Basket Data
    func saveResponseData(_ responseObject:NSDictionary, andWithGrocery grocery:Grocery?) {
        
            //guard let dataDict = responseObject["data"] as? NSDictionary else {return}
        guard let shopperCartProducts = responseObject["data"] as? [NSDictionary] else {return}
        
        var isPromoChanged = false
        
        Thread.OnMainThread {
            if(shopperCartProducts.count > 0){
                let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                context.performAndWait {
                    ShoppingBasketItem.clearActiveGroceryShoppingBasket(context)
                }
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
                    
                    if let messages = productDict["messages"] as? [NSDictionary] {
                        
                        for message in messages {
                            
                            
                                //checking for promotion change
                            
                            if let messages = productDict["messages"] as? [NSDictionary]{
                                for message in messages{
                                    
                                    if let messageCode = message["message_code"] as? NSNumber{
                                        if messageCode == 2000{
                                            if !isPromoChanged{
                                                isPromoChanged = true
                                                self.promotionalItemChanged = isPromoChanged
                                                break
                                            }
                                            
                                        }else{
                                            self.promotionalItemChanged = isPromoChanged
                                        }
                                    }
                                    if let messageString = message["message"] as? String{
                                        self.promotionalItemChangedMessage = messageString
                                    }
                                    
                                }
                                if messages.count == 0{
                                    self.promotionalItemChanged = isPromoChanged
                                }
                            } else {
                                self.promotionalItemChanged = isPromoChanged
                            }
                        }
                    }
                    
                    DatabaseHelper.sharedInstance.saveDatabase()
                    ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: grocery, brandName: nil, quantity: quantity, context: context, orderID: nil, nil, false)
                    
                }
                
            }
            
            ElGrocerUtility.sharedInstance.delay(0.2) {
                self.checkData()
                self.loadShoppingBasketData()
                self.reloadTableData()
            }
        }
    }
    
        
    
    private func removeOutOfStockProductsFromBasket(){
        
        ElGrocerUtility.sharedInstance.delay(0.1) {
            
            for productToDelete in self.products {
                if (!productToDelete.isAvailable.boolValue  || !productToDelete.isPublished.boolValue){
                    if let index = self.products.firstIndex(of:productToDelete) {
                        self.deleteProduct(index, productToDelete)
                    }
                }
            }
            self.loadShoppingBasketData()
            self.isOutOfStockProductAvailablePreCart = false
            self.isOutOfStockProductAvailable = false
            self.reloadTableData()
//            if let grocery = self.grocery {
//                self.proceedToCheckOutWithGrocery(grocery)
//            }
            
        }
        
    }
    
    @IBAction func btnAddAddressAction(_ sender: Any) {
        
        if let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            let editLocationController = ElGrocerViewControllers.editLocationViewController()
            editLocationController.deliveryAddress = deliveryAddress
            editLocationController.editScreenState = .isFromCart
            
            
            let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navigationController.hideSeparationLine()
            navigationController.viewControllers = [editLocationController]
            navigationController.modalPresentationStyle = .fullScreen
            self.navigationController?.present(navigationController, animated: true, completion: nil) //pushViewController(editLocationController, animated: true)
        }
        
    }
    
    
    
}


extension MyBasketViewController : CategorySearchBarDelegate {
    
    func categorySearchBarActivated() {
        
    }
    func didTapCategorySearchBar() {
        
        let searchController = ElGrocerViewControllers.searchViewController()
        searchController.isNavigateToSearch = true
        searchController.navigationFromControllerName = FireBaseScreenName.MyBasket.rawValue
        MixpanelEventLogger.trackEditCartSearchClick()
        if let topName = FireBaseEventsLogger.gettopViewControllerName() {
            searchController.navigationFromControllerName = topName
        }
        self.navigationController?.pushViewController(searchController, animated: true)
    }
    
}


extension MyBasketViewController {
    
    
    private func setOrderTypeLabelText() {
        
        /*1- instant or Instant + Schedule + open - ASAP.
         2- Schedule or (Instant + Schedule + close) - Next available slot.*/
        self.deliverySlotsArray = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: self.grocery?.dbID ?? "-1")
        if let slots =  UserDefaults.getEditOrderSelectedDeliverySlot() {
            self.deliverySlotsArray.append(DeliverySlot.createDeliverySlotFromCustomDictionary(slots as! NSDictionary, context: DatabaseHelper.sharedInstance.mainManagedObjectContext))
        }
        let slotId = UserDefaults.getCurrentSelectedDeliverySlotId()
        if (self.grocery?.deliveryTypeId != nil && (self.grocery?.deliveryTypeId == "1" || (self.grocery?.deliveryTypeId == "2" && self.grocery?.isOpen.boolValue == false))) {
            
                // elDebugPrint("Delivery Slots Array Count:%d",self.deliverySlotsArray.count)
            
            if (self.deliverySlotsArray.count > 0) {
                var currentSlots : [DeliverySlot] = []
                let slot = self.deliverySlotsArray[0]
                currentSlots = [slot]
            }else{
                orderTypeDescription =  localizedString("no_slots_available", comment: "")
            }
        }
        if slotId != 0 {
            let index = self.deliverySlotsArray.firstIndex(where: { $0.dbID == slotId })
            if (index != nil) {
                self.currentDeliverySlot = self.deliverySlotsArray[index!]
            }else{
               // self.showCustomTipBar()
                self.currentDeliverySlot = nil
            }
            if self.currentDeliverySlot != nil && (!self.currentDeliverySlot!.isInstant.boolValue)  && (self.currentDeliverySlot.estimated_delivery_at.minutesFrom(Date())) < 0 {
                self.updateSlotsAndChooseNextAvailable()
                let currentSlotIndex = self.deliverySlotsArray.firstIndex(where: {$0.dbID == self.currentDeliverySlot.dbID})
                if (currentSlotIndex != nil) {
                        // elDebugPrint("Current Slot Index:%d",currentSlotIndex!)
                    let nextAvailableSlotIndex = currentSlotIndex! + 1
                        //elDebugPrint("Next Available Slot Index:%d",nextAvailableSlotIndex)
                    if(nextAvailableSlotIndex < self.deliverySlotsArray.count){
                        self.currentDeliverySlot = self.deliverySlotsArray[nextAvailableSlotIndex]
                    }else{
                        self.isNextSlotAvailable = false
                    }
                }
            }
        }else{
            if UserDefaults.getEditOrderSelectedDeliverySlot() == nil {
                self.currentDeliverySlot = nil
            }
        }
        if self.currentDeliverySlot != nil && isNextSlotAvailable == true {
            UserDefaults.setCurrentSelectedDeliverySlotId(self.currentDeliverySlot.dbID)
            orderTypeDescription = self.currentDeliverySlot.getSlotFormattedString(true, isDeliveryMode: ElGrocerUtility.sharedInstance.isDeliveryMode)
        }else{
            if (self.grocery?.deliveryTypeId == "0" || (self.grocery?.deliveryTypeId == "2" && self.grocery?.isOpen.boolValue == true)) {
                orderTypeDescription =   localizedString("today_title", comment: "") + " "   +  localizedString("60_min", comment: "")
            }else{
                if  self.deliverySlotsArray.count > 0 {
                    self.currentDeliverySlot = self.deliverySlotsArray[0]
                    orderTypeDescription = self.currentDeliverySlot.getSlotFormattedString(true, isDeliveryMode: ElGrocerUtility.sharedInstance.isDeliveryMode)
                    
                }else{
                    orderTypeDescription = localizedString("choose_slot", comment: "")
                }
            }
        }
        let _ =  self.getFinalAmount ()
    }
    
    @objc func showCustomTipBar() {
        
        ElGrocerUtility.sharedInstance.delay(1) {
            if UIApplication.topViewController() is MyBasketViewController {
                let msg = localizedString("slot_expired_message", comment: "")
                ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "BasketAvailable") , -1 , false) { (sender , index , isUnDo) in  }
            }
        }
        
    }
    
    
        // MARK: Get Delivery Slots
    func updateSlotsAndChooseNextAvailable(_ isNeedToChooseNext : Bool = true){
        
        let groceryID =  Grocery.getGroceryIdForGrocery(self.grocery)
        ElGrocerApi.sharedInstance.getGroceryDeliverySlotsWithGroceryId(groceryID, andWithDeliveryZoneId: self.grocery!.deliveryZoneId, completionHandler: { (result) -> Void in
            SpinnerView.hideSpinnerView()
            switch result {
                    
                case .success(let response):
                        // elDebugPrint("SERVER Response:%@",response)
                    self.saveResponseDataForSlots(response,isNeedToChooseNext)
                    
                case .failure(let error):
                   elDebugPrint("Error while getting Delivery Slots from SERVER:%@",error.localizedMessage)
            }
        })
    }
    
        // MARK: Data
    func saveResponseDataForSlots(_ responseObject:NSDictionary , _ isNeedToChooseNext : Bool = true) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
            context.perform({ () -> Void in
                self.deliverySlotsArray = DeliverySlot.insertOrReplaceDeliverySlotsFromDictionary(responseObject, context: context )
                if !isNeedToChooseNext {
                    self.setOrderTypeLabelText()
                }else{
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {return}
                        if(self.deliverySlotsArray.count > 0){
                            let deliverySlot = self.deliverySlotsArray[0]
                            if (Int(truncating: deliverySlot.dbID) != asapDbId){
                                self.currentDeliverySlot = deliverySlot
                            }else{
                                if(self.deliverySlotsArray.count > 1){
                                    self.currentDeliverySlot = self.deliverySlotsArray[1]
                                }else{
                                    self.isNextSlotAvailable = false
                                    self.showNoSlotAvailableAlert()
                                }
                            }
                        }else{
                            self.isNextSlotAvailable = false
                            self.showNoSlotAvailableAlert()
                        }
                        self.setOrderTypeLabelText()
                    }
                }
                
            })
        }
    }
    
    private func showNoSlotAvailableAlert(){
        
        ElGrocerAlertView.createAlert(localizedString("no_slot_available_title", comment: ""),
                                      description:localizedString("no_slot_available_message", comment: ""),
                                      positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                      negativeButton: nil, buttonClickCallback: nil).show()
        
    }
    
    private func showSlotExpiryAlert(){
        
        self.updateSlotsAndChooseNextAvailable()
        
        let currentSlotIndex = self.deliverySlotsArray.firstIndex(where: {$0.dbID == self.currentDeliverySlot.dbID})
        if (currentSlotIndex != nil) {
            self.deliverySlotsArray.sort { $0.start_time ?? Date() < $1.start_time ?? Date() }
           elDebugPrint("Current Slot Index:%d",currentSlotIndex!)
            let nextAvailableSlotIndex = currentSlotIndex! + 1
           elDebugPrint("Next Available Slot Index:%d",nextAvailableSlotIndex)
            if(nextAvailableSlotIndex < self.deliverySlotsArray.count){
                self.currentDeliverySlot = self.deliverySlotsArray[nextAvailableSlotIndex]
            }
        }
        
        ElGrocerAlertView.createAlert(localizedString("slot_expired_title", comment: ""),
                                      description:localizedString("slot_expired_message", comment: ""),
                                      positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                      negativeButton: nil, buttonClickCallback: nil).show()
        
    }
    
    
}

extension MyBasketViewController {
    
    
    func isSlotValidated() -> Bool {
        
        return ((self.grocery?.deliveryTypeId == "0") || (self.grocery?.deliveryTypeId == "2" && self.grocery?.isOpen.boolValue == true) || (self.currentDeliverySlot != nil))
        
    }
    
    
    func getFinalAmount () -> Double {
        
        var discountedPriceis = 0.0
        if let promoCodeValue = UserDefaults.getPromoCodeValue() {
            discountedPriceis = priceSum - promoCodeValue.valueCents
        }
        
        if discountedPriceis == 0 {
            discountedPriceis = priceSum
        }
        
        DispatchQueue.main.async {
//            self.itemsTotalPrice.text = String(format:"%@ %.2f",CurrencyManager.getCurrentCurrency() ,self.getFinalAmountToDisplay())
            self.itemsTotalPrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: self.getFinalAmountToDisplay())
        }
        
        var isNeedToEnableButton = false
        if self.isAddressCompleted && UserDefaults.isUserLoggedIn() {
            isNeedToEnableButton = true
        }
        
        if isNeedToEnableButton {
            isNeedToEnableButton = self.isMinimumOrderValueFulfilled()
        }
        
        if !self.isOutOfStockProductAvailablePreCart {
            self.setCheckoutButtonEnabled(isNeedToEnableButton)
        }
       
        return discountedPriceis
        
    }
    
    func getFinalAmountToDisplay () -> Double {
        
            //        var discountedPriceis = 0.0
            //        var isPromoCode = false
            //        if let promoCodeValue = UserDefaults.getPromoCodeValue() {
            //            discountedPriceis = priceSum - promoCodeValue.valueCents
            //            isPromoCode = true
            //        }
            //        var finpriceToShow = discountedPriceis
            //        if discountedPriceis == 0 {
            //            discountedPriceis = priceSum
            //        }
            //        if finpriceToShow <= 0  && isPromoCode {
            //            finpriceToShow = 0.00
            //        }else{
            //            finpriceToShow = discountedPriceis
            //        }
        
        return priceSum
        
    }
    
    func getTotalSavingsAmountWithoutPromo() -> Double{
        
        var Discount : Double = 0.0
        for product in products {
            
            let item = shoppingItemForProduct(product)
            let isProductAvailable = isProductAvailableInGrocery(product)
            let priceDict = getPriceDictionaryForProduct(product)
            
            if let notNilItem = item {
                
                    // summaryCount += notNilItem.count.intValue
                
                if !isProductAvailable {
                        // notAvailableCount += notNilItem.count.intValue
                } else {
                    
                    if(product.isPublished.boolValue && product.isAvailable.boolValue){
                        let promotionValues = ProductQuantiy.checkPromoNeedToDisplay(product)
                        if promotionValues.isNeedToDisplayPromo{
                            let price : Double = product.price.doubleValue
                            var promoPrice : Double = 0.0
                            var discountOnSingle : Double = 0.0
                            if let promoPrices = product.promoPrice?.doubleValue{
                                promoPrice = promoPrices
                            }
                            if let promoDict = priceDict?["promotion"] as? NSDictionary {
                                if let promoPrices = promoDict["price"] as? Double{
                                    promoPrice = promoPrices
                                }
                            }
                            discountOnSingle = (price - promoPrice) * notNilItem.count.doubleValue
                            Discount += discountOnSingle
                        }
                    }
                }
            }
        }
        
            //        if isPromo{
            //            if promoValue != nil && promoValue.valueCents > 0{
            //                Discount = (promoValue.valueCents) + Discount
            //            }
            //        }
        
        return Discount
        
    }
    
    func getTotalShoppingAmount() {
        
        priceSum = 0.0
        itemsQuantity = 0
        
        
        for product in products {
            
            let item = shoppingItemForProduct(product)
            let isProductAvailable = isProductAvailableInGrocery(product)
            let priceDict = getPriceDictionaryForProduct(product)
            
            if let notNilItem = item {
                
                    // summaryCount += notNilItem.count.intValue
                
                if !isProductAvailable {
                        // notAvailableCount += notNilItem.count.intValue
                } else {
                    
                    if(product.isPublished.boolValue && product.isAvailable.boolValue){
                        var price = product.price.doubleValue
                        if let priceFromGrocery = priceDict?["price_full"] as? NSNumber {
                            price = priceFromGrocery.doubleValue
                        }
                        
                        if product.promotion?.boolValue == true{
                            if let promoPrice = product.promoPrice?.doubleValue{
                                price = promoPrice
                                
                            }
                            if let promoDict = priceDict?["promotion"] as? NSDictionary {
                                if let promoPrice = promoDict["price"] as? Double{
                                    price = promoPrice
                                }
                                
                            }
                        }
                        
                        priceSum += price * notNilItem.count.doubleValue
                        itemsQuantity = itemsQuantity + notNilItem.count.intValue
                    }
                }
            }
        }
        
        self.priceSum   = self.itemsSummaryValue
        
        /*
         if (self.itemsSummaryValue ) < self.grocery?.minBasketValue ?? 0 {
         
         // Order amount is less then minimum basket amount
         // add delivery fees + service fees
         self.serviceFee = (self.grocery?.serviceFee ?? 0) + (self.grocery?.deliveryFee ?? 0)
         self.priceSum  = (self.itemsSummaryValue ) + (self.serviceFee )
         
         }else{
         
         // Order amount more then or eqaul to minimum basket amount
         // add rider fees + service fees
         self.serviceFee = (self.grocery?.riderFee ?? 0) + (self.grocery?.serviceFee ?? 0)
         self.priceSum   = (self.itemsSummaryValue ) + (self.serviceFee )
         }
         */
        
    }
    
}
extension MyBasketViewController {
    
    
    func setRecipeCartAnalyticsAndRemoveRecipe() {
        
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        let userProfile = UserProfile.getUserProfile(context)
        RecipeCart.GETSpecficUserAddToCartListRecipes(forDBID:  userProfile?.dbID ?? 0 , context) { [weak self](recipeCartList) in
                // guard let self = self else {return}
            guard let listData = recipeCartList else {
                RecipeCart.DeleteAll(forDBID: userProfile?.dbID as! Int64 , context)
                return
            }
            
            let productCurrentA = self?.products
            
            for data :RecipeCart in listData {
                var isNeedToLockRecipeOrderEvent = false
                let ingredientsListID = data.ingredients
                let filterA = productCurrentA?.filter {
                    ingredientsListID.contains($0.productId)
                }
                if let finalA = filterA {
                    if finalA.count > 0 {
                        isNeedToLockRecipeOrderEvent = true
                    }
                    for prod in finalA {
                        if let productName = ElGrocerUtility.sharedInstance.isArabicSelected() ? prod.nameEn : prod.name {
                            let trackEventName = FireBaseElgrocerPrefix + FireBaseEventsName.RecipeIngredientPurchase.rawValue
                            FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: trackEventName , parameter: [FireBaseParmName.RecipeName.rawValue : data.recipeName , FireBaseParmName.recipeId.rawValue : data.recipeID , FireBaseParmName.RecipeIngredientid.rawValue :  prod.productId  , FireBaseParmName.ProductName.rawValue : productName , FireBaseParmName.BrandName.rawValue :  prod.brandNameEn ?? "" , FireBaseParmName.CategoryName.rawValue :  prod.categoryNameEn ?? "" , FireBaseParmName.SubCategoryName.rawValue :  prod.subcategoryNameEn ?? ""   ])
                                //GoogleAnalyticsHelper.trackRecipeIngredientsOrderEvent(trackEventName, data.recipeName)
                        }
                    }
                }
                if isNeedToLockRecipeOrderEvent {
                    let eventName = FireBaseElgrocerPrefix +  FireBaseEventsName.RecipePurchase.rawValue
                    GoogleAnalyticsHelper.trackRecipeOrderEvent(eventName)
                    FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: eventName , parameter: [FireBaseParmName.RecipeName.rawValue : data.recipeName , FireBaseParmName.recipeId.rawValue : data.recipeID])
                }
            }
            RecipeCart.DeleteAll(forDBID: userProfile?.dbID as! Int64 , context)
            
        }
        
        CarouselProducts.GetSpecficUserAddToCartListCarousel(forUserDBID: userProfile?.dbID ?? 0 , context) { [unowned self] (carouselProducts) in
            
            guard let listData = carouselProducts else {
                CarouselProducts.DeleteAll(forDBID: userProfile?.dbID as! Int64 , context)
                return
            }
            
            self.carouselProductsArray.removeAll()
            let productCurrentA = self.products
            for data :CarouselProducts in listData {
                let filterA = productCurrentA.filter {
                    data.dbID == Int64(truncating: $0.productId)
                }
                for product:Product in filterA {
                    if let productName = ElGrocerUtility.sharedInstance.isArabicSelected() ? product.nameEn : product.name {
                        let trackEventName = FireBaseElgrocerPrefix + FireBaseEventsName.CarousalIngredientPurchase.rawValue
                        FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: trackEventName , parameter: [ FireBaseParmName.ProductId.rawValue :  product.productId  , FireBaseParmName.ProductName.rawValue : productName , FireBaseParmName.BrandName.rawValue :  product.brandNameEn ?? "" , FireBaseParmName.CategoryName.rawValue :  product.categoryNameEn ?? "" , FireBaseParmName.SubCategoryName.rawValue :  product.subcategoryNameEn ?? ""   ])
                    }
                    self.carouselProductsArray.append(product)
                }
            }
            CarouselProducts.DeleteAll(forDBID: userProfile?.dbID as! Int64 , context)
        }
    }
    
    
    
    func makeOrderEdit() {
        
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.ChangeOrderStatustoEdit(order_id: self.order.dbID.stringValue ) { [weak self](result) in
            spinner?.removeFromSuperview()
            guard let self = self else {return}
            if self.order.status.intValue == OrderStatus.inEdit.rawValue {
                self.order.status = NSNumber(value: OrderStatus.inEdit.rawValue)
                self.naviagteUserToOrderSummary()
            }else{
                switch result {
                    case .success(let data):
                        elDebugPrint(data)
                        self.order.status = NSNumber(value: OrderStatus.inEdit.rawValue)
                        self.naviagteUserToOrderSummary()
                    case .failure(let error):
                        if error.code == 471 {
                            self.order.status = NSNumber(value: OrderStatus.inEdit.rawValue)
                            self.naviagteUserToOrderSummary()
                        }
                }
            }
        }
    }
    
    private func naviagteUserToOrderSummary(){
        
        
        var productIds : [String] = []
        var brandNames : [String] = []
        var fbDataA : [[AnyHashable : Any]] = []
        for finalItem in self.shoppingItems {
            let facebookProductParams = ["id" : "\(Product.getCleanProductId(fromId:finalItem.productId))"  , "quantity" : finalItem.count.intValue ] as [AnyHashable: Any]
            fbDataA.append(facebookProductParams)
            productIds.append("\(Product.getCleanProductId(fromId:finalItem.productId))")
            brandNames.append(finalItem.brandName ?? "")
        }
        let paramsJSON = JSON(fbDataA)
        let paramsString = paramsJSON.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!
        
        ElGrocerEventsLogger.sharedInstance.trackCheckOut(coupon: productIds.joined(separator: ","), currency: kProductCurrencyEngAEDName, value: self.itemsSummaryValue , isEdit: UserDefaults.isOrderInEdit(), itemsCount: self.itemsCount.text ?? "", productIds: productIds.joined(separator: ","), appFlayerJsonString: paramsString )
        if self.orderToReplace {
            MixpanelEventLogger.trackEditCartBeginCheckout(value: "\(self.itemsSummaryValue)")
        }else {
            MixpanelEventLogger.trackCartBeginCheckout(value: "\(self.itemsSummaryValue)")
        }
        
        setRecipeCartAnalyticsAndRemoveRecipe()
        
        guard self.isDeliveryMode else {
            
            let vc = ElGrocerViewControllers.myBasketPlaceOrderVC()
            vc.hidesBottomBarWhenPushed = true
            vc.secondCheckOutDataHandler = self.populateMyBasketObjForCheckout()
            self.navigationController?.pushViewController(vc, animated: true)
            return
            
        }
        
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        
        var deliveryAddress : DeliveryAddress? = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        var slotId = self.currentDeliverySlot != nil ? self.currentDeliverySlot.backendDbId : 0
        var slot: DeliverySlot? = self.currentDeliverySlot != nil ? self.currentDeliverySlot : nil
        var orderID : String? = nil
        var orderForEdit : Order? = nil
        if UserDefaults.isOrderInEdit(), order != nil {
            deliveryAddress = order.deliveryAddress
            slotId = order.deliverySlot?.backendDbId ?? 0
            slot = order.deliverySlot
            orderID = UserDefaults.getEditOrderDbId()?.stringValue
            orderForEdit = order
            
        }
        
        if let deliveryAddress = deliveryAddress {
            let user = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            let vm = SecondaryViewModel(address: deliveryAddress, grocery: self.grocery!, slot: slotId,orderId: orderID,shopingItems: self.shoppingItems, finalisedProducts: self.products, selectedPreferenceId: self.myBasketDataObj.getSelectedReason()?.reasonKey.intValue ?? 1, deliverySlot: slot)
            vm.setEditOrderInitialDetail(orderForEdit)
            vm.getCartDetailsApi()
            vm.setUserId(userId: user?.dbID)
            vm.basketData
                .subscribe(onNext: { [weak self] data in
                    guard let self = self, let _ = data else { return }
                    Thread.OnMainThread {
                        guard UIApplication.topViewController() == self else { return }
                        SpinnerView.hideSpinnerView()
                        let secondVC = ElGrocerViewControllers.getSecondCheckoutVC()
                        secondVC.viewModel = vm
                        self.navigationController?.pushViewController(secondVC, animated: true)
                    }
                })
                .disposed(by: disposeBag)
            
            vm.basketError
                .subscribe (onNext: { cartApiError in
                    guard cartApiError != nil else{
                        return
                    }
                    SpinnerView.hideSpinnerView()
                    cartApiError?.showErrorAlert()
                })
                .disposed(by: disposeBag)
            vm.getBasketData
                .subscribe(onNext: { [weak self] data in
                    guard let self = self, let _ = data else { return }
                    Thread.OnMainThread {
                        guard UIApplication.topViewController() == self else { return }
                        SpinnerView.hideSpinnerView()
                        let secondVC = ElGrocerViewControllers.getSecondCheckoutVC()
                        secondVC.viewModel = vm
                        self.navigationController?.pushViewController(secondVC, animated: true)
                    }
                })
                .disposed(by: disposeBag)
            
            vm.getBasketError
                .subscribe (onNext: { cartApiError in
                    guard cartApiError != nil else{
                        return
                    }
                    vm.getBasketDetailWithSlot()
                })
                .disposed(by: disposeBag)
        }
        
        
   
    }
    
    func finalHandlerResult ( result: Either<NSDictionary> , finalOrderItems:[ShoppingBasketItem] , activeGrocery:Grocery! , finalProducts:[Product]! , orderID: NSNumber?) {
        
        
        switch result {
            case .success(let responseDict):
                
                if let orderDict = (responseDict["data"] as? NSDictionary) {
                        // remove already order from db with same order Number
                    if let orderId = orderDict["id"] as? NSNumber {
                        Order.deleteOrdersNotInJSON([orderId.intValue], context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext , orderID: orderId)
                    }
                    /* Done change order here  it will stop analytics */
                    let order = Order.insertOrReplaceOrderFromDictionary(orderDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    self.order = order
                        //  self.recordAnalytics(finalOrderItems: finalOrderItems , finalProducts: finalProducts, finalOrder: order, paymentOptio: self.selectedPaymentOption ?? PaymentOption.none )
                    DatabaseHelper.sharedInstance.saveDatabase()
                    self.proceedWithPaymentProcess()
                }
            case .failure(let error):
                error.showErrorAlert()
        }
        
    }
    
    
    
    func recordAnalytics(finalOrderItems:[ShoppingBasketItem] , finalProducts:[Product]! , finalOrder:Order! , paymentOptio : PaymentOption) {
        /*
        ElGrocerEventsLogger.sharedInstance.recordPurchaseAnalytics(finalOrderItems:finalOrderItems , finalProducts:finalProducts , finalOrder: finalOrder ,  availableProductsPrices:availableProductsPrices  , priceSum : priceSum , discountedPrice : discountedPrice  , grocery : finalOrder.grocery , deliveryAddress : finalOrder.deliveryAddress , carouselproductsArray : carouselProductsArray , promoCode : self.order?.promoCode?.code ?? "" , serviceFee : serviceFee , payment : paymentOptio, discount: self.getTotalSavingsAmountWithoutPromo(), IsSmiles: false )
         */
        // TODO: if ever tyo use this function should update the ismiles bool
        elDebugPrint("All analytics work done")
    }
    
    func proceedWithPaymentProcess() {
        
        /*
         if self.selectedPaymentOption == .creditCard {
         
         self.goToCvvAuthController(order: self.order, cvv: self.txtCvv.text ?? "", cardID: String(describing: self.selectedCreditCard?.cardID ?? 0) , authAmount: self.getFinalAmountToDisplay())
         
         return
         }else{
         showConfirmationView()
         return
         }
         */
        
    }
    
    
    func goToCvvAuthController( order : Order , cvv : String , cardID : String , authAmount : Double) {
        
        let vc = ElGrocerViewControllers.getEmbededPaymentWebViewController()
        vc.isAddNewCard = false
        vc.isNeedToDismiss = false
        vc.isForCVVAuth = true
        vc.order = order
        vc.cvv = cvv
        vc.cardID = cardID
        vc.authAmount = authAmount > 0 ? authAmount : 1
        vc.finalOrderItems  = self.shoppingItems
        vc.finalProducts = self.products
        vc.availableProductsPrices = self.availableProductsPrices
        vc.deliveryAddress = self.currentAddress
        vc.discountedPrice = self.discountedPrice
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func showConfirmationView() {
        
        defer {
            
            UserDefaults.setLeaveUsNote(nil)
            self.currentDeliverySlot = nil
            self.order = nil
        }
        
        UserDefaults.resetEditOrder()
        self.resetLocalDBData()
        let orderConfirmationController = ElGrocerViewControllers.orderConfirmationViewController()
        orderConfirmationController.order = self.order
        orderConfirmationController.grocery = self.order.grocery
        orderConfirmationController.finalOrderItems = self.shoppingItems
        orderConfirmationController.finalProducts = self.products
        orderConfirmationController.availableProductsPrices = self.availableProductsPrices
        orderConfirmationController.deliveryAddress = self.order.deliveryAddress
        orderConfirmationController.priceSum = self.discountedPrice
        self.navigationController?.pushViewController(orderConfirmationController, animated: true)
        
    }
    
    private func resetLocalDBData() {
        ElGrocerUtility.sharedInstance.resetBasketPresistence()
        self.deleteBasketFromServerWithGrocery(self.order.grocery)
    }
    
    
}

extension MyBasketViewController : MyBasketCandCDataHandlerDelegate {
    
    
    func collectorDataLoaded() {
        self.tblBasket.reloadDataOnMain()
        
    }
    
    func carDataLoaded() {
        
        self.tblBasket.reloadDataOnMain()
        
    }
    
    func pickUpLocationLoaded() {
        
        self.tblBasket.reloadDataOnMain()
        let cellindex = 1
        self.tblBasket.beginUpdates()
        self.tblBasket.setNeedsDisplay()
        let indexPath = IndexPath(row: cellindex, section: 0)
        let isVisible = self.tblBasket.indexPathsForVisibleRows?.contains{$0 == indexPath}
        if let v = isVisible, v == true {
            self.tblBasket.reloadRows(at: [(NSIndexPath.init(row: cellindex, section: 0) as IndexPath)], with: .none)
        }
        self.tblBasket.endUpdates()
        let _ = getFinalAmount()
    }
    
}

extension MyBasketViewController: NavigationBarProtocol {
    
    func backButtonClickedHandler() {
        self.backButtonClick()
        
    }
    
}
extension MyBasketViewController: GroceryChangeProtocol {
    func groceryDataUpdated(grocery: Grocery) {
        self.grocery = grocery
        self.groceryFetchRetry = 0
    }
    func groceryDataUpdationFaliure(error: ElGrocerError) {
        if groceryFetchRetry < 3 {
            if error.code == 10000 {
                self.updateGroceryData()
            }else {
                self.updateGroceryData()
                self.groceryFetchRetry = groceryFetchRetry + 1
            }
        }else {
            SpinnerView.hideSpinnerView()
        }
    }
}
