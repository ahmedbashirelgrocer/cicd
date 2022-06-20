//
//  RecipesListViewController.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 15/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import JDFTooltips
// import BBBadgeBarButtonItem

class RecipesListViewController: BasketBasicViewController {
    
    @IBOutlet weak var tableView: CustomTableView!
    lazy var dataHandler : RecipeDataHandler = {
        let dataH = RecipeDataHandler()
        dataH.delegate = self
        return dataH
    }()
    lazy var toolTipView:JDFTooltipView?=nil
    lazy var currentSpinnerView : SpinnerView?=nil
    let privateWorkQueue : DispatchQueue = DispatchQueue(label: "privateWorkQueue")
    private (set) var recipeSearchHeader : SearchRecipeHeader?=nil
    private (set) var recipCartList : [RecipeCart]?=nil
    private var emtpyTitle : String = ""
    private var emtpyDescription : String = ""
    
             var isNeedToShowCrossIcon : Bool = false
    private  var isLoadedFirstTime : Bool = false
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
  
    var groceryA : [Grocery]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpApearance()
        self.initailCellRegistration()
        self.addClouser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        self.setProductNumber()
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsRecipeBoutiqueScreen)
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.Recipes.rawValue, screenClass: String(describing: self.classForCoder)) //
        
       
        
        
        
        if !isLoadedFirstTime {
            isLoadedFirstTime = true
            self.getRecipeData()
        }else{
            self.recipeList(recipeTotalA: [])
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let isHeaderAvailable = self.recipeSearchHeader {
            let retailerIds = GenerateRetailerIdString()
            isHeaderAvailable.chefListView.getChefData(retailerString : retailerIds)
        }
        
    }
    func GenerateRetailerIdString() -> String{
        
        var retailerIDString = ""
        if groceryA?.count ?? 0 > 0{
            var i = 0
            while i < groceryA!.count {
                if i == 0 {
                    retailerIDString.append((groceryA?[i].dbID)!)
                }else{
                    retailerIDString.append("," + (groceryA?[i].dbID)!)
                }
                i = i + 1
            }
        }
        return retailerIDString
    }
    func setUpApearance(){
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarDelegate(self)
        
        self.navigationController!.navigationBar.topItem!.title = localizedString("title_recipe_list", comment: "")
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.view.backgroundColor = UIColor.navigationBarColor()
        
        self.view.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9647058824, blue: 0.9725490196, alpha: 1)
        
        
        if self.navigationController is ElGrocerNavigationController {
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setNewLightBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            self.addCustomTitleViewWithTitleDarkShade( localizedString("title_recipe_list", comment: "") , true)
        }
        
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        if isNeedToShowCrossIcon {
            self.addBackButtonWithCrossIcon()
        }
        // self.addBackButtonWithCrossIcon()
        
    }
    
    func setProductNumber(){
        
        self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
        self.basketIconOverlay?.grocery = self.grocery
        self.refreshBasketIconStatus()
    }
    
    
    override func backButtonClick() {
        self.dismiss(animated: true , completion: nil)
    }
    
    func initailCellRegistration() {
        
        recipeSearchHeader = (Bundle.resource.loadNibNamed("SearchRecipeHeader", owner: self, options: nil)![0] as? SearchRecipeHeader)!
        
        
        let recipeListCell = UINib(nibName: KRecipeTableViewCellIdentifier, bundle: Bundle.resource)
        self.tableView.register(recipeListCell, forCellReuseIdentifier: KRecipeTableViewCellIdentifier )
        self.tableView.backgroundColor = UIColor.lightGrayBGColor()
        self.tableView.estimatedRowHeight = CGFloat(KRecipeTableViewCellHeight)
        self.tableView.separatorStyle = .none
        self.tableView.keyboardDismissMode = .onDrag
        
    }
    
    func addClouser() {
        
        
        self.recipeSearchHeader?.searchCharChanged = {[weak self] (searchString) in
            guard let self = self else {return}
            if searchString.isEmpty {
                let deadlineTime = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.dataHandler.resetRecipeList()
                    self.getRecipeData()
                }
            }else{
                FireBaseEventsLogger.trackRecipeSearch(searchString)
                self.elasticSearchWithString(searchString: searchString , isNeedToReset: true)
            }
            
        }
        
        self.recipeSearchHeader?.chefListView.chefSelected = {[weak self] (selectedChef) in
            guard let self = self else {return}
            // self.dataHandler.setFilterChef(selectedChef)
            // self.getFilteredData(isNeedToReset: true)
            self.gotoFilterController(chef: selectedChef, category: nil)
            
        }
        
        self.recipeSearchHeader?.categoryListView.recipeCategorySelected = {[weak self] (selectedCategory) in
            guard let self = self else {return}
            //            self.dataHandler.setFilterRecipeCategory(selectedCategory)
            //            self.getFilteredData(isNeedToReset: true)
            guard selectedCategory != nil else {
                return
            }
            self.gotoFilterController(chef: nil, category: selectedCategory)
        }
        
        self.tableView.refreshCalled = {[weak self] in
            guard let self = self else {return}
            let deadlineTime = DispatchTime.now() + .seconds(1)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.dataHandler.resetRecipeList()
                self.getRecipeData()
            }
        }
        
        //        self.tableView.LoadMoreCalled = {[weak self] in
        //            guard let self = self else {return}
        //            let deadlineTime = DispatchTime.now() + .seconds(1)
        //            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
        //                self.getFilteredData(isNeedToReset: false)
        //            }
        //        }
    }
    
    private func gotoFilterController (  chef : CHEF? ,  category : RecipeCategoires?) {
        
        guard chef != nil || category != nil  else {
            return
        }
        let recipeFilter : FilteredRecipeViewController = ElGrocerViewControllers.recipeFilterViewController()
        recipeFilter.dataHandler.setFilterChef(chef)
        recipeFilter.dataHandler.setFilterRecipeCategory(category)
        recipeFilter.vcTitile = (chef == nil ? category?.categoryName : chef?.chefName)!
        recipeFilter.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(recipeFilter, animated: true)
        
    }
    
    // API Search Calling
    
    func elasticSearchWithString (searchString : String? , isNeedToReset : Bool) {
        
        var catID : Int64?
        var chefID: Int64?
        
        if let cat_ID = self.dataHandler.selectRecipeCategoires?.categoryID {
            catID = cat_ID
        }
        if let chef_ID = self.dataHandler.selectChef?.chefID {
            chefID = chef_ID
        }
        
        
        
        self.dataHandler.getRecipeElasticSearchedList(searchString: searchString , chefID: chefID, categoryID: catID, retailerId: "", storeType_iDs: "", groupIds: [], withReset: isNeedToReset)
    }
    
    func getFilteredData(isNeedToReset : Bool) {
        
        guard recipeSearchHeader?.textFieldSearch.text?.count ?? 0 > 1 else {
            
            var catID : Int64?
            var chefID: Int64?
            
            if let cat_ID = self.dataHandler.selectRecipeCategoires?.categoryID {
                catID = cat_ID
            }
            if let chef_ID = self.dataHandler.selectChef?.chefID {
                chefID = chef_ID
            }
            //sab
            //self.dataHandler.getNextRecipeListWithFilter(recipeID: nil , chefID: chefID, categoryID: catID , withReset: isNeedToReset)
            let retailerIds = GenerateRetailerIdString()
            self.dataHandler.getNextRecipeListWithFilter(recipeID: nil, chefID: chefID, categoryID: catID, withReset: isNeedToReset, retailersId: retailerIds)
            return
        }
        
        if let searchString = recipeSearchHeader?.textFieldSearch.text {
            self.elasticSearchWithString(searchString: searchString , isNeedToReset: isNeedToReset)
        }
        
    }
    
    func getRecipeData() {
        
        if let catList = self.recipeSearchHeader?.categoryListView {
            catList.resetSelectedIndex()
        }
        if let chefList = self.recipeSearchHeader?.chefListView {
            chefList.resetSelectedIndex()
        }
        if let txtField = recipeSearchHeader?.textFieldSearch {
            txtField.text = ""
            txtField.resignFirstResponder()
        }
        self.currentSpinnerView = SpinnerView.showSpinnerViewInView(self.view)
        
        privateWorkQueue.async { [weak self] in
            guard let self = self else {return}
            //sab
            //self.dataHandler.getNextRecipeList(retailersId: <#T##String#>)
        }
        
    }
    
    func reloadData() {
        
        self.tableView.reloadData()
        self.tableView.stopRefreshing()
        SpinnerView.hideSpinnerView()
        
    }
    func showAddToBasketToolMessage() {
        
        //let toolTipStr = localizedString("product_added_to_basket", comment: "")
        let msg = localizedString("product_added_to_basket", comment: "")
        ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "lbl_edit_Added") , -1 , false) { (sender , index , isUnDo) in  }
        
        if self.toolTipView != nil {
            self.toolTipView = nil
        }
        
        if toolTipView == nil {
            let toolTipStr = localizedString("product_added_to_basket", comment: "")
            
                //          FIXME: Badge library discontinue. Verify before release
            /*if let barButton = self.navigationItem.rightBarButtonItem as? BBBadgeBarButtonItem {
                self.toolTipView = JDFTooltipView.init(targetBarButtonItem: barButton, hostView: self.view.window, tooltipText: toolTipStr, arrowDirection: JDFTooltipViewArrowDirection.up, width:  self.view.bounds.width)
                self.toolTipView!.tooltipBackgroundColour = UIColor.lightGreenColor()
                self.toolTipView!.font = UIFont.SFProDisplaySemiBoldFont(14.0)
                self.toolTipView!.textColour = UIColor.mediumGreenColor()
                
            }*/
        }
        guard self.toolTipView != nil else { return }
        self.setProductNumber()
        self.toolTipView!.show()
        ElGrocerUtility.sharedInstance.delay(2.0) { [weak self] in
            guard let self = self else { return }
            if let tooptip = self.toolTipView {
              tooptip.hide(animated: true)
            }
        }
        
    }
    
}
extension RecipesListViewController : UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(KSearchHeaderHeight)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return recipeSearchHeader
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

