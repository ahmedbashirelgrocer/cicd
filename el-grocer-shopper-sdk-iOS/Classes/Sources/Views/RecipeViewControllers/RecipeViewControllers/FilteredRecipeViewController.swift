//
//  FilteredRecipeViewController.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 03/05/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import JDFTooltips
import Storyly
import BBBadgeBarButtonItem

class FilteredRecipeViewController: BasketBasicViewController, NoStoreViewDelegate {
    
    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet var categoryListView: RecipeCategoriesList!
    lazy var toolTipView:JDFTooltipView?=nil
    lazy var dataHandler : RecipeDataHandler = {
        let dataH = RecipeDataHandler()
        dataH.delegate = self
        return dataH
    }()
    lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.delegate = self
        noStoreView?.configureNoSavedRecipe()
        return noStoreView!
    }()
    var storlyCellHeight : CGFloat = 0.0
    var isCellLoaded = false
    func noDataButtonDelegateClick(_ state: actionState) {
        //self.tabBarController?.selectedIndex = 0
        print("show recipe boutique")
        //
//        ElGrocerEventsLogger.sharedInstance.trackRecipeViewAllClickedFromNewGeneric()
//        if ElGrocerUtility.sharedInstance.activeGrocery != nil {
//            self.goToRecipe(ElGrocerUtility.sharedInstance.activeGrocery!)
//        }else if ElGrocerUtility.sharedInstance.groceries.count > 0 {
//            self.goToRecipe(nil)
//        }
    }
    
    
    lazy var vcTitile : String = ""
    private  var isLoadedFirstTime : Bool = false
    let privateWorkQueue : DispatchQueue = DispatchQueue(label: "privateWorkQueue")
    private (set) var recipCartList : [RecipeCart]?=nil
    private var emtpyTitle : String = ""
    private var emtpyDescription : String = ""
    
    var recipeListArray = [Recipe]()
    var groceryA = [Grocery]()
    var selectedCategroyId : Int64 = -1
    var chef = CHEF()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setUpApearance()
        self.initailCellRegistration()
        self.categoryListView.getCategoryData(savedCategories: false)
        self.addClosure()
        //self.checkStolryStory()
    }
    
    
    
    func setUpApearance(){
        
        self.title = self.vcTitile
        self.navigationItem.hidesBackButton = true

        if self.navigationController is ElGrocerNavigationController {
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
            /*(self.navigationController as? ElGrocerNavigationController)?.setLocationHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setWhiteTitleColor()
        }
        
        self.navigationController?.navigationBar.isHidden = false
        self.view.backgroundColor = UIColor.white*/
            (self.navigationController as? ElGrocerNavigationController)?.setNavBarHidden(false)
        }
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarColor()
        self.navigationController?.navigationBar.backgroundColor = .navigationBarColor()
        self.view.backgroundColor = .navigationBarWhiteColor()
    }
    
    func initailCellRegistration() {
        
        self.tableView.register(UINib(nibName: "chefDescriptionCell", bundle: nil), forCellReuseIdentifier: "chefDescriptionCell")
        self.tableView.register(UINib(nibName: KGenericViewTitileTableViewCell, bundle: nil), forCellReuseIdentifier: KGenericViewTitileTableViewCell)
        
        
        self.tableView.register(UINib(nibName: KStorlyTableViewCell, bundle: nil), forCellReuseIdentifier: KStorlyTableViewCell)
        
        let recipeListCell = UINib(nibName: KRecipeTableViewCellIdentifier, bundle: Bundle(for: RecipeTableViewCell.self))
        self.tableView.register(recipeListCell, forCellReuseIdentifier: KRecipeTableViewCellIdentifier )
        self.tableView.backgroundColor = .tableViewBackgroundColor() //.navigationBarWhiteColor()
        self.tableView.estimatedRowHeight = CGFloat(KRecipeTableViewCellHeight)
        self.tableView.separatorStyle = .none
        
        
    }
    
    
   
    
    override func backButtonClickedHandler() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func backButtonClick() {
//        self.setOldNavSetting()
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
//        self.setOldNavSetting()
    }
    fileprivate func setOldNavSetting(){
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
            self.navigationController?.navigationBar.isTranslucent = false
        }
        
    }
    
    func setProductNumber(){
        
        self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
        self.basketIconOverlay?.grocery = self.grocery
        self.refreshBasketIconStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.setProductNumber()
        self.setUpApearance()
        
        if !isLoadedFirstTime {
            isLoadedFirstTime = true
            self.getRecipeData(catId: nil)
        }
        categoryListView.superview?.clipsToBounds = true
        categoryListView.superview?.layer.cornerRadius = 18
        categoryListView.superview?.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let chef_name = self.dataHandler.selectChef?.chefName {
            let screenName =  "Chef " + chef_name
            FireBaseEventsLogger.setScreenName(screenName, screenClass: String(describing: self.classForCoder))
        }
       
    }
    
    func addClosure(){
        self.categoryListView.recipeCategorySelected = {[weak self] (selectedCategory) in
            guard let self = self else {return}
            //            self.dataHandler.setFilterRecipeCategory(selectedCategory)
            //            self.getFilteredData(isNeedToReset: true)
            guard selectedCategory != nil else {
                return
            }
            if let id = selectedCategory?.categoryID{
                self.selectedCategroyId = id
            }
            self.getRecipeData(catId: selectedCategory?.categoryID)
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refreshRecipeFromNotifcation(_:)), name: Notification.Name(rawValue: "SaveRefresh") , object: nil)
        
       /* NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "SaveRefresh"), object: self, queue: OperationQueue.main, using: { notification in
            let recipeId = notification.object
            if recipeId is Int64 {
             let filterA  =  self.recipeListArray.filter { (rec) -> Bool in
                return rec.recipeID == recipeId as? Int64
                }
                if filterA.count > 0 {
                    var selected = filterA[0]
                    selected.isSaved = true
                    
                    if let index = self.recipeListArray.firstIndex(where: { (rec) -> Bool in
                        return rec.recipeID == recipeId as? Int64
                    }){
                        self.recipeListArray[index] = selected
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })*/
    }
    
    @objc
    func refreshRecipeFromNotifcation(_ notification : Notification) {
        let recipeId = notification.object
        if recipeId is Int64 {
            let filterA  =  self.recipeListArray.filter { (rec) -> Bool in
                return rec.recipeID == recipeId as? Int64
            }
            if filterA.count > 0 {
                var selected = filterA[0]
                selected.isSaved = true
                
                if let index = self.recipeListArray.firstIndex(where: { (rec) -> Bool in
                    return rec.recipeID == recipeId as? Int64
                }){
                    self.recipeListArray[index] = selected
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func getRecipeData(catId : Int64? , _ isNeedToReset : Bool =  true) {
        
        var catID : Int64?
        var chefID: Int64?
        
        if let cat_ID = catId {
            catID = cat_ID
        }
        if let chef_ID = self.dataHandler.selectChef?.chefID {
            chefID = chef_ID
        }
        
        //  _ = SpinnerView.showSpinnerViewInView(self.view)
        privateWorkQueue.async { [weak self] in
            guard let self = self else {return}
            //sab
           // self.dataHandler.getNextRecipeListWithFilter(recipeID: nil , chefID: chefID, categoryID: catID , withReset: true)
            if self.groceryA.count > 0{
                let id = ElGrocerUtility.sharedInstance.GenerateRetailerIdString(groceryA: self.groceryA)
                self.dataHandler.getNextRecipeListWithFilter(recipeID: nil, chefID: chefID, categoryID: catID, withReset: isNeedToReset , retailersId: id)
            }
            
        }
        
    }
    
    func reloadData() {
        
        self.tableView.reloadData()
        self.tableView.stopRefreshing()
        SpinnerView.hideSpinnerView()
        
    }
    
    func showAddToBasketToolMessage() {
        
        if toolTipView == nil {
            let toolTipStr = NSLocalizedString("product_added_to_basket", comment: "")
            if let barButton = self.navigationItem.rightBarButtonItem as? BBBadgeBarButtonItem {
                self.toolTipView = JDFTooltipView.init(targetBarButtonItem: barButton, hostView: self.view.window, tooltipText: toolTipStr, arrowDirection: JDFTooltipViewArrowDirection.up, width:  self.view.bounds.width)
                self.toolTipView!.tooltipBackgroundColour = UIColor.lightGreenColor()
                self.toolTipView!.font = UIFont.SFProDisplaySemiBoldFont(14.0)
                self.toolTipView!.textColour = UIColor.mediumGreenColor()
                
            }
        }
        guard self.toolTipView != nil else { return }
        self.toolTipView!.show()
        ElGrocerUtility.sharedInstance.delay(2.0) { [weak self] in
            guard let self = self else { return }
            self.toolTipView!.hide(animated: true)
        }
        
    }
    
    //MARK: Save recipe
    @objc func saveButtonHandler(sender : UIButton){
        
        if let index = sender.tag as? Int{
            if recipeListArray.count > 0{
                if recipeListArray.count > index{
                    if recipeListArray[index].isSaved{
                        saveButtonHandler(isSaved: false, index: index)
                    }else{
                        saveButtonHandler(isSaved: true, index: index)
                    }
                }

            }
        }
    }
    func saveButtonHandler(isSaved : Bool , index : Int){
        
        if isSaved{
           apiCallSaveRecipe(index: index, isSave: true)
        }else{
            apiCallSaveRecipe(index: index, isSave: false)
        }
    }
    func apiCallSaveRecipe(index : Int , isSave : Bool ){
        if recipeListArray[index].recipeID != -1 && recipeListArray != nil{
            dataHandler.saveRecipeApiCall(recipeID: recipeListArray[index].recipeID!, isSave: isSave) { (Done) in
                if Done{
                    self.saveResponceSuccess(done: Done, index: index)
                }else{
                    self.saveResponceSuccess(done: Done, index: index)

                }
            }
        }
        
    }
    
    func saveResponceSuccess(done : Bool , index : Int){
        if recipeListArray.count > 0{
            guard tableView.numberOfSections > 2 else {
                return
            }
            if done{
                if self.recipeListArray[index].isSaved{
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 2)) as? RecipeTableViewCell{

                        cell.saveRecipeImageView.image = UIImage(named: "saveUnfilled")
                        self.recipeListArray[index].isSaved = false
                    }
                }else{
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 2)) as? RecipeTableViewCell{

                        cell.saveRecipeImageView.image = UIImage(named: "saveFilled")
                        self.recipeListArray[index].isSaved = true
                    }
                    let msg = NSLocalizedString("recipe_save_success", comment: "")
                    ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(named: "saveFilled") , -1 , false) { (sender , index , isUnDo) in  }
                }
            }else{
                if self.recipeListArray[index].isSaved{
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 2)) as? RecipeTableViewCell{

                            cell.saveRecipeImageView.image = UIImage(named: "saveFilled")

                    }
                }else{
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 2)) as? RecipeTableViewCell{

                            cell.saveRecipeImageView.image = UIImage(named: "saveUnfilled")

                    }
                }
            }
        }
        
    }
    
    
    func dynamicHeight(text : String , font : UIFont) -> CGFloat{
        let string = text
        let textSize = string.heightOfString(withConstrainedWidth: ScreenSize.SCREEN_WIDTH - 104 - 16 , font: font)
        return textSize + 14
    }
    
}
//extension FilteredRecipeViewController : UIGestureRecognizerDelegate {}

