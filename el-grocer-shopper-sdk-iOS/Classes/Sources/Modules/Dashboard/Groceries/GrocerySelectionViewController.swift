//
//  GrocerySelectionViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 28.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

protocol GrocerySelectionProtocol : class {
    
    func grocerySelectionController(_ controller:GrocerySelectionViewController, didSelectGrocery grocery:Grocery, notAvailableItems:[Int], availableProductsPrices:NSDictionary?) -> Void
    func updateDataWithNewGrocery(grocery:Grocery) ->Void
}

class GrocerySelectionViewController : UIViewController, GrocerySelectionCellProtocol,GroceriesEmptyViewDelegate , UITableViewDelegate , UITableViewDataSource , NavigationBarProtocol {
    //ebebeb
    // MARK: Outlets
    
    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    
    weak var delegate:GrocerySelectionProtocol?
    
    var isRecipeItems : Bool = false
    var groceries:[Grocery] = [Grocery]()
    var notAvailableProducts:[[Int]] = [[Int]]()
    var availableProductsPrices:NSDictionary = NSDictionary()
    var productsToCheck:[Product]!
    
    var shoppingItems:[ShoppingBasketItem]!
    var availableItemsCount:[[Int]] = [[Int]]()
    var totalItemsCount:Int = 0
    
    var selectedIndex : IndexPath?
    
