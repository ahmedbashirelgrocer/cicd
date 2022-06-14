//
//  RecipeBoutiqueListInteractor.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 04/04/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class RecipeBoutiqueListInteractor: PresenterToInteractorRecipeListProtocol {

    lazy var dataHandler : RecipeDataHandler = {
        let dataH = RecipeDataHandler()
        return dataH
    }()
    var presenter : RecipeBoutiqueListPresenter!

    

    func setPresenter(presenter : RecipeBoutiqueListPresenter){
        self.presenter = presenter
    }
    func setDataHandlerDelegate(delegate : RecipeBoutiqueListPresenter){
        dataHandler.delegate = delegate
    }
    
    
    func apiCallSaveRecipe(index : Int , isSave : Bool ){
        if presenter.recipeListArray?[index].recipeID != -1 && presenter.recipeListArray != nil{
            dataHandler.saveRecipeApiCall(recipeID: presenter.recipeListArray![index].recipeID!, isSave: isSave) { (Done) in
                if Done{
                    self.presenter.saveResponceSuccess(done: Done, index: index)
                }else{
                    self.presenter.saveResponceSuccess(done: Done, index: index)

                }
            }
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
