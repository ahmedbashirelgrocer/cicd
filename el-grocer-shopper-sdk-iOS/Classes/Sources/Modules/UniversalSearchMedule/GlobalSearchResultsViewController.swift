//
//  GlobalSearchResultsViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 25/01/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
var minCellHeight =  CGFloat.leastNormalMagnitude + 0.01  
class GlobalSearchResultsViewController: UIViewController {
    
   
    var dataSource : GlobalSearchResultDataSource = GlobalSearchResultDataSource()
    var presentingVC : UIViewController?
    var keyWord : String = ""
    var filterData  : Dictionary<String, Array<Product>> = [:]
    var groceryAndBannersList : [Home] = []
    var filterGroceryData  : [Grocery] = []
    var selectedGrocery  : Grocery?
    
    @IBOutlet var tableView: UITableView!
    lazy var searchBarHeader : GenericHyperMarketHeader = {
        let searchHeader = GenericHyperMarketHeader.loadFromNib()
        searchHeader?.searchBarTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        searchHeader?.txtSearchBar.text = self.keyWord
        if let clearButton = searchHeader?.txtSearchBar.value(forKeyPath: "_clearButton") as? UIButton {
                    clearButton.setImage(UIImage(name:"sCross"), for: .normal)
                }
        return searchHeader!
    }()
    @IBOutlet weak var searchBarContainerView: UIView!
    @IBOutlet weak var segmentsCollectionView: UICollectionView!
    var selectedSegment: Int?
    
