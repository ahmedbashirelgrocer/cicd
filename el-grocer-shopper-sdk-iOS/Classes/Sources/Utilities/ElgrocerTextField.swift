//
//  ElgrocerTextField.swift
//  test
//
//  Created by M Abubaker Majeed on 16/02/2021.
//

import UIKit

public class ElgrocerTextField: UITextField {
    
    public enum FloatingDisplayStatus{
        case always
        case never
        case defaults
    }
    public enum DTBorderStyle{
        case none
        case rounded
        case sqare
        case top
        case bottom
        case left
        case right
    }
    
    fileprivate var lblFloatPlaceholder:UILabel             = UILabel()
                var lblError:UILabel                        = UILabel()
    
    fileprivate var paddingX:CGFloat                        = 16.0
    
    fileprivate let paddingHeight:CGFloat                   = 10.0
    fileprivate var borderLayer:CALayer                     = CALayer()
    public var dtLayer:CALayer                              = CALayer()
    public var floatPlaceholderColor:UIColor                = UIColor.black
    public var floatPlaceholderActiveColor:UIColor          = UIColor.black
    public var activeFieldColor:UIColor                =  UIColor.navigationBarColor()
    public var floatingLabelShowAnimationDuration           = 0.3
    public var floatingDisplayStatus:FloatingDisplayStatus  = .defaults
    public var borderWidth:CGFloat                          = 1.0{
        didSet{
            let borderStyle = dtborderStyle;
            dtborderStyle = borderStyle
        }
    }
    public var borderCornerRadius:CGFloat = 8.0{
        didSet{
            let borderStyle = dtborderStyle;
            dtborderStyle = borderStyle
        }
    }
    
    
    public var dtborderStyle:DTBorderStyle = .rounded {
        didSet{
            borderLayer.removeFromSuperlayer()
            switch dtborderStyle {
                case .none:
                    dtLayer.cornerRadius        = 0.0
                    dtLayer.borderWidth         = 0.0
                case .rounded:
                    dtLayer.cornerRadius        = borderCornerRadius
                    dtLayer.borderWidth         = borderWidth
                    dtLayer.borderColor         = borderColor.cgColor
                case .sqare:
                    dtLayer.cornerRadius        = 0.0
                    dtLayer.borderWidth         = borderWidth
                    dtLayer.borderColor         = borderColor.cgColor
                case .bottom,.left,.right,.top:
                    dtLayer.cornerRadius        = 0.0
                    dtLayer.borderWidth         = 0.0
                    borderLayer.backgroundColor = borderColor.cgColor
                    if dtborderStyle == .bottom {
                        borderLayer.frame = CGRect(x: 0, y: dtLayer.bounds.size.height - borderWidth, width: dtLayer.bounds.size.width, height: borderWidth)
                    }else if dtborderStyle == .left{
                        borderLayer.frame = CGRect(x: 0, y: 0, width: borderWidth, height: dtLayer.bounds.size.height)
                    }else if dtborderStyle == .right{
                        borderLayer.frame = CGRect(x: dtLayer.bounds.size.width - borderWidth, y: 0, width: borderWidth, height: dtLayer.bounds.size.height)
                    }else{
                        borderLayer.frame = CGRect(x: 0, y: 0, width: dtLayer.bounds.size.width, height: borderWidth - self.lblError.frame.height)
                    }
                    dtLayer.addSublayer(borderLayer)
            }
        }
    }
    
    public var errorMessage:String = ""{
        didSet{ lblError.text = errorMessage }
    }
    
    public var animateFloatPlaceholder:Bool = true
    public var hideErrorWhenEditing:Bool   = true
    
    public var errorFont = UIFont.SFProDisplayNormalFont(12) {
        didSet{
            lblError.setCaptionOneRegErrorStyle()
            invalidateIntrinsicContentSize()
        }
    }
    
    public var floatPlaceholderFont = UIFont.SFProDisplayNormalFont(12){
        didSet{
            lblFloatPlaceholder.font = floatPlaceholderFont
            invalidateIntrinsicContentSize()
        }
    }
    
    public var paddingYFloatLabel:CGFloat = 8.0{
        didSet{ invalidateIntrinsicContentSize() }
    }
    
    public var paddingYErrorLabel:CGFloat = 3.0{
        didSet{ invalidateIntrinsicContentSize() }
    }
    
    public var borderColor:UIColor = .clear {
        didSet{
            switch dtborderStyle {
                case .none,.rounded,.sqare:
                    dtLayer.borderColor = borderColor.cgColor
                case .bottom,.right,.top,.left:
                    borderLayer.backgroundColor = borderColor.cgColor
            }
            borderLayer.cornerRadius =  self.borderCornerRadius
        }
    }
    
