//
//  ShoppingListViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 15/02/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

//


import UIKit
import STPopup

let kShoppingListCellIdentifier = "ShoppingListCellTableViewCell"
let kShoppingListCellHeight: CGFloat = kProductCellHeight + 34

class ShoppingListViewController: BasketBasicViewController , UIGestureRecognizerDelegate  {

    
    @IBOutlet var topBGGreenView: UIView!{
        didSet{
            topBGGreenView.backgroundColor = .navigationBarColor()
        }
    }
    @IBOutlet weak var shoppingListTableView: UITableView!{
        didSet{
            shoppingListTableView.bounces = false
            shoppingListTableView.roundWithShadow(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 24, withShadow: false)
            shoppingListTableView.backgroundColor = .textfieldBackgroundColor()
            shoppingListTableView.clipsToBounds = true
        }
    }
    private (set) var DoneViewFooter : DoneButtonFooterView?=nil

    let privateWorkQueue : DispatchQueue = DispatchQueue(label: "ShoppingListViewController" )
    
    private var categoryA = [AnyObject]()
    private var productsA = [[AnyObject]?]() // we will send product object here
    private var selectedIndex : Int?
    private var selectedProduct:Product!
            var searchList : String?
    private var index : Int  = 0
            var location:DeliveryAddress? = nil
     var isChooseAlternative:Bool = false
     var chooseAlternativeProducts : [Product]?
     var bannerIndexArray : [Int] = [Int]()
     var bannerArray : [NSDictionary] = [NSDictionary]()
    var isFromHeader: Bool = false

    var tableViewBottomConstraint: NSLayoutConstraint?
    
    lazy var dataHandler : ShoopingListDataHandler = {
        let dataH = ShoopingListDataHandler()
        dataH.delegate = self
        dataH.grocery = self.grocery
        return dataH
    }()
    
    lazy var locationHeader : ElgrocerlocationView = {
        let locationHeader = ElgrocerlocationView.loadFromNib()
        return locationHeader!
    }()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCells()
        self.setTitle()
        
        var array = searchList!.components(separatedBy: CharacterSet.newlines)
        array = array.filter({ $0 != ""})
        array = array.map { $0.trimmingCharacters(in: .whitespaces) }
        categoryA = array as [AnyObject]
        if self.isChooseAlternative {
           // GoogleAnalyticsHelper.trackShopList(array)
        }else{
            GoogleAnalyticsHelper.trackShopList(array)
            if let grocery = self.grocery {
            // PushWooshTracking.addShoppingListSearchEvent(array.joined(separator: ","), storeId: grocery.dbID)
            }
        }
        dataHandler.banneraSearchStringArray = array
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
       
        navigationApearance()
        self.basketIconOverlay?.shouldShow = true
        guard self.productsA.count == 0 else {
            if let grocery = self.grocery {
                self.basketIconOverlay?.grocery = grocery
                self.refreshBasketIconStatus()
                self.setTableViewBottomConstraint()
            }
            if UIApplication.topViewController()?.children.contains(where: { (vc) -> Bool in
                return vc is PopImageViwerViewController
            }) ?? false {
                return
            }
            self.shoppingListTableView.reloadDataOnMain()
            return
        }
        self.reloadTableViewData()
        self.getData()
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if self.isChooseAlternative {
            ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_Alternatives_screen")
            GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsChooseAlternativeScreen)
            FireBaseEventsLogger.setScreenName(kGoogleAnalyticsChooseAlternativeScreen, screenClass: String(describing: self.classForCoder))
        }else{
            ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_ShoppingList_screen")
            GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsShoppingListScreen)
            FireBaseEventsLogger.setScreenName(FireBaseScreenName.MultiSearch.rawValue, screenClass: String(describing: self.classForCoder))
        }
        
