//
//  GenricHomeRecipeTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import RxSwift

let KGenricHomeRecipeTableViewCell = "GenricHomeRecipeTableViewCell"
class GenricHomeRecipeTableViewCell: RxUITableViewCell {
    private var viewModel: RecipeCellViewModelType!
   
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
    
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    
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
        } else {
            self.recipeList.collectionView?.isPagingEnabled = false
        }
        
    }
    
    
    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? RecipeCellViewModelType else { return }
        
        self.viewModel = viewModel
        self.bindView()
    }
}

// MARK: - Configure Table View with View Model
extension GenricHomeRecipeTableViewCell {
    func bindView() {
        viewModel.outputs.recipeList.subscribe(onNext: { [weak self] cRecipeList in
            guard let self = self else { return }
            
            self.recipeList.configureData(cRecipeList, page: self.pageControl)
            
            self.cellHeight.constant = cRecipeList.isNotEmpty ? (ScreenSize.SCREEN_WIDTH - 32) + 23 : 0
            
        }).disposed(by: disposeBag)
        
        viewModel.outputs.isBgGrey.subscribe(onNext: { [weak self] bgEnabled in
            guard let self = self else { return }
            
            self.recipeList.backgroundColor = bgEnabled ? .tableViewBackgroundColor() : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            self.recipeList.superview?.backgroundColor = bgEnabled ? .tableViewBackgroundColor() : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.outputs.recipeList, viewModel.outputs.showMiniView).subscribe(onNext: { [weak self] recipeA, isMiniView in
            guard let self = self else { return }
            
            self.recipeList.showMiniVersion = isMiniView
            
            if !isMiniView {
                self.recipeList.collectionView?.isPagingEnabled = true
                if recipeA.count > 1 {
                    self.pageControl.numberOfPages = recipeA.count
                    self.pageControl.isHidden = false
                }else{
                    self.pageControl.numberOfPages = 0
                    self.pageControl.isHidden = true
                }
            } else {
                self.recipeList.collectionView?.isPagingEnabled = false
            }
        }).disposed(by: disposeBag)
    }
}
