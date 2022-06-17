//
//  HyperMarketViewController.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 31/10/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class HyperMarketViewController: UIViewController {

    @IBOutlet var tableView: UITableView!{
        didSet{
            tableView.backgroundColor = .textfieldBackgroundColor()
        }
    }
    
    lazy var searchBarHeader : GenericHyperMarketHeader = {
        let searchHeader = GenericHyperMarketHeader.loadFromNib()
        return searchHeader!
    }()
    
    var groceryArray: [Grocery] = []
    var filterGroceryA: [Grocery] = []
    var featureGroceryBanner : [BannerCampaign] = []
    var type : RetailerType?
    var controllerTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerCellsAndSetDelegates()
        setNavigationBarAppearence()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTableViewHeader()
        setNavigationBarAppearence()
        self.setFeatureGroceryBanners()
        
        //self.tabBarController?.tabBar.isHidden = false
        //hide tabbar
        hidetabbar()
    }
    
    func setNavigationBarAppearence() {
        
        if self.navigationController is ElGrocerNavigationController {
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLocationHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setNavBarHidden(false)
            (self.navigationController as? ElGrocerNavigationController)?.setWhiteTitleColor()
            
            self.navigationItem.hidesBackButton = true
            self.title = self.controllerTitle//localizedString("title_hyperMarket", comment: "")
            self.addRightCrossButton(true)
        }
    }
    
    func registerCellsAndSetDelegates(){
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        
        let HyperMarketGroceryTableCell = UINib(nibName: "HyperMarketGroceryTableCell" , bundle: Bundle.resource)
        self.tableView.register(HyperMarketGroceryTableCell, forCellReuseIdentifier: "HyperMarketGroceryTableCell" )
        
        let genericBannersCell = UINib(nibName: KGenericBannersCell, bundle: Bundle.resource)
        self.tableView.register(genericBannersCell, forCellReuseIdentifier: KGenericBannersCell)
        
    }
    
    func setTableViewHeader() {
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
    
            self.searchBarHeader.setNeedsLayout()
            self.searchBarHeader.layoutIfNeeded()
            var isNeedToShowMsgs = self.type?.getRetailerType() == .hypermarket ||  self.type?.getRetailerType() == .supermarket
            isNeedToShowMsgs = isNeedToShowMsgs && self.type?.description?.count ?? 0 > 0
            self.searchBarHeader.setInitialUI(type: isNeedToShowMsgs ? .hyperMarket : .specialityStore)
            
            if let text = self.type?.description {
              let dateA =  text.components(separatedBy: "|")
                if dateA.count == 2 {
                    self.searchBarHeader.setTextFor(firstDesc: dateA[0], secondDesc: dateA[1])
                } else {
                    self.searchBarHeader.setTextFor(firstDesc: text, secondDesc: "")
                }
            }
           // self.searchBarHeader.frame = CGRect.init(origin: CGPoint.zero, size: isNeedToShowMsgs ? CGSize.init(width: self.searchBarHeader.frame.size.width, height: 100) : CGSize.init(width: self.searchBarHeader.frame.size.width, height: 200))
            self.tableView.tableHeaderView = self.searchBarHeader
            self.tableView.layoutTableHeaderView()
            self.tableView.reloadData()
        })
    }
    
    private func setFeatureGroceryBanners() {
        
        self.filterGroceryA = self.groceryArray
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
            self.filterGroceryA.removeAll { groceryObj in
                return groceryObj.dbID == grocery.dbID
            }
        }
        
        self.featureGroceryBanner = bannerA
        if bannerA.count == 0 {
            FireBaseEventsLogger.trackNoPriorityStore()
        }
        self.tableView.reloadDataOnMain()
        
    }
    
    override func rightBackButtonClicked() {
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
       
    }
    
    func makeActiveTopGroceryOfArray() {
        
        guard let active = ElGrocerUtility.sharedInstance.activeGrocery else {
            return
        }
        let activeID = active.dbID
        if let finalIndex =  groceryArray.firstIndex(where: {  $0.dbID == activeID }) {
            groceryArray =  self.rearrange(array: groceryArray , fromIndex: finalIndex, toIndex: 0)
        }
        (self.navigationController as? ElgrocerGenericUIParentNavViewController)?.updateBadgeValue()
//        self.reloadGroceryRows(false)
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
            //let currentSelf = self;
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                if let navtabbar = appDelegate.window?.rootViewController as? UINavigationController  {
                    
                    if !(appDelegate.window?.rootViewController is ElgrocerGenericUIParentNavViewController) {
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
extension HyperMarketViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        
        return filterGroceryA.count
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
                        if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                            ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                        }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                            banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.groceryArray)
                        }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue  {
                            banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.groceryArray)
                        }else if banner.campaignType.intValue == BannerCampaignType.priority.rawValue {
                            banner.changeStoreForBanners(currentActive: nil, retailers: self.groceryArray)
                        }
                    }
                }
            }
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HyperMarketGroceryTableCell", for: indexPath) as! HyperMarketGroceryTableCell
        if filterGroceryA.count > 0 {
            cell.configureCell(grocery: filterGroceryA[indexPath.row])
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
//        let vc = ElGrocerViewControllers.getSpecialtyStoresGroceryViewController()
//        self.navigationController?.pushViewController(vc, animated: true)

        self.dismiss(animated: true) {
            if self.filterGroceryA.count > 0{
                self.goToGrocery(self.filterGroceryA[indexPath.row], nil)
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
extension HyperMarketViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let calculatedOffset = searchBarHeader.bestForViewHeightConstraint.constant + searchBarHeader.bestForViewBottomConstraint.constant
        //if scrollView.contentOffset.y > 0
        if scrollView.contentOffset.y > calculatedOffset
        {
            scrollView.layoutIfNeeded()
            if var headerFrame = tableView.tableHeaderView?.frame {
                
                headerFrame.origin.y = scrollView.contentOffset.y - calculatedOffset
                headerFrame.size.height = searchBarHeader.frame.size.height
                tableView.tableHeaderView?.frame = headerFrame
            }
        }
    }
}
