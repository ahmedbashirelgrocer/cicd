//
//  SmilesPointsViewAr.swift
//  SmilesNavigationBaar
//
//  Created by Sarmad Abbas on 10/10/2022.
//

import UIKit

class SmilesPointsViewAr: UIView, SmilesPointsView {
    let titleLogo: UIImageView = {
        let view = UIImageView(image: UIImage(name: "smiles_logo_white"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var titleLabel: CircularGradientLabel = {
        let label = CircularGradientLabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    lazy var animationView: UIView = {
        let innerView = UIView(frame: CGRect(x: 0, y: -50, width: 15, height: 150))
        innerView.backgroundColor = .white
        innerView.alpha = 0.5
        innerView.transform = CGAffineTransform.identity.rotated(by: Double.pi / 4)
        
        let outerView = UIView(frame: CGRect(x: -40, y: -10, width: 17, height: 100))
        outerView.backgroundColor = .clear
        outerView.addSubview(innerView)
        innerView.center = outerView.center
        
        return outerView
    }()
    
    func setSmilesPoints(_ points: Int) {
//        if points == 0 {
//            titleLabel.text = ""
//            return
//        }
        
        titleLabel.textColor = titleLabel.textColor.withAlphaComponent(0)
        
        let setPoints = {
            if points == -1 {
                self.titleLabel.text = "    \(localizedString("earn_rewards_now", comment: ""))    "
            } else {
                let string = localizedString("smiles_pts", comment: "")
                self.titleLabel.text = String.localizedStringWithFormat(string, "\(points)")
            }
            self.layoutIfNeeded()
        }
        
        let animateAlpha = { (_: Bool) in
            UIView.animate(withDuration: 0.4, delay: 0.45, options: .curveEaseIn) {
                self.titleLabel.textColor = self.titleLabel.textColor.withAlphaComponent(1)
                self.layoutIfNeeded()
            }
        }
        
        let traslatetion = {
            self.animationView.frame.origin.x = self.titleLabel.frame.size.width + 30
        }
        
        let didComplete = { (_: Bool) in
            self.animationView.frame.origin.x = -40
            self.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: setPoints, completion: animateAlpha)
        UIView.animate(withDuration: 0.6, delay: 0.9, options: .curveEaseIn, animations: traslatetion, completion: didComplete)
    }
    
    func initialSetup() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLogo)
        addSubview(titleLabel)
        titleLabel.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            titleLogo.rightAnchor.constraint(equalTo: rightAnchor),
            titleLogo.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 0),
            titleLogo.heightAnchor.constraint(equalToConstant: 22),
            titleLogo.widthAnchor.constraint(equalTo: titleLogo.heightAnchor, multiplier: 116 / 48)
        ])
        NSLayoutConstraint.activate([
            titleLabel.rightAnchor.constraint(equalTo: titleLogo.leftAnchor, constant: -2),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            // titleLabel.topAnchor.constraint(equalTo: topAnchor),
            // titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    convenience init () {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    internal required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
}
