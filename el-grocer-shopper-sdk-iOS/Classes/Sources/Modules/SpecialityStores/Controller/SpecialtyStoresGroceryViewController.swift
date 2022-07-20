//
//  SpecialtyStoresGroceryTableCellViewController.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 31/10/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

enum SpecialtyStoresGroceryViewControllerType : Int {
    case specialty = 0
    case viewAllStores = 1
    case miniMarket = 2
    case viewAllStoresWithBack = 3
    case viewAllStoreCategories = 4
}

class SpecialtyStoresGroceryViewController: UIViewController {

    @IBOutlet var tableView: UITableView!{
        didSet{
            tableView.backgroundColor = .textfieldBackgroundColor()
        }
    }
    
    @IBOutlet var tableViewTopConstraint: NSLayoutConstraint!
    lazy var searchBarHeader : GenericHyperMarketHeader = {
        let searchHeader = GenericHyperMarketHeader.loadFromNib()
        return searchHeader!
    }()
    private (set) var header : SegmentHeader? = nil
    
    
    var controllerType : SpecialtyStoresGroceryViewControllerType = .specialty
    var groceryArray: [Grocery] = []
    var filteredGroceryArray: [Grocery] = []
    var availableStoreTypeA: [StoreType] = []
    var featureGroceryBanner : [BannerCampaign] = []
    var lastSelectType : StoreType? = nil
    var controllerTitle: String = ""
    var selectStoreType : StoreType? = nil
    var retailerType: RetailerType? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerCellsAndSetDelegates()
        setTableViewHeader()
       
        setNavigationBarAppearence()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarAppearence()
        
