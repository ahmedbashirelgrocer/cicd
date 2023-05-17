//
//  GenricRecipeCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import Foundation
import MSPeekCollectionViewDelegateImplementation
class GenricRecipeCell : CustomCollectionView {
    //var behavior: MSCollectionViewPeekingBehavior!
    var collectionData : [Recipe] = [Recipe]()
    lazy var dataHandler : RecipeDataHandler = {
        let dataH = RecipeDataHandler()
        return dataH
    }()
    var pageControl : UIPageControl!
    
    var showMiniVersion: Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerCellsAndSetDelegateAndDataSource()
        self.setUpInitialApearance()
    }
    
    func setUpInitialApearance() {
        self.backgroundColor = .white
        self.pageControl?.currentPageIndicatorTintColor = ApplicationTheme.currentTheme.pageControlActiveColor
    }
    
    func registerCellsAndSetDelegateAndDataSource () {
        
        self.addCollectionViewWithDirection(.horizontal)
        let genricRecipeCollectionViewCell = UINib(nibName: KGenricRecipeCollectionViewCell , bundle: Bundle.resource)
        self.collectionView?.register(genricRecipeCollectionViewCell, forCellWithReuseIdentifier: KGenricRecipeCollectionViewCell )
        
//        behavior = MSCollectionViewPeekingBehavior(cellSpacing: CGFloat(12), cellPeekWidth: CGFloat(12), maximumItemsToScroll: Int(1), numberOfItemsToShow: Int(1), scrollDirection: .horizontal, velocityThreshold: 0.2)
//        self.collectionView?.configureForPeekingBehavior(behavior: behavior)
        
        
        self.collectionView?.isScrollEnabled = true
        self.collectionView?.isPagingEnabled = true
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.reloadData()
        
    }
    
    func configureData (_ dataA : [Recipe] , page : UIPageControl) {
        self.pageControl = page
        self.collectionData = dataA
        self.reloadData()
        self.collectionView?.setContentOffset(.zero, animated: true)
    }
    
    func apiCallSaveRecipe(index : Int , isSave : Bool){
        
        guard UserDefaults.isUserLoggedIn() else {
     
            let signInVC = ElGrocerViewControllers.signInViewController()
            signInVC.isForLogIn = true
            signInVC.isCommingFrom = .saveRecipe
            signInVC.dismissMode = .dismissModal
            signInVC.recipeId =  collectionData[index].recipeID
            let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navController.viewControllers = [signInVC]
            navController.modalPresentationStyle = .fullScreen
            if let topVc = UIApplication.topViewController() {
                topVc.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        if collectionData[index].recipeID != -1 {
            dataHandler.saveRecipeApiCall(recipeID: collectionData[index].recipeID!, isSave: isSave) { (Done) in
                if Done{
                    if self.collectionData[index].isSaved{
                        if let cell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? GenricRecipeCollectionViewCell{
                            
                            cell.saveRecipeImageView.image = UIImage(name: "saveUnfilled")
                            self.collectionData[index].isSaved = false
                        }
                    }else{
                        if let cell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? GenricRecipeCollectionViewCell{
                            
                            cell.saveRecipeImageView.image = UIImage(name: "saveFilled")
                            self.collectionData[index].isSaved = true
                        }
                        let msg = localizedString("recipe_save_success", comment: "")
                        ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "saveFilled") , -1 , false) { (sender , index , isUnDo) in  }
                    }
                    
                }else{
                    
                    if self.collectionData[index].isSaved{
                        if let cell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? GenricRecipeCollectionViewCell{
                            
                                cell.saveRecipeImageView.image = UIImage(name: "saveFilled")
                            
                        }
                    }else{
                        if let cell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? GenricRecipeCollectionViewCell{
                            
                                cell.saveRecipeImageView.image = UIImage(name: "saveUnfilled")
                            
                        }
                    }
                }
            }
        }
        
    }
    
    @objc func saveButtonHandler(sender : UIButton){
        
        if let index = sender.tag as? Int{
            if collectionData.count > index && collectionView!.numberOfSections >= 0{
                if collectionData[index].isSaved{
                    apiCallSaveRecipe(index: index, isSave: false)
                }else{
                    apiCallSaveRecipe(index: index, isSave: true)
                }
            }
        }
    }
    
}
extension GenricRecipeCell : UICollectionViewDelegate , UICollectionViewDataSource {
    
    
    // MARK:- UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count  // return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KGenricRecipeCollectionViewCell , for: indexPath) as! GenricRecipeCollectionViewCell
        cell.recipeDetailBGView.isHidden = showMiniVersion
        cell.setupRecipeBGView()
        cell.setRecipe(collectionData[indexPath.row])
        cell.saveRecipeButton.tag = indexPath.row
        cell.saveRecipeButton.addTarget(self, action: #selector(self.saveButtonHandler(sender:)), for: .touchUpInside)
        //  cell.contentView.backgroundColor = .gray
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       
        if let topVC = UIApplication.topViewController(){
            
            
            
            
            
           // topVC.navigationController?.setNavigationBarHidden(true, animated: true)
//            (topVC.tabBarController?.navigationController as? ElgrocerGenericUIParentNavViewController)?.setLogoHidden(true)
//            (topVC.tabBarController?.navigationController as? ElgrocerGenericUIParentNavViewController)?.setBasketButtonHidden(true)
//            
            let selectedRecipe = collectionData[indexPath.row]
            FireBaseEventsLogger.trackRecipeClick(recipe: selectedRecipe)
        
//            let recipeDetail : RecipeDetailViewController = ElGrocerViewControllers.recipesDetailViewController()
            let recipeDetail : RecipeDetailVC = ElGrocerViewControllers.recipeDetailViewController()
            recipeDetail.source = FireBaseEventsLogger.gettopViewControllerName() ?? "UnKnown"
            recipeDetail.recipe = selectedRecipe
            recipeDetail.addToBasketMessageDisplayed = { [weak self] in
                guard let self = self else {return}
            }
            if UIApplication.topViewController()?.tabBarController?.selectedIndex == 1 {
                if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                    recipeDetail.groceryA = [grocery]
                }
            }
            recipeDetail.hidesBottomBarWhenPushed = true
            let trackeventAction = (selectedRecipe.recipeName ?? " ") + " View"
            GoogleAnalyticsHelper.trackRecipeWithName(trackeventAction)
            if let recipeName = selectedRecipe.recipeName {
                ElGrocerEventsLogger.sharedInstance.trackRecipeDetailNav(selectedRecipe.recipeChef?.chefName ?? "", recipeName: recipeName)
                MixpanelEventLogger.trackHomeRecipesClick(recipeName: recipeName, recipeId: "\(selectedRecipe.recipeID)", chefId: "\(selectedRecipe.recipeChef?.chefID ?? -1)", chefName: selectedRecipe.recipeChef?.chefName ?? "")
            }
            
            let navRecipeDetailController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navRecipeDetailController.viewControllers = [recipeDetail]
            navRecipeDetailController.modalPresentationStyle = .fullScreen
            

            topVC.navigationController?.present(navRecipeDetailController, animated: true, completion: nil)
        }
        
    }
    
}

extension GenricRecipeCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width =  (ScreenSize.SCREEN_WIDTH - 32)//(ScreenSize.SCREEN_WIDTH * 0.168 )) //0.1892
        var cellSize:CGSize = CGSize(width: width , height: width )/// CGFloat(KRecipeCellRatio))
//        if cellSize.width > collectionView.frame.width {
//            cellSize.width = collectionView.frame.width
//        }
//        
//        if cellSize.height > collectionView.frame.height {
//            cellSize.height = collectionView.frame.height
//        }
        if showMiniVersion {
            let w =  (ScreenSize.SCREEN_WIDTH * 0.385 )
            cellSize = CGSize(width: w , height: w*1.355 )
        }
        return cellSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return showMiniVersion ? 16 : 32
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16 , bottom: 0 , right: 16)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row <= collectionData.count{
            self.pageControl.currentPage = indexPath.row
        }
        
    }
    
    
}