extension FilteredRecipeViewController : UITableViewDelegate , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            
            guard chef.chefName.count > 0 else {
                return 0.01
            }
            let height = dynamicHeight(text: chef.chefDescription , font: UIFont.SFProDisplayNormalFont(14)) + dynamicHeight(text: chef.chefName , font: UIFont.SFProDisplayBoldFont(20))
            if height < kChefDescriptionCell {
                return kChefDescriptionCell
            }
            return height + 20 //20 for padding
        }else if indexPath.section == 1{
            if indexPath.row == 0{
                return storlyCellHeight > 0 ? KGenericViewTitileTableViewCellHeight : storlyCellHeight
            }else{
                return storlyCellHeight //for storyly
            }
        }
        return ScreenSize.SCREEN_WIDTH - 16
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }else if section == 1{
            return 2
        }
        
        if recipeListArray.count == 0 {
            self.tableView.setEmptyView(title: self.emtpyTitle, message: self.emtpyDescription)

        }
        else {
            self.tableView.restore()
        }
        return recipeListArray.count
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            
            let listCell = tableView.dequeueReusableCell(withIdentifier: "chefDescriptionCell" ) as! chefDescriptionCell
            listCell.contentView.backgroundColor = .clear //.navigationBarWhiteColor()
            if chef.chefID != -1{
                listCell.configCell(chef: chef)
            }
            return listCell
            
        }else if indexPath.section == 1{
            if indexPath.row == 0{
                print("heading")
                let cell : GenericViewTitileTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
                cell.configureCell(title: NSLocalizedString("lbl_preparation_Highlight", comment: ""))
                return cell
            }else{
                // print("storyly Collection view")
                let cell : StorlyTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KStorlyTableViewCell , for: indexPath) as! StorlyTableViewCell
                if self.chef.chefStorlySlug.count > 0 {
                    if !isCellLoaded {
                        isCellLoaded = true
                        cell.chef = self.chef
                        cell.topVc = self
                    }
                }
               
                return cell
            }
        }
        
        let listCell = tableView.dequeueReusableCell(withIdentifier: KRecipeTableViewCellIdentifier ) as! RecipeTableViewCell
        listCell.contentView.backgroundColor = .clear //.navigationBarWhiteColor()
        if recipeListArray.count > 0 {
            
            listCell.setRecipe(recipeListArray[indexPath.row])
            listCell.saveRecipeButton.tag = indexPath.row
            //listCell.saveRecipeButton.addTarget(self, action: #selector(self.saveButtonHandler(sender:)), for: .touchUpInside)
            
        }
        
        listCell.changeRecipeSaveStateTo = { [weak self] (isSave , recipe) in
            guard self != nil  else {
                return
            }
            let objInA = self?.recipeListArray.filter { (rec) -> Bool in
                return rec.recipeID == recipe?.recipeID
            }
            if objInA?.count ?? 0 > 0 {
                if var currentSelectRecipe = objInA?[0] {
                    if isSave != nil {
                        currentSelectRecipe.isSaved = isSave!
                        if let index = self?.recipeListArray.firstIndex(where: { (rec) -> Bool in
                            return rec.recipeID == currentSelectRecipe.recipeID
                        }) {
                            self?.recipeListArray[index] = currentSelectRecipe
                        }
                        
                    }
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }
        }
        
        
        return listCell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
        guard tableView.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath) else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        if recipeListArray.count > 0 && indexPath.section > 1{
                
                let selectedRecipe = recipeListArray[indexPath.row]
                let recipeDetail : RecipeDetailVC = ElGrocerViewControllers.recipeDetailViewController()
                recipeDetail.source = FireBaseEventsLogger.gettopViewControllerName()  ?? "UnKnown"
                recipeDetail.recipe = selectedRecipe
                recipeDetail.addToBasketMessageDisplayed = { [weak self] in
                    guard let self = self else {return}
                   
                }
                recipeDetail.groceryA = self.groceryA
                recipeDetail.hidesBottomBarWhenPushed = true
                let trackeventAction = (selectedRecipe.recipeName ?? " ") + " View"
                GoogleAnalyticsHelper.trackRecipeWithName(trackeventAction)
                if let recipeName = selectedRecipe.recipeName {
                    ElGrocerEventsLogger.sharedInstance.trackRecipeDetailNav(selectedRecipe.recipeChef?.chefName ?? "", recipeName: recipeName)
                }
                
                self.navigationController?.pushViewController(recipeDetail, animated: true)
//            }
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            if selectedCategroyId == -1{
                self.getRecipeData(catId: nil , false)
            }else{
                self.getRecipeData(catId: selectedCategroyId , false)
            }
            
        }
    }
    
    
}