        self.groceryArray = ElGrocerUtility.sharedInstance.makeFilterOneSlotBasis(storeTypeA: self.groceryArray)
        self.makeActiveTopGroceryOfArray()
        self.setFeatureGroceryBanners()
        self.setSegmentView()
    }
    
    func setNavigationBarAppearence() {
        
        self.view.backgroundColor = .textfieldBackgroundColor()
        self.navigationItem.hidesBackButton = true
        //self.tabBarController?.tabBar.isHidden = false
        //hide tabbar
        hidetabbar()
        
        if self.controllerType == .viewAllStores {
            self.title = localizedString("title_all_stores", comment: "")
            //self.addBackButton(isGreen: false)
        }else if self.controllerType == .viewAllStoresWithBack {
            self.title = localizedString("txt_Shop_by_store_category", comment: "")
            self.addBackButton(isGreen: false)
        }else {
            self.title = self.controllerTitle
        }
        
        self.addRightCrossButton(true)
        
        if let controller = self.navigationController as? ElGrocerNavigationController {
            
            controller.setLogoHidden(true)
            controller.setGreenBackgroundColor()
            controller.setBackButtonHidden(true)
            controller.setLocationHidden(true)
            controller.setChatButtonHidden(true)
            controller.setNavBarHidden(false)
            controller.setWhiteTitleColor()
        }
    }
    override func backButtonClick(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func registerCellsAndSetDelegates() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        
        
        let SpecialtyStoresGroceryTableCell = UINib(nibName: "SpecialtyStoresGroceryTableCell" , bundle: Bundle.resource)
        self.tableView.register(SpecialtyStoresGroceryTableCell, forCellReuseIdentifier: "SpecialtyStoresGroceryTableCell" )
        
        let HyperMarketGroceryTableCell = UINib(nibName: "HyperMarketGroceryTableCell" , bundle: Bundle.resource)
        self.tableView.register(HyperMarketGroceryTableCell, forCellReuseIdentifier: "HyperMarketGroceryTableCell" )
        
        
        let genericBannersCell = UINib(nibName: KGenericBannersCell, bundle: Bundle.resource)
        self.tableView.register(genericBannersCell, forCellReuseIdentifier: KGenericBannersCell)
    }
    
    func setSegmentView() {
        
       
        var segmentArray = [localizedString("all_store", comment: "")]
        var filterStoreTypeData : [StoreType] = []
        for data in self.groceryArray {
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
            
        }
        
        
     
        
        self.filteredGroceryArray = self.groceryArray
        self.tableView.reloadDataOnMain()
        
        
        if self.controllerType == .viewAllStores && self.selectStoreType != nil {
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
        
        
    }
    
    func setTableViewHeader() {
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
            self.searchBarHeader.setInitialUI(type: .specialityStore)
            self.searchBarHeader.setNeedsLayout()
            self.searchBarHeader.layoutIfNeeded()
            self.view.addSubview(self.searchBarHeader)
            self.searchBarHeader.translatesAutoresizingMaskIntoConstraints = false
            let heightConstraint = NSLayoutConstraint(item: self.searchBarHeader, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 90)
            let weidthConstraint = NSLayoutConstraint(item: self.searchBarHeader, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: ScreenSize.SCREEN_WIDTH)
            self.view.addConstraints([heightConstraint,weidthConstraint])
            self.searchBarHeader.retailerType = self.retailerType
            self.searchBarHeader.setNeedsLayout()
            self.searchBarHeader.layoutIfNeeded()
            self.tableViewTopConstraint.constant = self.searchBarHeader.frame.size.height
        })
    }
    
    override func rightBackButtonClicked() {
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
        if self.retailerType?.getRetailerType() == GroceryRetailerMarketType.speciality || self.retailerType?.getRetailerType() == GroceryRetailerMarketType.supermarket{
            MixpanelEventLogger.trackStoreListingClose(storeListCategoryId: "\(self.retailerType?.dbId ?? -1)" , storeListCategoryName: self.retailerType?.getRetailerName() ?? "")
        }
        /*
        if  self.navigationController?.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }else{
             self.navigationController?.popViewController(animated: true)
        }*/
        //self.dismiss(animated: true)
    }
    
    func makeActiveTopGroceryOfArray() {
        
        guard let active = ElGrocerUtility.sharedInstance.activeGrocery else {
            return
        }
        let activeID = active.dbID
        if let finalIndex =  groceryArray.firstIndex(where: {  $0.dbID == activeID }) {
            groceryArray =  self.rearrange(array: groceryArray, fromIndex: finalIndex, toIndex: 0)
        }
        (self.navigationController as? ElgrocerGenericUIParentNavViewController)?.updateBadgeValue()
        self.tableView.reloadData()
    }
    
    
    func goToGrocery (_ grocery : Grocery , _ bannerLink : BannerLink?) {
        
        UserDefaults.setCurrentSelectedDeliverySlotId(0)
        UserDefaults.setPromoCodeValue(nil)
        
        if (grocery.isOpen.boolValue && Int(grocery.deliveryTypeId!) != 1) || (grocery.isSchedule.boolValue && Int(grocery.deliveryTypeId!) != 0){
            let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if currentAddress != nil  {
                UserDefaults.setGroceryId(grocery.dbID , WithLocationId: (currentAddress?.dbID)!)
            }
        }
        ElGrocerUtility.sharedInstance.activeGrocery = grocery
        if ElGrocerUtility.sharedInstance.groceries.count == 0 {
//            ElGrocerUtility.sharedInstance.groceries = self.homeDataHandler.groceryA ?? []
        }
        self.makeActiveTopGroceryOfArray()
        if let retailerType = retailerType {
            MixpanelEventLogger.trackStoreListingStoreSelected(storeListCategoryId: "\(retailerType.dbId ?? -1)", storeListCategoryName: retailerType.getRetailerName() ?? "", storeId: grocery.dbID, storeName: grocery.name ?? "")
        }
            //let currentSelf = self;
        DispatchQueue.main.async {
            // if let SDKManager = SDKManager.shared {
                if let navtabbar = SDKManager.shared.rootViewController as? UINavigationController  {
                    
                    if !(SDKManager.shared.rootViewController is ElgrocerGenericUIParentNavViewController) {
                        if let tabbar = navtabbar.viewControllers[0] as? UITabBarController {
                            ElGrocerUtility.sharedInstance.activeGrocery = grocery
                            if ElGrocerUtility.sharedInstance.groceries.count == 0 {
//                                ElGrocerUtility.sharedInstance.groceries = self.homeDataHandler.groceryA ?? []
                            }
                            if ((tabbar.viewControllers?[1] as? UINavigationController) != nil) {
                                let nav = tabbar.viewControllers?[1] as! UINavigationController
                                nav.popToRootViewController(animated: false)
                            }
                            if ((tabbar.viewControllers?[2] as? UINavigationController) != nil) {
                                let nav = tabbar.viewControllers?[2] as! UINavigationController
                                nav.popToRootViewController(animated: false)
                            }
                            if ((tabbar.viewControllers?[3] as? UINavigationController) != nil) {
                                let nav = tabbar.viewControllers?[3] as! UINavigationController
                                nav.popToRootViewController(animated: false)
                            }
                            if ((tabbar.viewControllers?[4] as? UINavigationController) != nil) {
                                let nav = tabbar.viewControllers?[4] as! UINavigationController
                                nav.popToRootViewController(animated: false)
                            }
                            tabbar.selectedIndex = 1
                            
                            if  let navMain  = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController  {
                                if navMain.viewControllers.count > 0 {
                                    if let _ =   navMain.viewControllers[0] as? MainCategoriesViewController {
                                        ElGrocerUtility.sharedInstance.activeGrocery = grocery
                                        if ElGrocerUtility.sharedInstance.groceries.count == 0 {
//                                            ElGrocerUtility.sharedInstance.groceries = self.homeDataHandler.groceryA ?? []
                                        }
                                        return
                                    }
                                }
                            }
                            
                        }
                    }
                }else{
                        // debugPrint(self.grocerA[12312321])
                    FireBaseEventsLogger.trackCustomEvent(eventType: "Error", action: "generic grocery controller found failed.Force crash")
                }
            // }
        }
    }
    
    private func setFeatureGroceryBanners() {
        
     
      let featureGroceries =  self.groceryArray.filter { grocery in
            return grocery.featured?.boolValue ?? false
        }
        var bannerA : [BannerCampaign] = []
        for grocery in featureGroceries {
            let campaign = BannerCampaign.init()
            campaign.imageUrl = grocery.featureImageUrl  ?? ""
            if let groceryID = Int(grocery.getCleanGroceryID()) {
                if groceryID > 0 {
                    campaign.retailerIds = [groceryID]
                    campaign.campaignType = NSNumber.init(integerLiteral: BannerCampaignType.priority.rawValue)
                }
            }
            bannerA.append(campaign)
            self.groceryArray.removeAll { groceryObj in
                return groceryObj.dbID == grocery.dbID
            }
        }
        
        self.featureGroceryBanner = bannerA
        
        if bannerA.count == 0 {
            FireBaseEventsLogger.trackNoPriorityStore()
        }
        self.tableView.reloadDataOnMain()
    
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
extension SpecialtyStoresGroceryViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return self.availableStoreTypeA.count > 0 ?  45 : 0.01
        }
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return self.availableStoreTypeA.count > 0 ? header : nil
        }
        return nil
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        return filteredGroceryArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell : GenericBannersCell = self.tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
            cell.contentView.backgroundColor = .clear
            cell.bgView.backgroundColor = .clear
            cell.bannerList.backgroundColor = .clear
            cell.bannerList.collectionView?.backgroundColor = .clear
            cell.configured(self.featureGroceryBanner)
            cell.bannerList.bannerCampaignClicked = { [weak self] (banner) in
                guard let self = self  else {   return   }
                Thread.OnMainThread {
                    self.dismiss(animated: true) {
                        let totalStoreA = HomePageData.shared.groceryA ?? self.groceryArray
                        if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                            ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                        }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                            banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: totalStoreA)
                        }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue  {
                            banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: totalStoreA)
                        }else if banner.campaignType.intValue == BannerCampaignType.priority.rawValue {
                            banner.changeStoreForBanners(currentActive: nil, retailers: totalStoreA)
                        }
                    }
                }
                
            }
            return cell
        }
        
        if self.controllerType == .specialty {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpecialtyStoresGroceryTableCell", for: indexPath) as! SpecialtyStoresGroceryTableCell
            if filteredGroceryArray.count > 0 {
                cell.configureCell(grocery: filteredGroceryArray[indexPath.row])
            }
            return cell
            
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HyperMarketGroceryTableCell", for: indexPath) as! HyperMarketGroceryTableCell
            if filteredGroceryArray.count > 0 {
                cell.configureCell(grocery: filteredGroceryArray[indexPath.row])
            }
            return cell
            
        }
        
          
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
//        let vc = ElGrocerViewControllers.getShopByCategoriesViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
        self.dismiss(animated: true) {
            if self.filteredGroceryArray.count > 0{
                self.goToGrocery(self.filteredGroceryArray[indexPath.row], nil)
            }
        }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.featureGroceryBanner.count > 0 ? ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner() : minCellHeight
        }
        return UITableView.automaticDimension
    }
}



