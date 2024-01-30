//
//  SubCateSegmentTableViewHeader.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 06/09/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

let KSubCateSegmentTableViewHeaderWithMessageHeight = CGFloat(171)
let KSubCateSegmentTableViewHeaderWithOutMessageHeight = CGFloat(109)


let MessageLblHeight = 62

class SubCateSegmentTableViewHeader: UIView {

    @IBOutlet var lblTitleBGView: UIView!
    @IBOutlet var MsgLableHeight: NSLayoutConstraint!
    @IBOutlet var lblCategoryName: UILabel!
    @IBOutlet var lblSubCategorySuperBGView: UIView!
    @IBOutlet var lblSubCategoryMsgBGView: AWView!
    @IBOutlet var lblSubCategoryMsg: UILabel!
    var titlesArray = [String]()
    @IBOutlet var segmentSuperBGView: UIView!
    @IBOutlet var segmenntCollectionView: AWSegmentView! {
        didSet {
            segmenntCollectionView.segmentViewType = .subCategories
            segmenntCollectionView.commonInit()
        }
    }
    var viewLayoutCliced: (()->Void)?
    @IBOutlet var viewLayoutButton: UIButton!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func setUpUIColors() {
        self.lblTitleBGView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        self.lblSubCategorySuperBGView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        self.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        self.segmentSuperBGView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        self.segmenntCollectionView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        self.lblCategoryName.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
    }
    
    func setBounds (_ rect : CGRect) {
        self.bounds = CGRect.init(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
    }
    
    func configureView (_ segmentData : [String] , index : NSIndexPath) {
        setUpUIColors()
        segmenntCollectionView.lastSelection = index as IndexPath
        segmenntCollectionView.refreshWith(dataA: segmentData)
    }
    
    func refreshWithSubCategoryText (_ text : String) {
        setUpUIColors()
        self.lblSubCategoryMsg.text = text
        if text.count > 0 {
            self.MsgLableHeight.constant = CGFloat(MessageLblHeight)
        }else{
          self.MsgLableHeight.constant = 0
        }
    }
    func refreshWithCategoryName (_ text : String) {
        self.lblCategoryName.text = text
    }
    @IBAction func viewLayoutHandler(_ sender: Any) {
        if let clouser = self.viewLayoutCliced {
            clouser()
        }
    }
    
}
