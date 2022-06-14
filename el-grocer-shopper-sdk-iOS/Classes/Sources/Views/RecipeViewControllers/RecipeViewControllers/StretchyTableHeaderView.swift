//
//  StretchyTableHeaderView.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 09/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import UIKit

class StretchyTableHeaderView: UIView {
    var imageViewHeight = NSLayoutConstraint()
    var imageViewBottom = NSLayoutConstraint()
    
    //var containerView: stetchyRecipeHeaderView!
    lazy var containerView : stetchyRecipeHeaderView = {
        let View = stetchyRecipeHeaderView.loadFromNib()
        return View!
    }()
    //var containerView: UIView!
    var imageView: UIImageView!{
        didSet{
            //imageView.isHidden = true
            imageView.image = UIImage(named: "product_placeholder")
        }
    }
    
    var containerViewHeight = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        
        //setViewConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createViews() {
        // Container View
        //containerView = stetchyRecipeHeaderView()
        
        
        //containerView = UIView()
        self.addSubview(containerView)
        
        // ImageView for background
        imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.alpha = 0.3
        imageView.isHidden = true
        imageView.backgroundColor = UIColor.newUIrecipelightGrayBGColor()
        imageView.contentMode = .scaleAspectFill
        containerView.addSubview(imageView)
    }
    
    func setViewConstraints() {
        // UIView Constraints
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            self.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            self.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        // Container View Constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        containerViewHeight = containerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        containerViewHeight.isActive = true
        
        // ImageView Constraints
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageViewBottom = imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        imageViewBottom.isActive = true
        imageViewHeight = imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        imageViewHeight.isActive = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        if scrollView.contentOffset.y > 100{
//            imageViewHeight.constant = 50
//            containerViewHeight.constant = 50
//            scrollView.contentSize = CGSize(width: ScreenSize.SCREEN_WIDTH, height: 50)
//        }else{
//            containerViewHeight.constant = scrollView.contentInset.top
//            let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
//            containerView.clipsToBounds = offsetY <= 0
//            imageViewBottom.constant = (offsetY >= 0 ? 0 : -offsetY / 2)
//            imageViewHeight.constant = max(offsetY + scrollView.contentInset.top,scrollView.contentInset.top)
//        }
        print("content ofset y : \(scrollView.contentOffset.y)")
        print("container height: \(containerViewHeight.constant)")
        print("imageviewbottom ofset: \(imageViewBottom.constant)")
        print("imageViewHeight.constant : \(imageViewHeight.constant)")
        
//        let y = -scrollView.contentOffset.y
//        let height = max(y, 60)
//        //imageView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: height)
//        containerView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: height)
//        
//        self.layoutIfNeeded()
       
    }
}