extension FilteredRecipeViewController : RecipeDataHandlerDelegate {
    
    func recipeList(recipeTotalA: [Recipe]) {
        
        if recipeTotalA.count > 0{
            self.recipeListArray.removeAll()
            self.recipeListArray = recipeTotalA
            self.reloadData()
        }else{
            self.tableView.backgroundView = self.NoDataView
            self.recipeListArray = recipeTotalA
            //SpinnerView.hideSpinnerView()
            reloadData()
//            self.getAlreadyAddedList { [weak self](recipeCartList) in
//                guard let self = self else {return}
//                self.recipCartList = recipeCartList
//                self.emtpyTitle = NSLocalizedString("title_no_Recipe_Found", comment: "")
//                self.emtpyDescription = NSLocalizedString("message_no_Recipe_Found", comment: "")
//                self.reloadData()
//            }
        }
        
        
        
    }
    
    func getAlreadyAddedList(completion : ([RecipeCart]?) ->Void) {
        
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        let userProfile = UserProfile.getUserProfile(context)
        context.performAndWait {
            let predicate = NSPredicate(format: "dbID == %@", userProfile?.dbID ?? "")
            completion(RecipeCart.getFilteredRecipeCart(context, predicate: predicate))
        }
    }
    
}


extension FilteredRecipeViewController : StorylyDelegate {
    
  
    
    func storylyLoaded(_ storylyView: StorylyView, storyGroupList: [StoryGroup], dataSource: StorylyDataSource) {
        debugPrint("")
        if storyGroupList.count > 0 {
            storlyCellHeight = 140
        }
        self.tableView.reloadData()
    }
    
    func storylyLoadFailed(_ storylyView: StorylyView, errorMessage: String) {
        debugPrint("")
    }
    
    
    
    
}