//        self.setTableViewHeader(self.grocery)
        self.reloadTableViewData()
        
        
        //self.addImages()
        
    }
    
    override func refreshSlotChange() {
        
        self.productsA = [[AnyObject]?]()
        if let grocery = self.grocery {
                self.basketIconOverlay?.grocery = grocery
                self.refreshBasketIconStatus()
                self.setTableViewBottomConstraint()
        }
        index = 0
        self.reloadTableViewData()
        self.getData()
        
    }
    
    
    func navigationApearance() {
        
        if self.navigationController is ElGrocerNavigationController {
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLocationHidden(true)
            self.addBackButton(isGreen: false)
            if isFromHeader{
                self.addRightCrossButton(true)
            }
            
        }
        
    }
    
    override func rightBackButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addImages(){
        
        if let window = SDKManager.shared.window {
            let image =  UIImage.init(named: "Store page-Main")
            let windowFrame = CGRect.init(x: 0, y: 0, width: image?.size.width ?? 375, height: image?.size.height ?? 2275)
            let imageView = UIImageView(frame: windowFrame)
            imageView.image = UIImage.init(named: "Store page-Main")
            imageView.alpha = 0.4
            window.addSubview(imageView)
        }
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UserDefaults.removeBannerView(topControllerName: FireBaseScreenName.MultiSearch.rawValue)
    }
    

    ///To adjust the bottom constraint for basketIconOverlay appear/disappear
    func setTableViewBottomConstraint() {
        if (tableViewBottomConstraint == nil) && (self.basketIconOverlay != nil) {
            tableViewBottomConstraint = NSLayoutConstraint(item:
                                        self.basketIconOverlay!,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: self.shoppingListTableView,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 0.0)
        }
        tableViewBottomConstraint?.isActive = !(self.basketIconOverlay?.isHidden ?? true)
    }
    
    func setTableViewHeader(_ optGrocery : Grocery?) {
        
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
           // self.locationHeader.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 130)
            self.shoppingListTableView.tableHeaderView = self.locationHeader
            if optGrocery != nil {
                self.locationHeader.configuredLocationAndGrocey(optGrocery!)
            }else{
                self.locationHeader.configured()
            }
            self.locationHeader.setNeedsLayout()
            self.locationHeader.layoutIfNeeded()
            self.shoppingListTableView.tableHeaderView = self.locationHeader
            
        })
    }
    
    
    override func backButtonClickedHandler() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Product search
    
    func getData() {

        if (self.grocery != nil || self.shouldShowGroceryActiveBasket != nil) {
            location = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        self.callRequestSequentallyWith(replaceIndex: nil , DataA: categoryA , location: location) { (isSuccess, data) in
            self.reloadTableViewData()
        }
         self.refreshBasketIconStatus()
         self.setTableViewBottomConstraint()
    }


    func callRequestSequentallyWith (replaceIndex : Int? ,  DataA : [AnyObject] , location : DeliveryAddress?   , completion:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void ) {
        
        guard let grocery = self.grocery else {
            return
        }
        var currentSearchString : String?
        if replaceIndex != nil {
            guard replaceIndex! < DataA.count  else {
                completion (false , nil)
                return
            }
            currentSearchString  = (DataA[replaceIndex!] as! String)
        }else{
            guard index < DataA.count else {
                completion (true , nil)
                return
            }
            currentSearchString =  (DataA[index] as! String)
        }
        
        privateWorkQueue.async { [weak self] in
            guard let self = self else { return }
            if self.isChooseAlternative  {
                
                guard  self.chooseAlternativeProducts != nil else { return }

                let currentProduct : Product = self.chooseAlternativeProducts![self.index]
                ElGrocerApi.sharedInstance.getReplacementProductsForListSearch(currentSearchString! , product: currentProduct.dbID  , grocery:  self.grocery , completionHandler: {[weak self] (result:Bool, responseObject:NSDictionary?) -> Void in
                    
                    guard let self = self else { return }
                    Thread.OnMainThread {
                        if result {
                            var newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                            for product in newProducts {
                                if product.brandId == nil {
                                    let removedObjectIndex = newProducts.firstIndex(of: product)!
                                   elDebugPrint("Object Remove Index:%@",removedObjectIndex)
                                    newProducts.remove(at: removedObjectIndex)
                                }
                            }
                           elDebugPrint("searched Products Array After Filtering Brand ID:%@",newProducts.count)
                            if replaceIndex != nil {
                                self.productsA[replaceIndex!] = newProducts
                                Thread.OnMainThread {
                                    self.shoppingListTableView.reloadRows(at: [IndexPath.init(row: replaceIndex!, section: 0)], with: .fade)
                                }
                                
                            }else{
                                self.productsA.append(newProducts)
                                Thread.OnMainThread {
                                    self.shoppingListTableView.reloadRows(at: [NSIndexPath.init(row: self.index , section: 0) as IndexPath], with: .fade)
                                }
                                self.index += 1
                            }
                        }
                        
                        self.callRequestSequentallyWith( replaceIndex: replaceIndex == nil ? replaceIndex : DataA.count + 1 , DataA: DataA, location: location, completion: completion )
                    }
                })
                
            }else{

                AlgoliaApi.sharedInstance.searchQueryWithCurrentStoreItems(currentSearchString! , storeID: grocery.dbID, pageNumber: 0, seachSuggestion: nil, searchType: "shopping_list", completion: { [weak self](content, error) in
                    guard let self = self else { return }
                    Thread.OnMainThread {
                    if content != nil {
                        if let responseObject = content as NSDictionary? {
                                var newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , searchString: currentSearchString)
                                for product in newProducts {
                                    if product.brandId == nil {
                                        let removedObjectIndex = newProducts.firstIndex(of: product)!
                                        //                                   elDebugPrint("Object Remove Index:%@",removedObjectIndex)
                                        newProducts.remove(at: removedObjectIndex)
                                    }
                                }
                                //print("searched Products Array After Filtering Brand ID:%@",newProducts.count)
                                if replaceIndex != nil {
                                    self.productsA[replaceIndex!] = newProducts
                                    self.shoppingListTableView.reloadRows(at: [IndexPath.init(row: replaceIndex!, section: 0)], with: .fade)
                                }else{
                                    self.productsA.append(newProducts)
                                    self.shoppingListTableView.reloadRows(at: [NSIndexPath.init(row: self.index , section: 0) as IndexPath], with: .fade)
                                    self.index += 1
                                    
                                }
                            }
                        }
                        self.callRequestSequentallyWith( replaceIndex: replaceIndex == nil ? replaceIndex : DataA.count + 1 , DataA: DataA, location: location, completion: completion )
                    }
                })
            }
        }
        
    }

    func setTitle() {

        if self.isChooseAlternative {
             self.title = localizedString("alternatives_New_title", comment: "")
        }else{
             self.title = localizedString("Add_Shopping_list_Title", comment: "")
        }
        self.navigationController?.navigationBar.tintColor = .white
        
     //   self.addBackButton()
        if self.isChooseAlternative {
        DoneViewFooter = (Bundle.resource.loadNibNamed("DoneButtonFooterView", owner: self, options: nil)![0] as? DoneButtonFooterView)!
            self.addClouser()
        }else{  }
       
        self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
//        self.setTableViewHeader(self.grocery )
        self.basketIconOverlay?.grocery = self.grocery
        
        
       
        

    }
    
    func addClouser() {
        
        self.DoneViewFooter?.doneButton = {[weak self] () in
            guard let self = self else {return}
            self.backButtonClick()
//            NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateNotificationKey), object: nil)
//            self.navigationController?.popViewController(animated: true)
        }
    }

    override func backButtonClick() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateNotificationKey), object: nil)
        self.navigationController?.popViewController(animated: true)
    }

    func registerCells() {
        let shoppingListCell = UINib(nibName: kShoppingListCellIdentifier, bundle: Bundle.resource)
        self.shoppingListTableView.register(shoppingListCell, forCellReuseIdentifier: kShoppingListCellIdentifier )
        self.shoppingListTableView.backgroundColor = UIColor.textfieldBackgroundColor()
        
        let spaceTableViewCell = UINib(nibName: "ProgressCompleteionTableViewCell", bundle: Bundle.resource)
        self.shoppingListTableView.register(spaceTableViewCell, forCellReuseIdentifier: "ProgressCompleteionTableViewCell")
    }

    func reloadTableViewData() ->Void {
        self.shoppingListTableView.reloadData()
    }
    
    override func reloadCellIndexForBanner(_ currentIndex: Int , cell : ShoppingListCellTableViewCell) {
        

        self.bannerIndexArray.append(currentIndex)
        let unique = Array(Set(self.bannerIndexArray))
        self.bannerIndexArray = unique
        self.shoppingListTableView.reloadDataOnMain()

    }
    
    override func addBannerFor(_ currentIndex: Int, searchResultString: String, homeFeed: Any?) {
        
        self.bannerIndexArray.append(currentIndex)
        let unique = Array(Set(self.bannerIndexArray))
        self.bannerIndexArray = unique
        
        let namePredicate = NSPredicate(format: "value contains[c] %@",searchResultString);
        let filteredArray = self.bannerArray.filter { namePredicate.evaluate(with: $0) }
        guard filteredArray.count == 0 else {
            return
        }
        let dict : NSDictionary = [currentIndex : homeFeed as Any , "value" : searchResultString]
        self.bannerArray.append(dict)
        
        
        
        self.shoppingListTableView.reloadDataOnMain()

        
    }
    override func addProductToBasketFromQuickAdd(_ product: Product) {
        
      //  ElGrocerEventsLogger.sharedInstance.addToCart(product: product)

//        ElGrocerUtility.sharedInstance.createBranchLinkForProduct(product)
//       ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("add_item_to_cart")
//        ElGrocerUtility.sharedInstance.logAddToCartEventWithProduct(product)
//        GoogleAnalyticsHelper.trackMultiSearchAddToCart(product.name)

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
        let elementToFind = self.selectedProduct.dbID


        //let columnIndex:Int?
        for (columIndex, data) in self.productsA.enumerated() {
           let finalA = (data?.filter{$0.dbID == elementToFind})
            let rowIndex =  data?.firstIndex(where: { (porduct) -> Bool in
                return porduct.dbID == elementToFind
            })
            if let data = finalA,let row = rowIndex {
                guard (data.count) > 0 else {
                    self.shoppingListTableView.reloadDataOnMain()
                    self.basketIconOverlay?.grocery = self.grocery
                    self.refreshBasketIconStatus()
                    self.setTableViewBottomConstraint()
                    return
                }
                if columIndex < self.categoryA.count {
                if ((shoppingListTableView.indexPathsForVisibleRows?.contains(IndexPath.init(row: columIndex , section: 0)))!) {
                    if let cell  = shoppingListTableView.cellForRow(at: IndexPath.init(row: columIndex , section: 0))  as? ShoppingListCellTableViewCell {
                        if row < cell.customCollectionView.collectionA.count {
                            if (cell.customCollectionView.collectionView!.indexPathsForVisibleItems.contains(IndexPath(row: row, section: 0))) {
                                Thread.OnMainThread {
                                    cell.customCollectionView.collectionView!.reloadItems(at: [IndexPath(row: row, section: 0)])
                                }
                                if self.isChooseAlternative {
                                    if let productItem = self.chooseAlternativeProducts?[columIndex] {
                                        self.removeProductFromCart(productItem , cartGrocery: self.grocery!)
                                    }
                                }
                            }
                        }
                    }
                    }
                }
            }
        }
        self.basketIconOverlay?.grocery = self.grocery
        self.refreshBasketIconStatus()
        self.setTableViewBottomConstraint()
    }
    
    func removeProductFromCart(_ currentAlternativeProduct : Product , cartGrocery : Grocery ) {
        //removing out of stock prodcut from basket
        ShoppingBasketItem.removeProductFromBasket(currentAlternativeProduct, grocery: cartGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }

    


    // MARK:-  Keyboard methods

   @objc override func keyboardWillShow(_ notification: Notification) {
    if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
        shoppingListTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }

   @objc override func keyboardWillHide(_ notification: Notification)  {
    UIView.animate(withDuration: 0.2, animations: {
        self.shoppingListTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    })
}

}


