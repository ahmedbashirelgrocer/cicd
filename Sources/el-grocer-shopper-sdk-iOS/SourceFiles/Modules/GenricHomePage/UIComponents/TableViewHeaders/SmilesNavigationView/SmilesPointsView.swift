//
//  SmilesPointsView.swift
//  SmilesNavigationBaar
//
//  Created by Sarmad Abbas on 10/10/2022.
//

import UIKit

protocol SmilesPointsView: UIView {
    var titleLabel: CircularGradientLabel { get }
    var animationView: UIView  { get }
    func setSmilesPoints(_ points: Int)
}
