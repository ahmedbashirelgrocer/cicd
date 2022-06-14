//
//  RecipeBoutiqueListRouter.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 04/04/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class RecipeBoutiqueListRouter: PresenterToRouterRecipeProtocol {

    

    func gotoFilterController (  chef : CHEF? ,  category : RecipeCategoires? , view : RecipeBoutiqueListVC) {
        
        guard chef != nil || category != nil  else {
            return
        }
        let recipeFilter : FilteredRecipeViewController = ElGrocerViewControllers.recipeFilterViewController()
        recipeFilter.dataHandler.setFilterChef(chef)
        recipeFilter.dataHandler.setFilterRecipeCategory(category)
        guard let groceryArr = view.groceryA else {
            return
        }
        guard let chefToPass = chef else {
            return
        }
        recipeFilter.groceryA = groceryArr
        recipeFilter.chef = chefToPass
        recipeFilter.vcTitile = (chef == nil ? category?.categoryName : chef?.chefName)!
        recipeFilter.hidesBottomBarWhenPushed = true
        view.navigationController?.pushViewController(recipeFilter, animated: true)
        
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
