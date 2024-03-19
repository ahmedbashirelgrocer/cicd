//
//  RecipeCategoriesHeader.swift
//  Adyen
//
//  Created by saboor Khan on 19/03/2024.
//

import UIKit

class RecipeCategoriesHeader: UIView {
    
    var recipeCategorySelected: ((_ selectedCategory : RecipeCategoires?)->Void)?

    @IBOutlet weak var categoryListView: RecipeCategoriesList!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        addClosure()
    }
    
    func configureHeader(groceryA: [Grocery]) {
        self.categoryListView.getCategoryData(savedCategories: false,groceryA)
        addClosure()
    }
    
    func addClosure(){
        categoryListView.recipeCategorySelected = {[weak self] (selectedCategory) in
            guard let self = self else {return}
            guard selectedCategory != nil else {
                return
            }
            self.categoryListView.categorySelected = selectedCategory
            
            if let recipeCategorySelected = self.recipeCategorySelected {
                recipeCategorySelected(selectedCategory)
            }
            
        }
    }
    
    class func loadFromNib() -> RecipeCategoriesHeader? {
        return self.loadFromNib(withName: "RecipeCategoriesHeader")
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
