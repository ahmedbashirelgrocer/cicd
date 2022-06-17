//
//  RecipeBoutiqueListPresenter.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 04/04/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class RecipeBoutiqueListPresenter: ViewToPresenterRecipeListProtocol {
    
    // MARK: Properties
    var view : RecipeBoutiqueListVC!
    var interactor = RecipeBoutiqueListInteractor()
    var router = RecipeBoutiqueListRouter()
    private  var isLoadedFirstTime : Bool = false
    var isRecipeCalling : Bool = false 
    // private  var isRecipeAlgoliaCalling : Bool = false
    var recipeListArray : [Recipe]?
    var searching : Bool = false
    
    
    //var chefListView = ChefListView()
    
    //MARK: Delegates
    func viewDidLoad(view : RecipeBoutiqueListVC){
        self.view = view
        
        view.setUpApearance()
        view.initailCellRegistration()
        self.addClouser()
    }
    
    func viewWillAppear(view : RecipeBoutiqueListVC){
        self.view = view
        view.setUpApearance()
        view.setProductNumber()
        interactor.setPresenter(presenter: self)
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsRecipeBoutiqueScreen)
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.Recipes.rawValue, screenClass: String(describing: view.classForCoder)) //
        
        interactor.setDataHandlerDelegate(delegate: self)
        
        if self.view.searchString.count > 0 {
            self.view.searchTextField.text = self.view.searchString
            self.getFilteredData(isNeedToReset: true)
            self.view.searchString = ""
        }else if !isLoadedFirstTime {
            isLoadedFirstTime = true
            view.getRecipeData()
            view.recipeCategoriesListView.getCategoryData(savedCategories: false , view.groceryA)
        }

    }
    
    func viewDidAppear(view : RecipeBoutiqueListVC){
        let retailerString = GenerateRetailerIdString(groceryA: view.groceryA)
        //chefListView.getChefData(retailerString: retailerString)
        if let cell = view.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? chefListTableCellTableViewCell{
            if let chefView = cell.chefListView{
                chefView.getChefData(retailerString: retailerString)
            }

        }
    }
 
    
    func GenerateRetailerIdString(groceryA : [Grocery]?) -> String{
        
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
    
    @objc
    func refreshRecipeFromNotifcation(_ notification : Notification) {
        let recipeId = notification.object
        if recipeId is Int64 {
            let filterA  =  self.recipeListArray?.filter { (rec) -> Bool in
                return rec.recipeID == recipeId as? Int64
            }
            if filterA?.count ?? 0 > 0 {
                var selected = filterA?[0]
                selected?.isSaved = true
                
                if let index = self.recipeListArray?.firstIndex(where: { (rec) -> Bool in
                    return rec.recipeID == recipeId as? Int64
                }){
                    if selected != nil {
                        self.recipeListArray?[index] = selected!
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.view.tableView.reloadData()
        }
        
    }
    
    func addClouser() {
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshRecipeFromNotifcation(_:)), name: Notification.Name(rawValue: "SaveRefresh") , object: nil)
        
        
        /*NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "SaveRefresh"), object: self.view, queue: OperationQueue.main, using: { notification in
            let recipeId = notification.object
            if recipeId is Int64 {
                let filterA  =  self.recipeListArray?.filter { (rec) -> Bool in
                    return rec.recipeID == recipeId as? Int64
                }
                if filterA?.count ?? 0 > 0 {
                    var selected = filterA?[0]
                    selected?.isSaved = true
                    
                    if let index = self.recipeListArray?.firstIndex(where: { (rec) -> Bool in
                        return rec.recipeID == recipeId as? Int64
                    }){
                        if selected != nil {
                            self.recipeListArray?[index] = selected!
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.view.tableView.reloadData()
            }
            
        })*/
       
        view.searchCharChanged = {[weak self] (searchString) in
            guard let self = self else {return}
            if searchString.isEmpty {
                let deadlineTime = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.searching = false
                    self.interactor.dataHandler.resetRecipeList()
                    self.recipeListArray?.removeAll()
                    self.view.isNeedToResetCategory = true
                    if self.view.isNeedToResetCategory{
                        self.view.recipeCategoriesListView.getCategoryData(savedCategories: false, self.view.groceryA)
                        self.view.isNeedToResetCategory = false
                    }
                    self.view.getRecipeData()
                }
            }else{
                self.searching = true
                FireBaseEventsLogger.trackRecipeSearch(searchString)
                self.elasticSearchWithString(searchString: searchString , isNeedToReset: true , true)
            }

        }
        if view.tableView.numberOfSections > 0{
            if let cell = view.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? chefListTableCellTableViewCell{
                cell.chefListView.chefSelected = {[weak self] (selectedChef) in
                    guard let self = self else {return}
                    // self.dataHandler.setFilterChef(selectedChef)
                    // self.getFilteredData(isNeedToReset: true)
                    self.router.gotoFilterController(chef: selectedChef, category: nil , view : self.view)

                }
            }
        }

        view.recipeCategoriesListView.recipeCategorySelected = {[weak self] (selectedCategory) in
            guard let self = self else {return}
              
            
            
            guard selectedCategory != nil else {
                return
            }
         //   let retailerString = self.GenerateRetailerIdString(groceryA: self.view.groceryA)
            guard self.view.searchTextField.text?.count ?? 0 > 1 else {
//                self.searching = true
//                self.interactor.dataHandler.getNextRecipeListWithFilter(recipeID: nil, chefID: nil, categoryID: selectedCategory?.categoryID, withReset: true, retailersId: retailerString)
                self.searching = true
                self.getFilteredData(isNeedToReset: true)
                DispatchQueue.main.async {
                    self.view.tableView.setContentOffset(.zero, animated: false)
                }
                
                
                return
            }
            self.interactor.dataHandler.setFilterRecipeCategory(selectedCategory)
            self.getFilteredData(isNeedToReset: true)
            DispatchQueue.main.async {
                self.view.tableView.setContentOffset(.zero, animated: false)
            }
        }
        
        view.tableView.refreshCalled = {[weak self] in
            guard let self = self else {return}
            let deadlineTime = DispatchTime.now() + .seconds(1)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                
                self.getFilteredData(isNeedToReset: true)
               // self.interactor.dataHandler.resetRecipeList()
               // self.view.getRecipeData()
            }
        }
    }
    
    
    //MARK: API Calling
    func elasticSearchWithString (searchString : String? , isNeedToReset : Bool , _ isNewKeywordSearch : Bool = false) {

        var catID : Int64?
        var chefID: Int64?
        
        if let cat_ID = self.view.recipeCategoriesListView.categorySelected?.categoryID {
            catID = cat_ID
        }
        if let chef_ID = self.interactor.dataHandler.selectChef?.chefID {
            chefID = chef_ID
        }
        
        if isNewKeywordSearch {
            catID = nil
        }
        
        let retailerIds = self.GenerateRetailerIdString(groceryA: self.view.groceryA)
        let storeIds = ElGrocerUtility.sharedInstance.GenerateStoreTypeIdsString(groceryA: self.view.groceryA)
        let groupIds = ElGrocerUtility.sharedInstance.GenerateStoreGroupIdsString(groceryAForIds: self.view.groceryA)
        
        
        self.interactor.dataHandler.getRecipeElasticSearchedList(searchString: searchString , chefID: chefID, categoryID: catID, retailerId: retailerIds, storeType_iDs: storeIds, groupIds: groupIds.uniqued() , withReset: isNeedToReset)
    }
    func getFilteredData(isNeedToReset : Bool) {
        //sab
        
        guard self.isRecipeCalling == false else {
            return
        }
        
        self.isRecipeCalling = true
        guard view.searchTextField.text?.count ?? 0 > 1 else {

            var catID : Int64?
            var chefID: Int64?
            if let cat_ID = self.interactor.presenter.view.recipeCategoriesListView.categorySelected?.categoryID {
                catID = cat_ID
            }
                self.interactor.dataHandler.getNextRecipeListWithFilter(recipeID: nil, chefID: chefID, categoryID: catID, withReset: isNeedToReset, retailersId: self.GenerateRetailerIdString(groceryA: view.groceryA))
//            }
            
            return
        }
        
        if let searchString = view.searchTextField.text {
            self.elasticSearchWithString(searchString: searchString , isNeedToReset: isNeedToReset)
        }
        
    }
    
    func saveButtonHandler(isSaved : Bool , index : Int){
        
        if isSaved{
            interactor.apiCallSaveRecipe(index: index, isSave: true)
        }else{
            interactor.apiCallSaveRecipe(index: index, isSave: false)
        }
    }
    
    //MARK: TableView Functions
    
    func numberOfSecions() -> Int{
        return 2
    }
    
    func numberOfRowsInSection(section : Int) -> Int{
        if section == 0{
            return 1
        }else{
            if self.recipeListArray?.count == 0  {
                view.tableView.setEmptyView(title: view.emtpyTitle, message: view.emtpyDescription)
            }
            else {
                view.tableView.restore()
            }
            return (self.recipeListArray?.count ?? 0) + 1

        }
    }
    
    func heightForRowInSection(indexPath : IndexPath, isSearching: Bool) -> CGFloat{
        
        if indexPath.section == 0{
            if isSearching {
                return 0
            }
            return kChefListCellHeight
        }else{
            if indexPath.row == 0 && indexPath.section == 1{
                return KGenericViewTitileTableViewCellHeight
            }
            let height = ScreenSize.SCREEN_WIDTH - 16
            return height
        }
        
    }
    
    
}
extension RecipeBoutiqueListPresenter : RecipeDataHandlerDelegate {
    
    
    func recipeCatogeiresList(categoryTotalA: [RecipeCategoires]) {
        self.view.recipeCategoriesListView.recipeCatogeiresList(categoryTotalA: categoryTotalA)
    }
    
    
    func recipeList(recipeTotalA: [Recipe]) {
        
        self.recipeListArray = recipeTotalA
        DispatchQueue.main.async {
            self.view.reloadData()
        }
        ElGrocerUtility.sharedInstance.delay(0.05) {
            self.isRecipeCalling = false
        }
        return
        
        //sab
        var i = 0
        if searching {
            self.recipeListArray = nil
        }
        
        
        
        while i < recipeTotalA.count {
            
            if recipeListArray != nil{
//                if recipeListArray!.count >= recipeTotalA.count{
                    let alreadyExist = recipeListArray?.contains(where: { (recipe) -> Bool in
                       return (recipe.recipeID == recipeTotalA[i].recipeID )
                    }) ?? false
                    if !alreadyExist{
                            self.recipeListArray?.append(recipeTotalA[i])
                    }
            }else{
                self.recipeListArray = [recipeTotalA[i]]
            }
            
            i = i + 1
        }
        DispatchQueue.main.async {
            self.view.reloadData()
        }
        self.isRecipeCalling = false

    }
}

