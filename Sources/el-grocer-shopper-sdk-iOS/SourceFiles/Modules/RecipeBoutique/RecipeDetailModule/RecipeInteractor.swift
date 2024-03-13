//
//  RecipeInteractor.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 24/03/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class RecipeInteractor: PresenterToInteractorRecipeProtocol {
    
    
    
    var presenter : RecipePresenter!
    lazy var dataHandler : RecipeDataHandler = {
        let dataH = RecipeDataHandler()
        dataH.delegate = self
        return dataH
    }()
//    weak var presenter: InteractorToPresenterQuotesProtocol?

    
    func apiCallSaveRecipe(recipeId : Int64 , isSave : Bool){
        dataHandler.saveRecipeApiCall(recipeID: recipeId, isSave: isSave) { (Done) in
            if Done{
                self.presenter.saveResponce(sucess: true)
                
            }else{
                self.presenter.saveResponce(sucess: false)
                
            }
        }
    }

    func getRecipeDetialData(_ recipe : Recipe , grocery : Grocery? , presenter : RecipePresenter) {
        
        self.presenter = presenter
        
        if recipe != nil {
            if  recipe.recipeID != nil {
                if recipe.recipeID != -1 {
                    dataHandler.getRecipDetail((recipe.recipeID)!, retailerID: grocery?.dbID)
                    return;
                }else{
                    self.presenter.fetchResponceFailure()
                }
            }else{
                self.presenter.fetchResponceFailure()
            }
            
        }
        self.presenter.noNewDataSuccess()
    }
}

extension RecipeInteractor : RecipeDataHandlerDelegate {
    
    func recipeDetial(_ recipe: Recipe) {
       elDebugPrint("interactor")
        self.presenter.fetchResponceSuccess(recipe: recipe)
        SpinnerView.hideSpinnerView()
    }
    
    func addToCartCompleted() {
        ElGrocerUtility.sharedInstance.delay(1.0) {
            let msg = localizedString("product_added_to_cart", comment: "")
            ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
        }
        self.presenter.view.addToCartCompleted()
    }
    
}
