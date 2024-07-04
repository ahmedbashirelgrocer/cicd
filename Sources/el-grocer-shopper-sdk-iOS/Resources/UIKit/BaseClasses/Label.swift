//
//  Label.swift
//  iOSApp
//
//  Created by Abbas on 07/06/2021.
//

import UIKit

public class Label: UILabel {

    open var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    open override var text: String? {
        set { super.text = newValue; makeUI()}
        get { return super.attributedText?.string ?? super.text }
    }
    public override var font: UIFont! {
        set { super.font = newValue; makeUI()}
        get { return super.font }
    }
    public override var textColor: UIColor! {
        set { super.textColor = newValue; makeUI()}
        get { return super.textColor }
    }
    
    open var spacing:Float? = nil { didSet {
        makeUI()
    }}
    
    open var lineSpacing:CGFloat? = nil { didSet {
        makeUI()
    }}

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    private func makeUI() {
        layer.masksToBounds = true
        updateUI()
    }

    private func updateUI() {
        setNeedsDisplay()
        if !(spacing == nil && self.lineSpacing == nil) {
            self.setAttributedText(text ?? "")
        }
    }
}

public extension Label {
    
    @discardableResult func setInsets(_ insets:UIEdgeInsets) -> Self {
        textInsets = insets
        return self
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    var leftTextInset: CGFloat {
        get { return textInsets.left }
        set { textInsets.left = newValue }
    }

    var rightTextInset: CGFloat {
        get { return textInsets.right }
        set { textInsets.right = newValue }
    }

    var topTextInset: CGFloat {
        get { return textInsets.top }
        set { textInsets.top = newValue }
    }

    var bottomTextInset: CGFloat {
        get { return textInsets.bottom }
        set { textInsets.bottom = newValue }
    }
}

extension Label {
    fileprivate func setAttributedText(_ string:String) {
        let attributedString = NSMutableAttributedString(string: string, attributes: [.font:font!, .foregroundColor:textColor!])
        if let spacing = spacing {
            attributedString.addAttributes([.kern : spacing], range: string.range )
        }
        
        if let lineSpacing = lineSpacing {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            paragraphStyle.alignment = textAlignment
            attributedString.addAttributes([.paragraphStyle : paragraphStyle, .font:font!, .foregroundColor:textColor!], range: string.range )
        }
        attributedText = attributedString
    }
}