    fileprivate let groceriesEmptyView = GroceriesEmptyView.initFromNib()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localizedString("grocery_selection_screen_title", comment: "")
        self.addBackButton()
        self.configureGroceriesEmptyView()
        self.fetchData()
        self.setUpApearnce()
    
    }
    
    func registerNewTableCell() {
        
        let cellNib = UINib(nibName: "GroceryCell", bundle: Bundle.resource)
        self.tableView.register(cellNib, forCellReuseIdentifier: kGroceryCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsGrocerySelectionScreen)
        FireBaseEventsLogger.setScreenName( kGoogleAnalyticsGrocerySelectionScreen , screenClass: String(describing: self.classForCoder))
    }
    
    func setUpApearnce() {
        if self.isRecipeItems {
            self.title = localizedString("grocery_selection_From_Recipe_screen_title", comment: "")
            self.registerNewTableCell()
            //No stores in your area have the sufficient ingredients for the recipes
            groceriesEmptyView.agentChatBtn.isHidden = self.isRecipeItems
            groceriesEmptyView.changeLocationBtn.isHidden = self.isRecipeItems
            groceriesEmptyView.topImageView.isHidden = self.isRecipeItems
            groceriesEmptyView.titleLabel.text = localizedString("No_Store_For_Recipe_title", comment: "")
            groceriesEmptyView.subtitleLabel.isHidden = self.isRecipeItems
            groceriesEmptyView.bgView.isHidden = self.isRecipeItems
            
        }else{
             self.registerTableCell()
        }
    }
    
    // MARK: Actions
    
    func backButtonClickedHandler() {
        backButtonClick()
    }
    
    override func backButtonClick() {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shopOfflineButtonTouched(_ sender: UIButton) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Helpers
    fileprivate func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    func fetchLatestGroceries() {
        
        guard let currentAddress = getCurrentDeliveryAddress() else {
             self.groceriesEmptyView.isHidden = false
            self.tableView.reloadData()
            return
        }
        
        self.groceriesEmptyView.isHidden = true
        _ = SpinnerView.showSpinnerViewInView(self.tableViewContainer)
        
        ElGrocerApi.sharedInstance.getAllGroceries(currentAddress, completionHandler: { (result) in
            
            switch result {
                
            case .success(let response):
            
                let responseData = Grocery.insertGroceriesWithNotAvailableProducts(response, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                self.groceries = responseData.groceries
                self.notAvailableProducts = responseData.notAvailableProducts
                self.availableProductsPrices = responseData.availableProductsPrices
                self.calculateAvailableItemsNumber()
                self.tableView.reloadData()
                self.groceriesEmptyView.isHidden = self.groceries.count != 0
                
            case .failure(let error):
                error.showErrorAlert()
            }
            SpinnerView.hideSpinnerView()
            self.refreshData()
        })
        
    }
    
    fileprivate func fetchData() {
        
        guard !isRecipeItems else {
            self.fetchLatestGroceries()
            return
        }
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
    ElGrocerApi.sharedInstance.checkAvailableGroceriesForProducts(self.productsToCheck, andForLocation: DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)!) { (result) -> Void in
            
            SpinnerView.hideSpinnerView()
            
            switch result {
                
            case .success(let response):
                
                print("Response:%@",response)
                
                let responseData = Grocery.insertGroceriesWithNotAvailableProducts(response, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                self.groceries = responseData.groceries
                self.notAvailableProducts = responseData.notAvailableProducts
                self.availableProductsPrices = responseData.availableProductsPrices
                self.calculateAvailableItemsNumber()
                // if there are no groceries available we should notify the user about it
                self.groceriesEmptyView.isHidden = self.groceries.count != 0
                
            case .failure(let error):
                error.showErrorAlert()
                
            }
            
            self.refreshData()

        }
    }
    
    func refreshData() {
        
        self.tableView.reloadData()
    }
    
    fileprivate func configureGroceriesEmptyView() {
        
        self.groceriesEmptyView.isHidden = true
        self.groceriesEmptyView.mode = .noPartnerGrocery
        self.tableViewContainer.addSubviewFullscreen(groceriesEmptyView)
        
    }
    
    // MARK: UITableView
    
    func registerTableCell() {
        
        let cellNib = UINib(nibName: "GrocerySelectionCell", bundle: Bundle.resource)
        self.tableView.register(cellNib, forCellReuseIdentifier: kGrocerySelectionCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if self.isRecipeItems {
//            if let indexAvailable = self.selectedIndex {
//                if indexAvailable == indexPath {
//                     return kGroceryCellHeightWithInfo
//                }
//            }
//             return kGroceryCellHeight
//        }
        
       // kGroceryCellHeight
        
        return kGroceryCellHeightWithInfo
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.groceries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if self.isRecipeItems {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: kGroceryCellIdentifier, for: indexPath) as! GroceryCell
            let grocery = self.groceries[indexPath.row]
            
//            let isRequiredToShowDetails = self.arrayDetailShowingIndexes.contains(NSNumber.init(value: (indexPath as NSIndexPath).row as Int))
            cell.configureWithGrocery(grocery, isDetailsShown: false)
            cell.delegate = self
            return cell
            
        }
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kGrocerySelectionCellIdentifier, for: indexPath) as! GrocerySelectionCell
        let grocery = self.groceries[(indexPath as NSIndexPath).row]
        let notAvailableProducts = self.notAvailableProducts[(indexPath as NSIndexPath).row]
        
        let notAvailableCount = calculateNotAvailableItemsCount(notAvailableProducts)
        cell.configureWithGrocery(grocery, availableProducts:self.totalItemsCount - notAvailableCount, totalProducts:self.totalItemsCount)
        cell.delegate = self
        cell.groceryItemsCount.isHidden = self.isRecipeItems
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let grocery = self.groceries[(indexPath as NSIndexPath).row]
        let notAvailableProducts = self.notAvailableProducts[(indexPath as NSIndexPath).row]
        let prices = self.availableProductsPrices[grocery.dbID] as? NSDictionary
        
       
        
        
        if self.isRecipeItems{
            
            
            var isBasketForCurrentGroceryActive = false
            if ElGrocerUtility.sharedInstance.activeGrocery != nil {
                isBasketForCurrentGroceryActive = ShoppingBasketItem.checkIfBasketForCurrentGroceryIsActive(ElGrocerUtility.sharedInstance.activeGrocery!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            }
            if isBasketForCurrentGroceryActive {
                
                
                ShoppingBasketItem.clearCurrentActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
                ElGrocerUtility.sharedInstance.resetBasketPresistence()
                self.selectNewGrocery(grocery, notAvailableProducts: notAvailableProducts, prices: prices)
                
                
//                ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description:localizedString("basket_active_from_other_grocery_message", comment: ""),positiveButton: localizedString("clear_button_title", comment: ""),negativeButton: localizedString("products_adding_different_grocery_alert_cancel_button", comment: ""),buttonClickCallback: { (buttonIndex:Int) -> Void in
//
//                    if buttonIndex == 0 {
//                        //clear active basket and add product
//                    ShoppingBasketItem.clearCurrentActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
//                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
//                        ElGrocerUtility.sharedInstance.resetBasketPresistence()
//                        self.selectNewGrocery(grocery, notAvailableProducts: notAvailableProducts, prices: prices)
//                    }else{
//                        self.navigationController?.popViewController(animated: true)
//                    }
//
//                }).show()
                
                
            }else{

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
                ElGrocerUtility.sharedInstance.resetBasketPresistence()
                
                self.selectNewGrocery(grocery, notAvailableProducts: notAvailableProducts, prices: prices)
                
            }
            
            
        }else{
            self.delegate?.grocerySelectionController(self, didSelectGrocery: grocery, notAvailableItems: notAvailableProducts, availableProductsPrices: prices)
        }
        
    }
    

    
    fileprivate func selectNewGrocery(_ selectedGrocery : Grocery ,notAvailableProducts : [Int], prices : NSDictionary?) {
        
        
        if (selectedGrocery.isOpen.boolValue && Int(selectedGrocery.deliveryTypeId!) != 1) || (selectedGrocery.isSchedule.boolValue && Int(selectedGrocery.deliveryTypeId!) != 0){
            
            
            let loadedGroceryId = ElGrocerUtility.sharedInstance.activeGrocery?.dbID
            if (loadedGroceryId != selectedGrocery.dbID){
                let SDKManager = UIApplication.shared.delegate as! SDKManager
                if SDKManager.window!.rootViewController as? UITabBarController != nil {
                    if let tababarController = SDKManager.window!.rootViewController as? UITabBarController {
                        if  let main : ElGrocerNavigationController =  tababarController.viewControllers?[1] as? ElGrocerNavigationController {
                            if let  controller = main.viewControllers[0] as? MainCategoriesViewController {
                                let result =     ElGrocerUtility.sharedInstance.completeGroceries.filter({ $0.dbID == selectedGrocery.dbID })
                                if result.count > 0 {
                                    if let  index = ElGrocerUtility.sharedInstance.completeGroceries.firstIndex(of: result[0]) {
                                        //controller.grocerySelectedIndex = index
                                    }
                                }
                                controller.refreshViewWithGrocery(selectedGrocery)
                                ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("change_store")
                            }
                        }
                    }
                }
                /*else if SDKManager.window!.rootViewController as? ElgrocerGenericUIParentNavViewController != nil {
                 debugPrint((SDKManager.window!.rootViewController as? ElgrocerGenericUIParentNavViewController)?.viewControllers)
                 }*/
            }
            let _ = SpinnerView.showSpinnerViewInView(self.view)
            self.delegate?.updateDataWithNewGrocery(grocery: selectedGrocery)
           
            
            DispatchQueue.main.async {
                self.delegate?.grocerySelectionController(self, didSelectGrocery: selectedGrocery, notAvailableItems: notAvailableProducts, availableProductsPrices: prices)
            }
        
            return
            
          
           
        }else{
            
            print("Currently Grocery is closed")
            ElGrocerAlertView.createAlert(localizedString("store_close_alert_title", comment: ""),
                                          description:localizedString("store_close_alert_message", comment: ""),
                                          positiveButton: localizedString("store_close_alert_button", comment: ""),
                                          negativeButton: nil, buttonClickCallback: nil).show()
        }
        
        
    }

    // MARK: Items count
    
    fileprivate func calculateAvailableItemsNumber() {
        
        self.shoppingItems = ShoppingBasketItem.getBasketItemsForOrder(nil, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)

        for product in self.productsToCheck {
            //get basket item for product
            if let item = shoppingItemForProduct(product, items: self.shoppingItems) {
                self.totalItemsCount += item.count.intValue
            }
        }
        
        if self.isRecipeItems {
            self.totalItemsCount = self.productsToCheck.count
        }
    }
    
    fileprivate func calculateNotAvailableItemsCount(_ notAvailableProducts:[Int]) -> Int {
        
        var result = 0
        
        for productId in notAvailableProducts {
            
            if  let item = shoppingItemByProductId("\(productId)", items: self.shoppingItems) {
                result += item.count.intValue
            }
           
        }
        if self.isRecipeItems {
            result = notAvailableProducts.count
        }
        
       
        return result
    }
    
    fileprivate func shoppingItemForProduct(_ product:Product, items:[ShoppingBasketItem]) -> ShoppingBasketItem? {
        
        for item in items {
            
            if product.dbID == item.productId {
                
                return item
            }
        }
        
        return nil
    }
    
    fileprivate func shoppingItemByProductId(_ productId:String, items:[ShoppingBasketItem]) -> ShoppingBasketItem? {
        
        for item in items {
            
            var splittedId = "0"
            //we can have product with groceryId as first part
            let productSplittedIds = (item.productId.split {$0 == "_"}.map { String($0) })
            splittedId = productSplittedIds.count == 1 ? productSplittedIds[0] : productSplittedIds[1]
            
            if productId == splittedId {
                
                return item
            }
        }
        
        return nil
    }
    
    // MARK: GrocerySelectionCellProtocol
    
    func grocerySelectionCellDidTouchScore(_ cell: GrocerySelectionCell) {
        
        let indexPath = self.tableView.indexPath(for: cell)
        let grocery = self.groceries[(indexPath! as NSIndexPath).row]
        
        //show reviews
        let reviewsController = ElGrocerViewControllers.groceryReviewsViewController()
        reviewsController.grocery = grocery
        reviewsController.shouldShowMenuButton = false
        
        self.navigationController?.pushViewController(reviewsController, animated: true)
    }
    
    // MARK: GroceriesEmptyViewDelegate
    
    func presentChangeLocationView(){
        
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [ElGrocerViewControllers.dashboardLocationViewController()]
        navigationController.setLogoHidden(true)
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    
    func presentChatViewController(){
        
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_help_from_meun")
        //ZohoChat.showChat()
        let sendBirdManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
        sendBirdManager.setUpSenBirdDeskWithCurrentUser()
       
        
    }

}
extension GrocerySelectionViewController : GroceryCellProtocol {
    
    func groceryCellDidTouchFavourite(_ groceryCell: GroceryCell, grocery: Grocery) {}
    func groceryCellDidTouchScore(_ groceryCell: GroceryCell, grocery: Grocery) {}
    
    func didTapInfoButtonForCell(_ cell: GroceryCell, isDetailShowing: Bool) {
        let indexPath = self.tableView.indexPath(for: cell)
        if cell.frame.size.height > kGroceryCellHeight {
          self.selectedIndex = nil
        }else{
            self.selectedIndex = indexPath
        }       
        if let availableIndex = self.selectedIndex {
            self.tableView.reloadRows(at: [availableIndex], with: .none)
        }else{
            self.tableView.reloadData()
        }
    }
}
