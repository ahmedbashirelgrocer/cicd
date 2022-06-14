//
//  ReplacementViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 23/04/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage


class ReplacementViewController: BasketBasicViewController,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var searchTextField: UITextField! 
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productView: UIView!
    
    //    @IBOutlet weak var collectionViewBottomToSuperView: NSLayoutConstraint!
    //    @IBOutlet weak var collectionViewBottomToProductView: NSLayoutConstraint!
    
    
    @IBOutlet var viewChooseButton: AWView!
    @IBOutlet var chooseButton: UIButton!
    @IBOutlet var lblSearchForReplacment: UILabel! {
        didSet{
            lblSearchForReplacment.text = NSLocalizedString("lbl_Search_Replacment", comment: "")
        }
    }
    @IBOutlet var lblConfirmReplacment: UILabel! {
        didSet{
            lblConfirmReplacment.text =    NSLocalizedString("btn_Confirm_Replacement", comment: "")
            
        }
    }
    
    
    
    var chooseReplacementClouser: ((_ currentAlternativeProduct : Product , _ alternativeProducts : [Product] )->Void)?
    
    var userChooseA:[Product] = [Product]()
    
    var alternativeProducts:[Product] = [Product]()
    var currentAlternativeProduct:Product!
    var besketSelectedProductsId: [String] = [String]()
    
    var selectedProduct:Product!
    
    var notAvailableProducts:[Product]!
    
    var isFromBasket = false
    
    var cartGrocery:Grocery?
    var isSearching = false
    var isMoreProductsAvailable = true
    var searchText:String = ""
    
    var currentIndex:Int = 1
    
    var currentOffset = 0
    var currentLimit = 6
    
    var placeholderPhoto = UIImage(named: "product_placeholder")!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //self.title = NSLocalizedString("alternatives_title", comment: "")
        self.title = NSLocalizedString("alternatives_New_title", comment: "")
        
        addBackButton()
        
        self.navigationItem.rightBarButtonItem = nil
        
        self.registerCellsForCollection()
        self.setProductViewAppearance()
        
        if isFromBasket == true {
            self.setSearchTextFieldAppearance()
            self.getNextProductIndex()
            self.addTapGestureToProductView()
            
            self.searchText = self.currentAlternativeProduct.name!
            self.getReplacementProductsFromServer(true)
            self.hideProductView(true)
        }else{
            
            self.searchText = self.currentAlternativeProduct.name!
            self.getReplacementProductsFromServer(true)
            self.hideProductView(true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        setButtonState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.Replacement.rawValue , screenClass: String(describing: self.classForCoder))
        self.collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func backButtonClick() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateNotificationKey), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func getNextProductIndex(){
        
        if notAvailableProducts.count > 1{
            
            let index = notAvailableProducts.firstIndex(where: { $0.dbID == self.currentAlternativeProduct.dbID})
            if (index != nil) {
                let element = notAvailableProducts.remove(at: index!)
                notAvailableProducts.insert(element, at: 0)
            }
            
            let product = self.notAvailableProducts[self.currentIndex]
            self.configureViewWithProduct(product)
        }else{
            self.hideProductView(true)
        }
    }
    
    // MARK: Appearance
    
    private func setButtonState(){
        self.chooseButton.isUserInteractionEnabled = userChooseA.count > 0
        if userChooseA.count > 0 {
            self.chooseButton.isUserInteractionEnabled = userChooseA.count > 0
            self.viewChooseButton.backgroundColor = .navigationBarColor()
        }else{
            self.viewChooseButton.backgroundColor = .disableButtonColor()
        }
    }
    
    private func setSearchTextFieldAppearance() {
        
        self.searchTextField.delegate = self
        
        self.searchTextField.font = UIFont.SFProDisplaySemiBoldFont(16.0)
        self.searchTextField.placeholder =  NSLocalizedString("search_products_replace", comment: "")
        
        
        
        self.searchTextField.attributedPlaceholder = NSAttributedString.init(string: self.searchTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.buttonNonSelectionColor() , NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14) ])
        self.searchTextField.font = UIFont.SFProDisplayNormalFont(14)
        self.searchTextField.textColor = UIColor.newBlackColor()
        self.searchTextField.clipsToBounds = false
        
        self.searchTextField.leftViewMode = UITextField.ViewMode.always
        
        let mainSearchView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: 32, height: 24))
        let searchView = UIImageView(image: UIImage(named: "icSearchLight"))
        searchView.contentMode = UIView.ContentMode.center
        searchView.backgroundColor = UIColor.clear
        searchView.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        mainSearchView.addSubview(searchView)
        // searchView.center = mainSearchView.center
        self.searchTextField.leftView = mainSearchView
        
        self.searchTextField.text = self.searchText
        self.searchTextField.becomeFirstResponder()
    }
    
    private func configureViewWithProduct(_ product:Product) {
        
        let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(15.0), NSAttributedString.Key.foregroundColor : UIColor.black]
        
        let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14.0), NSAttributedString.Key.foregroundColor : UIColor.lightTextGrayColor()]
        
        let attributedString1 = NSMutableAttributedString(string: String(format:"%@ ",NSLocalizedString("select_alternative_title", comment: "")), attributes:attrs1)
        
        let attributedString2 = NSMutableAttributedString(string:product.name!, attributes:attrs2)
        
        attributedString1.append(attributedString2)
        self.productName.attributedText = attributedString1
        self.productName.sizeToFit()
        self.productName.numberOfLines = 0
        self.productName.lineBreakMode = .byWordWrapping
        
        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {
            
            self.productImage.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.productImage.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }
    
    private func setProductViewAppearance() {
        
        self.productView.layer.cornerRadius = 5
        self.productView.layer.masksToBounds = false
        
        self.productView.layer.shadowColor = UIColor.navigationBarColor().cgColor
        self.productView.layer.shadowOpacity = 0.7
        self.productView.layer.shadowOffset = CGSize.zero
        self.productView.layer.shadowRadius = 5
    }
    
    func registerCellsForCollection() {
        let productCellNib = UINib(nibName: "ProductCell", bundle: Bundle(for: ReplacementViewController.self))
        self.collectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        
        self.collectionView.backgroundColor = UIColor.tableViewBackgroundColor()
        self.collectionView.superview?.backgroundColor = .tableViewBackgroundColor()
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.init(top: 5 , left: 5, bottom: 10 , right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
        
        
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.alternativeProducts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return configureCellForSearchedProducts(indexPath)
    }
    
    func configureCellForSearchedProducts(_ indexPath:IndexPath) -> ProductCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        
        let product = self.alternativeProducts[(indexPath as NSIndexPath).row]
        cell.configureWithProduct(product, grocery: self.cartGrocery, cellIndex: indexPath)
        UIView.performWithoutAnimation {
            cell.addToCartButton.setTitle(NSLocalizedString("btn_Choose_title", comment: ""), for: UIControl.State())
            cell.addToCartButton.layoutIfNeeded()
        }
        cell.delegate = self
        
        if let item =   ShoppingBasketItem.checkIfProductIsInBasket(self.currentAlternativeProduct, grocery: self.cartGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            
            if item.subStituteItemID  == product.dbID {
                
                cell.productContainer.layer.borderColor = UIColor.navigationBarColor().cgColor
                cell.productContainer.layer.borderWidth = 2.0
                //                let filtetA =   self.alternativeProducts.filter { (product) -> Bool in
                //                    return item.subStituteItemID == product.dbID
                //                }
                //                if filtetA.count > 0 {
                //                    for prod in filtetA {
                //                        ShoppingBasketItem.removeProductFromBasket(prod, grocery: self.cartGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                //                    }
                //                }
            }else{
                // cell.productContainer.layer.borderColor = UIColor.navigationBarColor().cgColor
                cell.productContainer.layer.borderWidth = 0.0
            }
            //            item.isSubtituted = 1
            //            item.subStituteItemID = self.selectedProduct.dbID
        }
        
        
        
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
        
        var cellSpacing: CGFloat = -20.0
        var numberOfCell: CGFloat = 2.13
        if self.view.frame.size.width == 320 {
            cellSpacing = 3.0
            numberOfCell = 1.965
        }
        let cellSize = CGSize(width: ((collectionView.frame.size.width - 32) - cellSpacing * 2 ) / numberOfCell , height: kProductCellHeight)
        return cellSize
        
    }
    
    
    
    
    // MARK: Product quick add
    
    override func addProductToBasketFromQuickAdd(_ product: Product) {
        
        //  ElGrocerEventsLogger.sharedInstance.addToCart(product: product)
        
        var productQuantity = 1
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.cartGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity += product.count.intValue
        }
        
        self.selectedProduct = product
        self.updateProductQuantity(productQuantity)
        setButtonState()
    }
    
    override func removeProductToBasketFromQuickRemove(_ product: Product){
        
        var productQuantity = 0
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.cartGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity = product.count.intValue - 1
        }
        
        if productQuantity < 0 {return}
        
        self.selectedProduct = product
        self.updateProductQuantity(productQuantity)
        setButtonState()
    }
    
    func updateProductQuantity(_ quantity: Int) {
        
        //removing out of stock prodcut from basket
        //   ShoppingBasketItem.removeProductFromBasket(self.currentAlternativeProduct, grocery: self.cartGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if quantity == 0 {
            
            //remove product from basket
            ShoppingBasketItem.removeProductFromBasket(self.selectedProduct, grocery: self.cartGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            self.userChooseA.removeAll { (product) -> Bool in
                return self.selectedProduct.dbID == product.dbID
            }
            if let item =   ShoppingBasketItem.checkIfProductIsInBasket(self.currentAlternativeProduct, grocery: self.cartGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                
                if item.subStituteItemID  == self.selectedProduct.dbID {
                    item.isSubtituted = 0
                    item.subStituteItemID = nil
                }
            }
            
            
            
            
        } else {
            
            //Add or update item in basket
            ShoppingBasketItem.addOrUpdateProductInBasket(self.selectedProduct, grocery: self.cartGrocery, brandName: nil, quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            if  self.userChooseA.firstIndex(of: self.selectedProduct) == nil {
                self.userChooseA.append(self.selectedProduct)
            }
            
            if let item =   ShoppingBasketItem.checkIfProductIsInBasket(self.currentAlternativeProduct, grocery: self.cartGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                
                if item.subStituteItemID  != self.selectedProduct.dbID {
                    let filtetA =   self.alternativeProducts.filter { (product) -> Bool in
                        return item.subStituteItemID == product.dbID
                    }
                    if filtetA.count > 0 {
                        for prod in filtetA {
                            ShoppingBasketItem.removeProductFromBasket(prod, grocery: self.cartGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        }
                    }
                }
                item.isSubtituted = 1
                item.subStituteItemID = self.selectedProduct.dbID
            }
            
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        
        //reload this product cell
        /*let index = self.alternativeProducts.index(of: self.selectedProduct)
         if let notNilIndex = index {
         if (self.collectionView.indexPathsForVisibleItems.contains(IndexPath(row: notNilIndex, section: 0))) {
         self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
         }
         }*/
        
        self.collectionView.reloadData()
        
        
        
        
        
    }
    
    // MARK: Data
    @objc
    func perfomSearchAnalytics() {
        FireBaseEventsLogger.trackSearch(self.searchText, topControllerName: FireBaseScreenName.Replacement.rawValue)
        
    }
    
    func getReplacementProductsFromServer(_ shouldClearProductsArray:Bool) {
        
        self.isSearching = true
        
        if let dbid : String = self.cartGrocery?.dbID {
            
            let pageNumber = shouldClearProductsArray ? 0 : self.currentOffset / self.currentLimit
            if self.searchTimer != nil {
                self.searchTimer?.invalidate()
                self.searchTimer = nil
            }
            self.searchTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(perfomSearchAnalytics), userInfo: nil, repeats: false)
            AlgoliaApi.sharedInstance.searchQueryWithCurrentStoreItems(self.searchText, storeID: dbid, pageNumber: pageNumber , seachSuggestion: nil, searchType: "alternate" , self.currentLimit ) { (content, error) in
                
                debugPrint("content : \(String(describing: content))")
                
                Thread.OnMainThread {
                    if error != nil {
                        debugPrint("==============")
                        debugPrint(error as Any)
                        
                    }else if  content != nil{
                        
                        if shouldClearProductsArray {
                            self.alternativeProducts = [Product]()
                        }
                        
                        let newProducts = Product.insertOrReplaceProductsFromDictionary(content! as NSDictionary , context: DatabaseHelper.sharedInstance.mainManagedObjectContext , searchString: self.searchText)
                        
                        var productCount = 0
                        if let algoliaObj = content?["hits"] as? [NSDictionary] {
                            productCount = algoliaObj.count
                        }
                        
                        self.currentOffset = self.currentOffset + productCount
                        self.isMoreProductsAvailable = productCount % self.currentLimit == 0
                        
                        self.alternativeProducts += newProducts
                        DatabaseHelper.sharedInstance.saveDatabase()
                    }
                    
                    self.alternativeProducts = self.alternativeProducts.filter { (product) -> Bool in
                        let dbid = product.dbID
                        if let _ = self.besketSelectedProductsId.firstIndex(of: dbid) {
                            return false
                        }
                        return true
                    }
                    
                    self.isSearching = false
                    self.collectionView.reloadData()
                    
                    SpinnerView.hideSpinnerView()
                }
            }
            return
        }
        
        self.currentOffset = shouldClearProductsArray ? 0 : self.currentOffset + self.currentLimit
        
        ElGrocerApi.sharedInstance.getReplacementProducts(self.searchText, limit: self.currentLimit, offset: self.currentOffset, product: self.currentAlternativeProduct, grocery: self.cartGrocery,completionHandler: { (result:Bool, responseObject:NSDictionary?) -> Void in
            
            if result {
                
                
                
                if shouldClearProductsArray {
                    self.alternativeProducts = [Product]()
                }
                
                Thread.OnMainThread {
                    let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    self.isMoreProductsAvailable = newProducts.count > 0
                    
                    self.alternativeProducts += newProducts
                    DatabaseHelper.sharedInstance.saveDatabase()
                }
                
           
            }
            Thread.OnMainThread {
                self.isSearching = false
                self.collectionView.reloadData()
            }
        })
    }
    
    // MARK: TAP Gesture
    private func addTapGestureToProductView() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.productTapped))
        self.productView.addGestureRecognizer(tapGesture)
    }
    
    @objc func productTapped() {
        
        if self.currentIndex <= self.notAvailableProducts.count{
            
            self.currentAlternativeProduct = self.notAvailableProducts[self.currentIndex]
            self.searchText = self.currentAlternativeProduct.name!
            self.getReplacementProductsFromServer(true)
            
            self.searchTextField.text = self.searchText
            
            self.currentIndex = self.currentIndex + 1
            if self.currentIndex < self.notAvailableProducts.count{
                let product = self.notAvailableProducts[self.currentIndex]
                self.configureViewWithProduct(product)
            }else{
                self.hideProductView(true)
            }
        }else{
            self.hideProductView(true)
        }
    }
    
    private func hideProductView(_ hidden:Bool){
        
        self.productView.isHidden = hidden
        //        self.collectionViewBottomToSuperView.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
        //        self.collectionViewBottomToProductView.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
    }
    
    //MARK: - Scrolling
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //load more only if we are searching
        if !self.searchText.isEmpty{
            
            let kLoadingDistance = 2 * kProductCellHeight + 8
            let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
            
            if y + kLoadingDistance > scrollView.contentSize.height && self.isMoreProductsAvailable && !self.isSearching {
                self.getReplacementProductsFromServer(false)
            }
        }
        
        self.searchTextField.resignFirstResponder()
    }
    
    @objc func goForSearch() {
        self.getReplacementProductsFromServer(true)
    }
    
    @IBAction func confirmReplacment(_ sender: Any) {
        
        if let clouser = self.chooseReplacementClouser {
            clouser(currentAlternativeProduct , self.userChooseA)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func backActionHandler(_ sender: Any) {
        
        if userChooseA.count > 0 {
            self.selectedProduct = userChooseA[0]
            self.updateProductQuantity(0)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}

// MARK: UITextFieldDelegate Extension

extension ReplacementViewController: UITextFieldDelegate {
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        self.searchTextField.text = newText
        self.searchText = newText
        if(self.searchText.isEmpty == false){
            NSObject.cancelPreviousPerformRequests(
                withTarget: self,
                selector: #selector(ReplacementViewController.goForSearch),
                object: textField)
            self.perform(
                #selector(ReplacementViewController.goForSearch),
                with: textField,
                afterDelay: 2.0)
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    
}
