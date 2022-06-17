//
//  SearchViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 11/10/2017.
//  Copyright © 2017 elGrocer. All rights reserved.

import UIKit
import BBBadgeBarButtonItem
import SDWebImage


class SearchViewController: BasketBasicViewController,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource , UIGestureRecognizerDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.bounces = false
        }
    }
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.bounces = false
        }
    }
    @IBOutlet weak var tobaccoLabel: UILabel!
    @IBOutlet weak var tableViewBottomToSuperView: NSLayoutConstraint!
    @IBOutlet weak var searchBarBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var searchBarViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchBarCancelHeight: NSLayoutConstraint!
  //  @IBOutlet weak var collectionViewTopSpace: NSLayoutConstraint!
    @IBOutlet weak var SearchBarTopDistance: NSLayoutConstraint!
    @IBOutlet var btnCancel: UIButton! {
        didSet{
            btnCancel.setTitle(localizedString("account_setup_cancel", comment: ""), for: .normal)
        }
    }
    
    @IBOutlet var searchViewHeight: NSLayoutConstraint!
    @IBOutlet var groceryImage: UIImageView!
    @IBOutlet var lblgroceryName: UILabel!
    
    var commingFromVc : UIViewController?
    @IBOutlet var searchViewHeader: UIView! {
        didSet {
            searchViewHeader.backgroundColor = .textfieldBackgroundColor()
        }
    }
    lazy var locationHeader : ElgrocerlocationView = {
        let locationHeader = ElgrocerlocationView.loadFromNib()
        return locationHeader!
    }()
    @IBOutlet var searchBarView: AWView!
    
    @IBOutlet var progressCompletionBGView: UIView! {
        didSet {
            progressCompletionBGView.roundWithShadow(corners: [.layerMinXMinYCorner , .layerMaxXMinYCorner], radius: 24)
        }
    }
    @IBOutlet var lblCreatShoppingList: UILabel! {
        
        didSet{
            lblCreatShoppingList.text =      localizedString("lbl_shopping_list", comment: "Create your shopping list")
        }
        
    }
    @IBOutlet var lblSearchAndShop: UILabel!{
        
        didSet{
            lblSearchAndShop.text = localizedString("lbl_search_shop", comment: "Search and shop products")
        }
        
    }
    
    
    @IBOutlet var lblOne: UILabel! {
        didSet {
            lblOne.text = localizedString("lbl_One", comment: "")
        }
    }
    @IBOutlet var lblTwo: UILabel!{
        didSet {
            lblTwo.text = localizedString("lbl_Two", comment: "")
        }
    }
    @IBOutlet weak var searchBgView: UIView!
    
    private var bannerWorkItem:DispatchWorkItem?
    var topSearchesArray = [String]()
    var isNavigateToSearch = false
    var notSupportedSearchTexts = [String]()
    var searchSuggestions = [SearchSuggestion]()
    
    var bannerFeeds:[Home] = [Home]()
    var increamentIndexPathRow = 0
    var showBannerAtIndex = 5
    
    var selectedProduct:Product!
    var searchSuggestion:SearchSuggestion?
    var isTrendingSearch = false

    var isNeedToHideSearchBar = false
    var navigationFromControllerName : String = "Main"
    var isFromShoppingListViewAll: Bool = false
    var showHeading: Bool = false
    
    var collectionViewBottomConstraint: NSLayoutConstraint?

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
        
        if isNavigateToSearch == true {
            self.title = localizedString("search_placeholder", comment: "")
            self.addRightCrossButton(true)
           //  addBackButton()
        }else{
            self.navigationController!.navigationBar.topItem!.title = localizedString("search_placeholder", comment: "")
        }
   
      //  self.collectionView.backgroundColor = UIColor.white // removed while merging
        self.collectionView.backgroundColor = UIColor.textfieldBackgroundColor()

        
        self.setTableViewAppearence()
        self.setTobaccoLabelAppearence()
        
        self.registerCellsForTable()
        self.registerCellsForCollection()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil)


        self.searchWithSpecficProductName(productName: self.searchString)

        if isNeedToHideSearchBar && !self.searchString.isEmpty {

            if (ElGrocerUtility.sharedInstance.activeGrocery != nil && ElGrocerUtility.sharedInstance.activeGrocery!.topSearch.count > 0){
                self.topSearchesArray = (ElGrocerUtility.sharedInstance.activeGrocery!.topSearch)
            }
            self.collectionView.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
            self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
            self.basketIconOverlay?.grocery = self.grocery
            self.refreshBasketIconStatus()
            self.title = localizedString("Add_Shopping_list_Title", comment: "")

        }
        self.basketIconOverlay?.shouldShow = isFromShoppingListViewAll
        self.setCollectionViewBottomConstraint()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIApplication.topViewController()?.children.contains(where: { (vc) -> Bool in
            return vc is SearchViewController
        }) ?? false {
            return
        }
        
      
        
        // self.navigationController?.setNavigationBarHidden(true, animated: animated)
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarDelegate(self)
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        //(self.navigationController as? ElGrocerNavigationController)?.setNavigationBarHidden(!isNeedToHideSearchBar, animated: true)
        self.locationHeader.configuredLocationAndGrocey(self.grocery)
        self.locationHeader.setSlotData()
        if isNeedToHideSearchBar {
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            addBackButton(isGreen: false)
        }
        
        if isNeedToHideSearchBar {
            self.initialSettingIsCommingFromViewMore()
            self.btnCancel.isHidden = true
        }
        if isNeedToHideSearchBar && !self.searchString.isEmpty { } else {
            self.btnCancel.isHidden = false
            
            if self.searchedProducts.count == 0 {
                self.setViewForTopSearches()
            }
        }
        if isFromShoppingListViewAll {
            searchViewHeader.isHidden = false
            self.progressCompletionBGView.isHidden = false
            searchViewHeader.backgroundColor = .navigationBarColor()
        }else {
            searchViewHeight.constant = 0.0
            searchViewHeader.backgroundColor = .textfieldBackgroundColor()
            self.progressCompletionBGView.isHidden = true
            self.addLocationHeader()
            searchViewHeader.isHidden = true
        }
        checkEmptyView()
        
        self.view.layoutIfNeeded()
       
        self.navigationItem.hidesBackButton = true
        searchBgView.backgroundColor = .navigationBarColor()
        self.extendedLayoutIncludesOpaqueBars = true
        self.view.backgroundColor = .tableViewBackgroundColor()
    }
    override func viewDidAppear(_ animated: Bool) {
        
         super.viewDidAppear(animated)
      
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsSearchScreen)
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.Search.rawValue, screenClass: String(describing: self.classForCoder))
        
        if self.grocery != ElGrocerUtility.sharedInstance.activeGrocery {
            
            self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
            self.basketIconOverlay?.grocery = self.grocery
            self.refreshBasketIconStatus()
            if (ElGrocerUtility.sharedInstance.activeGrocery != nil && ElGrocerUtility.sharedInstance.activeGrocery!.topSearch.count > 0) {
                self.topSearchesArray = (ElGrocerUtility.sharedInstance.activeGrocery!.topSearch)
                self.tableView.reloadData()
            }

        } else {
            
            self.basketIconOverlay?.grocery = self.grocery
            self.refreshBasketIconStatus()
            if (ElGrocerUtility.sharedInstance.activeGrocery != nil && ElGrocerUtility.sharedInstance.activeGrocery!.topSearch.count > 0){
                self.topSearchesArray = (ElGrocerUtility.sharedInstance.activeGrocery!.topSearch)
                self.tableView.reloadData()
            }
            self.collectionView.reloadData()
            
        }
        self.setCollectionViewBottomConstraint()
   
    }
    
    override func rightBackButtonClicked() {
        self.dismiss(animated: true)
    }
    ///To adjust the bottom constraint for basketIconOverlay appear/disappear
    func setCollectionViewBottomConstraint() {
        if (collectionViewBottomConstraint == nil) && (self.basketIconOverlay != nil) {
            collectionViewBottomConstraint = NSLayoutConstraint(item:
                                        self.basketIconOverlay!,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: self.collectionView,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 0.0)
        }
        collectionViewBottomConstraint?.isActive = !(self.basketIconOverlay?.isHidden ?? true)
    }
    
    private func addLocationHeader() {
        
        guard self.btnCancel.isHidden else {
            
            self.lblgroceryName.text = self.grocery?.name ?? ""
            if  self.grocery?.smallImageUrl != nil &&  self.grocery?.smallImageUrl?.range(of: "http") != nil {
                self.setGroceryImage(self.grocery?.smallImageUrl! ?? "")
            }else{
                self.groceryImage.image = productPlaceholderPhoto
            }
            self.groceryImage.layer.cornerRadius = self.groceryImage.frame.size.height / 2
            return
        }
        
        
        
        
        self.view.addSubview(self.locationHeader)
        self.setLocationViewConstraints()
        
    }
    
    private func setLocationViewConstraints() {
        
        self.locationHeader.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.locationHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            self.locationHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.locationHeader.bottomAnchor.constraint(equalTo: self.collectionView.topAnchor, constant: 0)
            
        ])
        
        let widthConstraint = NSLayoutConstraint(item: self.locationHeader, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: ScreenSize.SCREEN_WIDTH)
        let heightConstraint = NSLayoutConstraint(item: self.locationHeader, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.locationHeader.headerMaxHeight)
        NSLayoutConstraint.activate([ widthConstraint, heightConstraint])
        
    }
    
    
