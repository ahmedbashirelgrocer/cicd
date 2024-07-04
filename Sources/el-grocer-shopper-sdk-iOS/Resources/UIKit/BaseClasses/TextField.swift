//
//  TextField.swift
//  iOSApp
//
//  Created by Abbas on 07/06/2021.
//

import UIKit

public class TextField: UITextField {

    var isCircular = false { didSet {
        invalidateIntrinsicContentSize()
    } }

    convenience public init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if isCircular { layer.cornerRadius = frame.size.height / 2 }
    }

    private func makeUI() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true
    }
}

// MARK: Utalities
public extension UITextField {
    func setClearImage(_ image: UIImage?, for state: UIControl.State) {
        guard let image = image else { return }
        let clearButton = value(forKey: "_clearButton") as? UIButton
        clearButton?.setImage(image, for: state)
        clearButton?.backgroundColor = UIColor.clear
    }

    var clearImageTint: UIColor? {
        set { (value(forKey: "_clearButton") as? UIButton)?.tintColor = newValue }
        get { return (value(forKey: "_clearButton") as? UIButton)?.tintColor }
    }
}
