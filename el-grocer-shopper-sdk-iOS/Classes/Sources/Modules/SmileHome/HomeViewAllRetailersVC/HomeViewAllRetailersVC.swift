//
//  HomeViewAllRetailersVC.swift
//  Adyen
//
//  Created by Abdul Saboor on 02/03/2024.
//

import UIKit

class HomeViewAllRetailersVC: UIViewController {
    
    @IBOutlet var storeTableView: UITableView!
    
    lazy private (set) var categoryHeader : ILSegmentView = {
        let view = ILSegmentView()
        view.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        view.backgroundView?.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        view.onTap { [weak self] index in self?.subCategorySelectedWithSelectedIndex(index) }
        return view
    }()
    
    typealias tapped = (_ grocery: Grocery)-> Void
    var groceryTapped: tapped?
    
    var lastSelectType : StoreType? = nil
    var selectStoreType : StoreType? = nil
    
    var availableStoreTypeA: [StoreType] = []
    
    
    var groceryArray: [Grocery] = []
    var sortedGroceryArray: [Grocery] = []
    var filteredGroceryArray: [Grocery] = [] {
        didSet {
            sortedGroceryArray = filteredGroceryArray
                .filter{ $0.featured == 1 }
                .sorted(by: { ($0.priority ?? 0) < ($1.priority ?? 0) })
            + filteredGroceryArray
                .filter{ $0.featured != 1 }
                .sorted(by: { ($0.priority ?? 0) < ($1.priority ?? 0) })
            if storeTableView != nil {
                storeTableView.reloadDataOnMain()
            }
            
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationCustimzation()
        registerTableViewCells()
        setHeader()
        setSegmentView()
        subCategorySelectedWithSelectedIndex(0)
        fetchPreviousSelectedIndexForHomePage()
    }
    
    func setHeader() {
        categoryHeader.onTap { [weak self] index in self?.subCategorySelectedWithSelectedIndex(index) }
    }
    
    func fetchPreviousSelectedIndexForHomePage() {
        if self.selectStoreType != nil && self.availableStoreTypeA.count > 0 {
            
            let selectedIndex = availableStoreTypeA.firstIndex { StoreType in
                StoreType.storeTypeid == selectStoreType?.storeTypeid
            }
            subCategorySelectedWithSelectedIndex(selectedIndex ?? 0)
            
        }
    }
    
    private func navigationCustimzation() {
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setLeftTitle("All available stores", false)
        self.title = localizedString("", comment: "")
        self.view.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        self.hidesBottomBarWhenPushed = true
        self.navigationItem.hidesBackButton = true
        
    }


    func registerTableViewCells() {
        
        self.storeTableView.dataSource = self
        self.storeTableView.delegate = self
        self.storeTableView.separatorStyle = .none
        
        let HyperMarketGroceryTableCell = UINib(nibName: "HyperMarketGroceryTableCell" , bundle: Bundle.resource)
        self.storeTableView.register(HyperMarketGroceryTableCell, forCellReuseIdentifier: "HyperMarketGroceryTableCell" )
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func makeAvailableStoreCellListStyle(indexPath: IndexPath, grocery: Grocery) -> UITableViewCell {
        let cell = self.storeTableView.dequeueReusableCell(withIdentifier: "HyperMarketGroceryTableCell") as! HyperMarketGroceryTableCell
        if (grocery.featured?.boolValue ?? false) && (indexPath.row == 0) {
            cell.configureCell(grocery: grocery, isFeatured: true)
        }else {
            cell.configureCell(grocery: grocery, isFeatured: false)
        }
        return cell
    }
    
    private func setSegmentView() {
        
        var filterStoreTypeData : [StoreType] = []
        for data in self.groceryArray {
            let typeA = data.getStoreTypes() ?? []
            for type in typeA {
                if let obj = self.availableStoreTypeA.first(where: { typeData in
                    return type.int64Value == typeData.storeTypeid
                }) {
                    
                    if let _ = filterStoreTypeData.first(where: { type in
                        return type.storeTypeid == obj.storeTypeid
                    }) {
                        elDebugPrint("available")
                    }else {
                        filterStoreTypeData.append(obj)
                    }
                }
            }
        }
        
        self.availableStoreTypeA = filterStoreTypeData.sorted { $0.priority < $1.priority }
        
        if self.availableStoreTypeA.count > 0 {
            let data = ([ self.availableStoreTypeA.first(where: { $0.storeTypeid == 0 }) ].compactMap { $0 } + self.availableStoreTypeA).compactMap { type in
                let url = type.imageUrl ?? ""
                let colour = UIColor.colorWithHexString(hexString: type.backGroundColor)
                let text = type.name ?? ""
                return (url, colour, text)
            }
            categoryHeader.refreshWith(data)
        }
        self.storeTableView.reloadDataOnMain()
    }
    
}
extension HomeViewAllRetailersVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedGroceryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return makeAvailableStoreCellListStyle(indexPath: indexPath, grocery: sortedGroceryArray[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let groceryTapped = self.groceryTapped {
            groceryTapped(sortedGroceryArray[indexPath.row])
            SegmentAnalyticsEngine.instance.logEvent(event: StoreClickedEvent(grocery: self.sortedGroceryArray[indexPath.row], source: ScreenName.allStoreListScreen.rawValue, section: StoreComponentMarketingEnablers.All_Available_Stores))

        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && self.availableStoreTypeA.count > 0 {
            categoryHeader.addBorder(vBorder: .Bottom, color: ApplicationTheme.currentTheme.separatorColor, width: 1)
            return categoryHeader
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.availableStoreTypeA.count > 0 {
            return 88 + 16 //cellheight + top
        }
        return 0.01
    }
    
}
extension HomeViewAllRetailersVC: AWSegmentViewProtocol {
    
    func subCategorySelectedWithSelectedIndex(_ selectedSegmentIndex:Int) {
        
        
        let finalIndex = selectedSegmentIndex
        guard finalIndex < self.availableStoreTypeA.count else {return}
        
        let selectedType = self.availableStoreTypeA[finalIndex]
        
        
        let filterA = self.groceryArray.filter { grocery in
            let storeTypes = grocery.getStoreTypes() ?? []
            return storeTypes.contains { typeId in
                return typeId.int64Value == selectedType.storeTypeid
            }
        }
        self.filteredGroceryArray = filterA
        self.filteredGroceryArray = ElGrocerUtility.sharedInstance.sortGroceryArray(storeTypeA: self.filteredGroceryArray)
        // self.tableView.reloadDataOnMain()
        
        FireBaseEventsLogger.trackStoreListingOneCategoryFilter(StoreCategoryID: "\(selectedType.storeTypeid)" , StoreCategoryName: selectedType.name ?? "", lastStoreCategoryID: "\(self.lastSelectType?.storeTypeid ?? 0)", lastStoreCategoryName: self.lastSelectType?.name ?? "All Stores")
        
        // Logging segment for store category switch
        let storeCategorySwitchedEvent = StoreCategorySwitchedEvent(currentStoreCategoryType: lastSelectType, nextStoreCategoryType: selectedType)
        SegmentAnalyticsEngine.instance.logEvent(event: storeCategorySwitchedEvent)
        
        let storeCategoryClickedEvent = StoreCategoryClickedEvent(storeType: availableStoreTypeA[selectedSegmentIndex], screenName: ScreenName.allStoreListScreen.rawValue)
        
        SegmentAnalyticsEngine.instance.logEvent(event: storeCategoryClickedEvent)
        
        self.lastSelectType = selectedType
        self.storeTableView.reloadDataOnMain()
    }
    
    
}
extension HomeViewAllRetailersVC: NavigationBarProtocol {
    
    func backButtonClickedHandler() {
        self.backButtonClick()
    }
    
    override func backButtonClick() {
//        (self.navigationController as? ElGrocerNavigationController)?.navigationBar.topItem?.title = ""
        self.navigationController?.dismiss(animated: true)
    }
}