//        let floatConstHeight = CGFloat(KRecipeTableViewCellHeight)
//        var height = floatConstHeight * ( (self.view.frame.size.height + 64) / 667)
//        if height > floatConstHeight {
//            height = floatConstHeight
//        }
//
//        return height
        
        let height = ScreenSize.SCREEN_WIDTH - 16
        return height
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if dataHandler.recipeList.count == 0  {
            self.tableView.setEmptyView(title: self.emtpyTitle, message: self.emtpyDescription)
        }
        else {
            self.tableView.restore()
        }
        return dataHandler.recipeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let listCell = tableView.dequeueReusableCell(withIdentifier: KRecipeTableViewCellIdentifier ) as! RecipeTableViewCell
       // listCell.contentView.backgroundColor =  UIColor.lightGrayBGColor()
        
        listCell.contentView.backgroundColor = UIColor.colorWithHexString(hexString: "ebecee")
        
        if indexPath.row < dataHandler.recipeList.count {
             listCell.configuredCell(dataHandler.recipeList[indexPath.row] , self.recipCartList)
        }
        
        return listCell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard tableView.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath) else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        if  indexPath.row < dataHandler.recipeList.count {
            
         let selectedRecipe = dataHandler.recipeList[indexPath.row]
            
            let recipeDetail : RecipeDetailViewController = ElGrocerViewControllers.recipesDetailViewController()
            recipeDetail.recipe = selectedRecipe
            recipeDetail.addToBasketMessageDisplayed = { [weak self] in
                guard let self = self else {return}
                ElGrocerUtility.sharedInstance.delay(1.0) { [weak self] in
                    guard let self = self else { return }
                    self.showAddToBasketToolMessage()
                }
            }
            recipeDetail.hidesBottomBarWhenPushed = true
            let trackeventAction = (selectedRecipe.recipeName ?? " ") + " View"
            GoogleAnalyticsHelper.trackRecipeWithName(trackeventAction)
            if let recipeName = selectedRecipe.recipeName {
                ElGrocerEventsLogger.sharedInstance.trackRecipeDetailNav(selectedRecipe.recipeChef?.chefName ?? "", recipeName: recipeName)
                // FireBaseEventsLogger.logEventToFirebaseWithEventName("Recipes", eventName: recipeName , parameter: nil)
            }
            self.navigationController?.pushViewController(recipeDetail, animated: true)
            
        }
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let _ = recipeSearchHeader?.textFieldSearch.text {
            let kLoadingDistance : CGFloat = CGFloat(KRecipeTableViewCellHeight + 8.0)
            let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
            if y + kLoadingDistance > scrollView.contentSize.height  {
                self.getFilteredData(isNeedToReset: false)
            }
        }

    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
//        // UITableView only moves in one direction, y axis
//        let currentOffset = scrollView.contentOffset.y
//        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
//
//        // Change 10.0 to adjust the distance from bottom
//        if maximumOffset - currentOffset <= 50.0 {
//            self.getFilteredData(isNeedToReset: false)
//        }
    }
    
    
}

extension RecipesListViewController : RecipeDataHandlerDelegate {
    
    func recipeList(recipeTotalA: [Recipe]) {

        RecipeCart.GETAddToCartListRecipes {  [weak self](recipeCartList) in
            guard let self = self else {return}
            self.currentSpinnerView?.removeFromSuperview()
            self.recipCartList = recipeCartList
            self.emtpyTitle = localizedString("title_no_Recipe_Found", comment: "")
            self.emtpyDescription = localizedString("message_no_Recipe_Found", comment: "")
            self.reloadData()
        }

    }
}