    public var canShowBorder:Bool = true {
        didSet{
            switch dtborderStyle {
                case .none,.rounded,.sqare:
                    dtLayer.isHidden = !canShowBorder
                case .bottom,.right,.top,.left:
                    borderLayer.isHidden = !canShowBorder
            }
        }
    }
    
    public var placeholderColor:UIColor?{
        didSet{
            guard let color = placeholderColor else { return }
            attributedPlaceholder = NSAttributedString(string: placeholderFinal,
                                                       attributes: [NSAttributedString.Key.foregroundColor:color])
        }
    }
    
    fileprivate var x:CGFloat {
        
        if let leftView = leftView {
            return leftView.frame.origin.x + leftView.bounds.size.width - paddingX
        }
        
        return paddingX
    }
    
    fileprivate var fontHeight:CGFloat{
        return ceil(font!.lineHeight)
    }
    
    fileprivate var dtLayerHeight:CGFloat{
        return  floor(bounds.height)  //showErrorLabel ? floor(bounds.height - lblError.bounds.size.height - paddingYErrorLabel) : bounds.height
    }
    
    fileprivate var floatLabelWidth:CGFloat{
        
        var width = bounds.size.width
        
        if let leftViewWidth = leftView?.bounds.size.width{
            width -= leftViewWidth
        }
        
        if let rightViewWidth = rightView?.bounds.size.width {
            width -= rightViewWidth
        }
        
        return width - (self.x * 2)
    }
    
    fileprivate var placeholderFinal:String{
        if let attributed = attributedPlaceholder { return attributed.string }
        return placeholder ?? " "
    }
    
    fileprivate var isFloatLabelShowing:Bool = false
    
    fileprivate var showErrorLabel:Bool = false{
        didSet{
            
            guard showErrorLabel != oldValue else { return }
            
            guard showErrorLabel else {
                hideErrorMessage()
                return
            }
            
            guard !errorMessage.isEmptyStr else { return }
            showErrorMessage()
        }
    }
    
    override public var borderStyle: UITextField.BorderStyle{
        didSet{
            guard borderStyle != oldValue else { return }
            borderStyle = .none
        }
    }
    
    public override var textAlignment: NSTextAlignment{
        didSet{ setNeedsLayout() }
    }
    
    public override var text: String?{
        didSet{ self.textFieldTextChanged() }
    }
    
    override public var placeholder: String?{
        didSet{
            
            guard let color = placeholderColor else {
                lblFloatPlaceholder.text = placeholderFinal
                return
            }
            attributedPlaceholder = NSAttributedString(string: placeholderFinal,
                                                       attributes: [NSAttributedString.Key.foregroundColor:color])
        }
    }
    