    private (set) var header : SegmentHeader? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setApearance()
        self.registerTableViewObject()
        self.setDataSource()
        self.setTableViewHeader()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.presentingVC?.tabBarController?.tabBar.isHidden = false
        //hide tabbar
        self.presentingVC?.tabBarController?.tabBar.isHidden = true
        self.setSegmentView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.presentingVC?.tabBarController?.tabBar.isHidden = false
        //hide tabbar
        self.presentingVC?.tabBarController?.tabBar.isHidden = true
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = UIRectEdge.bottom
    }
   
    func setApearance() {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = true
        UIView.performWithoutAnimation {
            if let controller = self.navigationController as? ElGrocerNavigationController {
                controller.actiondelegate = self
                controller.setLogoHidden(true)
                controller.setSearchBarHidden(true)
                controller.setBackButtonHidden(false)
                controller.setChatButtonHidden(true)
                controller.setSearchBarDelegate(self)
                controller.setSearchBarText(self.keyWord)
                controller.hideSeparationLine()
                controller.setGreenBackgroundColor()
            }
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
            self.title = NSLocalizedString("search_products", comment: "")
        }

    }
    func registerTableViewObject() {
        
        self.tableView.backgroundColor = .tableViewBackgroundColor()//.white
        let genericViewTitileTableViewCell = UINib(nibName: KGenericViewTitileTableViewCell, bundle: Bundle(for: GenericViewTitileTableViewCell.self))
        self.tableView.register(genericViewTitileTableViewCell, forCellReuseIdentifier: KGenericViewTitileTableViewCell)
        
        let ElgrocerCategorySelectTableViewCell = UINib(nibName: KElgrocerCategorySelectTableViewCell , bundle: nil)
        self.tableView.register(ElgrocerCategorySelectTableViewCell, forCellReuseIdentifier: KElgrocerCategorySelectTableViewCell)
        
        let homeCellNib = UINib(nibName: "HomeCell", bundle: Bundle(for: MainCategoriesViewController.self))
        self.tableView.register(homeCellNib, forCellReuseIdentifier: kHomeCellIdentifier)
        
        let genericBannersCell = UINib(nibName: KGenericBannersCell, bundle: Bundle(for: GenericBannersCell.self))
        self.tableView.register(genericBannersCell, forCellReuseIdentifier: KGenericBannersCell)
        
        let spaceTableViewCell = UINib(nibName: "SpaceTableViewCell", bundle: Bundle(for: SpaceTableViewCell.self))
        self.tableView.register(spaceTableViewCell, forCellReuseIdentifier: "SpaceTableViewCell")
        
        
        let genricHomeRecipeTableViewCell = UINib(nibName: KGenricHomeRecipeTableViewCell , bundle: Bundle(for: GenricHomeRecipeTableViewCell.self))
        self.tableView.register(genricHomeRecipeTableViewCell, forCellReuseIdentifier: KGenricHomeRecipeTableViewCell )
        
        let genericRecipeTitleTableViewCell = UINib(nibName: "GenericRecipeTitleTableViewCell" , bundle: Bundle(for: GenricHomeRecipeTableViewCell.self))
        self.tableView.register(genericRecipeTitleTableViewCell, forCellReuseIdentifier: "GenericRecipeTitleTableViewCell" )
         
        let categoryTextOnlyCell = UINib(nibName: "CarBrandCollectionCell" , bundle:nil)
        self.segmentsCollectionView!.register(categoryTextOnlyCell, forCellWithReuseIdentifier: "CarBrandCollectionCell")
        self.segmentsCollectionView.delegate = self
        self.segmentsCollectionView.dataSource = self
    }
    func setDataSource() {
        self.dataSource.searchString = self.keyWord
        self.dataSource.startFilterProcess()
        self.dataSource.displayList = { [weak self] (filterData , homelist ,  fitlerGroceryA) in
            guard let self = self else {return}
            self.filterData = filterData
            self.filterGroceryData = fitlerGroceryA
            self.groceryAndBannersList = homelist
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.segmentsCollectionView.reloadData()
            }
        }
    }

    func setTableViewHeader() {
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
            self.searchBarHeader.setInitialUI(type: .none)
            self.searchBarHeader.setNeedsLayout()
            self.searchBarHeader.layoutIfNeeded()
            //self.view.addSubview(self.searchBarHeader)
            self.searchBarContainerView.addSubview(self.searchBarHeader)
            self.searchBarHeader.translatesAutoresizingMaskIntoConstraints = false
            let heightConstraint = NSLayoutConstraint(item: self.searchBarHeader, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 90)
            let weidthConstraint = NSLayoutConstraint(item: self.searchBarHeader, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: ScreenSize.SCREEN_WIDTH)
            self.view.addConstraints([heightConstraint,weidthConstraint])
            self.searchBarHeader.setNeedsLayout()
            self.searchBarHeader.layoutIfNeeded()
            //self.searchBarContainerView.isHidden = false
        })
    }
    
    func setSegmentView() {
        /*
        var segmentArray = [NSLocalizedString("all_store", comment: "")]
        var filterStoreTypeData : [StoreType] = []
        for data in self.filterGroceryData {
            let typeA = data.storeType
            for type in typeA {
                if let obj = self.availableStoreTypeA.first(where: { typeData in
                    return type.int64Value == typeData.storeTypeid
                }) {
                    
                    if let _ = filterStoreTypeData.first(where: { type in
                        return type.storeTypeid == obj.storeTypeid
                    }) {
                        debugPrint("available")
                    }else {
                        filterStoreTypeData.append(obj)
                    }
                }
            }
        }
        filterStoreTypeData = filterStoreTypeData.sorted(by: { typeOne, typeTwo in
            return typeOne.priority < typeTwo.priority
        })
        
        for type in filterStoreTypeData {
            segmentArray.append(type.name ?? "")
        }
      
        self.availableStoreTypeA = filterStoreTypeData
        
        if self.availableStoreTypeA.count > 0 {
          
            header = (Bundle.resource.loadNibNamed("SegmentHeader", owner: self, options: nil)![0] as? SegmentHeader)!
            header?.segmentView.commonInit()
            header?.segmentView.backgroundColor = .textfieldBackgroundColor()
            header?.backgroundColor = .textfieldBackgroundColor()
            header?.segmentView.refreshWith(dataA: segmentArray)
            header?.segmentView.segmentDelegate = self
         // Fix: require fixing here for arabic to english conversion
            
        }
        
        
     
        
        self.filteredGroceryArray = self.groceryArray
        self.tableView.reloadDataOnMain()
        
        
        if self.controllerType == .ShopByCategory && self.selectStoreType != nil {
            if let indexOfType = self.availableStoreTypeA.firstIndex(where: { type in
                type.storeTypeid == self.selectStoreType?.storeTypeid
            }){
                let finalIndex = indexOfType + 1
                self.subCategorySelectedWithSelectedIndex(indexOfType + 1)
                header?.segmentView.lastSelection = IndexPath(row: finalIndex, section: 0)
                header?.segmentView.reloadData()
                
                ElGrocerUtility.sharedInstance.delay(0.2) {
                    if let index = self.header?.segmentView.lastSelection {
                        self.header?.segmentView.scrollToItem(at: index, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
                    }
                }
            }
            
        }
        */
        
    }
    
    fileprivate func handelSegmentSelected(index:Int)
    {
        if index==0 {
            self.selectedGrocery = nil
            selectedSegment = nil
        } else {
            self.selectedGrocery = filterGroceryData[index-1]// selectedGrocery
            selectedSegment = index-1
        }
        
        if self.selectedGrocery == nil {
            self.groceryAndBannersList = self.dataSource.groceryAndBannersList
        }else{
            let filetA =  self.dataSource.groceryAndBannersList.filter { (home) -> Bool in
                return home.attachGrocery?.dbID == self.selectedGrocery?.dbID
            }
            self.groceryAndBannersList = filetA
        }
        self.tableView.reloadData()
        self.segmentsCollectionView.reloadData()
    }
    
}

