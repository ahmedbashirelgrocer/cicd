//
//  BrowseViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 02/05/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

struct CategoryData {
    let categoryObj: Category
    let subCateList : [SubCategory]?
}

class BrowseViewController: BasketBasicViewController, UITableViewDelegate, UITableViewDataSource, CategorySearchBarDelegate {
   
   
   
    

    @IBOutlet weak var tableViewCategories: UITableView!{
        didSet{
            tableViewCategories.bounces = false
        }
    }
    
    var categorySearchBar:CategorySearchBar!
    
    var categories = [Category]()
    var subCategorycategories :  Dictionary <Int,[SubCategory] > = [:]
    
    var selectedCategory:Category!
    var selectedSubCategory:SubCategory?
    var selectedIndex:Int = 0
    
    var tableViewBottomConstraint: NSLayoutConstraint?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    lazy var locationHeader : ElgrocerlocationView = {
        let locationHeader = ElgrocerlocationView.loadFromNib()
        return locationHeader!
    }()
    
    lazy var locationHeaderFlavor : ElgrocerStoreHeader = {
        let locationHeader = ElgrocerStoreHeader.loadFromNib()
        locationHeader?.translatesAutoresizingMaskIntoConstraints = false
        locationHeader?.setDismisType(.popVc)
        return locationHeader!
    }()
    
    private lazy var locationHeaderShopper: ElGrocerStoreHeaderShopper = {
        let locationHeader = ElGrocerStoreHeaderShopper.loadFromNib()
        locationHeader?.translatesAutoresizingMaskIntoConstraints = false
        locationHeader?.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return locationHeader!
    }()
    
    private var effectiveOffset: CGFloat = 0
    private var offset: CGFloat = 0 {
        didSet {
            let diff = offset - oldValue
            if diff > 0 { effectiveOffset = min(60, effectiveOffset + diff) }
            else { effectiveOffset = max(0, effectiveOffset + diff) }
        }
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.configureNoSavedCar()
        return noStoreView!
    }()
    
    private func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    private func addLocationHeader() {
        let marketType = sdkManager.launchOptions?.marketType ?? .shopper
        
        switch marketType {
            
        case .marketPlace:
            self.view.addSubview(self.locationHeader)
            self.setLocationViewConstraints()
            
        case .shopper:
            self.view.addSubview(self.locationHeaderShopper)
            self.setupShopperLocationHeaderConstraint()
            
        case .grocerySingleStore:
            self.view.addSubview(self.locationHeaderFlavor)
            self.setLocationViewFlavorHeaderConstraints()
        }
    }
    