//    func addLocationHeader() {
//
//        self.lblgroceryName.text = self.grocery?.name ?? ""
//        if  self.grocery?.smallImageUrl != nil &&  self.grocery?.smallImageUrl?.range(of: "http") != nil {
//            self.setGroceryImage(self.grocery?.smallImageUrl! ?? "")
//        }else{
//            self.groceryImage.image = productPlaceholderPhoto
//        }
//        self.groceryImage.layer.cornerRadius = self.groceryImage.frame.size.height / 2
//
//    }
//
    
    fileprivate func setGroceryImage(_ urlString : String) {

        self.groceryImage.sd_setImage(with: URL(string: urlString ), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
            guard let self = self else {
                return
            }
            if cacheType == SDImageCacheType.none {

                UIView.transition(with: self.groceryImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                    guard let self = self else {
                        return
                    }
                    self.groceryImage.image = image
                    }, completion: nil)

            }
        })

    }
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.backButtonClick()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateNotificationKey), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UserDefaults.removeBannerView(topControllerName: FireBaseScreenName.Search.rawValue)
        self.commingFromVc = UIApplication.topViewController()
    }
    
    override func backButtonClickedHandler(){
        self.backButtonClick()
    }
    
    
    fileprivate func checkEmptyView() {
        
        
        self.view.bringSubviewToFront(self.searchTextField)
        self.view.bringSubviewToFront(self.btnCancel)
        
        if !self.tableView.isHidden {
            
            self.emptyView?.isHidden = true
            
        }else{
            self.emptyView?.isHidden = self.searchedProducts.count > 0
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func searchWithSpecficProductName(productName : String) -> Void {
        if isNeedToHideSearchBar && !self.searchString.isEmpty {
            self.setSearchTextFieldAppearance()
            self.tobaccoLabel.isHidden = true
            self.searchTextField.isHidden = true
            self.initialSettingIsCommingFromViewMore()

        }
    }

    func initialSettingIsCommingFromViewMore() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.searchBarBottomSpace.constant  = 55
            self.searchBarCancelHeight.constant = 0
            self.searchBarViewHeight.constant = 0
           // self.collectionViewTopSpace.constant =  75
            self.SearchBarTopDistance.constant = 0
            self.btnCancel.isHidden = true
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.searchTextField.text  = self.searchString
            _ = self.textFieldShouldReturn(self.searchTextField)

        }
    }
    
    func registerCellsForTable() {
        
        let topSearchCellNib = UINib(nibName: "TopSearchCell", bundle: Bundle.resource)
        self.tableView.register(topSearchCellNib, forCellReuseIdentifier: kTopSearchCell)
        
        let searchSuggestionCellNib = UINib(nibName: "SearchSuggestionCell", bundle: Bundle.resource)
        self.tableView.register(searchSuggestionCellNib, forCellReuseIdentifier: kSearchSuggestionCellIdentifier)
    }
    
    func registerCellsForCollection() {
        
        let productCellNib = UINib(nibName: "ProductCell", bundle: Bundle.resource)
        self.collectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        
        
        self.collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TitleHeader")
        
        let BasketBannerCollectionViewCellNIB = UINib(nibName: "BasketBannerCollectionViewCell", bundle: Bundle.resource)
        self.collectionView.register(BasketBannerCollectionViewCellNIB , forCellWithReuseIdentifier: BasketBannerCollectionViewCellIdentifier)


         let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.init(top: 5 , left: 0, bottom: 10 , right: 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    override func backButtonClick() {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
        if isNavigateToSearch == true {
            self.navigationController?.popViewController(animated: false)
        }else{
            
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let nav = appDelegate.window!.rootViewController as? UINavigationController {
                if nav.viewControllers.count > 0 {
                    if  nav.viewControllers[0] as? UITabBarController != nil {
                        let tababarController = nav.viewControllers[0] as! UITabBarController
                        tababarController.selectedIndex = ElGrocerUtility.sharedInstance.tabBarSelectedIndex
                    }
                }
            }
          
        }
    }
    
    // MARK: Appearance
    
    fileprivate func setSearchTextFieldAppearance() {
        
       // self.searchTextField.clearButtonTintColor = .lightGrayBGColor()
        
        if #available(iOS 13.0, *) {
            self.searchTextField.overrideUserInterfaceStyle = .light
        }
    
        self.searchTextField.delegate = self
        
        self.searchTextField.font = UIFont.SFProDisplayNormalFont(14)
        self.searchTextField.placeholder =  localizedString("search_products", comment: "")
        self.searchTextField.attributedPlaceholder = NSAttributedString(string: localizedString("search_products", comment: "") ,
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchPlaceholderTextColor()])
        self.searchTextField.textColor = UIColor.newBlackColor()
        self.searchTextField.clipsToBounds = false
        
        self.searchTextField.clearButton?.setImage(UIImage(name: "sCross"), for: .normal)
        
        
       
        
       let xValue = (self.searchTextField.clearButton?.frame.origin.x ?? 0) - 20
       let finalRect =  CGRect.init(x: xValue, y: self.searchTextField.clearButton?.frame.origin.y ?? 0  , width: self.searchTextField.clearButton?.frame.size.width ?? 0 , height: self.searchTextField.clearButton?.frame.size.height ?? 0)
        self.searchTextField.clearButtonRect(forBounds: finalRect)
        
     
//        let imageView = UIImageView(image: UIImage(name: "icSearchLight"))
//        imageView.contentMode = UIView.ContentMode.left
//        imageView.frame = CGRect(x: 0.0, y: 0.0, width: imageView.image!.size.width + 20.0, height: imageView.image!.size.height)
//        self.searchTextField.leftViewMode = UITextField.ViewMode.always
//        self.searchTextField.leftView = imageView
        
        
        
//        self.searchTextField.leftViewMode = UITextField.ViewMode.always
//        let searchView = UIImageView(image: UIImage(name: "icSearchLight"))
//        searchView.frame = CGRect(x: 0.0, y: 0.0, width: searchView.image!.size.width + 20.0, height: searchView.image!.size.height)
//        searchView.contentMode = UIView.ContentMode.left
//        searchView.backgroundColor = UIColor.clear
       //  self.searchTextField.leftView = searchView
        if !isNeedToHideSearchBar && self.searchString.isEmpty {
            self.searchTextField.becomeFirstResponder()
        }
        
        if isNeedToHideSearchBar  {
           self.searchTextField.leftView = nil
        }

    }
    
    fileprivate func setTableViewAppearence(){
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.tableView.separatorColor = UIColor.borderGrayColor()
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.backgroundColor = UIColor.textfieldBackgroundColor()
        self.tableView.tableFooterView = UIView()
    }
    
    private func setTobaccoLabelAppearence() {
        
        self.tobaccoLabel.font = UIFont.SFProDisplaySemiBoldFont(14.0)
        self.tobaccoLabel.text =  localizedString("tobacco_products_message", comment: "")
        self.tobaccoLabel.textColor = UIColor.darkGrayTextColor()
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.searchString.isEmpty == false && self.isTrendingSearch == false {
            return kSearchSuggestionCellHeight
        }else{
            return kTopSearchCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.searchString.isEmpty == false && self.isTrendingSearch == false {
            return self.searchSuggestions.count+1
        }else{
            return self.topSearchesArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.searchString.isEmpty == false && self.isTrendingSearch == false {
    
                let cell = tableView.dequeueReusableCell(withIdentifier: kSearchSuggestionCellIdentifier, for: indexPath) as! SearchSuggestionCell
                cell.backgroundColor = UIColor.clear
                if self.searchSuggestions.count+1 > indexPath.row  {
                    if(indexPath.row == self.searchSuggestions.count){
                        cell.configureCellWithSearchText(self.searchString)
                        if isNeedToHideSearchBar && !self.searchString.isEmpty {
                            cell.titleLbl.isHidden = true
                            cell.searchImgView.isHidden = true
                        }else{
                            cell.titleLbl.isHidden = false
                            cell.searchImgView.isHidden = false
                        }
                    }else{
                        let suggestion = searchSuggestions[indexPath.row]
                        cell.configureCellWithSearchText(self.searchString, andWithSuggestion: suggestion.suggestionName)
                    }
                }
                return cell
                
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: kTopSearchCell, for: indexPath) as! TopSearchCell
            cell.backgroundColor = UIColor.clear
            if indexPath.row < topSearchesArray.count {
                cell.configure(topSearchesArray[indexPath.row])
            }else{
                 cell.configure("")
            }
            
            cell.titleLbl.font = UIFont.SFProDisplayNormalFont(15.0)
            cell.titleLbl.textColor = UIColor(red: 182.0 / 255.0, green: 182.0 / 255.0, blue: 182.0 / 255.0, alpha: 1)
            
            
//            if (indexPath.row == 0) {
//
//                cell.titleLbl.font = UIFont.openSansRegularFont(16.0)
//                cell.titleLbl.textColor = UIColor.black
//                cell.configure(localizedString("trending_searches", comment: ""))
//                cell.selectionStyle = UITableViewCell.SelectionStyle.none
//
//            }else{
//
//                cell.configure(topSearchesArray[indexPath.row - 1])
//                cell.titleLbl.font = UIFont.openSansRegularFont(15.0)
//                cell.titleLbl.textColor = UIColor(red: 182.0 / 255.0, green: 182.0 / 255.0, blue: 182.0 / 255.0, alpha: 1)
//            }
            
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.searchString.isEmpty {
            
            if indexPath.row != 0 {
                
                let searchStr = topSearchesArray[indexPath.row - 1]
                self.searchString = searchStr
                self.performSearch(searchString, withSearchSuggestion: nil)
                isTrendingSearch = true
                self.searchSuggestions.removeAll()
                
            }
            
        }else{
            
            if(indexPath.row == self.searchSuggestions.count){
                self.performSearch(searchString, withSearchSuggestion: nil)
            }else{
                
                if self.searchSuggestions.count > indexPath.row  {
                    self.searchSuggestion = searchSuggestions[indexPath.row]
                    self.performSearch(searchString, withSearchSuggestion: self.searchSuggestion)
                }else{
                    // FIXME:- here condition not handle by last developer. we need to fix it.
                    //string is not empty and not search suggestion
                    if self.topSearchesArray.count > indexPath.row - 1 {
                        let searchStr = topSearchesArray[indexPath.row - 1]
                        self.searchString = searchStr
                        self.performSearch(searchString, withSearchSuggestion: nil)
                        isTrendingSearch = true
                        self.searchSuggestions.removeAll()
                    }
                }
            }
        }
        
        self.searchTextField.text = self.searchString
        self.searchTextField.resignFirstResponder()
        self.getBanners(searchInput: searchString)
        tableView .deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return self.searchedProducts.count > 0 ? (self.searchedProducts.count + self.bannerFeeds.count) : 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard self.checkIsBannerCell(indexPath) == true else {
            return configureCellForSearchedProducts(getNewIndexPathAfterBanner(oldIndexPath: indexPath))
        }
        if getBannerIndex(oldIndexPath: indexPath).row - 1 == 1 {
            debugPrint("check here")
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BasketBannerCollectionViewCellIdentifier, for: indexPath) as! BasketBannerCollectionViewCell
        cell.grocery  = self.grocery
        cell.homeFeed = self.bannerFeeds[getBannerIndex(oldIndexPath: indexPath).row]
        return cell
        
    }
    

    
    func configureCellForSearchedProducts(_ indexPath:IndexPath) -> ProductCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        
        if indexPath.row < self.searchedProducts.count {
            let product = self.searchedProducts[(indexPath as NSIndexPath).row ]
            cell.configureWithProduct(product, grocery: self.grocery , cellIndex: indexPath)
            cell.delegate = self
        }else{
            debugPrint(indexPath)
        }
        cell.productContainer.isHidden = !(indexPath.row < self.searchedProducts.count)
    
        return cell
    }
    
    
    fileprivate func checkIsBannerCell(_ indexPath : IndexPath) -> Bool {
       
        guard  ((indexPath.row) % showBannerAtIndex  == 0) && self.bannerFeeds.count > getBannerIndex(oldIndexPath: indexPath).row   else {
           return false
        }
       return true
    }
    
    func getNewIndexPathAfterBanner(oldIndexPath : IndexPath) -> IndexPath {
        
        //debugPrint("oldIndexPath : \(oldIndexPath)")
        var newIndexPath = oldIndexPath
        newIndexPath.row = oldIndexPath.row - getIncrementedIndexNumber(oldIndexPath : oldIndexPath)
       // debugPrint("newIndexPath : \(newIndexPath)")
        return newIndexPath
    }
    
    
    @discardableResult func getIncrementedIndexNumber(oldIndexPath : IndexPath) -> Int {
        
        self.increamentIndexPathRow = 0
        guard oldIndexPath.row > 0 else {
            return oldIndexPath.row
        }
        self.increamentIndexPathRow = oldIndexPath.row / showBannerAtIndex
        self.increamentIndexPathRow = self.increamentIndexPathRow + 1
        if self.increamentIndexPathRow > self.bannerFeeds.count {
            self.increamentIndexPathRow = self.bannerFeeds.count
        }
//        debugPrint("self.increamentIndexPathRow : ")
//        debugPrint(self.increamentIndexPathRow)
        return  self.increamentIndexPathRow
    }
    
    func getBannerIndex(oldIndexPath : IndexPath) -> IndexPath {
        
        self.increamentIndexPathRow = 0
        self.increamentIndexPathRow = oldIndexPath.row / showBannerAtIndex
        var newIndexPath = oldIndexPath
        newIndexPath.row = self.increamentIndexPathRow
        return newIndexPath
        
    }
    
    //MARK: - CollectionView Layout Delegate Methods (Required)
    //** Size for the cells in Layout */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard self.checkIsBannerCell(indexPath) == true else {
            
            var cellSpacing: CGFloat = -20.0
            var numberOfCell: CGFloat = 2.13
            if self.view.frame.size.width == 320 {
                cellSpacing = 3.0
                numberOfCell = 2.965
            }
            let cellSize = CGSize(width: ((collectionView.frame.size.width - 32) - cellSpacing * 2 ) / numberOfCell , height: kProductCellHeight)
            return cellSize
            
        }
        
        let wid = (ScreenSize.SCREEN_WIDTH - 32)
        
        let cellSize = CGSize(width:ScreenSize.SCREEN_WIDTH - 28   , height: wid  / KBannerRation)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
         return UIEdgeInsets(top: 0, left: 6 , bottom: 0 , right: 6)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0, showHeading {
            return CGSize.init(width: ScreenSize.SCREEN_WIDTH , height: 25)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section == 0, showHeading {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TitleHeader", for: indexPath) as! SectionHeader
                headerView.label.text = self.searchString //+ "(shop list. view all)"
                return headerView
            }
        }
        return UICollectionReusableView()
        
    }
    
    
    // MARK: Data
    
    func setViewForTopSearches(){
        
        self.setSearchTextFieldAppearance()
        self.tobaccoLabel.isHidden = true

        if isNeedToHideSearchBar && !self.searchString.isEmpty {
            self.initialSettingIsCommingFromViewMore()
        }else{
            
            self.searchTextField.text = ""
            self.searchString = ""
        }

        if (ElGrocerUtility.sharedInstance.activeGrocery != nil && ElGrocerUtility.sharedInstance.activeGrocery!.topSearch.count > 0){
            self.topSearchesArray = (ElGrocerUtility.sharedInstance.activeGrocery!.topSearch)
        }
        
        self.collectionView.isHidden = true
        self.tableView.isHidden = false
        
        self.tableView.reloadData()
        
        self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
        self.basketIconOverlay?.grocery = self.grocery
        self.refreshBasketIconStatus()
        self.setCollectionViewBottomConstraint()


    }
    
    override func refreshData() {
        
        self.tobaccoLabel.isHidden = true
        
        if self.searchString.isEmpty {
            
            self.collectionView.isHidden = true
            
            self.tableView.isHidden = false
            if  !ElGrocerUtility.sharedInstance.isComingFromPopUp(self.commingFromVc) {
                self.tableView.setContentOffset(CGPoint.zero, animated:true)
            }
            self.tableView.reloadData()
            
        }else{
            
            self.tableView.isHidden = true
            
            self.collectionView.isHidden = false
            
            if self.currentSearchPage == 0 && !ElGrocerUtility.sharedInstance.isComingFromPopUp(self.commingFromVc)  {
                self.collectionView.setContentOffset(CGPoint.zero, animated:true)
            }
            
            self.collectionView.reloadData()
            
            if notSupportedSearchTexts.contains(where: {$0.caseInsensitiveCompare(self.searchString) == .orderedSame}) {
                
                self.collectionView.isHidden = true
                self.tableView.isHidden = true
                
                self.tobaccoLabel.isHidden = false
                
                self.searchTextField.resignFirstResponder()
            }
        }
        self.checkEmptyView()
    }
    
    //MARK: - Scrolling
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //load more only if we are searching
        
        if !self.searchString.isEmpty && self.tableView.isHidden == true {
            
            let kLoadingDistance = 2 * kProductCellHeight + 8
            let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
            
            if y + kLoadingDistance > scrollView.contentSize.height && self.moreProductsAvailable && !self.isLoadingProducts {
                self.searchProducts(false, withSearchSuggestion: self.searchSuggestion)
            }
            
        }
        
        guard self.btnCancel.isHidden else {
            return
        }
        
        scrollView.layoutIfNeeded()
        
        let constraintA = self.locationHeader.constraints.filter({$0.firstAttribute == .height})
        if constraintA.count > 0 {
            let constraint = constraintA.count > 1 ? constraintA[1] : constraintA[0]
            let headerViewHeightConstraint = constraint
            let maxHeight = self.locationHeader.headerMaxHeight
            headerViewHeightConstraint.constant = min(max(maxHeight-scrollView.contentOffset.y,70),maxHeight)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.locationHeader.myGroceryName.alpha = scrollView.contentOffset.y < 10 ? 1 : scrollView.contentOffset.y / 100
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            let title = scrollView.contentOffset.y > 40 ? self.grocery?.name : ""
            self.navigationController?.navigationBar.topItem?.title = title
        }
    }
    
    
    // MARK: Product quick add
    
    override func addProductToBasketFromQuickAdd(_ product: Product) {
        
        //  ElGrocerEventsLogger.sharedInstance.addToCart(product: product)
        
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
        
        if UserDefaults.isOrderInEdit() {
      
        ElGrocerUtility.sharedInstance.showTopMessageView(localizedString("lbl_edit_Added", comment: ""), image: UIImage(name: "iconAddItemSuccess"), -1 , backButtonClicked: { [weak self] (sender , index , isUnDo) in
            if isUnDo {
                if let availableP = self?.selectedProduct {
                     self?.removeProductToBasketFromQuickRemove(availableP)
                }
            }else{
               
            }
        })
            
        }
        
        
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
//        let index = self.searchedProducts.index(of: self.selectedProduct)
//        if let notNilIndex = index {
//            let finalIndex = notNilIndex + self.getIncrementedIndexNumber(oldIndexPath: IndexPath(row: notNilIndex  , section: 0))
//            if (self.collectionView.indexPathsForVisibleItems.contains(IndexPath(row: finalIndex  , section: 0))) {
//                self.collectionView.reloadItems(at: [IndexPath(row: finalIndex, section: 0)])
//            }else{
//
//            }
//        }
        self.collectionView.reloadData()
        self.tableView.reloadData()
        self.basketIconOverlay?.grocery = self.grocery
        self.refreshBasketIconStatus()
        self.setCollectionViewBottomConstraint()
    }
    
    
    //MARK:- Banner calling  Methods -
    // MARK: Banners Products
    
    func removeBannerCall () {
        if let bannerWork = self.bannerWorkItem {
            bannerWork.cancel()
        }
    }
    
    func getBanners(searchInput : String ){
        
        self.removeBannerCall()
        self.bannerWorkItem = DispatchWorkItem {
            if let gorceryId = self.grocery?.dbID {
                self.getBannersFromServer(gorceryId , searchInput: searchInput)
            }
        }
        DispatchQueue.global().async(execute: self.bannerWorkItem!)

    }
 
    private func getBannersFromServer(_ gorceryId:String , searchInput : String){
        
        
        
        let homeTitle = "Banners"
        let location = BannerLocation.in_search_tier_1
        ElGrocerApi.sharedInstance.getBannersFor(location: location , retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(gorceryId)], store_type_ids: nil , retailer_group_ids: nil  , category_id: nil , subcategory_id: nil, brand_id: nil, search_input: searchInput ) { (result) in
            switch result {
                case .success(let response):
                    self.saveBannersResponseData(response, withHomeTitle: homeTitle, andWithGroceryId: gorceryId)
                case.failure( _):break
            }
        }
       
    }
   
    func saveBannersResponseData(_ responseObject:NSDictionary, withHomeTitle homeTitle:String, andWithGroceryId gorceryId:String) {
        
        if (self.grocery?.dbID == gorceryId){
            
            let banners = BannerCampaign.getBannersFromResponse(responseObject)
            let homeFeed = Home.init(homeTitle, withCategory: nil, withBanners: banners , withType:HomeType.Banner,  andWithResponse: nil)
            self.bannerFeeds.append(homeFeed)
            self.bannerFeeds.removeAll()
            self.increamentIndexPathRow = 0
            self.collectionView.reloadDataOnMainThread()
        }
        
    }
    
    //MARK: KeyBoard Handling
    
    @objc override func keyboardWillShow(_ notification: Notification) {
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        self.tableViewBottomToSuperView.constant = keyboardHeight - 50
    }
    
    @objc override func keyboardWillHide(_ notification: Notification) {
        self.tableViewBottomToSuperView.constant = 0.0
    }
    
    func getSearchSuggestions() {
        
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            ElGrocerApi.sharedInstance.getSearchSuggestions(self.searchString, page: self.currentSearchPage, grocery: self.grocery, completionHandler:{ (result:Bool, responseObject:NSDictionary?) -> Void in
                
                if result {
                    self.saveAllSearchSuggestionsFromResponse(responseObject!)
                }
            })
            
        })
        
        
    }
    
    func saveAllSearchSuggestionsFromResponse(_ response: NSDictionary) {
        
        self.searchSuggestions.removeAll()
        
        let searchSuggestions : [SearchSuggestion] =  SearchSuggestion.getAllSearchSuggestionFromResponse(response)
        print("Search Suggestions Count:%d",searchSuggestions.count)
        
        self.searchSuggestions = searchSuggestions
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.tableView.isHidden = false
            let range = NSMakeRange(0, self.tableView.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            self.tableView.reloadSections(sections as IndexSet, with: .automatic)
            self.collectionView.isHidden = true
            self.checkEmptyView()
        }
       
        
    }
    
    //MARK:- Search Methods
    override func navigationBarSearchViewDidChangeText(_ navigationBarSearch: NavigationBarSearchView, searchString: String) {
    }
    override func navigationBarSearchTapped() {
        (self.navigationController as? ElGrocerNavigationController)?.resetViewsLayout()
    }
    
    override func navigationBarSearchViewDidChangeCharIn(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) {
      let _ =  self.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
}

