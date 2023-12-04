//
//  SmilesNavigationViewAr.swift
//  ElGrocerShopper
//
//  Created by Sarmad Abbas on 03/11/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

protocol SmilesNavigationViewType: UIView {
    
    var profileButton: UIButton { get }
    var cartButton: UIButton { get }
    var titleView: UIView { get }
    var logoView: UIImageView { get }
    var smilesPointsView: SmilesPointsView { get }
    
    func smilesViewTapped()
    func setSmilesPoints(_ points: Int)
    func clearSmilesPoints()
}

//class SmilesNavigationView: SmilesNavigationViewType {
//
//    var profileButton: UIButton { navigatinonView.profileButton }
//
//    var cartButton: UIButton { navigatinonView.cartButton }
//
//    var titleView: UIView { navigatinonView.titleView }
//
//    var logoView: UIImageView { navigatinonView.logoView }
//
//    var smilesPointsView: SmilesPointsView { navigatinonView.smilesPointsView }
//
//    private var navigatinonView: SmilesNavigationViewType!
//
//    init(language: String) {
//        if language == "ar" {
//            navigatinonView = SmilesNavigationViewAr()
//        } else {
//            navigatinonView = SmilesNavigationViewEn()
//        }
//    }
//
//    func smilesViewTapped() {
//        navigatinonView.smilesViewTapped()
//    }
//
//    func setSmilesPoints(_ points: Int) {
//        navigatinonView.setSmilesPoints(points)
//    }
//
//    func clearSmilesPoints() {
//        navigatinonView.clearSmilesPoints()
//    }
//}
