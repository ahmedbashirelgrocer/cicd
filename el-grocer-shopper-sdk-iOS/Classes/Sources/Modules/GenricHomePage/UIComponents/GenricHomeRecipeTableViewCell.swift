//
//  GenricHomeRecipeTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
let KGenricHomeRecipeTableViewCell = "GenricHomeRecipeTableViewCell"
class GenricHomeRecipeTableViewCell: UITableViewCell {
   
    @IBOutlet var recipeList: GenricRecipeCell!{
        didSet{
            recipeList.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    @IBOutlet var pageControl: UIPageControl! {
        didSet {
            pageControl.currentPageIndicatorTintColor = ApplicationTheme.currentTheme.pageControlActiveColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureData(_ recipeA  : [Recipe], isMiniView:Bool = false, withGrayBg: Bool = false) {
        recipeList.backgroundColor = withGrayBg ? .tableViewBackgroundColor() : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        recipeList.superview?.backgroundColor = recipeList.backgroundColor
        recipeList.showMiniVersion = isMiniView
        recipeList.configureData(recipeA , page: pageControl)
        
        //permanently hiding page control Darkstore new UI 2.0 for home and universal search
        if !isMiniView {
            self.recipeList.collectionView?.isPagingEnabled = true
            if recipeA.count > 1{
                self.pageControl.numberOfPages = recipeA.count
                self.pageControl.isHidden = false
            }else{
                self.pageControl.numberOfPages = 0
                self.pageControl.isHidden = true
            }
        }else {
            self.recipeList.collectionView?.isPagingEnabled = false
        }
        
    }
    
    
    
}
