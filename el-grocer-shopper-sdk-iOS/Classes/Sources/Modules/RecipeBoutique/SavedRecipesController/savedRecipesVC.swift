//
//  savedRecipesVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 11/04/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class savedRecipesVC: BasketBasicViewController, NoStoreViewDelegate  {

    @IBOutlet var categoryListView: RecipeCategoriesList!
    @IBOutlet var tableView: UITableView!
    
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
    func noDataButtonDelegateClick(_ state: actionState) {
        //self.tabBarController?.selectedIndex = 0
        print("show recipe boutique")
        //
        ElGrocerEventsLogger.sharedInstance.trackRecipeViewAllClickedFromNewGeneric(source: FireBaseScreenName.SavedRecipes.rawValue)
        if ElGrocerUtility.sharedInstance.activeGrocery != nil {
            self.goToRecipe(ElGrocerUtility.sharedInstance.activeGrocery!)
        }else if ElGrocerUtility.sharedInstance.groceries.count > 0 {
            self.goToRecipe(nil)
        }
    }
    
    
    var recipeListArray = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerTableCells()
        categoryListView.getCategoryData(savedCategories: true)
        getRecipeData()
        initialAppearence()
        addClosure()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialAppearence()
        if recipeListArray.count == 0 {
            categoryListView.getCategoryData(savedCategories: true)
            getRecipeData()
        }
        categoryListView.superview?.clipsToBounds = true
        categoryListView.superview?.layer.cornerRadius = 18
        categoryListView.superview?.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    override func backButtonClick() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func backButtonClickedHandler(){
        self.backButtonClick()
    }
    
    
    
    func initialAppearence(){
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        self.navigationController?.navigationBar.topItem?.title = localizedString("title_saved_recipes", comment: "")
        self.navigationController?.navigationBar.isHidden = false
        
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        self.view.backgroundColor = .navigationBarWhiteColor()
        self.tableView.backgroundColor = .tableViewBackgroundColor()
        self.navigationController?.navigationBar.backgroundColor = .navigationBarColor()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    func addClosure(){
        categoryListView.recipeCategorySelected = {[weak self] (selectedCategory) in
            guard let self = self else {return}
            //            self.dataHandler.setFilterRecipeCategory(selectedCategory)
            //            self.getFilteredData(isNeedToReset: true)
            guard selectedCategory != nil else {
                return
            }
            
            self.categoryListView.categorySelected = selectedCategory
            
            if let id = UserDefaults.getLogInUserID() as? String{
                if let catId = selectedCategory?.categoryID{
                    print("categ : \(catId)")
                    
                    self.dataHandler.getSavedRecipeList(shopperId: id , categoryId: "\(catId)")
                }else{
                    self.dataHandler.getSavedRecipeList(shopperId: id , categoryId: nil)
                }
                
            }
            //self.gotoFilterController(chef: nil, category: selectedCategory)
        }
    }
    
    func getRecipeData() {
        
        SpinnerView.showSpinnerViewInView(self.view)

        if let id = UserDefaults.getLogInUserID() as? String{
            self.dataHandler.getSavedRecipeList(shopperId:id , categoryId: nil)
        }
    }
    
    func reloadData() {
        
        if categoryListView.recipeCategoryDataList.count > 2{
            //self.categoryListView.visibility = .visible
            self.categoryListView.isHidden = false
        }else{
            //self.categoryListView.visibility = .gone
            self.categoryListView.isHidden = true
        }
        
        self.tableView.reloadData()
        SpinnerView.hideSpinnerView()
        
    }
    
    
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
        if recipeListArray != nil{
            if done{
                if self.recipeListArray[index].isSaved{
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RecipeTableViewCell{

                        cell.saveRecipeImageView.image = UIImage(name: "saveUnfilled")
                        self.recipeListArray[index].isSaved = false
                        
                        if let catId = self.categoryListView.categorySelected?.categoryID{
                            SpinnerView.showSpinnerViewInView(self.view)
                            self.dataHandler.getSavedRecipeList(shopperId: UserDefaults.getLogInUserID(), categoryId: "\(catId)")
                            self.categoryListView.getCategoryData(savedCategories: true)
                        }else{
                            SpinnerView.showSpinnerViewInView(self.view)
                            self.dataHandler.getSavedRecipeList(shopperId: UserDefaults.getLogInUserID(), categoryId: nil)
                            self.categoryListView.getCategoryData(savedCategories: true)
                        }
                        
                        
                    }
                }else{
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RecipeTableViewCell{

                        cell.saveRecipeImageView.image = UIImage(name: "saveFilled")
                        self.recipeListArray[index].isSaved = true
                    }
                    let msg = localizedString("recipe_save_success", comment: "")
                    ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "saveFilled") , -1 , false) { (sender , index , isUnDo) in  }
                }
            }else{
                if self.recipeListArray[index].isSaved{
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RecipeTableViewCell{

                            cell.saveRecipeImageView.image = UIImage(name: "saveFilled")

                    }
                }else{
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RecipeTableViewCell{

                            cell.saveRecipeImageView.image = UIImage(name: "saveUnfilled")
                        if let catId = self.categoryListView.categorySelected?.categoryID{
                            SpinnerView.showSpinnerViewInView(self.view)
                            self.dataHandler.getSavedRecipeList(shopperId: UserDefaults.getLogInUserID(), categoryId: "\(catId)")
                            self.categoryListView.getCategoryData(savedCategories: true)
                        }else{
                            SpinnerView.showSpinnerViewInView(self.view)
                            self.dataHandler.getSavedRecipeList(shopperId: UserDefaults.getLogInUserID(), categoryId: nil)
                            self.categoryListView.getCategoryData(savedCategories: true)
                        }

                    }
                }
            }
        }
        
    }
    
    
    func goToRecipe (_ grocery : Grocery?) {
        if grocery != nil{
            ElGrocerUtility.sharedInstance.activeGrocery = grocery
        }
        
        // ElGrocerUtility.sharedInstance.groceries  = self.grocerA
        let recipeStory = ElGrocerViewControllers.recipesBoutiqueListVC()
        recipeStory.isNeedToShowCrossIcon = true
        recipeStory.groceryA = ElGrocerUtility.sharedInstance.groceries
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [recipeStory]
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: { });
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func registerTableCells(){
        
        let recipeListCell = UINib(nibName: KRecipeTableViewCellIdentifier, bundle: Bundle.resource)
        self.tableView.register(recipeListCell, forCellReuseIdentifier: KRecipeTableViewCellIdentifier )
        self.tableView.backgroundColor = .tableViewBackgroundColor() //.navigationBarWhiteColor()
        self.tableView.estimatedRowHeight = CGFloat(KRecipeTableViewCellHeight)
        self.tableView.separatorStyle = .none
    }

}
extension savedRecipesVC : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScreenSize.SCREEN_WIDTH - 16
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: KRecipeTableViewCellIdentifier) as! RecipeTableViewCell
        if recipeListArray.count > 0 {
            cell.setRecipe(recipeListArray[indexPath.row])
            cell.saveRecipeButton.tag = indexPath.row
            cell.saveRecipeButton.addTarget(self, action: #selector(self.saveButtonHandler(sender:)), for: .touchUpInside)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)

        if recipeListArray.count > 0{
            if let topVC = UIApplication.topViewController(){
                (topVC.tabBarController?.navigationController as? ElgrocerGenericUIParentNavViewController)?.setLogoHidden(true)
                (topVC.tabBarController?.navigationController as? ElgrocerGenericUIParentNavViewController)?.setBasketButtonHidden(true)
                
                let selectedRecipe = recipeListArray[indexPath.row]
                let recipeDetail : RecipeDetailVC = ElGrocerViewControllers.recipeDetailViewController()
                recipeDetail.source = FireBaseEventsLogger.gettopViewControllerName()  ?? "UnKnown"
                recipeDetail.recipe = selectedRecipe
                recipeDetail.addToBasketMessageDisplayed = { [weak self] in
                    guard let self = self else {return} }
                recipeDetail.hidesBottomBarWhenPushed = true
                let trackeventAction = (selectedRecipe.recipeName ?? " ") + " View"
                GoogleAnalyticsHelper.trackRecipeWithName(trackeventAction)
                if let recipeName = selectedRecipe.recipeName {
                    ElGrocerEventsLogger.sharedInstance.trackRecipeDetailNav(selectedRecipe.recipeChef?.chefName ?? "", recipeName: recipeName)
                }
                
                topVC.navigationController?.pushViewController(recipeDetail, animated: true)
            }
        }
        
    }
    
}

extension savedRecipesVC : RecipeDataHandlerDelegate {
    
    
    func recipeList(recipeTotalA: [Recipe]) {

            self.recipeListArray = recipeTotalA
        DispatchQueue.main.async {
            if self.recipeListArray.count > 0{
                self.tableView.backgroundView = UIView()
                self.reloadData()
            }else{
                if self.categoryListView.recipeCategoryDataList.count > 1{
                    self.categoryListView.categorySelected = nil
                    self.getRecipeData()
                }else{
                    self.reloadData()
                    SpinnerView.hideSpinnerView()
                    self.tableView.backgroundView = self.NoDataView
                }
                
            }
            
        }

    }
}