extension SpecialtyStoresGroceryViewController: AWSegmentViewProtocol {
    
    func subCategorySelectedWithSelectedIndex(_ selectedSegmentIndex:Int) {
        
        debugPrint(selectedSegmentIndex)
        
       
        
       
        
        guard selectedSegmentIndex > 0 else {
            if let retailerType = self.retailerType {
                MixpanelEventLogger.trackStoreListingCategoryFilter(storeListCategoryId: "\(retailerType.dbId)", storeListCategoryName: retailerType.getRetailerName(), selectedCatId: "-1", selectedCatName: "All Stores")
            }
            self.filteredGroceryArray = self.groceryArray
            self.tableView.reloadDataOnMain()
            return
        }
        
        
        let finalIndex = selectedSegmentIndex - 1
        guard finalIndex < self.availableStoreTypeA.count else {return}
        
        let selectedType = self.availableStoreTypeA[finalIndex]

        
        let filterA = self.groceryArray.filter { grocery in
            return grocery.storeType.contains { typeId in
                return typeId.int64Value == selectedType.storeTypeid
            }
        }
        self.filteredGroceryArray = filterA
        self.tableView.reloadDataOnMain()
        
        FireBaseEventsLogger.trackStoreListingOneCategoryFilter(StoreCategoryID: "\(selectedType.storeTypeid)" , StoreCategoryName: selectedType.name ?? "", lastStoreCategoryID: "\(self.lastSelectType?.storeTypeid ?? 0)", lastStoreCategoryName: self.lastSelectType?.name ?? "All Stores")
        if let retailerType = self.retailerType {
            MixpanelEventLogger.trackStoreListingCategoryFilter(storeListCategoryId: "\(retailerType.dbId)", storeListCategoryName: retailerType.getRetailerName(), selectedCatId: "\(selectedType.storeTypeid)", selectedCatName: selectedType.name ?? "")
        }
        self.lastSelectType = selectedType
        
    }

    
}
