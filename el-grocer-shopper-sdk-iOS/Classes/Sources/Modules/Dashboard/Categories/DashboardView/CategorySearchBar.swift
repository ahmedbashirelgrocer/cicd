//
//  CategorySearchBar.swift
//  ElGrocerShopper
//
//  Created by Azeem Akram on 13/10/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit

let kSearchBarHeight: CGFloat = 60

protocol CategorySearchBarDelegate : class {
    func categorySearchBarActivated()
    func didTapCategorySearchBar()
}


class CategorySearchBar: UIView {

    @IBOutlet var searchBarBGView: AWView!{
        didSet{
            searchBarBGView.cornarRadius = 22
        }
    }
    @IBOutlet weak var searchLabel: UILabel!

    weak var delegate:CategorySearchBarDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.backgroundColor = ApplicationTheme.currentTheme.navigationBarColor

        self.setUpSearchViewAppearance()
    }

    func setUpSearchViewAppearance() {

        self.searchLabel.text = localizedString("search_products_add", comment: "")
        self.searchLabel.font = UIFont.SFProDisplayNormalFont(14)
        self.searchLabel.textColor = UIColor.darkGrayTextColor()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.naviagteToSearchController))
        self.addGestureRecognizer(tapGesture)
    }

    @objc func naviagteToSearchController(){

        if self.delegate != nil {
            self.delegate?.didTapCategorySearchBar()
        }
    }
}

