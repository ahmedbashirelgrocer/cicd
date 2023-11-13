//
//  SmilesPointsViewEn.swift
//  SmilesNavigationBaar
//
//  Created by Sarmad Abbas on 10/10/2022.
//

import UIKit

class SmilesPointsViewEn: UIView, SmilesPointsView {
    let elLogo: UIImageView = {
        let view = UIImageView(image: UIImage(name: "el_logo"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        return view
    }()
    
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
        label.backgroundColor = UIColor.colorWithHexString(hexString: "423B79")
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
                self.titleLabel.text = localizedString("earn_rewards_now", comment: "")
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
        
        addSubview(elLogo)
        addSubview(titleLogo)
        addSubview(titleLabel)
        titleLabel.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            elLogo.leftAnchor.constraint(equalTo: leftAnchor),
            elLogo.centerYAnchor.constraint(equalTo: centerYAnchor),
            elLogo.heightAnchor.constraint(equalToConstant: 21),
            elLogo.widthAnchor.constraint(equalTo: titleLogo.heightAnchor, multiplier: 20 / 21)
        ])
        
        NSLayoutConstraint.activate([
            titleLogo.leftAnchor.constraint(equalTo: elLogo.rightAnchor, constant: 8),
            titleLogo.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLogo.heightAnchor.constraint(equalToConstant: 16),
            titleLogo.widthAnchor.constraint(equalTo: titleLogo.heightAnchor, multiplier: 52 / 16)
        ])
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: titleLogo.rightAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 34)
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