// MARK: UITextFieldDelegate Extension

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
      //  self.tableView.isHidden = false
      //  self.tableView.reloadData()
      //  self.collectionView.isHidden = true
        self.checkEmptyView()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.searchBarView.layer.borderColor = UIColor.navigationBarColor().cgColor
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.searchBarView.layer.borderColor = UIColor.borderGrayColor().cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(SearchViewController.performAlgoliaSearch),
            object: textField)

        self.perform(
            #selector(SearchViewController.performAlgoliaSearch),
            with: textField,
            afterDelay: 0.25)
        
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(SearchViewController.userSearchedKeyWords),
            object: textField)
        
        self.perform(
            #selector(SearchViewController.userSearchedKeyWords),
            with: textField,
            afterDelay: 3.0)
        
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let newText = text.replacingCharacters(in: textRange, with: string)
            let trimmedSearchString = newText.trimmingCharacters(in: .whitespacesAndNewlines)
            self.searchString = trimmedSearchString
        }
        return true
        
    }
    
    @objc
    func userSearchedKeyWords() {
        self.userPerformedSearch()
    }
     
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        
        if ElGrocerUtility.sharedInstance.isComingFromPopUp(self.commingFromVc) {
            textField.resignFirstResponder()
            return true
        }
        textField.resignFirstResponder()
       
        self.collectionView.setContentOffset(CGPoint.zero, animated:true)
        
        if(textField.returnKeyType == .search && self.searchString.isEmpty == false){
            self.performSearch(searchString, withSearchSuggestion: nil)
            self.getBanners(searchInput: searchString)
        }
        if isNeedToHideSearchBar && !self.searchString.isEmpty {
            self.getBanners(searchInput: searchString)
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        self.searchString = ""
        if  !ElGrocerUtility.sharedInstance.isComingFromPopUp(self.commingFromVc) {
            self.collectionView.setContentOffset(CGPoint.zero, animated:true)
            
        }
        self.refreshData()
        return true
    }
    
    @objc
    func performAlgoliaSearch(textField: UITextField){
          self.performSearch(searchString, withSearchSuggestion: nil)
    }
}


class SectionHeader: UICollectionReusableView {
     var label: UILabel = {
         let label: UILabel = UILabel()
         label.sizeToFit()
         label.setH4SemiBoldStyle()
         return label
     }()

     override init(frame: CGRect) {
         super.init(frame: frame)

         addSubview(label)

         label.translatesAutoresizingMaskIntoConstraints = false
         label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
         label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
         label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
