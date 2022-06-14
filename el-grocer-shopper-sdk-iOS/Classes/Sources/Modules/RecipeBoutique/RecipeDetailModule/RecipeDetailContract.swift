//
//  RecipeDetailContract.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 24/03/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

// MARK: View Output (Presenter -> View)
protocol PresenterToViewRecipeProtocol: class {

    
    func setUpApearance()
    func setProductNumber()
    //func getRecipeDetialData()
    func reloadData()
    func initailCellRegistration()
}


// MARK: View Input (View -> Presenter)
protocol ViewToPresenterRecipeProtocol{

    func viewDidLoad(view : RecipeDetailVC)
    func heightForFooter(section : Int) -> CGFloat
    func viewForFooter() -> UIView
    func heightForRowAtIndexPath(indexPath : IndexPath , tableView : UITableView) -> CGFloat
    func numberOfRowsInSection(section : Int) -> Int
    func addSingleIngrediantsToCartHandler(recipe : Recipe? , ingrediants : [RecipeIngredients]? , grocery : Grocery?)
    func addAllIngrediantsToCartHandler(recipe : Recipe? , ingrediants : [RecipeIngredients]? , grocery : Grocery?)
}

extension ViewToPresenterRecipeProtocol {
    func addSingleIngrediantsToCartHandler(recipe : Recipe? , ingrediants : [RecipeIngredients]? , grocery : Grocery?){}
    
}


// MARK: Interactor Input (Presenter -> Interactor)
protocol PresenterToInteractorRecipeProtocol: class {
    
//    var presenter: InteractorToPresenterQuotesProtocol? { get set }

    func apiCallSaveRecipe(recipeId : Int64 , isSave : Bool)
    func getRecipeDetialData(_ recipe : Recipe , grocery : Grocery? , presenter : RecipePresenter)
}


// MARK: Interactor Output (Interactor -> Presenter)
protocol InteractorToPresenterRecipeProtocol: class {
    func noNewDataSuccess()
    func fetchResponceSuccess(recipe : Recipe)
    func fetchResponceFailure()
    func saveResponce(sucess : Bool)
    
}


// MARK: Router Input (Presenter -> Router)
protocol PresenterToRouterRecipeProtocol: class {
    
//    static func createModule() -> UINavigationController
//
//    func pushToQuoteDetail(on view: PresenterToViewQuotesProtocol, with quote: Quote)
}