    override public var attributedPlaceholder: NSAttributedString?{
        didSet{ lblFloatPlaceholder.text = placeholderFinal }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public func showError(message:String? = nil) {
        if let msg = message { errorMessage = msg }
        showErrorLabel = true
        self.borderColor = .redValidationErrorColor()
        
    }
    
    public func hideError()  {
        showErrorLabel = false
    }
    
    public func setInitialPadding(leftPadding: CGFloat) {
        self.paddingX = leftPadding
        self.commonInit()
    }
    
    
    fileprivate func commonInit() {
        
        dtborderStyle               = .rounded
        dtLayer.backgroundColor     = UIColor.textfieldBackgroundColor().cgColor// UIColor.locationScreenLightColor().cgColor
        
        floatPlaceholderColor       = UIColor.searchPlaceholderTextColor()
       // floatPlaceholderActiveColor = tintColor
        lblFloatPlaceholder.frame   = CGRect.zero
        lblFloatPlaceholder.alpha   = 0.0
        lblFloatPlaceholder.font    = floatPlaceholderFont
        lblFloatPlaceholder.text    = placeholderFinal
        
        addSubview(lblFloatPlaceholder)
        
        lblError.frame              = CGRect.zero
        lblError.font               = errorFont
        lblError.textColor          = UIColor.redValidationErrorColor()
        lblError.numberOfLines      = 0
        lblError.isHidden           = true
        
        addTarget(self, action: #selector(textFieldTextChanged), for: .editingChanged)
        addTarget(self, action: #selector(textFieldTextDidActive), for: .editingDidBegin)
        addTarget(self, action: #selector(textFieldTextDidEndEditing), for: .editingDidEnd)
        
        addSubview(lblError)
        
        layer.insertSublayer(dtLayer, at: 0)
    }
    
    fileprivate func showErrorMessage(){
        
        lblError.text = errorMessage
        lblError.isHidden = false
        let boundWithPadding = CGSize(width: bounds.width - (paddingX * 2), height: bounds.height)
        lblError.frame = CGRect(x: paddingX, y: 1, width: boundWithPadding.width, height: boundWithPadding.height)
        lblError.sizeToFit()
        
        invalidateIntrinsicContentSize()
        self.layoutSubviews()
    }
    
    func setErrorLabelAlignment() {
        var newFrame = lblError.frame
        
        if textAlignment == .right {
            newFrame.origin.x = bounds.width - paddingX - newFrame.size.width
        }else if textAlignment == .left{
            newFrame.origin.x = paddingX
        }else if textAlignment == .center{
            newFrame.origin.x = (bounds.width / 2.0) - (newFrame.size.width / 2.0)
        }else if textAlignment == .natural{
            
            if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft{
                newFrame.origin.x = bounds.width - paddingX - newFrame.size.width
            }
        }
        
        lblError.frame = newFrame
    }
    
    func setFloatLabelAlignment() {
        var newFrame = lblFloatPlaceholder.frame
        
        if textAlignment == .right {
            newFrame.origin.x = bounds.width - paddingX - newFrame.size.width
        }else if textAlignment == .left{
            newFrame.origin.x = paddingX
        }else if textAlignment == .center{
            newFrame.origin.x = (bounds.width / 2.0) - (newFrame.size.width / 2.0)
        }else if textAlignment == .natural{
            
            if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft{
                newFrame.origin.x = bounds.width - paddingX - newFrame.size.width
            }
            
        }
        
        lblFloatPlaceholder.frame = newFrame
    }
    
    fileprivate func hideErrorMessage(){
        lblError.text = ""
        lblError.isHidden = true
        lblError.frame = CGRect.init(x: lblError.frame.origin.x, y: lblError.frame.origin.y, width: lblError.frame.size.width, height: .leastNonzeroMagnitude)
        invalidateIntrinsicContentSize()
    }
    
    fileprivate func showFloatingLabel(_ animated:Bool) {
        
        let animations:(()->()) = {
            self.lblFloatPlaceholder.alpha = 1.0
            self.lblFloatPlaceholder.frame = CGRect(x: self.lblFloatPlaceholder.frame.origin.x,
                                                    y: self.paddingYFloatLabel,
                                                    width: self.lblFloatPlaceholder.bounds.size.width,
                                                    height: self.lblFloatPlaceholder.bounds.size.height)
        }
        
        if animated && animateFloatPlaceholder {
            UIView.animate(withDuration: floatingLabelShowAnimationDuration,
                           delay: 0.0,
                           options: [.beginFromCurrentState,.curveEaseOut],
                           animations: animations){ status in
                DispatchQueue.main.async {
                    self.layoutIfNeeded()
                }
            }
        }else{
            animations()
        }
    }
    
    fileprivate func hideFlotingLabel(_ animated:Bool) {
        
        let animations:(()->()) = {
            self.lblFloatPlaceholder.alpha = 0.0
            self.lblFloatPlaceholder.frame = CGRect(x: self.lblFloatPlaceholder.frame.origin.x,
                                                    y: self.lblFloatPlaceholder.font.lineHeight,
                                                    width: self.lblFloatPlaceholder.bounds.size.width,
                                                    height: self.lblFloatPlaceholder.bounds.size.height)
        }
        
        if animated && animateFloatPlaceholder {
            UIView.animate(withDuration: floatingLabelShowAnimationDuration,
                           delay: 0.0,
                           options: [.beginFromCurrentState,.curveEaseOut],
                           animations: animations){ status in
                DispatchQueue.main.async {
                    self.layoutIfNeeded()
                }
            }
        }else{
            animations()
        }
    }
    
    fileprivate func insetRectForEmptyBounds(rect:CGRect) -> CGRect{
        let newX = x
        guard showErrorLabel else { return CGRect(x: newX, y: 0, width: rect.width - newX - paddingX, height: rect.height) }
        
        // let topInset = (rect.size.height - lblError.bounds.size.height - paddingYErrorLabel - fontHeight) / 2.0
        // let textY = topInset - ((rect.height - fontHeight) / 2.0)
        //floor(textY)
        return CGRect(x: newX, y: 0 , width: rect.size.width - newX - paddingX, height: rect.size.height)
    }
    
    fileprivate func insetRectForBounds(rect:CGRect) -> CGRect {
        
        guard let placeholderText = lblFloatPlaceholder.text,!placeholderText.isEmptyStr  else {
            return insetRectForEmptyBounds(rect: rect)
        }
        
        if floatingDisplayStatus == .never {
            return insetRectForEmptyBounds(rect: rect)
        }else{
            
            if let text = text,text.isEmptyStr && floatingDisplayStatus == .defaults {
                return insetRectForEmptyBounds(rect: rect)
            }else{
                let topInset = paddingYFloatLabel + lblFloatPlaceholder.bounds.size.height + (paddingHeight / 2.0)
                let textOriginalY = (rect.height - fontHeight) / 2.0
                var textY = topInset - textOriginalY
                
                if textY < 0 && !showErrorLabel { textY = topInset }
                let newX = x
                return CGRect(x: newX, y: ceil(textY), width: rect.size.width - newX - paddingX, height: rect.height)
            }
        }
    }
    
    @objc fileprivate func textFieldTextChanged(){
        
        self.borderColor = self.activeFieldColor
        
        if self.isEditing{
            print("editing")
        }else{
            self.resignFirstResponder()
        }
        guard hideErrorWhenEditing && showErrorLabel else { return }
        showErrorLabel = false
    }
    @objc fileprivate func textFieldTextDidActive(){
        self.borderColor = self.activeFieldColor
        invalidateIntrinsicContentSize()
    }
    @objc fileprivate func textFieldTextDidEndEditing(){
        self.borderColor = .clear
        invalidateIntrinsicContentSize()
    }
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        self.borderColor = .clear
        return true
    }

    
    override public var intrinsicContentSize: CGSize{
        self.layoutIfNeeded()
        
        let textFieldIntrinsicContentSize = super.intrinsicContentSize
        
        if showErrorLabel {
            lblFloatPlaceholder.sizeToFit()
            return CGSize(width: textFieldIntrinsicContentSize.width,
                          height: textFieldIntrinsicContentSize.height + paddingYFloatLabel + paddingYErrorLabel + lblFloatPlaceholder.bounds.size.height + lblError.bounds.size.height + paddingHeight)
        }else{
            return CGSize(width: textFieldIntrinsicContentSize.width,
                          height: textFieldIntrinsicContentSize.height + paddingYFloatLabel + lblFloatPlaceholder.bounds.size.height + paddingHeight)
        }
    }
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return insetRectForBounds(rect: rect)
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return insetRectForBounds(rect: rect)
    }
    
    fileprivate func insetForSideView(forBounds bounds: CGRect) -> CGRect{
        var rect = bounds
        rect.origin.y = 0
        rect.size.height = dtLayerHeight
        return rect
    }
    
    override public func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.leftViewRect(forBounds: bounds)
        return insetForSideView(forBounds: rect)
    }
    
    override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.rightViewRect(forBounds: bounds)
        return insetForSideView(forBounds: rect)
    }
    