extension ShoppingListViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var value = 0.0
        if isChooseAlternative {
            value = 80.0
        }
        return CGFloat(value)
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var viewToShow = UIView()
        if isChooseAlternative {
            if let viewAvailable = DoneViewFooter {
             viewToShow =  viewAvailable
            }
        }
        return viewToShow
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /*
        if indexPath.row == 0 {
            return 68
        }
        */
        
        //let row = indexPath.row - 1
        let row = indexPath.row
        

        if row < self.productsA.count  {
            let currentProdcut = self.productsA[row]
            if currentProdcut?.count == 0 {
                return 100
            }
        }

        let bannerForString = categoryA[row]
        let namePredicate = NSPredicate(format: "value contains[c] %@", bannerForString as! CVarArg);
        let filteredArray = self.dataHandler.bannerArray.filter { namePredicate.evaluate(with: $0) }
        if filteredArray.count > 0 {
            let result = filteredArray[0]
            if  result.object(forKey: bannerForString) is Home {
                return kShoppingListCellHeight + ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner()
            }
        }
        return kShoppingListCellHeight + 30

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryA.count
        //return categoryA.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        if indexPath.row == 0 {
            let cell : ProgressCompleteionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ProgressCompleteionTableViewCell", for: indexPath) as! ProgressCompleteionTableViewCell
            return cell
        }*/
        
        let listCell = tableView.dequeueReusableCell(withIdentifier: kShoppingListCellIdentifier ) as! ShoppingListCellTableViewCell

        //let rowNumber = indexPath.row - 1
        let rowNumber = indexPath.row
        listCell.currentIndex = rowNumber
        listCell.delegate = self
        listCell.grocery = self.grocery
        let cellTitle = categoryA[rowNumber]
        listCell.searchItemLable.text = "\(localizedString("shopping_Search_Item_Header_Title", comment: "")) \(cellTitle)"
        
        let namePredicate = NSPredicate(format: "value contains[c] %@",cellTitle as! CVarArg);
        let filteredArray = self.dataHandler.bannerArray.filter { namePredicate.evaluate(with: $0) }
        if filteredArray.count > 0 {
            let results = filteredArray[0]
            let resultObj = results.object(forKey: cellTitle )
            if  resultObj is Home {
                listCell.homeFeed = resultObj as? Home
            }else{
                listCell.homeFeed = nil
            }

        } else {
            listCell.homeFeed = nil
        }
        
        listCell.currentSearchString = (cellTitle as! String)
    
        if rowNumber < self.productsA.count  {
            configureCell(indexPath, listCell: listCell)
        }
        listCell.editbutton.isHidden = self.isChooseAlternative
        
        
        
        return listCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerCell : ProgressCompleteionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ProgressCompleteionTableViewCell") as! ProgressCompleteionTableViewCell
        return headerCell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70//68
    }
    func configureCell (_ indexPath: IndexPath  , listCell : ShoppingListCellTableViewCell) {

        //let rowNumber = indexPath.row - 1
        let rowNumber = indexPath.row
        let currentProdcut = self.productsA[rowNumber]
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            listCell.customCollectionView.collectionView?.transform = CGAffineTransform(scaleX: -1, y: 1)
            listCell.customCollectionView.collectionView?.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            
          //  listCell.customCollectionView.collectionView?.scrollToItem(at: NSIndexPath(item: currentProdcut?.count ?? 1 - 1, section: 0) as IndexPath, at: .left, animated: true)
        }else{
            listCell.customCollectionView.collectionView?.setContentOffset(CGPoint.zero, animated:true)
        }
        
        
        listCell.customCollectionView.configuredCell(productA: currentProdcut!)
        if currentProdcut!.count == 0 {
            listCell.NoItemFoundLable.isHidden = false
            listCell.customCollectionView.bringSubviewToFront(listCell.ViewNoProduct)
        }else{
            listCell.NoItemFoundLable.isHidden = true
        }
        listCell.ViewNoProduct.isHidden  =  listCell.NoItemFoundLable.isHidden
        listCell.viewMoreButton.isHidden = !listCell.NoItemFoundLable.isHidden
        listCell.changeSearchResult = {[weak self] (newText , clouserIndex) in
            guard let self = self else { return }
            guard (newText?.count)! > 0 else { return }
            GoogleAnalyticsHelper.trackEditedItem(newProduct: newText! , editedName:  self.categoryA[clouserIndex!] as! String)
            self.categoryA[clouserIndex!] = newText as AnyObject
            self.categoryA = self.categoryA.filter({ $0 as! String != ""})
            self.categoryA = self.categoryA.map { $0.trimmingCharacters(in: .whitespaces) } as [AnyObject]
            self.productsA[clouserIndex!] = [""] as [AnyObject];
            Thread.OnMainThread {
                self.shoppingListTableView.reloadRows(at:  [IndexPath(row: clouserIndex! + 1, section: 0)], with: .fade)
            }
            
            self.callRequestSequentallyWith(replaceIndex: clouserIndex , DataA: self.categoryA , location: self.location) { [weak self] (isSuccess, data) in
                guard let self = self else { return }
                Thread.OnMainThread {
                    self.shoppingListTableView.reloadRows(at:  [IndexPath(row: clouserIndex! + 1 , section: 0)], with: .fade)
                }
              //  self.reloadTableViewData()

            }
        }
        listCell.goToSearchVCWith = {[weak self] (searchString , clouserIndex) in
            
            guard let self = self else { return }
            guard searchString != nil && !(searchString?.isEmpty)! else {
                return
            }
            if self.isChooseAlternative {
                if let indexAvailable = clouserIndex {
                    let productToReplace : Product = self.chooseAlternativeProducts![indexAvailable]
                    let replacementVC = ElGrocerViewControllers.replacementViewController()
                    replacementVC.isFromBasket = true
                    replacementVC.currentAlternativeProduct = productToReplace
                    replacementVC.cartGrocery = self.grocery
                    replacementVC.notAvailableProducts = []
                    Thread.OnMainThread {
                        self.navigationController?.pushViewController(replacementVC, animated: true)
                    }
                }
            }else{
                let searchController = ElGrocerViewControllers.searchViewController()
                searchController.isNavigateToSearch = true
                searchController.searchString = searchString!
                searchController.showHeading = true
                searchController.isNeedToHideSearchBar = true
                searchController.isFromShoppingListViewAll = true
                searchController.navigationFromControllerName = FireBaseEventsLogger.gettopViewControllerName() ?? FireBaseScreenName.MultiSearch.rawValue
                searchController.modalTransitionStyle = .crossDissolve
                searchController.modalPresentationStyle = .overCurrentContext
                Thread.OnMainThread {
                    self.navigationController?.pushViewController(searchController, animated: false)
                }
            }
        }
    }
}

