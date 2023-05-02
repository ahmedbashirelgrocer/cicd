//
//  TextFieldCell.swift
//  ElGrocerShopper
//
//  Created by Sarmad Abbas on 29/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class SimpleTextFieldCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldBottomAnchor: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateView(leftImage: UIImage?) {
        if let image = leftImage {
            let imageView = UIImageView()
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 40))
            view.addSubview(imageView)
    
            imageView.image = image
            imageView.contentMode = .scaleAspectFit

            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
            
            view.widthAnchor.constraint(equalToConstant: 44).isActive = true
            
            textField.leftViewMode = .always
            textField.leftView = view
        } else {
            textField.leftViewMode = UITextField.ViewMode.never
            textField.leftView = nil
        }
    }
}
