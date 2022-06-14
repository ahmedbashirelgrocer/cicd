//
//  CustomCollectionViewWithProducts.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 15/02/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

let CustomCollectionViewTag = -101

class CustomCollectionView: UIView {

    
    var collectionView: UICollectionView?
    var collectionViewFlowLayout: UICollectionViewFlowLayout?
    var scrollViewDidEndDecelerating: ((_ scrollView : UIScrollView?)->Void)?
    
    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
           //  self.collectionView?.reloadData()
        }
    }
    @IBInspectable
    public var showScrollDirectionIndicator: Bool = false {
        didSet {
            self.collectionView?.showsVerticalScrollIndicator = self.showScrollDirectionIndicator
        }
    }

    @IBInspectable
    public var bgColor: UIColor = .clear {
        didSet {
            self.collectionView?.backgroundColor = self.bgColor
        }
    }

    enum Direction: String {
        case horizontal = "Horizontal" // lowercase to make it case-insensitive
        case vertical = "Vertical"
    }
    

    func reloadData() -> Void {
        
        Thread.OnMainThread {
            self.collectionView?.reloadData()
            self.resetConstraintsForCollectionView()
            self.collectionView?.setNeedsLayout()
            self.collectionView?.layoutIfNeeded()
            self.layoutIfNeeded()
        }
          
    }
    func getCustomFlowLayout(scrollDirection : String) -> UICollectionViewFlowLayout {

        let flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        if(scrollDirection == Direction.horizontal.rawValue) {
            flowLayout.scrollDirection = .horizontal
        } else {
            flowLayout.scrollDirection = .vertical
        }
        
        flowLayout.invalidateLayout()
       // flowLayout.sectionInset = UIEdgeInsets.init(top: sectionInsect, left: sectionInsect, bottom: sectionInsect, right: sectionInsect)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        return flowLayout

    }



    override func awakeFromNib() {
        super.awakeFromNib()
        self.addCollectionViewWithDirection(.horizontal)
    }
    func addCollectionViewWithDirection(_ direction : Direction) -> Void {
        


        if self.collectionView != nil {
            self.collectionView?.delegate = nil
            self.collectionView?.dataSource = nil
            self.collectionView?.removeFromSuperview()
            self.collectionView = nil
        }

        self.collectionViewFlowLayout = self.getCustomFlowLayout(scrollDirection: direction.rawValue)
        self.collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: self.collectionViewFlowLayout!)
        self.collectionView?.backgroundColor = self.bgColor
        self.collectionView?.showsVerticalScrollIndicator = self.showScrollDirectionIndicator
        self.collectionView?.showsHorizontalScrollIndicator = self.showScrollDirectionIndicator
        self.addSubview(self.collectionView!)
        
        if let lng = UserDefaults.getCurrentLanguage(){
            if lng == "ar"{
                self.collectionView?.semanticContentAttribute = .forceRightToLeft
            }else{
                self.collectionView?.semanticContentAttribute = .forceLeftToRight
            }
        }

        self.collectionView?.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute:NSLayoutConstraint.Attribute.left , multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0).isActive = true

         self.collectionView?.tag = CustomCollectionViewTag
    }

    func resetConstraintsForCollectionView() {
        
        Thread.OnMainThread {
            self.collectionView?.removeAllConstraints()
            self.collectionView?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: self.collectionView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.collectionView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.collectionView!, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute:NSLayoutConstraint.Attribute.left , multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.collectionView!, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0).isActive = true
        }
    }

}

extension UIView {

    public func removeAllConstraints() {
        var _superview = self.superview

        while let superview = _superview {
            for constraint in superview.constraints {

                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }

                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }

            _superview = superview.superview
        }

        self.removeConstraints(self.constraints)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
}
extension UICollectionViewFlowLayout {
    override open var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft
    }
}
public class CollectionViewFooterView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
