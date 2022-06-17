//
//  stetchyRecipeHeaderView.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 25/03/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import Storyly
class stetchyRecipeHeaderView: UIView {

    @IBOutlet var headerCollectionView: UICollectionView!{
        didSet{
            headerCollectionView.bounces = false
        }
    }
    @IBOutlet var headerPageControl: UIPageControl!{
        didSet{
            headerPageControl.numberOfPages = 0
        }
    }
    
    class func loadFromNib() -> stetchyRecipeHeaderView? {
        return self.loadFromNib(withName: "View")
    }

    var recipe : Recipe?
    
    var storyGroup : StoryGroup? = nil {
        didSet{
            self.headerCollectionView.reloadData()
        }
    }
    var storylyView: StorylyView? = nil {
        didSet{
            self.headerCollectionView.reloadData()
        }
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        registerCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //registerCell()
    }
    
    
    
    func setInitailAppearence(){
        self.backgroundColor = UIColor.white
        
    }
    
    func setPageControl(){
        if recipe?.recipeImages?.count ?? 0 > 1 {
            self.headerPageControl.numberOfPages = (recipe?.recipeImages!.count)!
        }else{
            self.headerPageControl.numberOfPages = 0
        }
        
    }
    
    func configureHeader(recipe : Recipe){
        self.recipe = recipe
        self.setPageControl()
        self.headerCollectionView.reloadData()
    }
    
    func registerCell(){
        self.headerCollectionView.register(UINib.init(nibName: "recipeCustomHeaderCVC", bundle: nil), forCellWithReuseIdentifier: "recipeCustomHeaderCVC")
        headerCollectionView.delegate = self
        headerCollectionView.dataSource = self
        
        self.storylyView = nil
        self.storyGroup = nil
        
        headerCollectionView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        //[self.myScrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        
    }
}
extension stetchyRecipeHeaderView : UICollectionViewDelegate ,  UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if recipe?.recipeImages != nil{
            return (recipe?.recipeImages?.count)!
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCustomHeaderCVC", for: indexPath) as! recipeCustomHeaderCVC
        cell.imageView.image = UIImage(name: "product_placeholder")
        //cell.setUpInitialAppearence()
        if recipe?.recipeImages != nil {
            if recipe?.recipeImages?[indexPath.row].isEmpty == false{
                cell.configureCell(recipeImage: (recipe?.recipeImages?[indexPath.row])!)
            }
            
        }
        
        cell.playClicked = { [weak self] in
            if self != nil{
                guard self?.storylyView != nil && self?.storyGroup != nil else {
                    cell.btnPlay.isHidden = true
                    return
                }
                self?.storylyView?.openStory(storyGroupId: self?.storyGroup?.id ?? 0)
            }
            
        }
        
        if self.headerPageControl.visibility == .gone {
            if (self.storylyView != nil && self.storyGroup != nil){
                cell.btnPlay.isHidden = false
            }else{
                cell.btnPlay.isHidden = !(self.storylyView != nil && self.storyGroup != nil)
            }
                
            
            
        }else{
            if indexPath.row == 0  && self.storylyView != nil && self.storyGroup != nil {
                cell.btnPlay.isHidden = false
            }else{
                cell.btnPlay.isHidden = true
            }
        }
        
       
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.headerPageControl.currentPage = indexPath.row
    }
    
}
extension stetchyRecipeHeaderView : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height )
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
}