extension ShoppingListViewController : ShoopingListDataHandlerDelegate {

    func receivedBannerDataOfSearchString(bannerSearchString: String) {
        elDebugPrint(bannerSearchString)
        
    
        let indexResult =  self.categoryA.enumerated().compactMap { $0.element as! String == bannerSearchString ? $0.offset : nil }
        if indexResult.count > 0 {
            
            let index = indexResult[0]
            DispatchQueue.main.async {
                self.shoppingListTableView.beginUpdates()
                self.shoppingListTableView.setNeedsDisplay()
                let indexPath = IndexPath(row: index + 1 , section: 0)
                let isVisible = self.shoppingListTableView.indexPathsForVisibleRows?.contains{$0 == indexPath}
                if let v = isVisible, v == true {
                    UIView.performWithoutAnimation {
                        Thread.OnMainThread {
                            self.shoppingListTableView.reloadRows(at: [indexPath], with: .none)
                        }
                    }
                }
                self.shoppingListTableView.endUpdates()
            }
            return
        }
        
        UIView.performWithoutAnimation {
            self.shoppingListTableView.reloadDataOnMain()
        }
      
    }

}

extension ShoppingListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        scrollView.layoutIfNeeded()
        locationHeader.myGroceryName.sizeToFit()
        if var headerFrame = shoppingListTableView.tableHeaderView?.frame {
            
            if scrollView.contentOffset.y > 0 {
                headerFrame.origin.y = scrollView.contentOffset.y }
            let maxHeight = locationHeader.headerMaxHeight + 10
            headerFrame.size.height = min(max(maxHeight-scrollView.contentOffset.y,75),maxHeight)
            shoppingListTableView.tableHeaderView?.frame = headerFrame
            
                //storeSearchBarHeader.frame = headerFrame
                //scrollView.contentOffset.y = scrollView.contentOffset.y + headerFrame.size.height
                // self.tableViewCategories.contentOffset = CGPoint.init(x: 0, y: 20)
//           elDebugPrint("scrollView.contentOffset.y",scrollView.contentOffset.y)
//           elDebugPrint("headerFrame.size.height",headerFrame.size.height)
            
            if maxHeight == headerFrame.size.height {
                self.shoppingListTableView.tableHeaderView = locationHeader
            }
            
        }
       // self.navigationController?.navigationBar.topItem?.title = scrollView.contentOffset.y > 40 ? self.grocery?.name : ""
        locationHeader.setNeedsLayout()
        locationHeader.layoutIfNeeded()
            // self.tableViewCategories.tableHeaderView = storeSearchBarHeader
        
    }
}


extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
    
    
}