    private func setLocationViewFlavorHeaderConstraints() {
        
        self.locationHeaderFlavor.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.locationHeaderFlavor.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            self.locationHeaderFlavor.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.locationHeaderFlavor.bottomAnchor.constraint(equalTo: self.tableViewCategories.topAnchor, constant: 0)
          
        ])
        
        let widthConstraint = NSLayoutConstraint(item: self.locationHeaderFlavor, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: ScreenSize.SCREEN_WIDTH)
        let heightConstraint = NSLayoutConstraint(item: self.locationHeaderFlavor, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.locationHeaderFlavor.headerMaxHeight)
        NSLayoutConstraint.activate([ widthConstraint, heightConstraint])
      
    }
    
    private func setLocationViewConstraints() {
        
        self.locationHeader.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.locationHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            self.locationHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.locationHeader.bottomAnchor.constraint(equalTo: self.tableViewCategories.topAnchor, constant: 0)
            
        ])
        
        let widthConstraint = NSLayoutConstraint(item: self.locationHeader, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: ScreenSize.SCREEN_WIDTH)
        let heightConstraint = NSLayoutConstraint(item: self.locationHeader, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.locationHeader.headerMaxHeight)
        NSLayoutConstraint.activate([ widthConstraint, heightConstraint])
        
    }
    
    private func setupShopperLocationHeaderConstraint() {
        NSLayoutConstraint.activate([
            locationHeaderShopper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            locationHeaderShopper.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            locationHeaderShopper.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            locationHeaderShopper.bottomAnchor.constraint(equalTo: self.tableViewCategories.topAnchor)
        ])
    }
    
    ///To adjust the bottom constraint for basketIconOverlay appear/disappear
    func setTableViewBottomConstraint() {
        if (tableViewBottomConstraint == nil) && (self.basketIconOverlay != nil) {
            tableViewBottomConstraint = NSLayoutConstraint(item:
                                        self.basketIconOverlay!,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: self.tableViewCategories,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 0.0)
        }
        tableViewBottomConstraint?.isActive = !(self.basketIconOverlay?.isHidden ?? true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if sdkManager.isSmileSDK || sdkManager.isShopperApp { self.view.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor }
        self.view.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
        self.registerCellsForTableView()
        self.setupClearNavBar()
        DispatchQueue.main.async {
            self.setData()
        }
        
        self.addLocationHeader()
    }
    
    override func refreshSlotChange() {
        
        
        for (index , _) in self.subCategorycategories {
            self.subCategorycategories[index]  = []
        }
    
        self.setData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func backButtonClickedHandler() {
        self.navigationController?.popViewController(animated: true)
    }
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setData() {
        
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            guard let currentAddress = getCurrentDeliveryAddress() else {
                return
            }
            ElGrocerApi.sharedInstance.getAllCategories(currentAddress,
                                                        parentCategory:nil , forGrocery: grocery) { (result) -> Void in
                switch result {
                    case .success(let response):
                        elDebugPrint(response)
                        self.saveAllCategories(responseDict: response, grocery: grocery)
                        
                    case .failure( let error):
                        self.serverErrorHandling(error)
                        
                       
                }
            }
        }
    }
    
    
    private func serverErrorHandling(_ error : ElGrocerError?) {
        
        
        DispatchQueue.main.async {
      
        if ((error?.code ?? 0) >= 500 && (error?.code ?? 0) <= 599) ||  (error?.code ?? 0) == -1011 {
            
            if let views = sdkManager.window?.subviews {
                var popUp : NotificationPopup? = nil
                for dataView in views {
                    if let popUpView = dataView as? NotificationPopup {
                        popUp = popUpView
                        break
                    }
                }
                if popUp?.titleLabel.text == localizedString("alert_error_title", comment: "") {
                    return
                }
            }
            
            let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage() , header: localizedString("alert_error_title", comment: "") , detail: localizedString("error_500", comment: ""),localizedString("btn_Go_Back", comment: "") , localizedString("lbl_retry", comment: "") , withView: sdkManager.window!) { (buttonIndex) in
                if buttonIndex == 1 {
                    self.refreshSlotChange()
                } else {
                    UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
                }
            }
        }else {
            self.fetchSubCateData()
        }
        }
    }
    
    private func saveAllCategories(responseDict : NSDictionary , grocery : Grocery?) {
        
       
        if let categoryArray = responseDict["data"] as? [NSDictionary] {
            if let groceryBgContext = DatabaseHelper.sharedInstance.getEntityWithName(GroceryEntity, entityDbId: grocery?.dbID as AnyObject, keyId: "dbID", context: DatabaseHelper.sharedInstance.mainManagedObjectContext) as? Grocery {
                Category.insertOrUpdateCategoriesForGrocery(groceryBgContext, categoriesArray: categoryArray, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                DatabaseHelper.sharedInstance.saveDatabase()
            }else{
                elDebugPrint("check here");
            }
        }
        if let updateGrocery = Grocery.getGroceryById(grocery?.dbID ?? "", context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            if var categories = updateGrocery.categories.allObjects as? [Category] {
                categories.sort { $0.sortID < $1.sortID}
                self.categories = categories
            }
        }else{
            if var categories = grocery?.categories.allObjects as? [Category] {
                categories.sort { $0.sortID < $1.sortID}
                self.categories = categories
            }
        }
        fetchSubCateData()
       
    }
    
    private func fetchSubCateData() {
        
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
        
        self.categories = grocery.categories.allObjects as! [Category]
        self.categories.sort { $0.sortID < $1.sortID}
        self.tableViewCategories.reloadData()
        
        self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
        self.basketIconOverlay?.grocery = grocery
        self.basketIconOverlay?.shouldShow = true
        self.refreshBasketIconStatus()
        self.setTableViewBottomConstraint()
        
        for (index,categories) in self.categories.enumerated() {
            self.fetchSubCategories(categories, grocery: self.grocery, index:index)
        }
        
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem = nil
       
        let isSingleStore = SDKManager.shared.launchOptions?.marketType == .grocerySingleStore
        
        if !isSingleStore {
            
            sdkManager.isShopperApp ? addWhiteBackButton() : self.addBackButton(isGreen: false)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLocationHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarDelegate(self)
             self.navigationItem.hidesBackButton = true;
        }
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
   
        if let controller = self.navigationController as? ElGrocerNavigationController {
            controller.setNavBarHidden(isSingleStore || sdkManager.isShopperApp)
            controller.setupGradient()
        }
        
        
        self.setTableViewHeader(ElGrocerUtility.sharedInstance.activeGrocery)
        
        self.refreshBasketIconStatus()
        self.setTableViewBottomConstraint()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsCategoriesScreen)
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.Category.rawValue, screenClass: String(describing: self.classForCoder))
       // self.addImages()
    }
    
    
    
    func addImages(){
        
        if let window = sdkManager.window {
            let image =  UIImage.init(named: "Store page-Main")
            let windowFrame = CGRect.init(x: 0, y: 20, width: image?.size.width ?? 360, height: image?.size.height ?? 824)
            let imageView = UIImageView(frame: windowFrame)
            imageView.image = UIImage.init(named: "Store page-Main")
            imageView.alpha = 0.4
            window.addSubview(imageView)
        }
        
    }
    
    
    func setTableViewHeader(_ optGrocery : Grocery?) {
  
        guard let grocery = optGrocery  else{
            return
        }
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
            
            if sdkManager.isShopperApp {
                self.locationHeaderShopper.configuredLocationAndGrocey(grocery)
                self.locationHeaderShopper.setSlotData()
            } else {
                sdkManager.isGrocerySingleStore
                    ? self.locationHeaderFlavor.configureHeader(grocery: grocery, location: ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress())
                    : self.locationHeader.configuredLocationAndGrocey(grocery)
            }
            
            self.tableViewCategories.tableHeaderView = nil
        })
        
  
    }
    
    
    
    func registerCellsForTableView() {
        
        self.tableViewCategories.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableViewCategories.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor

        categorySearchBar = Bundle.resource.loadNibNamed("CategorySearchBar", owner: self, options: nil)![0] as? CategorySearchBar
        categorySearchBar.delegate = self
        
        let categoryCellNib = UINib(nibName: "CategoryCell", bundle: .resource)
        self.tableViewCategories.register(categoryCellNib, forCellReuseIdentifier: kCategoryCellIdentifier)
        
        let spaceTableViewCell = UINib(nibName: "SpaceTableViewCell", bundle: .resource)
        self.tableViewCategories.register(spaceTableViewCell, forCellReuseIdentifier: "SpaceTableViewCell")
    }
    
    // MARK: UITableView Data Source Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//         return kSearchBarHeight
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return categorySearchBar
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.categories.count + 1
        if section == 0 {
            return 1
        }
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 18
        }
        return kCategoryCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell : SpaceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell", for: indexPath) as! SpaceTableViewCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kCategoryCellIdentifier) as! CategoryCell
        cell.cellIndex = indexPath.row
        cell.subCategorySelected = {[weak self](subCate , index) in
            guard let self = self else {return}
            guard subCate != nil else {return}
            self.goToSubCategory(subCate!, index: index)
        }
        cell.viewAllSelected = { (index) in
          self.goToSubCategory(nil, index: index)
        }
        
        
        let category = self.categories[indexPath.row]
        if let subCateA  =  self.subCategorycategories[indexPath.row] {
             cell.configureWithCategory(category, subCateA)
        }else{
             cell.configureWithCategory(category)
        }
        return cell
    }
    
    // MARK: UITableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedCategory = self.categories[indexPath.row]
        self.selectedIndex = indexPath.row
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
        // PushWooshTracking.addEventCategorySearchResult(self.selectedCategory, storeId: grocery.dbID)
        }
        self.performSegue(withIdentifier: "BrowseToSubCategories", sender: self)
    }
    
    
    func goToSubCategory(_ subCategory : SubCategory? , index : Int) {
        self.selectedSubCategory = subCategory
        self.selectedCategory = self.categories[index]
        self.selectedIndex = index
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            // PushWooshTracking.addEventCategorySearchResult(self.selectedCategory, storeId: grocery.dbID)
        }
        self.performSegue(withIdentifier: "BrowseToSubCategories", sender: self)
    }
    
    
    
    // MARK: Category Search bar Delegate
    func categorySearchBarActivated() {}
    
    func didTapCategorySearchBar() {
        
         // FireBaseEventsLogger.trackSearchClicked()
        
        let searchController = ElGrocerViewControllers.searchViewController()
        searchController.isNavigateToSearch = true
        searchController.navigationFromControllerName = FireBaseEventsLogger.gettopViewControllerName() ?? FireBaseScreenName.Category.rawValue
        self.navigationController?.pushViewController(searchController, animated: true)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "BrowseToSubCategories" {
            let controller = segue.destination as! SubCategoriesViewController
            controller.viewHandler = CateAndSubcategoryView()
            controller.grocery = ElGrocerUtility.sharedInstance.activeGrocery
            controller.viewHandler.setGrocery(ElGrocerUtility.sharedInstance.activeGrocery)
            controller.viewHandler.setParentCategory(self.selectedCategory)
            controller.viewHandler.setParentSubCategory(self.selectedSubCategory)
            controller.viewHandler.setLastScreenName(FireBaseScreenName.Category.rawValue)
            controller.hidesBottomBarWhenPushed = false
            (self.navigationController as? ElGrocerNavigationController)?.clearSearchBar()
        }
    }
}

