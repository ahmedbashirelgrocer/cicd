//
//  RecipeBoutiqueListContract.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 04/04/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

// MARK: View Output (Presenter -> View)
protocol PresenterToViewRecipeListProtocol: class {
    
    func setUpApearance()
    func setProductNumber()
    func initailCellRegistration()
    
}


// MARK: View Input (View -> Presenter)
protocol ViewToPresenterRecipeListProtocol{
    
    func viewDidLoad(view : RecipeBoutiqueListVC)
    func viewWillAppear(view : RecipeBoutiqueListVC)
    func viewDidAppear(view : RecipeBoutiqueListVC)
    func updateItemsCount()
    func addClouser()
    func numberOfSecions() -> Int
    func numberOfRowsInSection(section : Int) -> Int
    func heightForRowInSection(indexPath : IndexPath, isSearching: Bool) -> CGFloat
    func getFilteredData(isNeedToReset : Bool)
    func saveButtonHandler(isSaved : Bool , index : Int)
}

extension ViewToPresenterRecipeListProtocol {
    func updateItemsCount() {}
}


// MARK: Interactor Input (Presenter -> Interactor)
protocol PresenterToInteractorRecipeListProtocol: class {
    func setPresenter(presenter : RecipeBoutiqueListPresenter)
    func setDataHandlerDelegate(delegate : RecipeBoutiqueListPresenter)
    func apiCallSaveRecipe(index : Int , isSave : Bool )
}


// MARK: Interactor Output (Interactor -> Presenter)
protocol InteractorToPresenterRecipeListProtocol: class {
    func saveResponceSuccess(done : Bool , index : Int)
    func saveResponceFaliure(done : Bool)
    
}


// MARK: Router Input (Presenter -> Router)
protocol PresenterToRouterRecipeListProtocol: class {
    func gotoFilterController (  chef : CHEF? ,  category : RecipeCategoires? , view : RecipeBoutiqueListVC)
}