extension GlobalSearchResultsViewController : NavigationBarProtocol , NavigationBarSearchProtocol {
    
    func backButtonClickedHandler() {
        self.navigationController?.dismiss(animated: false, completion: {
            self.presentingVC?.tabBarController?.selectedIndex = 2
            self.presentingVC?.tabBarController?.selectedIndex = 0
        })
  
    }
    

    
    func navigationBarSearchTapped() {
        GenericClass.print("")
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    func navigationBarSearchViewDidChangeText(_ navigationBarSearch: NavigationBarSearchView, searchString: String) {
        GenericClass.print("")
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: false)
    }
    func navigationBarSearchViewDidChangeCharIn(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) {
        GenericClass.print("")
    }
  
}

extension GlobalSearchResultsViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /*
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 40
            }
            if indexPath.row == 1 {
                if self.groceryAndBannersList.count > 0 {
                    let final =  singleTypeRowHeight
                    return CGFloat(final)
                }else {
                    return .leastNormalMagnitude + 0.01
                }
              
            }
        }*/
        
        if indexPath.section == 2 {
            return 40
        }
        
        
        if indexPath.row < self.groceryAndBannersList.count {
            let homeFeed = self.groceryAndBannersList[indexPath.row]
            if homeFeed.type == .Banner {
                let rowHeight =  (ScreenSize.SCREEN_WIDTH/KBannerRation) + 20
                return rowHeight
            }
        }else if indexPath.row == self.groceryAndBannersList.count {
            return self.dataSource.recipeList?.count ?? 0 > 0 ?  50  : minCellHeight
        }else if indexPath.row == self.groceryAndBannersList.count + 1{
            let final =  ((ScreenSize.SCREEN_WIDTH*0.665 - 32))
            return self.dataSource.recipeList?.count ?? 0 > 0 ?  final + 23  : minCellHeight
        }
      
        return kHomeCellHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1//2//3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if section == 0 {