    override public func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRect(forBounds: bounds)
        rect.origin.y = (dtLayerHeight - rect.size.height) / 2
        return rect
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        dtLayer.frame = CGRect(x: bounds.origin.x,
                               y: bounds.origin.y,
                               width: bounds.width,
                               height: dtLayerHeight)
        let borderStype = dtborderStyle
        dtborderStyle = borderStype
        CATransaction.commit()
        
        if showErrorLabel {
            
           
        }
        
        var lblErrorFrame = lblError.frame
        lblErrorFrame.origin.y = dtLayer.frame.origin.y + dtLayer.frame.size.height + paddingYErrorLabel
        lblError.frame = lblErrorFrame
        
        let floatingLabelSize = lblFloatPlaceholder.sizeThatFits(lblFloatPlaceholder.superview!.bounds.size)
        
        lblFloatPlaceholder.frame = CGRect(x: x, y: lblFloatPlaceholder.frame.origin.y,
                                           width: floatingLabelSize.width,
                                           height: floatingLabelSize.height)
        
        setErrorLabelAlignment()
        setFloatLabelAlignment()
        lblFloatPlaceholder.textColor = isFirstResponder ? floatPlaceholderActiveColor : floatPlaceholderColor
        
        switch floatingDisplayStatus {
            case .never:
                hideFlotingLabel(isFirstResponder)
            case .always:
                showFloatingLabel(isFirstResponder)
            default:
                if let enteredText = text,!enteredText.isEmptyStr{
                    showFloatingLabel(isFirstResponder)
                }else{
                    hideFlotingLabel(isFirstResponder)
                }
        }
    }
    
}
public extension String {
    
    var isEmptyStr:Bool{
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces).isEmpty
    }
}