extension BrowseViewController {
    
    func fetchSubCategories(_ cate : Category , grocery : Grocery? , index : Int) {
       
        guard let availableGrocery = grocery else {return}
        guard let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else {return}
        ElGrocerApi.sharedInstance.getAllCategories(currentAddress, parentCategory: cate , forGrocery: availableGrocery) { (result) -> Void in
            switch result {
                case .success(let response):
                    self.saveAllSubCategoriesFromResponse(response , index : index)
                    self.tableViewCategories.backgroundView = UIView()
                case .failure(let _):
                    self.tableViewCategories.backgroundView = UIView()
            }
        }
    }
    
    func saveAllSubCategoriesFromResponse(_ response: NSDictionary , index : Int) {
        
        let newSubCategories = SubCategory.getAllSubCategoriesFromResponse(response)
        guard newSubCategories.count > 0 else {
            SpinnerView.hideSpinnerView()
            return
        }
        self.subCategorycategories[index] = newSubCategories
        self.tableViewCategories.reloadRows(at: [(NSIndexPath.init(row: index, section: 1) as IndexPath)], with: .fade)
        
    }
    
}
extension BrowseViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        // locationHeader.myGroceryName.sizeToFit()
         scrollView.layoutIfNeeded()
         
         guard !sdkManager.isGrocerySingleStore else {
             let constraintA = self.locationHeaderFlavor.constraints.filter({$0.firstAttribute == .height})
             if constraintA.count > 0 {
                 let constraint = constraintA.count > 1 ? constraintA[1] : constraintA[0]
                 let headerViewHeightConstraint = constraint
                 let maxHeight = self.locationHeaderFlavor.headerMaxHeight
                 headerViewHeightConstraint.constant = min(max(maxHeight-scrollView.contentOffset.y,self.locationHeaderFlavor.headerMinHeight),maxHeight)
             }
             
             UIView.animate(withDuration: 0.2) {
                 self.view.layoutIfNeeded()
             }
             
             return
         }
         
        if sdkManager.isShopperApp {
            offset = scrollView.contentOffset.y
            let value = min(effectiveOffset, scrollView.contentOffset.y)
            
            self.locationHeaderShopper.searchViewTopAnchor.constant = 62 - value
            self.locationHeaderShopper.searchViewLeftAnchor.constant = 16 + ((value / 60) * 30)
            self.locationHeaderShopper.groceryBGView.alpha = max(0, 1 - (value / 60))
        } else {
            let constraintA = self.locationHeader.constraints.filter({$0.firstAttribute == .height})
            if constraintA.count > 0 {
                let constraint = constraintA.count > 1 ? constraintA[1] : constraintA[0]
                let headerViewHeightConstraint = constraint
                let maxHeight = self.locationHeader.headerMaxHeight
                headerViewHeightConstraint.constant = min(max(maxHeight-scrollView.contentOffset.y,64),maxHeight)
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                self.locationHeader.myGroceryName.alpha = scrollView.contentOffset.y < 10 ? 1 : scrollView.contentOffset.y / 100
            }
           
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
                self.locationHeader.myGroceryImage.alpha = scrollView.contentOffset.y > 40 ? 0 : 1
                self.navigationController?.navigationBar.topItem?.title = scrollView.contentOffset.y > 40 ? self.groceryTitle : ""
                sdkManager.isSmileSDK ?  (self.navigationController as? ElGrocerNavigationController)?.setSecondaryBlackTitleColor() :  (self.navigationController as? ElGrocerNavigationController)?.setWhiteTitleColor()
            }
        }
    }
    
   
}