//            return 2
//        }
        if section == 1 {
            return 1
        }
        
        var isRecipeAvailable = false
        if self.dataSource.recipeList?.count ?? 0 > 0 {
            isRecipeAvailable = true
        }
        
        return self.groceryAndBannersList.count + (isRecipeAvailable ? 2 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            let cell : SpaceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell", for: indexPath) as! SpaceTableViewCell
            return cell
        }
        /*
         // disbaled in favour of UI 2.0
        else if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell : GenericViewTitileTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell ) as! GenericViewTitileTableViewCell
                cell.configureCell(title: "")
                let searchWord = " \"" + "\(self.keyWord)" + " \""
                let title = "\(NSLocalizedString("lbl_Stores_that_sell", comment: ""))" + searchWord
                let attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(20) , NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()])
                let nsRange = NSString(string: title).range(of: searchWord , options: String.CompareOptions.caseInsensitive)
                if nsRange.location != NSNotFound {
                    attributedString.addAttribute(NSAttributedString.Key.font , value: UIFont.SFProDisplayBoldFont(20) , range: nsRange )
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor , value: UIColor.navigationBarColor() , range: nsRange )
                }
                cell.lblTopHeader.attributedText =  attributedString
                return cell
            }else if indexPath.row == 1 {
                let cell : ElgrocerCategorySelectTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "ElgrocerCategorySelectTableViewCell") as! ElgrocerCategorySelectTableViewCell
                cell.configuredData(groceryList: self.filterGroceryData, selectedGrocery: self.selectedGrocery)
                cell.selectedGrocery  = { [weak self] (selectedGrocery) in
                    guard let self = self else {return}
                    self.selectedGrocery = selectedGrocery
                    if self.selectedGrocery == nil {
                        self.groceryAndBannersList = self.dataSource.groceryAndBannersList
                    }else{
                        let filetA =  self.dataSource.groceryAndBannersList.filter { (home) -> Bool in
                            return home.attachGrocery?.dbID == self.selectedGrocery?.dbID
                        }
                        self.groceryAndBannersList = filetA
                    }
                    self.tableView.reloadData()
                }
                return cell
            }
        }*/
        
        
        if indexPath.row < self.groceryAndBannersList.count {
            let homeFeed = self.groceryAndBannersList[indexPath.row]
            if homeFeed.type == .Banner {
                let cell : GenericBannersCell = tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell") as! GenericBannersCell
                cell.configured(homeFeed.banners)
                cell.bannerList.bannerCliked = { [weak self] (bannerLink) in
                    guard let self = self  else {   return   }
                  //  self.clickOnBanner(bannerLink.bannerLinks[0], grocery: homeFeed.attachGrocery, homeFeed: homeFeed)
                }
                
                cell.bannerList.bannerCampaignClicked =  { [weak self] (banner) in
                    guard let self = self  else {   return   }
                    if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                        ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                    }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                        // self.showWebUrl(banner.url)
                        banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: ElGrocerUtility.sharedInstance.groceries)
                    }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue ||  banner.campaignType.intValue == BannerCampaignType.priority.rawValue {
                        banner.changeStoreForBanners(currentActive: nil, retailers: ElGrocerUtility.sharedInstance.groceries)
                    }
                }
                
                return cell
            }
            let homeCell = tableView.dequeueReusableCell(withIdentifier: kHomeCellIdentifier) as! HomeCell
            homeCell.configureCell(homeFeed, grocery: homeFeed.attachGrocery)
            homeCell.delegate = self
            homeCell.backgroundColor = .tableViewBackgroundColor()
            return homeCell
            
        }
        
        if indexPath.row == self.groceryAndBannersList.count  {
            let cell : GenericRecipeTitleTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "GenericRecipeTitleTableViewCell" ) as! GenericRecipeTitleTableViewCell
            cell.configureForRecipe()
            cell.viewAllAction = { [weak self] in
                guard let self = self else {
                    return
                }
                let recipeStory = ElGrocerViewControllers.recipesBoutiqueListVC()
                recipeStory.isNeedToShowCrossIcon = true
                recipeStory.groceryA = ElGrocerUtility.sharedInstance.groceries
                recipeStory.searchString = self.keyWord
                
                let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                navigationController.viewControllers = [recipeStory]
                navigationController.modalPresentationStyle = .fullScreen
                self.navigationController?.present(navigationController, animated: true, completion: { });
                
            }
            return cell
        }

        if indexPath.row == self.groceryAndBannersList.count + 1 {
            let cell : GenricHomeRecipeTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenricHomeRecipeTableViewCell ) as! GenricHomeRecipeTableViewCell
            if let recipeA = self.dataSource.recipeList {
                cell.configureData(recipeA, isMiniView: true, withGrayBg: true)
            }
            return cell
        }
        let cell : GenericViewTitileTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell ) as! GenericViewTitileTableViewCell
        cell.configureCell(title: "")
        return cell
    }
    
    
    
}

extension GlobalSearchResultsViewController : HomeCellDelegate  {
    
    
    func productCellOnProductQuickRemoveButtonClick(_ selectedProduct: Product, homeObj: Home, collectionVeiw: UICollectionView) {}
    func productCellChooseReplacementButtonClick(_ product: Product) { }
    func navigateToProductsView(_ homeObj: Home) { }
    
    
    
    func clickOnBanner (_ banner : BannerLink ,  grocery: Grocery? , homeFeed: Home?) {
        ElGrocerUtility.sharedInstance.clickedBannerUniversalSearch = banner
        self.navigateToGrocery(grocery, homeFeed: homeFeed)
    }

