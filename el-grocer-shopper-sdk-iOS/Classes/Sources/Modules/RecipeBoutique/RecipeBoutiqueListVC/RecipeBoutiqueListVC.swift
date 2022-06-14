//
//  RecipeBoutiqueListVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 04/04/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import JDFTooltips
import IQKeyboardManagerSwift
class RecipeBoutiqueListVC: BasketBasicViewController, NoStoreViewDelegate {
     var isCommingFromDeepLink = false
    @IBOutlet var searchSuperBGView: UIView!{
        didSet{
            searchSuperBGView.roundWithShadow(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 16, withShadow: false)
        }
    }
    @IBOutlet var searchBGView: AWView!{
        didSet{
            searchBGView.borderWidth = 1
            searchBGView.borderColor = UIColor.searchBarBorderGreyColor()
        }
    }
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var searchTextField: UITextField!{
        didSet{
            searchTextField.font = UIFont.SFProDisplayNormalFont(14)
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                searchTextField.textAlignment = .right
            }
        }
    }
    @IBOutlet var recipeCategoriesListView: RecipeCategoriesList!
    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet var btnSearchCross: UIButton!{
        didSet {
            btnSearchCross.setTitle("", for: UIControl.State())
            btnSearchCross.isHidden = true
        }
    }
    lazy var currentSpinnerView : SpinnerView?=nil
    let privateWorkQueue : DispatchQueue = DispatchQueue(label: "privateWorkQueue")
    private (set) var recipCartList : [Recipe]?=nil
    var emtpyTitle : String = ""
    var emtpyDescription : String = ""
    
    var isSearching: Bool = false
    var isNeedToShowCrossIcon : Bool = false
    var recipeWorkItem:DispatchWorkItem?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
  
    var groceryA : [Grocery]?
    
    
    var presenter = RecipeBoutiqueListPresenter()
    var searchCharChanged: ((_ stringToFIltered : String)->Void)?
    var isNeedToResetCategory : Bool = false
    
    var isCommingAfterSaveRecipe : Bool = false
    
    
    
    lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.delegate = self
        noStoreView?.configureNoRecipe()
        return noStoreView!
    }()
    func noDataButtonDelegateClick(_ state: actionState) {
        //self.tabBarController?.selectedIndex = 0
        print("show recipe boutique")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear(view : self)
        recipeCategoriesListView.superview?.clipsToBounds = true
        recipeCategoriesListView.superview?.layer.cornerRadius = 18
        recipeCategoriesListView.superview?.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear(view: self)
    }
    func setUpApearance(){
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 10
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarDelegate(self)
        
        self.navigationController!.navigationBar.topItem!.title = NSLocalizedString("title_recipe_list", comment: "")
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        self.navigationController?.navigationBar.barTintColor = UIColor.white
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = false
        
        self.view.backgroundColor = .navigationBarWhiteColor()
        self.tableView.backgroundColor = .tableViewBackgroundColor()
        self.navigationController?.navigationBar.backgroundColor = .navigationBarColor()
        self.navigationController?.navigationBar.isTranslucent = true
        
        if self.navigationController is ElGrocerNavigationController {
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
//            self.addCustomTitleViewWithTitleDarkShade( NSLocalizedString("title_recipe_list", comment: "") , true)
        }
        
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        
        self.navigationController?.navigationBar.isHidden = false
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        if isNeedToShowCrossIcon {
            //self.addBackButtonWithCrossIconLeftSide(.white)
            self.addBackButtonWithCrossIconRightSide(.white)
            //self.addRightCrossButton(true)
        }
        self.setUpSearchApearance()
        
    }
    override func rightBackButtonClicked(){
        self.dismiss(animated: true, completion: nil)
    }
    func setUpSearchApearance() {

        self.searchTextField.delegate = self
        self.searchTextField.placeholder = NSLocalizedString("recipe_boutique_searchBar_txt", comment: "")
        self.searchTextField.attributedPlaceholder = NSAttributedString.init(string: self.searchTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryBlackColor()])
        
    }
    
    @IBAction func btnSearchCrossHandler(_ sender: Any) {
        self.searchTextField.text = ""
        self.searchString = ""
        self.btnSearchCross.isHidden = true
        self.isSearching = false
        self.startSearchProcess()
    }
    func setProductNumber(){
        
        self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
        self.basketIconOverlay?.grocery = self.grocery
        self.refreshBasketIconStatus()
    }
    
    override func crossButtonClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func backButtonClick() {
        self.dismiss(animated: true , completion: nil)
    }
    
    func initailCellRegistration() {
        self.tableView.register(UINib(nibName: "chefListTableCell", bundle: nil), forCellReuseIdentifier: "chefListTableCellTableViewCell")
        self.tableView.register(UINib(nibName: KGenericViewTitileTableViewCell, bundle: nil), forCellReuseIdentifier: KGenericViewTitileTableViewCell)
        
        let recipeListCell = UINib(nibName: KRecipeTableViewCellIdentifier, bundle: Bundle(for: RecipeTableViewCell.self))
        self.tableView.register(recipeListCell, forCellReuseIdentifier: KRecipeTableViewCellIdentifier )
        self.tableView.backgroundColor = UIColor.tableViewBackgroundColor()
        self.tableView.estimatedRowHeight = CGFloat(KRecipeTableViewCellHeight)
        self.tableView.separatorStyle = .none
        self.tableView.keyboardDismissMode = .onDrag
        
    }
    func startSearchProcess () {
        if let availableClouser = self.searchCharChanged  {
            availableClouser(self.searchTextField.text ?? "")
        }
    }
    //sab
    func getRecipeData() {
        //sab
        if let catList = self.recipeCategoriesListView {
            catList.resetSelectedIndex()
        }
        if self.recipeCategoriesListView.recipeCategoryDataList.count > 0 {
            self.recipeCategoriesListView.categorySelected = self.recipeCategoriesListView.recipeCategoryDataList[0]
        }
        if self.tableView.numberOfSections > 0{
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? chefListTableCellTableViewCell{
                if let chefList = cell.chefListView {
                    chefList.resetSelectedIndex()
                }
            }
        }
        if isNeedToResetCategory{
            self.recipeCategoriesListView.getCategoryData(savedCategories: false, self.groceryA)
            isNeedToResetCategory = false
        }
        
        if let txtField = self.searchTextField {
            txtField.text = ""
            txtField.resignFirstResponder()
        }
        self.currentSpinnerView = SpinnerView.showSpinnerViewInView(self.view)

        privateWorkQueue.async { [weak self] in
            guard let self = self else {return}
            
            self.recipeWorkItem?.cancel()
                self.recipeWorkItem = DispatchWorkItem {
                    let ids = self.presenter.GenerateRetailerIdString(groceryA: self.groceryA)
                    self.presenter.interactor.dataHandler.getNextRecipeList(retailersId: ids ,categroryId: self.recipeCategoriesListView.categorySelected?.categoryID ?? nil)
                }
                DispatchQueue.global(qos: .utility).async(execute: self.recipeWorkItem!)
            
        }

    }
    
    func reloadData() {
        DispatchQueue.main.async {
            if self.presenter.recipeListArray?.count == 0{
                self.tableView.backgroundView = self.NoDataView
            }
            
            self.tableView.reloadData()
            self.tableView.stopRefreshing()
            SpinnerView.hideSpinnerView()
        }
        
    }
    
    
    @objc func saveButtonHandler(sender : UIButton){
        
        if let index = sender.tag as? Int{
            if presenter.recipeListArray != nil{
                if presenter.recipeListArray!.count > index && self.tableView!.numberOfSections >= 2{
                    if presenter.recipeListArray![index].isSaved{
                        presenter.saveButtonHandler(isSaved: false, index: index)
                    }else{
                        presenter.saveButtonHandler(isSaved: true, index: index)
                        //apiCallSaveRecipe(index: index, isSave: true)
                    }
                }

            }
        }
    }


}
extension RecipeBoutiqueListVC : UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return presenter.heightForRowInSection(indexPath: indexPath, isSearching: isSearching)    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSecions()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "chefListTableCellTableViewCell") as! chefListTableCellTableViewCell
            cell.chefListView.getChefData(retailerString: presenter.GenerateRetailerIdString(groceryA: self.groceryA))
            return cell
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            
            let cell : GenericViewTitileTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
            
            cell.configureCell(title: recipeCategoriesListView.categorySelected?.categoryName ?? NSLocalizedString("txt_All_Recipes", comment: ""))
            return cell
            
        }
        
        let listCell = tableView.dequeueReusableCell(withIdentifier: KRecipeTableViewCellIdentifier ) as! RecipeTableViewCell
        //listCell.contentView.backgroundColor =  UIColor.navigationBarWhiteColor()

        //sab
        
        if presenter.recipeListArray?.isNotEmpty ?? false {
            listCell.setRecipe(presenter.recipeListArray![indexPath.row - 1])
            listCell.saveRecipeButton.tag = indexPath.row
           // listCell.saveRecipeButton.addTarget(self, action: #selector(self.saveButtonHandler(sender:)), for: .touchUpInside)
        }
        
        listCell.changeRecipeSaveStateTo = { [weak self] (isSave , recipe) in
            guard self != nil  else {
                return
            }
            let objInA = self?.presenter.recipeListArray?.filter { (rec) -> Bool in
                return rec.recipeID == recipe?.recipeID
            }
            if objInA?.count ?? 0 > 0 {
                if var currentSelectRecipe = objInA?[0] {
                    if isSave != nil {
                        currentSelectRecipe.isSaved = isSave!
                    }
                    
                    if let index = self?.presenter.recipeListArray?.firstIndex(where: { (rec) -> Bool in
                        return rec.recipeID == currentSelectRecipe.recipeID
                    }) {
                        self?.presenter.recipeListArray?[index] = currentSelectRecipe
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

        if indexPath.section == 1 && indexPath.row > 0{
            if let topVC = UIApplication.topViewController(){
                (topVC.tabBarController?.navigationController as? ElgrocerGenericUIParentNavViewController)?.setLogoHidden(true)
                (topVC.tabBarController?.navigationController as? ElgrocerGenericUIParentNavViewController)?.setBasketButtonHidden(true)
                
                let selectedRecipe = presenter.recipeListArray?[indexPath.row - 1]
                let recipeDetail : RecipeDetailVC = ElGrocerViewControllers.recipeDetailViewController()
                recipeDetail.source = FireBaseEventsLogger.gettopViewControllerName()  ?? "UnKnown"
                recipeDetail.recipe = selectedRecipe
                recipeDetail.groceryA = self.groceryA
                recipeDetail.addToBasketMessageDisplayed = { [weak self] in
                    guard let self = self else {return}
                   
                }
                recipeDetail.hidesBottomBarWhenPushed = true
                let trackeventAction = (selectedRecipe?.recipeName ?? " ") + " View"
                GoogleAnalyticsHelper.trackRecipeWithName(trackeventAction)
                if let recipeName = selectedRecipe?.recipeName {
                    ElGrocerEventsLogger.sharedInstance.trackRecipeDetailNav(selectedRecipe?.recipeChef?.chefName ?? "", recipeName: recipeName)
                }
                
                topVC.navigationController?.pushViewController(recipeDetail, animated: true)

            }
        }


    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let _ = searchTextField.text {
            let kLoadingDistance : CGFloat =  2 * CGFloat(KRecipeTableViewCellHeight + 8.0)
            let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
            if y + kLoadingDistance > scrollView.contentSize.height && !self.presenter.isRecipeCalling {
                presenter.getFilteredData(isNeedToReset: false)
            }
        }

    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
//        // UITableView only moves in one direction, y axis
    }
    
    
}

extension RecipeBoutiqueListVC : UITextFieldDelegate {


    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        self.isSearching = true
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(SearchRecipeHeader.performSearch),
            object: textField)
        self.perform(
            #selector(SearchRecipeHeader.performSearch),
            with: textField,
            afterDelay: 0.35)
        defer {
        }
        
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        self.searchTextField.text = newText
        if newText.count > 0 {
            btnSearchCross.isHidden = false
            self.isSearching = true
        }else {
            btnSearchCross.isHidden = true
            self.isSearching = false
            btnSearchCrossHandler(btnSearchCross)
        }
        return false

    }
    @objc
    func performSearch(textField: UITextField) {
        print("Hints for textField: \(textField)")
        if self.searchTextField.text?.count ?? 0 > 1 {
                self.startSearchProcess()
            
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count ?? 0 == 0 {
            btnSearchCross.isHidden = true
            self.isSearching = false
            self.startSearchProcess()
        }
        textField.resignFirstResponder()
        return true
    }
    


}