// MARK: - Outputs to view
extension RecipeBoutiqueListPresenter: InteractorToPresenterRecipeListProtocol {
    
    func saveResponceSuccess(done : Bool , index : Int){
        if recipeListArray != nil{
            if done{
                if self.recipeListArray![index].isSaved{
                    if let cell = view.tableView.cellForRow(at: IndexPath(row: index, section: 1)) as? RecipeTableViewCell{

                        cell.saveRecipeImageView.image = UIImage(name: "saveUnfilled")
                        self.recipeListArray?[index].isSaved = false
                    }
                }else{
                    if let cell = view.tableView.cellForRow(at: IndexPath(row: index, section: 1)) as? RecipeTableViewCell{

                        cell.saveRecipeImageView.image = UIImage(name: "saveFilled")
                        self.recipeListArray?[index].isSaved = true
                    }
                    let msg = NSLocalizedString("recipe_save_success", comment: "")
                    ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "saveFilled") , -1 , false) { (sender , index , isUnDo) in  }
                }
            }else{
                if self.recipeListArray![index].isSaved{
                    if let cell = view.tableView.cellForRow(at: IndexPath(row: index, section: 1)) as? RecipeTableViewCell{

                            cell.saveRecipeImageView.image = UIImage(name: "saveFilled")

                    }
                }else{
                    if let cell = view.tableView.cellForRow(at: IndexPath(row: index, section: 1)) as? RecipeTableViewCell{

                            cell.saveRecipeImageView.image = UIImage(name: "saveUnfilled")

                    }
                }
            }
        }
        
    }
    
    func saveResponceFaliure(done : Bool){
        
    }
}