    func navigateToGrocery(_ grocery: Grocery? , homeFeed: Home? ) {
        
       
                
        GenericClass.print("slectgrocer : \(String(describing: grocery?.name)) ")
        ElGrocerEventsLogger.sharedInstance.trackScreenNav([FireBaseParmName.CurrentScreen.rawValue : UIApplication.gettopViewControllerName() ?? "" , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Home.rawValue , "isForUniversalSearch" : "1" , "lastStoreID" : ElGrocerUtility.sharedInstance.activeGrocery?.dbID ?? "" , FireBaseParmName.SearchTerm.rawValue : self.keyWord ])
        
        
        func goToMain (_ grocery : Grocery) {
            SpinnerView.hideSpinnerView()
            ElGrocerUtility.sharedInstance.activeGrocery = grocery
            ElGrocerUtility.sharedInstance.isCommingFromUniversalSearch = true
            ElGrocerUtility.sharedInstance.searchFromUniversalSearch = homeFeed
            ElGrocerUtility.sharedInstance.searchString = self.keyWord
            self.navigationController?.dismiss(animated: false, completion: {
                if let tabbar = self.presentingVC?.tabBarController {
                    if  let navMain  = tabbar.viewControllers?[1] as? UINavigationController  {
                        if navMain.viewControllers.count > 0 {
                            if let mainVC =   navMain.viewControllers[0] as? MainCategoriesViewController {
                                mainVC.navigationController?.popToRootViewController(animated: false)
                            }
                        }
                    }
                }
                self.presentingVC?.tabBarController?.selectedIndex = 1
            })
        }
    
        func processDataForDeliveryMode() {
            let groceryID = ElGrocerUtility.sharedInstance.cleanGroceryID(grocery?.dbID)
            let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()
            ElGrocerApi.sharedInstance.getGroceryDetail(groceryID, lat: "\(address?.latitude ?? -1)", lng: "\(address?.longitude ?? -1)")  { (result) in
                switch result {
                    case .success(let responseObject):
                        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                        if  let groceryDict = responseObject["data"] as? NSDictionary {
                            if groceryDict.allKeys.count > 0 {
                                    let grocery =  Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)[0]
                                    goToMain(grocery)
                                }
                        }
                    case .failure(let error):
                        SpinnerView.hideSpinnerView()
                        error.showErrorAlert()
                }
            }
        }
        func processDataForCandCMode() {
            ElGrocerApi.sharedInstance.getcAndcRetailerDetail(nil, lng: nil , dbID: grocery?.dbID ?? "" , parentID: nil) { (result) in
                switch result {
                    case .success(let responseObject):
                        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                        if  let groceryDict = responseObject["data"] as? NSDictionary {
                           // if let groceryDict = response["retailers"] as? [NSDictionary] {
                                if groceryDict.count > 0 {
                                    let grocery =  Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)[0]
                                    goToMain(grocery)
                                }
                           // }
                        }
                    case .failure(let error):
                        SpinnerView.hideSpinnerView()
                        error.showErrorAlert()
                }
            }
        }
        
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        
        if ElGrocerUtility.sharedInstance.isDeliveryMode {
            processDataForDeliveryMode()
        }else{
            processDataForCandCMode()
        }
   
    }
    
    func productCellOnProductQuickAddButtonClick(_ selectedProduct: Product, homeObj: Home, collectionVeiw: UICollectionView) {
        GenericClass.print(selectedProduct.name ?? "")
        self.navigateToGrocery(homeObj.attachGrocery , homeFeed: homeObj)
    }
    
}



extension GlobalSearchResultsViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterGroceryData.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let storeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarBrandCollectionCell" , for: indexPath) as! CarBrandCollectionCell

        storeCell.setDesSelected()
        
        if indexPath.item == 0 {
            storeCell.lblBrandName.text = "All stores" // TODO: localization
            if self.selectedSegment == nil {
                storeCell.setSelected()
            }
            return storeCell
        }

        let store = self.filterGroceryData[indexPath.row-1]
        storeCell.setValues(title: store.name ?? "none")
        if let selectedIndex = self.selectedSegment {
            let selectedStore = filterGroceryData[selectedIndex]
            if store.dbID == String(selectedStore.dbID) {
                storeCell.setSelected()
            }
        }

        return storeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.handelSegmentSelected(index: indexPath.row)
    }
    
}
extension GlobalSearchResultsViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.row == 0 {
            let itemSize = "All stores".size(withAttributes: [
                NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(15)
            ])
            return CGSize(width: itemSize.width+32, height: 52)
        }
        let item = self.filterGroceryData[indexPath.row-1]
        let itemSize = item.name!.size(withAttributes: [
            NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(15)
        ])
        var size = itemSize.width + 32
        if size < 50 {
            size = 50
        }
        return CGSize(width: size  , height: 52)
        
    }
        
}
